#!/bin/bash

# ENABLE COMMON FUNCTIONS
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="jpeg"
set_toolchain_paths ${LIB_NAME}
export CCAS=${AS}

# SET BUILD FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export ASM_FLAGS=$(get_asmflags ${LIB_NAME})

# SET ARCH OPTIONS
ARCH_OPTIONS=""
case ${ARCH} in
    armv7 | armv7s | arm64 | arm64e)
        ARCH_OPTIONS="-DWITH_SIMD=1"
    ;;
    *)
        ARCH_OPTIONS="-DWITH_SIMD=0"
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

if [ -d "build" ]; then
    rm -rf build
fi

mkdir build || exit 1
cd build || exit 1

# fixing asm flags
${SED_INLINE} 's/${CMAKE_C_FLAGS} ${CMAKE_ASM_FLAGS}/${CMAKE_ASM_FLAGS}/g' ${BASEDIR}/src/${LIB_NAME}/simd/CMakeLists.txt

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
    -DCMAKE_ASM_FLAGS="$ASM_FLAGS" \
    -DENABLE_PIC=1 \
    -DENABLE_STATIC=1 \
    -DENABLE_SHARED=0 \
    -DWITH_JPEG8=1 \
    ${ARCH_OPTIONS} \
    -DWITH_TURBOJPEG=0 \
    -DWITH_JAVA=0 \
    -DCMAKE_SYSTEM_PROCESSOR=$(get_target_arch) \
    -DBUILD_SHARED_LIBS=0 .. || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ${BASEDIR}/src/${LIB_NAME}/build/pkgscripts/libjpeg.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
