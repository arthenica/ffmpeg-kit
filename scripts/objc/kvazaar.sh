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
LIB_NAME="kvazaar"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
ARCH_OPTIONS=""
case ${ARCH} in
    i386)
        BUILD_HOST="x86-apple-darwin"
    ;;
    x86-64 | x86-64-mac-catalyst)
        ARCH_OPTIONS="--disable-asm"
        BUILD_HOST=$(get_build_host)
    ;;
    *)
        BUILD_HOST=$(get_build_host)
    ;;
esac
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# ALWAYS RECONFIGURE
autoreconf_library ${LIB_NAME}

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${SDK_PATH} \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    ${ARCH_OPTIONS} \
    --host=${BUILD_HOST} || exit 1

make || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./src/kvazaar.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
