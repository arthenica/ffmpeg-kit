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
LIB_NAME="x265"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
CFLAGS=$(get_cflags ${LIB_NAME})
CXXFLAGS=$(get_cxxflags ${LIB_NAME})
LDFLAGS=$(get_ldflags ${LIB_NAME})

# USE CLEAN SOURCE ON EACH BUILD
cd ${BASEDIR}/src || exit 1
rm -rf ${LIB_NAME} || exit 1
DOWNLOAD_RESULT=$(download_gpl_library_source ${LIB_NAME})
if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
    exit 1
fi
cd ${BASEDIR}/src/${LIB_NAME} || exit 1

ARCH_OPTIONS=""
case ${ARCH} in
    arm-v7a | arm-v7a-neon)
        ARCH_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=1"
    ;;
    arm64-v8a)
        ARCH_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=1"
    ;;
    x86)
        ARCH_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=0"
    ;;
    x86-64)
        ARCH_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=0"
    ;;
esac

if [ -d "cmake-build" ]; then
    rm -rf cmake-build
fi

mkdir cmake-build || exit 1
cd cmake-build || exit 1

# FIX static_assert ERRORS
${SED_INLINE} 's/gnu++98/c++11/g' ${BASEDIR}/src/${LIB_NAME}/source/CMakeLists.txt

cmake -Wno-dev \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_SYSROOT="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot" \
    -DCMAKE_FIND_ROOT_PATH="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME}" \
    -DCMAKE_SYSTEM_NAME=Generic \
    -DCMAKE_C_COMPILER="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$CC" \
    -DCMAKE_CXX_COMPILER="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$CXX" \
    -DCMAKE_LINKER="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$LD" \
    -DCMAKE_AR="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$AR" \
    -DCMAKE_AS="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin/$AS" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
    -DSTATIC_LINK_CRT=1 \
    -DENABLE_PIC=1 \
    -DENABLE_CLI=0 \
    ${ARCH_OPTIONS} \
    -DCMAKE_SYSTEM_PROCESSOR="${ARCH}" \
    -DENABLE_SHARED=0 ../source || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_x265_package_config "3.4"

make install || exit 1
