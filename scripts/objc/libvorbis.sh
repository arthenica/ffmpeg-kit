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
LIB_NAME="libvorbis"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_libvorbis} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

# -force_cpusubtype_ALL FLAG REMOVED DUE TO THE FOLLOWING ERROR
# ld: -force_cpusubtype_ALL and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together
${SED_INLINE} 's/-force_cpusubtype_ALL//g' ${BASEDIR}/src/${LIB_NAME}/configure

PKG_CONFIG= ./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --with-ogg-includes=${BASEDIR}/prebuilt/$(get_target_build_directory)/libogg/include \
    --with-ogg-libraries=${BASEDIR}/prebuilt/$(get_target_build_directory)/libogg/lib \
    --with-pic \
    --with-sysroot=${SDK_PATH} \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --disable-docs \
    --disable-examples \
    --disable-oggtest \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_libvorbis_package_config "1.3.7"

make install || exit 1
