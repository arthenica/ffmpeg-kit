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

if ! [ -x "$(command -v tar)" ]; then
    echo -e "\n(*) tar command not found\n"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/android-common.sh

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
    x86)

        # please note that asm is disabled
        # because enabling asm for x86 causes text relocations in libavfilter.so
        ASM_FLAGS="--disable-asm"
    ;;
    x86-64)
        if ! [ -x "$(command -v nasm)" ]; then
            echo -e "\n(*) nasm command not found\n"
            exit 1
        fi

        export AS="$(command -v nasm)"

        # WORKAROUND APPLIED TO ENABLE X86 ASM
        # https://github.com/android-ndk/ndk/issues/693
        export CFLAGS="${CFLAGS} -mno-stackrealign"
    ;;
esac

./configure \
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
    --enable-pic \
    --sysroot=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot \
    --enable-static \
    --disable-cli \
    ${ASM_FLAGS} \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp x264.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
