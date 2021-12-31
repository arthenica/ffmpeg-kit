#!/bin/bash

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_kvazaar} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

# UPDATE BUILD FLAGS
# LINKING WITH ANDROID LTS SUPPORT LIBRARY IS NECESSARY FOR API < 18
if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]] && [[ ${API} -lt 18 ]]; then
  LTS_SUPPORT_LIBS=" -Wl,--no-whole-archive ${BASEDIR}/android/ffmpeg-kit-android-lib/src/main/cpp/libandroidltssupport.a -Wl,--no-whole-archive"
else
  LTS_SUPPORT_LIBS=""
fi

# WORKAROUND TO DISABLE LINKING TO -lrt
${SED_INLINE} 's/\-lrt//g' "${BASEDIR}"/src/"${LIB_NAME}"/configure || return 1

LIBS="${LTS_SUPPORT_LIBS}" ./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${ANDROID_SYSROOT}" \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --host="${HOST}" || return 1

# NOTE THAT kvazaar DOES NOT SUPPORT PARALLEL EXECUTION
make || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./src/kvazaar.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
