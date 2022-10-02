#!/bin/bash

mkdir -p "${BUILD_DIR}" || return 1
cd "${BUILD_DIR}" || return 1

cmake -Wno-dev \
  -DCMAKE_VERBOSE_MAKEFILE=0 \
  -DCMAKE_C_FLAGS="${CFLAGS}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_INSTALL_PREFIX="${LIB_INSTALL_PREFIX}" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_LINKER="$LD" \
  -DCMAKE_AR="$AR" \
  -DCMAKE_AS="$AS" \
  -DCMAKE_SYSTEM_PROCESSOR=$(get_cmake_system_processor) \
  -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
  -DFFT_LIB=kissfft \
  -DKISSFFT_SOURCE_DIR="${BASEDIR}"/src/"${LIB_NAME}"/src/3rdparty/kissfft \
  -DBUILD_SHARED_LIBS=0 \
  -DBUILD_TESTS=0 "${BASEDIR}"/src/"${LIB_NAME}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_chromaprint_package_config "1.5.1" || return 1
