#!/bin/bash

# INIT SUBMODULES
${SED_INLINE} 's|/abseil/|/arthenica/|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
git submodule update --init || return 1

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
  -DUNIX=1 \
  -DBUILD_SHARED_LIBS=0 \
  "${BASEDIR}"/src/"${LIB_NAME}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp "${BUILD_DIR}"/libilbc.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
