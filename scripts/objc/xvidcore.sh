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
LIB_NAME="xvidcore"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})

cd ${BASEDIR}/src/${LIB_NAME}/build/generic || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_xvidcore} -eq 1 ]]; then
    ./bootstrap.sh
fi

ASM_FLAGS=""
case ${ARCH} in
    armv7 | armv7s | arm64 | arm64e)
        ASM_FLAGS=""

        # REMOVING -flat_namespace OPTION FROM CONFIGURE TO FIX THE FOLLOWING ERROR
        # ld: -flat_namespace and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together
        ${SED_INLINE} 's/ -flat_namespace//g' configure

        # REMOVING -Wl,-read_only_relocs,suppress OPTION FROM CONFIGURE TO FIX THE FOLLOWING ERROR
        # ld: -read_only_relocs and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together
        ${SED_INLINE} 's/-Wl,-read_only_relocs,suppress//g' configure

    ;;
    i386 | x86-64 | x86-64-mac-catalyst)
        ASM_FLAGS="--disable-assembly"
    ;;
esac

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    ${ASM_FLAGS} \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_xvidcore_package_config "1.3.6"

make install || exit 1

# REMOVE DYNAMIC LIBS
rm -f ${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME}/lib/libxvidcore.dylib*