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
LIB_NAME="gnutls"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
COMMON_CFLAGS=$(get_cflags ${LIB_NAME})
COMMON_CXXFLAGS=$(get_cxxflags ${LIB_NAME})
COMMON_LDFLAGS=$(get_ldflags ${LIB_NAME})

export CFLAGS="${COMMON_CFLAGS} -I${BASEDIR}/prebuilt/android-$(get_target_build)/libiconv/include"
export CXXFLAGS="${COMMON_CXXFLAGS}"
export LDFLAGS="${COMMON_LDFLAGS} -L${BASEDIR}/prebuilt/android-$(get_target_build)/libiconv/lib"

export NETTLE_CFLAGS="-I${BASEDIR}/prebuilt/android-$(get_target_build)/nettle/include"
export NETTLE_LIBS="-L${BASEDIR}/prebuilt/android-$(get_target_build)/nettle/lib -lnettle -L${BASEDIR}/prebuilt/android-$(get_target_build)/gmp/lib -lgmp"
export HOGWEED_CFLAGS="-I${BASEDIR}/prebuilt/android-$(get_target_build)/nettle/include"
export HOGWEED_LIBS="-L${BASEDIR}/prebuilt/android-$(get_target_build)/nettle/lib -lhogweed -L${BASEDIR}/prebuilt/android-$(get_target_build)/gmp/lib -lgmp"
export GMP_CFLAGS="-I${BASEDIR}/prebuilt/android-$(get_target_build)/gmp/include"
export GMP_LIBS="-L${BASEDIR}/prebuilt/android-$(get_target_build)/gmp/lib -lgmp"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

HARDWARE_OPTIONS=""
case ${ARCH} in
    x86)
        HARDWARE_OPTIONS="--disable-hardware-acceleration"
    ;;
    *)
        HARDWARE_OPTIONS="--enable-hardware-acceleration"
    ;;
esac

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_gnutls} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

./configure \
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot \
    --with-included-libtasn1 \
    --with-included-unistring \
    --without-idn \
    --without-p11-kit \
    ${HARDWARE_OPTIONS} \
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
