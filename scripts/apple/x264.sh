#!/bin/bash

# SET BUILD OPTIONS
ASM_OPTIONS=""
DEBUG_OPTIONS=""
case ${ARCH} in
i386 | x86-64*)
  ASM_OPTIONS="--disable-asm"

  if ! [ -x "$(command -v nasm)" ]; then
    echo -e "\n(*) nasm command not found\n"
    return 1
  fi

  export AS="$(command -v nasm)"
  ;;
esac
if [[ -n ${FFMPEG_KIT_DEBUG} ]]; then
  DEBUG_OPTIONS="--enable-debug"
fi

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_x264} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

# UPDATE CONFIG FILES TO SUPPORT APPLE ARCHITECTURES
overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.guess "${BASEDIR}"/src/"${LIB_NAME}"/config.guess || return 1
overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.sub "${BASEDIR}"/src/"${LIB_NAME}"/config.sub || return 1

# WORKAROUND TO FIX arm64 BUILDS
${SED_INLINE} 's/\-arch arm64//g' "${BASEDIR}"/src/"${LIB_NAME}"/configure 1>>"${BASEDIR}"/build.log 2>&1 || return 1

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --enable-pic \
  --sysroot=${SDK_PATH} \
  --enable-static \
  --disable-cli \
  ${ASM_OPTIONS} \
  ${DEBUG_OPTIONS} \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp x264.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
