#!/bin/bash

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
    echo -e "\n(*) ANDROID_NDK_ROOT not defined\n"
    exit 1
fi

if [[ -z ${ARCH} ]]; then
    echo -e "\n(*) ARCH not defined\n"
    exit 1
fi

if [[ -z ${API} ]]; then
    echo -e "\n(*) API not defined\n"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo -e "\n(*) BASEDIR not defined\n"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/android-common.sh

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="libvpx"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
export CFLAGS="$(get_cflags ${LIB_NAME}) -I${ANDROID_NDK_ROOT}/sources/android/cpufeatures"
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS="$(get_ldflags ${LIB_NAME})"

# RECOVER configure.sh
rm -f ${BASEDIR}/src/${LIB_NAME}/build/make/configure.sh
cp ${BASEDIR}/tools/make/configure.libvpx.android.sh ${BASEDIR}/src/${LIB_NAME}/build/make/configure.sh

TARGET_CPU=""
DISABLE_NEON_FLAG=""
case ${ARCH} in
    arm-v7a)
        TARGET_CPU="armv7"

        # NEON disabled explicitly because
        # --enable-runtime-cpu-detect enables NEON for armv7 cpu
        DISABLE_NEON_FLAG="--disable-neon"
        unset ASFLAGS
    ;;
    arm-v7a-neon)
        # NEON IS ENABLED BY --enable-runtime-cpu-detect
        TARGET_CPU="armv7"
        unset ASFLAGS
    ;;
    arm64-v8a)
        # NEON IS ENABLED BY --enable-runtime-cpu-detect
        TARGET_CPU="arm64"
        unset ASFLAGS
    ;;
    *)
        # INTEL CPU EXTENSIONS ENABLED BY --enable-runtime-cpu-detect
        TARGET_CPU="$(get_target_build)"
        export ASFLAGS="-D__ANDROID__"
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

./configure \
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
    --target="${TARGET_CPU}-android-gcc" \
    --extra-cflags="${CFLAGS}" \
    --extra-cxxflags="${CXXFLAGS}" \
    --as=yasm \
    --log=yes \
    --enable-libs \
    --enable-install-libs \
    --enable-pic \
    --enable-optimizations \
    --enable-better-hw-compatibility \
    --enable-runtime-cpu-detect \
    ${DISABLE_NEON_FLAG} \
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
