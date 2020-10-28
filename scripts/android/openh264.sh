#!/bin/bash

# ENABLE COMMON FUNCTIONS
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="openh264"
set_toolchain_paths ${LIB_NAME}

# SET BUILD FLAGS
BUILD_HOST=$(get_build_host)
CFLAGS=$(get_cflags ${LIB_NAME})
CXXFLAGS=$(get_cxxflags ${LIB_NAME})
LDFLAGS=$(get_ldflags ${LIB_NAME})

# SET ARCH OPTIONS
case ${ARCH} in
    arm-v7a-neon)
        ARCH_OPTIONS=arm
        CFLAGS+=" -DHAVE_NEON -DANDROID_NDK"
    ;;
    arm64-v8a)
        ARCH_OPTIONS=arm64
        CFLAGS+=" -DHAVE_NEON_AARCH64 -DANDROID_NDK"
    ;;
    x86*)
        ARCH_OPTIONS=x86
        CFLAGS+=" -DHAVE_AVX2 -DANDROID_NDK"
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make clean 2>/dev/null 1>/dev/null

# revert ios changes
git checkout ${BASEDIR}/src/${LIB_NAME}/build 1>>"${BASEDIR}"/build.log 2>&1
git checkout ${BASEDIR}/src/${LIB_NAME}/codec 1>>"${BASEDIR}"/build.log 2>&1

# comment out the piece that compiles cpu-features into libopenh264.a
${SED_INLINE} 's/^COMMON_OBJS +=/# COMMON_OBJS +=/' ${BASEDIR}/src/${LIB_NAME}/build/platform-android.mk
${SED_INLINE} 's/^COMMON_CFLAGS +=/# COMMON_CFLAGS +=/' ${BASEDIR}/src/${LIB_NAME}/build/platform-android.mk

make -j$(get_cpu_count) \
ARCH="$(get_toolchain_arch)" \
CC="$CC" \
CFLAGS="$CFLAGS" \
CXX="$CXX" \
CXXFLAGS="${CXXFLAGS}" \
LDFLAGS="$LDFLAGS" \
OS=android \
PREFIX="${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME}" \
NDKLEVEL="${API}" \
NDKROOT="${ANDROID_NDK_ROOT}" \
NDK_TOOLCHAIN_VERSION=clang \
AR="$AR" \
ARCH_OPTIONS=${ARCH_OPTIONS} \
TARGET="android-${API}" \
install-static || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ${BASEDIR}/src/${LIB_NAME}/openh264-static.pc ${INSTALL_PKG_CONFIG_DIR}/openh264.pc || exit 1
