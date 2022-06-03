#!/bin/bash

# SET BUILD OPTIONS
case ${ARCH} in
x86-64)
  ASM_OPTIONS=x86
  CFLAGS+=" -DHAVE_AVX2"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make clean 2>/dev/null 1>/dev/null

# DISCARD APPLE WORKAROUNDS
git checkout "${BASEDIR}"/src/"${LIB_NAME}"/build || return 1
git checkout "${BASEDIR}"/src/"${LIB_NAME}"/codec || return 1

make -j$(get_cpu_count) \
  ARCH="$(get_target_cpu)" \
  AR="${AR}" \
  CC="${CC}" \
  CFLAGS="$CFLAGS" \
  CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  OS=linux \
  PREFIX="${LIB_INSTALL_PREFIX}" \
  ASM_OPTIONS=${ASM_OPTIONS} \
  install-static || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp "${BASEDIR}"/src/"${LIB_NAME}"/openh264-static.pc "${INSTALL_PKG_CONFIG_DIR}"/openh264.pc || return 1
