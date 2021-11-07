#!/bin/bash

# SET BUILD OPTIONS
case ${ARCH} in
armv7 | armv7s)
  ASM_OPTIONS="-DENABLE_ASSEMBLY=1 -DCROSS_COMPILE_ARM=1"
  ;;
arm64*)
  ASM_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=1"
  ;;
x86-64-mac-catalyst)
  ASM_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=0"
  ;;
i386)
  ASM_OPTIONS="-DENABLE_ASSEMBLY=0 -DCROSS_COMPILE_ARM=0"
  ;;
*)
  ASM_OPTIONS="-DENABLE_ASSEMBLY=1 -DCROSS_COMPILE_ARM=0"
  ;;
esac

mkdir -p "${BUILD_DIR}" || return 1
cd "${BUILD_DIR}" || return 1

# fix x86 and x86_64 assembly
${SED_INLINE} 's/win64/macho64 -DPREFIX/g' ${BASEDIR}/src/x265/source/cmake/CMakeASM_NASMInformation.cmake
${SED_INLINE} 's/win/macho/g' ${BASEDIR}/src/x265/source/cmake/CMakeASM_NASMInformation.cmake

# fixing constant shift
${SED_INLINE} 's/lsr 16/lsr #16/g' ${BASEDIR}/src/x265/source/common/arm/blockcopy8.S

# fixing leading underscores
${SED_INLINE} 's/function x265_/function _x265_/g' ${BASEDIR}/src/x265/source/common/arm/*.S
${SED_INLINE} 's/ x265_/ _x265_/g' ${BASEDIR}/src/x265/source/common/arm/pixel-util.S

# fixing relocation errors
${SED_INLINE} 's/sad12_mask:/sad12_mask_bytes:/g' ${BASEDIR}/src/x265/source/common/arm/sad-a.S
${SED_INLINE} 's/g_lumaFilter:/g_lumaFilter_bytes:/g' ${BASEDIR}/src/x265/source/common/arm/ipfilter8.S
${SED_INLINE} 's/g_chromaFilter:/g_chromaFilter_bytes:/g' ${BASEDIR}/src/x265/source/common/arm/ipfilter8.S
${SED_INLINE} 's/\.text/.equ sad12_mask, .-sad12_mask_bytes\
\
.text/g' ${BASEDIR}/src/x265/source/common/arm/sad-a.S
${SED_INLINE} 's/\.text/.equ g_lumaFilter, .-g_lumaFilter_bytes\
.equ g_chromaFilter, .-g_chromaFilter_bytes\
\
.text/g' ${BASEDIR}/src/x265/source/common/arm/ipfilter8.S

# WORKAROUND TO USE A CUSTOM BUILD FILE
overwrite_file "${BASEDIR}"/tools/patch/cmake/x265/CMakeLists.txt "${BASEDIR}"/src/"${LIB_NAME}"/source/CMakeLists.txt || return 1

cmake -Wno-dev \
  -DCMAKE_VERBOSE_MAKEFILE=0 \
  -DCMAKE_C_FLAGS="${CFLAGS}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
  -DCMAKE_SYSROOT="${SDK_PATH}" \
  -DCMAKE_FIND_ROOT_PATH="${SDK_PATH}" \
  -DCMAKE_OSX_SYSROOT="$(get_sdk_name)" \
  -DCMAKE_OSX_ARCHITECTURES="$(get_cmake_osx_architectures)" \
  -DCMAKE_SYSTEM_NAME="${CMAKE_SYSTEM_NAME}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${LIB_INSTALL_PREFIX}" \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_LINKER="$LD" \
  -DCMAKE_AR="$(xcrun --sdk $(get_sdk_name) -f ar)" \
  -DCMAKE_AS="$AS" \
  -DSTATIC_LINK_CRT=1 \
  -DENABLE_PIC=1 \
  -DENABLE_CLI=0 \
  -DHIGH_BIT_DEPTH=1 \
  ${ASM_OPTIONS} \
  -DCMAKE_SYSTEM_PROCESSOR="$(get_target_cpu)" \
  -DENABLE_SHARED=0 "${BASEDIR}"/src/"${LIB_NAME}"/source || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp x265.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
