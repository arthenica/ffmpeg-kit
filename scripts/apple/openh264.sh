#!/bin/bash

get_local_asm_arch() {
  case ${ARCH} in
  armv7*)
    echo "arm"
    ;;
  arm64*)
    echo "arm64"
    ;;
  x86-64*)
    echo "x86_64"
    ;;
  *)
    echo "${ARCH}"
    ;;
  esac
}

# UPDATE BUILD FLAGS AND SET BUILD OPTIONS
ASM_OPTIONS="OS=darwin"
case ${ARCH} in
armv7 | armv7s)
  CFLAGS+=" -DHAVE_NEON"
  ;;
arm64*)
  CFLAGS+=" -DHAVE_NEON_AARCH64"
  ;;
*)
  CFLAGS+=" -DHAVE_AVX2"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make clean 2>/dev/null 1>/dev/null

# DISCARD APPLE WORKAROUNDS
git checkout "${BASEDIR}"/src/"${LIB_NAME}"/build || return 1
git checkout "${BASEDIR}"/src/"${LIB_NAME}"/codec || return 1

# MAKE SURE THAT ASM IS ENABLED FOR ALL IOS ARCHITECTURES - EXCEPT x86-64
${SED_INLINE} 's/arm64 aarch64/arm64% aarch64/g' ${BASEDIR}/src/${LIB_NAME}/build/arch.mk
${SED_INLINE} 's/%86 x86_64,/%86 x86_64 x86-64%,/g' ${BASEDIR}/src/${LIB_NAME}/build/arch.mk
${SED_INLINE} 's/filter-out arm64,/filter-out arm64%,/g' ${BASEDIR}/src/${LIB_NAME}/build/arch.mk
${SED_INLINE} 's/CFLAGS += -DHAVE_NEON/#CFLAGS += -DHAVE_NEON/g' ${BASEDIR}/src/${LIB_NAME}/build/arch.mk
${SED_INLINE} 's/ifeq (\$(ASM_ARCH), arm64)/ifneq (\$(filter arm64%, \$(ASM_ARCH)),)/g' ${BASEDIR}/src/${LIB_NAME}/codec/common/targets.mk

make -j$(get_cpu_count) \
  ASM_ARCH="$(get_local_asm_arch)" \
  ARCH="${ARCH}" \
  CC="${CC}" \
  CFLAGS="$CFLAGS" \
  CXX="${CXX}" \
  CXXFLAGS="${CXXFLAGS}" \
  LDFLAGS="$LDFLAGS" \
  ${ASM_OPTIONS} \
  PREFIX="${LIB_INSTALL_PREFIX}" \
  SDK_MIN="${IOS_MIN_VERSION}" \
  SDKROOT="${SDK_PATH}" \
  STATIC_LDFLAGS="-lc++" \
  install-static || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ${BASEDIR}/src/${LIB_NAME}/openh264-static.pc ${INSTALL_PKG_CONFIG_DIR}/openh264.pc || return 1
