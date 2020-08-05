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

if ! [ -x "$(command -v tar)" ]; then
    echo -e "\n(*) tar command not found\n"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
if [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
    . ${BASEDIR}/build/tvos-common.sh
else
    . ${BASEDIR}/build/ios-common.sh
fi

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="x264"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

ASM_FLAGS=""
case ${ARCH} in
    i386 | x86-64 | x86-64-mac-catalyst)
        ASM_FLAGS="--disable-asm"

        if ! [ -x "$(command -v nasm)" ]; then
            echo -e "\n(*) nasm command not found\n"
            exit 1
        fi

        export AS="$(command -v nasm)"
    ;;
esac

# DISABLE INLINE -arch DEFINITIONS
${SED_INLINE} 's/CFLAGS=\"\$CFLAGS \-arch x86_64/CFLAGS=\"\$CFLAGS/g' configure
${SED_INLINE} 's/LDFLAGS=\"\$LDFLAGS \-arch x86_64/LDFLAGS=\"\$CFLAGS/g' configure

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --enable-pic \
    --sysroot=${SDK_PATH} \
    --enable-static \
    ${ASM_FLAGS} \
    --disable-cli \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp x264.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
