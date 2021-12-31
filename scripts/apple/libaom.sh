#!/bin/bash

# DISABLE ASM WORKAROUNDS BEFORE APPLYING THEM AGAIN
git checkout ${BASEDIR}/src/${LIB_NAME}/aom_ports 1>>"${BASEDIR}"/build.log 2>&1

# SET BUILD OPTIONS
ASM_OPTIONS=""
case ${ARCH} in
arm*)
  ASM_OPTIONS="-DCONFIG_RUNTIME_CPU_DETECT=0 -DARCH_ARM=1 -DENABLE_NEON=1 -DHAVE_NEON=1"
  ;;
i386)
  ASM_OPTIONS="-DARCH_X86=1 -DENABLE_SSE=0 -DHAVE_SSE=0 -DENABLE_SSE3=0 -DHAVE_SSE3=0"
  ;;
x86-64*)
  ASM_OPTIONS="-DARCH_X86_64=0 -DENABLE_SSE=0 -DENABLE_SSE2=0 -DENABLE_SSE3=0 -DENABLE_SSE4_1=0 -DENABLE_SSE4_2=0 -DENABLE_MMX=0"

  # WORKAROUND TO DISABLE ASM
  ${SED_INLINE} 's/define aom_clear_system_state() aom_reset_mmx_state()/define   aom_clear_system_state()/g' ${BASEDIR}/src/${LIB_NAME}/aom_ports/system_state.h
  ${SED_INLINE} 's/ add_asm_library("aom_ports/#add_asm_library("aom_ports/g' ${BASEDIR}/src/${LIB_NAME}/aom_ports/aom_ports.cmake
  ${SED_INLINE} 's/ target_sources(aom_ports/#target_sources(aom_ports/g' ${BASEDIR}/src/${LIB_NAME}/aom_ports/aom_ports.cmake
  ;;
esac

mkdir -p "${BUILD_DIR}" || return 1
cd "${BUILD_DIR}" || return 1

cmake -Wno-dev \
  -DCMAKE_VERBOSE_MAKEFILE=0 \
  -DCONFIG_PIC=1 \
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
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_LINKER="$LD" \
  -DCMAKE_AR="$(xcrun --sdk $(get_sdk_name) -f ar)" \
  -DCMAKE_AS="$AS" \
  ${ASM_OPTIONS} \
  -DENABLE_TESTS=0 \
  -DENABLE_EXAMPLES=0 \
  -DENABLE_TOOLS=0 \
  -DCONFIG_UNIT_TESTS=0 \
  -DCMAKE_SYSTEM_PROCESSOR="$(get_target_cpu)" \
  -DBUILD_SHARED_LIBS=0 "${BASEDIR}"/src/"${LIB_NAME}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp "${BUILD_DIR}"/aom.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
