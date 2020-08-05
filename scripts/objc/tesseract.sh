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

export LEPTONICA_CFLAGS="-I${BASEDIR}/prebuilt/$(get_target_build_directory)/leptonica/include/leptonica"
export LEPTONICA_LIBS="-L${BASEDIR}/prebuilt/$(get_target_build_directory)/leptonica/lib -llept"

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${SDK_PATH} \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --disable-debug \
    --disable-graphics \
    --disable-cube \
    --disable-tessdata-prefix \
    --disable-largefile \
    --host=${BUILD_HOST} || exit 1

${SED_INLINE} 's/$wl-bind_at_load//g' ${BASEDIR}/src/${LIB_NAME}/libtool
${SED_INLINE} 's/-lrt//g' ${BASEDIR}/src/${LIB_NAME}/api/Makefile

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_tesseract_package_config "3.05.02"

make install || exit 1
