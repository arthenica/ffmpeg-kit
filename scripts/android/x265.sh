#!/bin/bash

# SET BUILD OPTIONS
ASM_OPTIONS=""
case ${ARCH} in
arm-v7a | arm-v7a-neon)
  ASM_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=1"
  ;;
arm64-v8a)
  ASM_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=1"
  ;;
x86)
  ASM_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=0"
  ;;
x86-64)
  ASM_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=0"
  ;;
esac

mkdir -p "${BUILD_DIR}" || return 1
cd "${BUILD_DIR}" || return 1

# WORKAROUND TO FIX static_assert ERRORS
${SED_INLINE} 's/gnu++98/c++11/g' "${BASEDIR}"/src/"${LIB_NAME}"/source/CMakeLists.txt || return 1

cmake -Wno-dev \
  -DCMAKE_VERBOSE_MAKEFILE=0 \
  -DCMAKE_C_FLAGS="${CFLAGS}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
  -DCMAKE_SYSROOT="${ANDROID_SYSROOT}" \
  -DCMAKE_FIND_ROOT_PATH="${ANDROID_SYSROOT}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${LIB_INSTALL_PREFIX}" \
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
  -DHIGH_BIT_DEPTH=1 \
  ${ASM_OPTIONS} \
  -DCMAKE_SYSTEM_PROCESSOR="${ARCH}" \
  -DENABLE_SHARED=0 "${BASEDIR}"/src/"${LIB_NAME}"/source || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_x265_package_config "3.4" || return 1
