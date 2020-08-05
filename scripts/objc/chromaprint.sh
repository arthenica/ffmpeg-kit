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
LIB_NAME="chromaprint"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
CFLAGS=$(get_cflags ${LIB_NAME})
CXXFLAGS=$(get_cxxflags ${LIB_NAME})
LDFLAGS=$(get_ldflags ${LIB_NAME})

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

if [ -d "build" ]; then
    rm -rf build
fi

mkdir build;
cd build

cmake -Wno-dev \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_SYSROOT="${SDK_PATH}" \
    -DCMAKE_FIND_ROOT_PATH="${SDK_PATH}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME}" \
    -DCMAKE_SYSTEM_NAME=Darwin \
    -DCMAKE_OSX_SYSROOT="" \
    -DCMAKE_C_COMPILER="$CC" \
    -DCMAKE_LINKER="$LD" \
    -DCMAKE_AR="$(xcrun --sdk $(get_sdk_name) -f ar)" \
    -DCMAKE_AS="$AS" \
    -DFFT_LIB=kissfft \
    -DCMAKE_SYSTEM_PROCESSOR=$(get_target_arch) \
    -DBUILD_SHARED_LIBS=0 .. || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp libchromaprint.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
