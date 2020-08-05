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
LIB_NAME="libaom"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
CFLAGS=$(get_cflags ${LIB_NAME})
CXXFLAGS=$(get_cxxflags ${LIB_NAME})
LDFLAGS=$(get_ldflags ${LIB_NAME})

ARCH_OPTIONS=""
case ${ARCH} in
    arm-v7a)
        ARCH_OPTIONS="-DARCH_ARM=1 -DENABLE_NEON=0 -DHAVE_NEON=0"
    ;;
    arm-v7a-neon)
        ARCH_OPTIONS="-DARCH_ARM=1 -DENABLE_NEON=1 -DHAVE_NEON=1"
    ;;
    arm64-v8a)
        ARCH_OPTIONS="-DARCH_ARM=1 -DENABLE_NEON=1 -DHAVE_NEON=1"
    ;;
    x86)
        ARCH_OPTIONS="-DENABLE_SSE=1 -DHAVE_SSE=1 -DENABLE_SSE3=1 -DHAVE_SSE3=1"
    ;;
    x86-64)
        ARCH_OPTIONS="-DENABLE_SSE4_2=1 -DHAVE_SSE4_2=1"
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

if [ -d "cmake-build" ]; then
    rm -rf cmake-build
fi

mkdir cmake-build;
cd cmake-build

cmake -Wno-dev \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCONFIG_PIC=1 \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_SYSROOT="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot" \
    -DCMAKE_FIND_ROOT_PATH="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=Generic \
    -DCMAKE_INSTALL_PREFIX="${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME}" \
    -DCMAKE_CXX_COMPILER="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$CXX" \
    -DCMAKE_C_COMPILER="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$CC" \
    -DCMAKE_LINKER="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$LD" \
    -DCMAKE_AR="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$AR" \
    -DCMAKE_AS="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$AS" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
    ${ARCH_OPTIONS} \
    -DENABLE_TESTS=0 \
    -DENABLE_EXAMPLES=0 \
    -DENABLE_TOOLS=0 \
    -DCONFIG_UNIT_TESTS=0 \
    -DAOM_TARGET_CPU=generic \
    -DBUILD_SHARED_LIBS=0 .. || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_libaom_package_config "1.0.0"

make install || exit 1