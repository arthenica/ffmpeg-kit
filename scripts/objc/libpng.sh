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
LIB_NAME="libpng"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CPPFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})

ARCH_OPTIONS="--enable-hardware-optimizations=yes"
case ${ARCH} in
    x86 | x86-64 | x86-64-mac-catalyst)
        ARCH_OPTIONS+=" --enable-intel-sse=yes"
    ;;
    armv7 | armv7s | arm64 | arm64e)
        ARCH_OPTIONS+=" --enable-arm-neon=yes"
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_libpng} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${SDK_PATH} \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --disable-unversioned-libpng-pc \
    --disable-unversioned-libpng-config \
    ${ARCH_OPTIONS} \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_libpng_package_config "1.6.37"

make install || exit 1
