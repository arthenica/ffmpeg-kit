#!/bin/bash

mkdir -p "${BUILD_DIR}" || return 1
cd "${BUILD_DIR}" || return 1

# SET BUILD OPTIONS
ASM_OPTIONS=""
case ${ARCH} in
*-mac-catalyst)
  ASM_OPTIONS="-DENABLE_MONOTONIC_CLOCK=0"
  ;;
*)
  ASM_OPTIONS="-DENABLE_MONOTONIC_CLOCK=1"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
git clean -dfx 2>/dev/null 1>/dev/null

cmake -Wno-dev \
 -DUSE_ENCLIB=openssl \
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
 -DCMAKE_CXX_COMPILER="$CXX" \
 -DCMAKE_C_COMPILER="$CC" \
 -DCMAKE_LINKER="$LD" \
 -DCMAKE_AR="$(xcrun --sdk $(get_sdk_name) -f ar)" \
 -DCMAKE_AS="$AS" \
 -DCMAKE_SYSTEM_PROCESSOR="$(get_target_cpu)" \
 ${ASM_OPTIONS} \
 -DENABLE_STDCXX_SYNC=1 \
 -DENABLE_CXX11=1 \
 -DUSE_OPENSSL_PC=1 \
 -DENABLE_DEBUG=0 \
 -DENABLE_LOGGING=0 \
 -DENABLE_HEAVY_LOGGING=0 \
 -DENABLE_APPS=0 \
 -DENABLE_SHARED=0 "${BASEDIR}"/src/"${LIB_NAME}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
