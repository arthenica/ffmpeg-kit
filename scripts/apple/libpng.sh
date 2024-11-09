#!/bin/bash

# SET BUILD OPTIONS
ASM_OPTIONS=""
case ${ARCH} in
x86*)
  ASM_OPTIONS=" --enable-intel-sse=yes"
  ;;
arm*)
  ASM_OPTIONS=" --enable-arm-neon=yes"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_libpng} -eq 1 ]] || [[ $(is_gnu_config_files_up_to_date) == "0" ]]; then

  # UPDATE CONFIG FILES TO SUPPORT APPLE ARCHITECTURES
  overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.guess "${BASEDIR}"/src/"${LIB_NAME}"/config.guess || return 1
  overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.sub "${BASEDIR}"/src/"${LIB_NAME}"/config.sub || return 1

  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

# WORKAROUND TO FIX ZLIB VERSION DETECTED - OCCURS ON XCODE 14.3.1
if [[ -n "$DETECTED_IOS_SDK_VERSION" && $(compare_versions "$DETECTED_IOS_SDK_VERSION" "16.4") -ge 0 ]] ||
 [[ -n "$DETECTED_MACOS_SDK_VERSION" && $(compare_versions "$DETECTED_MACOS_SDK_VERSION" "13.3") -eq 0 ]] ||
 [[ -n "$DETECTED_TVOS_SDK_VERSION" && $(compare_versions "$DETECTED_TVOS_SDK_VERSION" "16.4") -ge 0 ]]; then
  ${SED_INLINE} "s|ZLIB_VERNUM default .*|ZLIB_VERNUM default 0|g" "${BASEDIR}"/src/"${LIB_NAME}"/scripts/pnglibconf.dfa
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --disable-unversioned-libpng-pc \
  --disable-unversioned-libpng-config \
  ${ASM_OPTIONS} \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_libpng_package_config "1.6.40" || return 1
