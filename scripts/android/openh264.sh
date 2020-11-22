#!/bin/bash

# UPDATE BUILD FLAGS
export CFLAGS="$CFLAGS $(pkg-config --cflags libiconv) $(pkg-config --cflags cpu-features)"
export LDFLAGS="$LDFLAGS $(pkg-config --libs --static libiconv) $(pkg-config --libs --static cpu-features)"

# SET BUILD OPTIONS
case ${ARCH} in
arm-v7a-neon)
  ASM_OPTIONS=arm
  CFLAGS+=" -DHAVE_NEON -DANDROID_NDK"
  ;;
arm64-v8a)
  ASM_OPTIONS=arm64
  CFLAGS+=" -DHAVE_NEON_AARCH64 -DANDROID_NDK"
  ;;
x86*)
  ASM_OPTIONS=x86
  CFLAGS+=" -DHAVE_AVX2 -DANDROID_NDK"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make clean 2>/dev/null 1>/dev/null

# DISCARD APPLE WORKAROUNDS
git checkout "${BASEDIR}"/src/"${LIB_NAME}"/build || return 1
git checkout "${BASEDIR}"/src/"${LIB_NAME}"/codec || return 1

# WORKAROUND TO DISABLE PARTS THAT COMPILE cpu-features INTO libopenh264.a
${SED_INLINE} 's/^COMMON_INCLUDES +=/# COMMON_INCLUDES +=/' "${BASEDIR}"/src/"${LIB_NAME}"/build/platform-android.mk
${SED_INLINE} 's/^COMMON_OBJS +=/# COMMON_OBJS +=/' "${BASEDIR}"/src/"${LIB_NAME}"/build/platform-android.mk
${SED_INLINE} 's/^COMMON_CFLAGS +=/# COMMON_CFLAGS +=/' "${BASEDIR}"/src/"${LIB_NAME}"/build/platform-android.mk

make -j$(get_cpu_count) \
  ARCH="$(get_toolchain_arch)" \
  CC="$CC" \
  CFLAGS="$CFLAGS" \
  CXX="$CXX" \
  CXXFLAGS="${CXXFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  OS=android \
  PREFIX="${LIB_INSTALL_PREFIX}" \
  NDKLEVEL="${API}" \
  NDKROOT="${ANDROID_NDK_ROOT}" \
  NDK_TOOLCHAIN_VERSION=clang \
  AR="$AR" \
  ASM_OPTIONS=${ASM_OPTIONS} \
  TARGET="android-${API}" install-static || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp "${BASEDIR}"/src/"${LIB_NAME}"/openh264-static.pc "${INSTALL_PKG_CONFIG_DIR}"/openh264.pc || return 1
