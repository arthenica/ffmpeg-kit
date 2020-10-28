#!/bin/bash

# ENABLE COMMON FUNCTIONS
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="libass"
set_toolchain_paths ${LIB_NAME}

# SET BUILD FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR=${INSTALL_PKG_CONFIG_DIR}

# SET ARCH OPTIONS
ARCH_OPTIONS=""
case ${ARCH} in
    x86-64 | x86-64-mac-catalyst)
        ARCH_OPTIONS="--disable-asm"
    ;;
    *)
        ARCH_OPTIONS="--enable-asm"
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_libass} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${SDK_PATH} \
    --disable-libtool-lock \
    --enable-static \
    --disable-shared \
    --disable-harfbuzz \
    --disable-fast-install \
    --disable-test \
    ${ARCH_OPTIONS} \
    --disable-profile \
    --disable-coretext \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
