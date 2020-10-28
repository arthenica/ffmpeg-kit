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
ARCH_OPTIONS="OS=ios"
case ${ARCH} in
    armv7 | armv7s)
        CFLAGS+=" -DHAVE_NEON"
    ;;
    arm64 | arm64e)
        CFLAGS+=" -DHAVE_NEON_AARCH64"
    ;;
    x86-64-mac-catalyst)
        ARCH_OPTIONS=""
        CFLAGS+=" -DHAVE_AVX2"
    ;;
    *)
        CFLAGS+=" -DHAVE_AVX2"
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

# MAKE SURE THAT ASM IS ENABLED FOR ALL IOS ARCHITECTURES - EXCEPT x86-64
${SED_INLINE} 's/arm64 aarch64/arm64% aarch64/g' ${BASEDIR}/src/${LIB_NAME}/build/arch.mk
${SED_INLINE} 's/%86 x86_64,/%86 x86_64 x86-64,/g' ${BASEDIR}/src/${LIB_NAME}/build/arch.mk
${SED_INLINE} 's/filter-out arm64,/filter-out arm64%,/g' ${BASEDIR}/src/${LIB_NAME}/build/arch.mk
${SED_INLINE} 's/CFLAGS += -DHAVE_NEON/#CFLAGS += -DHAVE_NEON/g' ${BASEDIR}/src/${LIB_NAME}/build/arch.mk
${SED_INLINE} 's/ifeq (\$(ASM_ARCH), arm64)/ifneq (\$(filter arm64%, \$(ASM_ARCH)),)/g' ${BASEDIR}/src/${LIB_NAME}/codec/common/targets.mk
${SED_INLINE} 's/ifeq (\$(ASM_ARCH), arm)/ifneq (\$(filter armv%, \$(ASM_ARCH)),)/g' ${BASEDIR}/src/${LIB_NAME}/codec/common/targets.mk

make clean 2>/dev/null 1>/dev/null

make -j$(get_cpu_count) \
ASM_ARCH="${ARCH}" \
ARCH="${ARCH}" \
CC="${CC}" \
CFLAGS="$CFLAGS" \
CXX="${CXX}" \
CXXFLAGS="${CXXFLAGS}" \
LDFLAGS="$LDFLAGS" \
${ARCH_OPTIONS} \
PREFIX="${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME}" \
SDK_MIN="${IOS_MIN_VERSION}" \
SDKROOT="${SDK_PATH}" \
STATIC_LDFLAGS="-lc++" \
install-static || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ${BASEDIR}/src/${LIB_NAME}/openh264-static.pc ${INSTALL_PKG_CONFIG_DIR}/openh264.pc || exit 1