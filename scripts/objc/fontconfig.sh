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
LIB_NAME="fontconfig"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR=${INSTALL_PKG_CONFIG_DIR}

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_fontconfig} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --with-pic \
    --with-libiconv-prefix=${SDK_PATH}/usr \
    --with-expat=${BASEDIR}/prebuilt/$(get_target_build_directory)/expat \
    --without-libintl-prefix \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --disable-rpath \
    --disable-libxml2 \
    --disable-docs \
    --host=${BUILD_HOST} || exit 1

# DISABLE IOS TESTS with system() calls - system() is deprecated for IOS
# 1. test-bz106632.c
rm -f ${BASEDIR}/src/${LIB_NAME}/test/test-bz106632.c
cp ${BASEDIR}/src/${LIB_NAME}/test/test-bz106618.c ${BASEDIR}/src/${LIB_NAME}/test/test-bz106632.c

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_fontconfig_package_config "2.13.92"

make install || exit 1
