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
LIB_NAME="tesseract"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ! -f ${BASEDIR}/src/${LIB_NAME}/configure ]] || [[ ${RECONF_tesseract} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

export LEPTONICA_CFLAGS="-I${BASEDIR}/prebuilt/android-$(get_target_build)/leptonica/include/leptonica"
export LEPTONICA_LIBS="-L${BASEDIR}/prebuilt/android-$(get_target_build)/leptonica/lib -llept"

# MANUALLY SET ENDIANNESS
export ac_cv_c_bigendian=no

./configure \
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --disable-debug \
    --disable-graphics \
    --disable-cube \
    --disable-tessdata-prefix \
    --disable-largefile \
    --host=${BUILD_HOST} || exit 1

${SED_INLINE} 's/\-lrt//g' ${BASEDIR}/src/${LIB_NAME}/api/Makefile

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_tesseract_package_config "3.05.02"

make install || exit 1
