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
LIB_NAME="libaom"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
CFLAGS="$(get_cflags ${LIB_NAME})"
CXXFLAGS="$(get_cxxflags ${LIB_NAME})"
LDFLAGS="$(get_ldflags ${LIB_NAME})"

TOOLCHAIN_FILE=""
ARCH_OPTIONS=""
case ${ARCH} in
    armv7)
        TOOLCHAIN_FILE="${BASEDIR}/src/${LIB_NAME}/build/cmake/toolchains/armv7-ios.cmake"
        ARCH_OPTIONS="-DARCH_ARM=1 -DENABLE_NEON=1 -DHAVE_NEON=1"
    ;;
    armv7s)
        TOOLCHAIN_FILE="${BASEDIR}/src/${LIB_NAME}/build/cmake/toolchains/armv7s-ios.cmake"
        ARCH_OPTIONS="-DARCH_ARM=1 -DENABLE_NEON=1 -DHAVE_NEON=1"
    ;;
    arm64)
        TOOLCHAIN_FILE="${BASEDIR}/src/${LIB_NAME}/build/cmake/toolchains/arm64-ios.cmake"
        ARCH_OPTIONS="-DARCH_ARM=1 -DENABLE_NEON=1 -DHAVE_NEON=1"
    ;;
    arm64e)
        TOOLCHAIN_FILE="${BASEDIR}/src/${LIB_NAME}/build/cmake/toolchains/arm-ios-common.cmake"
        ARCH_OPTIONS="-DAOM_TARGET_CPU=arm64 -DCMAKE_SYSTEM_PROCESSOR=arm64e -DCMAKE_OSX_ARCHITECTURES=arm64e -DARCH_ARM=1 -DENABLE_NEON=1 -DHAVE_NEON=1"
    ;;
    i386)
        TOOLCHAIN_FILE="${BASEDIR}/src/${LIB_NAME}/build/cmake/toolchains/x86-ios-simulator.cmake"
        ARCH_OPTIONS="-DARCH_X86=1 -DENABLE_SSE=1 -DHAVE_SSE=1 -DENABLE_SSE3=1 -DHAVE_SSE3=1"
    ;;
    x86-64)
        TOOLCHAIN_FILE="${BASEDIR}/src/${LIB_NAME}/build/cmake/toolchains/x86_64-ios-simulator.cmake"
        ARCH_OPTIONS="-DARCH_X86_64=1 -DENABLE_SSE4_1=1 -DHAVE_SSE4_2=1"
    ;;
    x86-64-mac-catalyst)
        cp ${BASEDIR}/tools/cmake/libaom.x86_64-mac-catalyst.cmake ${BASEDIR}/src/${LIB_NAME}/build/cmake/toolchains/x86_64-mac-catalyst.cmake
        TOOLCHAIN_FILE="${BASEDIR}/src/${LIB_NAME}/build/cmake/toolchains/x86_64-mac-catalyst.cmake"
        ARCH_OPTIONS="-DARCH_X86_64=0 -DENABLE_SSE=0 -DENABLE_SSE2=0 -DENABLE_SSE3=0 -DENABLE_SSE4_1=0 -DENABLE_SSE4_2=0 -DENABLE_MMX=0 -DCONFIG_OS_SUPPORT=0 -DCONFIG_RUNTIME_CPU_DETECT=0"
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

if [ -d "cmake-build" ]; then
    rm -rf cmake-build
fi

mkdir cmake-build;
cd cmake-build

# Workaround to disable asm on mac catalyst
if [ ${ARCH} == "x86-64-mac-catalyst" ]; then
    ${SED_INLINE} 's/define aom_clear_system_state() aom_reset_mmx_state()/define   aom_clear_system_state()/g' ${BASEDIR}/src/${LIB_NAME}/aom_ports/system_state.h
    ${SED_INLINE} 's/ add_asm_library("aom_ports/#add_asm_library("aom_ports/g' ${BASEDIR}/src/${LIB_NAME}/aom_ports/aom_ports.cmake
    ${SED_INLINE} 's/ target_sources(aom_ports/#target_sources(aom_ports/g' ${BASEDIR}/src/${LIB_NAME}/aom_ports/aom_ports.cmake
else
    ${SED_INLINE} 's/define   aom_clear_system_state()/define aom_clear_system_state() aom_reset_mmx_state()/g' ${BASEDIR}/src/${LIB_NAME}/aom_ports/system_state.h
    ${SED_INLINE} 's/#add_asm_library("aom_ports/ add_asm_library("aom_ports/g' ${BASEDIR}/src/${LIB_NAME}/aom_ports/aom_ports.cmake
    ${SED_INLINE} 's/#target_sources(aom_ports/ target_sources(aom_ports/g' ${BASEDIR}/src/${LIB_NAME}/aom_ports/aom_ports.cmake
fi

cmake -Wno-dev \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCONFIG_PIC=1 \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_SYSROOT="${SDK_PATH}" \
    -DCMAKE_FIND_ROOT_PATH="${SDK_PATH}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME}" \
    -DCMAKE_CXX_COMPILER="$CXX" \
    -DCMAKE_C_COMPILER="$CC" \
    -DCMAKE_LINKER="$LD" \
    -DCMAKE_AR="$(xcrun --sdk $(get_sdk_name) -f ar)" \
    -DCMAKE_AS="$AS" \
    -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE} \
    ${ARCH_OPTIONS} \
    -DENABLE_TESTS=0 \
    -DENABLE_EXAMPLES=0 \
    -DENABLE_TOOLS=0 \
    -DCONFIG_UNIT_TESTS=0 \
    -DBUILD_SHARED_LIBS=0 .. || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ${BASEDIR}/src/${LIB_NAME}/cmake-build/aom.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1