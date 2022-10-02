#!/bin/bash

if [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then

  # openssl does not support tvos yet
  echo -e "ERROR: openssl is not supported on $FFMPEG_KIT_BUILD_TYPE platform.\n" 1>>"${BASEDIR}"/build.log 2>&1
  return 200
fi

# SET BUILD OPTIONS
ASM_OPTIONS=""
case ${ARCH} in
arm64 | arm64e | arm64-mac-catalyst | arm64-simulator | x86-64 | x86-64-mac-catalyst)
  ASM_OPTIONS="enable-ec_nistp_64_gcc_128"
  ;;
i386)
  ASM_OPTIONS="386"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_openssl} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

INT128_AVAILABLE=$($CC -dM -E - </dev/null 2>>"${BASEDIR}"/build.log | grep __SIZEOF_INT128__)

echo -e "INFO: __uint128_t detection output: $INT128_AVAILABLE\n" 1>>"${BASEDIR}"/build.log 2>&1

./Configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  zlib \
  no-shared \
  no-engine \
  no-dso \
  no-legacy \
  ${ASM_OPTIONS} \
  no-tests \
  iphoneos-cross || return 1

make -j$(get_cpu_count) build_sw || return 1

make install_sw install_ssldirs || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
