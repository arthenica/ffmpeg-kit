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
LIB_NAME="gmp"
set_toolchain_paths ${LIB_NAME}

export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_gmp} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

# PREPARING FLAGS
case ${ARCH} in
    i386)
        unset gmp_cv_asm_w32
        BUILD_HOST="x86-apple-darwin"
    ;;
    x86-64-mac-catalyst)
        # Workaround for 'cannot determine how to define a 32-bit word' error
        export gmp_cv_asm_w32=".long"
        BUILD_HOST=$(get_build_host)
    ;;
    *)
        unset gmp_cv_asm_w32
        BUILD_HOST=$(get_build_host)
    ;;
esac

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${SDK_PATH} \
    --enable-static \
    --disable-shared \
    --disable-assembly \
    --disable-fast-install \
    --disable-maintainer-mode \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_gmp_package_config "6.2.0"

make install || exit 1
