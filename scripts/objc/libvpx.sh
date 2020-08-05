#!/bin/bash

if [[ -z ${ARCH} ]]; then
    echo -e "\n(*) ARCH not defined\n"
    exit 1
fi

if [[ -z ${TARGET_SDK} ]]; then
    echo -e "\n(*) TARGET_SDK not defined\n"
    exit 1
fi

if [[ -z ${SDK_PATH} ]]; then
    echo -e "\n(*) SDK_PATH not defined\n"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo -e "\n(*) BASEDIR not defined\n"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
if [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
    . ${BASEDIR}/build/tvos-common.sh
else
    . ${BASEDIR}/build/ios-common.sh
fi

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="libvpx"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})

# PREPARE CPU & ARCH OPTIONS
TARGET=""
ASM_FLAGS=""
case ${ARCH} in
    armv7 | armv7s)

        # note that --disable-runtime-cpu-detect is used for arm
        # using --enable-runtime-cpu-detect cause the following error
        # vpx_ports/arm_cpudetect.c:151:2: error: "--enable-runtime-cpu-detect selected, but no CPU detection method " "available for your platform. Reconfigure with --disable-runtime-cpu-detect."

        TARGET="$(get_target_arch)-darwin-gcc"
        ASM_FLAGS="--disable-runtime-cpu-detect --enable-neon --enable-neon-asm"
    ;;
    arm64)
        TARGET="arm64-darwin-gcc"

        # --enable-neon-asm option not added because it causes the following error
        # vpx_dsp/arm/intrapred_neon_asm.asm.S:653:26: error: vector register expected
        #    vst1.64
        ASM_FLAGS="--disable-runtime-cpu-detect --enable-neon"
    ;;
    arm64e)
        TARGET="arm64-darwin-gcc"

        ASM_FLAGS="--disable-runtime-cpu-detect --enable-neon"
    ;;
    i386)
        TARGET="x86-iphonesimulator-gcc"
        ASM_FLAGS="--enable-runtime-cpu-detect --disable-avx512"
    ;;
    x86-64)
        TARGET="x86_64-iphonesimulator-gcc"
        ASM_FLAGS="--enable-runtime-cpu-detect --disable-avx512 --disable-sse --disable-sse2 --disable-mmx"
    ;;
    x86-64-mac-catalyst)
        TARGET="x86_64-macosx-gcc"
        ASM_FLAGS="--enable-runtime-cpu-detect --disable-avx512 --disable-sse --disable-sse2 --disable-mmx"
    ;;
esac

# PREPARE CONFIGURE OPTIONS
rm -f ${BASEDIR}/src/${LIB_NAME}/build/make/configure.sh
case ${ARCH} in
    arm64e)
        cp ${BASEDIR}/tools/make/configure.libvpx.arm64e.sh ${BASEDIR}/src/${LIB_NAME}/build/make/configure.sh
    ;;
    x86-64-mac-catalyst)
        cp ${BASEDIR}/tools/make/configure.libvpx.x86_64_mac_catalyst.sh ${BASEDIR}/src/${LIB_NAME}/build/make/configure.sh
    ;;
    *)
        cp ${BASEDIR}/tools/make/configure.libvpx.all.sh ${BASEDIR}/src/${LIB_NAME}/build/make/configure.sh
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
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
    ${ASM_FLAGS} \
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
    --disable-internal-stats || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
