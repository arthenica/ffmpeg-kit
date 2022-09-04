#!/bin/bash

# SET BUILD OPTIONS
TARGET=""
ASM_OPTIONS=""
case ${ARCH} in
armv7 | armv7s)

  # note that --disable-runtime-cpu-detect is used for arm
  # using --enable-runtime-cpu-detect cause the following error
  # vpx_ports/arm_cpudetect.c:151:2: error: "--enable-runtime-cpu-detect selected, but no CPU detection method " "available for your platform. Reconfigure with --disable-runtime-cpu-detect."

  TARGET="$(get_target_cpu)-darwin-gcc"
  ASM_OPTIONS="--disable-runtime-cpu-detect --enable-neon --enable-neon-asm"
  ;;
arm64*)
  TARGET="arm64-darwin-gcc"

  # --enable-neon-asm option not added because it causes the following error
  # vpx_dsp/arm/intrapred_neon_asm.asm.S:653:26: error: vector register expected
  #    vst1.64
  ASM_OPTIONS="--disable-runtime-cpu-detect --enable-neon"
  ;;
i386)
  TARGET="x86-iphonesimulator-gcc"
  ASM_OPTIONS="--enable-runtime-cpu-detect --disable-avx512"
  ;;
x86-64*)
  if [[ ${ARCH} == "x86-64-mac-catalyst" ]]; then
    TARGET="x86_64-macosx-gcc"
  else

    # WORKAROUND TO USE A VALID TARGET FOR LIBVPX BUILD SCRIPTS
    # HAS NO EFFECT ON THE OUTPUT
    # CUSTOMIZED LIBVPX BUILD SCRIPTS (FOR tvOS, macOS) USE BUILD FLAGS SET BY FFMPEG KIT
    TARGET="x86_64-iphonesimulator-gcc"
  fi
  ASM_OPTIONS="--enable-runtime-cpu-detect --disable-avx512 --disable-sse --disable-sse2 --disable-mmx"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# NOTE THAT RECONFIGURE IS NOT SUPPORTED

# WORKAROUND TO FIX BUILD OPTIONS DEFINED IN configure.sh
case ${ARCH} in
x86-64-mac-catalyst)
  overwrite_file "${BASEDIR}"/tools/patch/make/libvpx/configure.x86_64_mac_catalyst.sh "${BASEDIR}"/src/"${LIB_NAME}"/build/make/configure.sh || return 1
  ;;
*)
  overwrite_file "${BASEDIR}"/tools/patch/make/libvpx/configure.sh "${BASEDIR}"/src/"${LIB_NAME}"/build/make/configure.sh || return 1
  ;;
esac

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --target="${TARGET}" \
  --extra-cflags="${CFLAGS}" \
  --extra-cxxflags="${CXXFLAGS}" \
  --as=yasm \
  --log=yes \
  --enable-libs \
  --enable-install-libs \
  --enable-pic \
  --enable-optimizations \
  --enable-better-hw-compatibility \
  --enable-vp9-highbitdepth \
  ${ASM_OPTIONS} \
  --enable-vp8 \
  --enable-vp9 \
  --enable-multithread \
  --enable-spatial-resampling \
  --enable-small \
  --enable-static \
  --disable-realtime-only \
  --disable-shared \
  --disable-debug \
  --disable-gprof \
  --disable-gcov \
  --disable-ccache \
  --disable-install-bins \
  --disable-install-srcs \
  --disable-install-docs \
  --disable-docs \
  --disable-tools \
  --disable-examples \
  --disable-unit-tests \
  --disable-decode-perf-tests \
  --disable-encode-perf-tests \
  --disable-codec-srcs \
  --disable-debug-libs \
  --disable-internal-stats || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
