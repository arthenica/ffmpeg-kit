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
LIB_NAME="gnutls"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
COMMON_CFLAGS=$(get_cflags ${LIB_NAME})
COMMON_CXXFLAGS=$(get_cxxflags ${LIB_NAME})
COMMON_LDFLAGS=$(get_ldflags ${LIB_NAME})

export CFLAGS="${COMMON_CFLAGS} -I${SDK_PATH}/usr/include"
export CXXFLAGS="${COMMON_CXXFLAGS}"
export LDFLAGS="${COMMON_LDFLAGS} -L${SDK_PATH}/usr/lib"

export NETTLE_CFLAGS="-I${BASEDIR}/prebuilt/$(get_target_build_directory)/nettle/include"
export NETTLE_LIBS="-L${BASEDIR}/prebuilt/$(get_target_build_directory)/nettle/lib -lnettle -L${BASEDIR}/prebuilt/$(get_target_build_directory)/gmp/lib -lgmp"
export HOGWEED_CFLAGS="-I${BASEDIR}/prebuilt/$(get_target_build_directory)/nettle/include"
export HOGWEED_LIBS="-L${BASEDIR}/prebuilt/$(get_target_build_directory)/nettle/lib -lhogweed -L${BASEDIR}/prebuilt/$(get_target_build_directory)/gmp/lib -lgmp"
export GMP_CFLAGS="-I${BASEDIR}/prebuilt/$(get_target_build_directory)/gmp/include"
export GMP_LIBS="-L${BASEDIR}/prebuilt/$(get_target_build_directory)/gmp/lib -lgmp"

ARCH_OPTIONS=""
case ${ARCH} in
    arm64 | arm64e)
        ARCH_OPTIONS="--enable-hardware-acceleration"
    ;;
    i386)
        # DISABLING thread_local WHICH IS NOT SUPPORTED ON i386
        export CFLAGS+=" -D__thread="
        ARCH_OPTIONS="--enable-hardware-acceleration"
    ;;
    *)
        ARCH_OPTIONS="--enable-hardware-acceleration"
    ;;
esac

# PATCH AARCH64 ASM FILES USING https://gitlab.com/gnutls/gnutls/merge_requests/661
rm -rf ${BASEDIR}/src/gnutls/lib/accelerated/aarch64/macosx
cp -r ${BASEDIR}/tools/make/gnutls/ios/macosx ${BASEDIR}/src/gnutls/lib/accelerated/aarch64

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_gnutls} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${SDK_PATH} \
    --with-included-libtasn1 \
    --with-included-unistring \
    --without-idn \
    --without-p11-kit \
    ${ARCH_OPTIONS} \
    --enable-static \
    --disable-openssl-compatibility \
    --disable-shared \
    --disable-fast-install \
    --disable-code-coverage \
    --disable-doc \
    --disable-manpages \
    --disable-guile \
    --disable-tests \
    --disable-tools \
    --disable-maintainer-mode \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_gnutls_package_config "3.6.13"

make install || exit 1
