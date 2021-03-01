#!/bin/bash

# ENABLE COMMON FUNCTIONS
source "${BASEDIR}"/scripts/function-"${FFMPEG_KIT_BUILD_TYPE}".sh 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

LIB_NAME="ffmpeg-kit"

echo -e "----------------------------------------------------------------" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "\nINFO: Building ${LIB_NAME} for ${HOST} with the following environment variables\n" 1>>"${BASEDIR}"/build.log 2>&1
env 1>>"${BASEDIR}"/build.log 2>&1
echo -e "----------------------------------------------------------------\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: System information\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: $(uname -a)\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "----------------------------------------------------------------\n" 1>>"${BASEDIR}"/build.log 2>&1

FFMPEG_KIT_LIBRARY_PATH="${LIB_INSTALL_BASE}/${LIB_NAME}"

# SET PATHS
set_toolchain_paths "${LIB_NAME}"

# SET BUILD FLAGS
HOST=$(get_host)
export CFLAGS="$(get_cflags ${LIB_NAME}) -I${LIB_INSTALL_BASE}/ffmpeg/include"
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS="$(get_ldflags ${LIB_NAME}) -L${LIB_INSTALL_BASE}/ffmpeg/lib -framework Foundation -framework CoreVideo -lavdevice"
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd "${BASEDIR}"/apple 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

# ALWAYS BUILD STATIC LIBRARIES
BUILD_LIBRARY_OPTIONS="--enable-static --disable-shared"

echo -n -e "\n${LIB_NAME}: "

make distclean 2>/dev/null 1>/dev/null

rm -f "${BASEDIR}"/apple/src/libffmpegkit* 1>>"${BASEDIR}"/build.log 2>&1

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/apple/configure ]] || [[ ${RECONF_ffmpeg_kit} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" || exit 1
fi

# CHECK IF VIDEOTOOLBOX IS ENABLED
VIDEOTOOLBOX_SUPPORT_FLAG=""
if [[ ${ENABLED_LIBRARIES[$LIBRARY_APPLE_VIDEOTOOLBOX]} -eq 1 ]]; then
  VIDEOTOOLBOX_SUPPORT_FLAG="--enable-videotoolbox"
fi

# REMOVE OPTIONS FROM CONFIGURE TO FIX THE FOLLOWING ERROR
# ld: -flat_namespace and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together
${SED_INLINE} 's/$wl-flat_namespace //g' configure 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
${SED_INLINE} 's/$wl-undefined //g' configure 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
${SED_INLINE} 's/${wl}suppress//g' configure 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

./configure \
  --prefix="${FFMPEG_KIT_LIBRARY_PATH}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  ${BUILD_LIBRARY_OPTIONS} \
  ${VIDEOTOOLBOX_SUPPORT_FLAG} \
  --disable-fast-install \
  --disable-maintainer-mode \
  --host="${HOST}" 1>>"${BASEDIR}"/build.log 2>&1

if [ $? -ne 0 ]; then
  echo -e "failed\n\nSee build.log for details\n"
  exit 1
fi

# DELETE THE PREVIOUS BUILD OF THE LIBRARY
if [ -d "${FFMPEG_KIT_LIBRARY_PATH}" ]; then
  rm -rf "${FFMPEG_KIT_LIBRARY_PATH}" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
fi

make -j$(get_cpu_count) 1>>"${BASEDIR}"/build.log 2>&1

make install 1>>"${BASEDIR}"/build.log 2>&1

if [ $? -eq 0 ]; then
  echo "ok"
else
  echo -e "failed\n\nSee build.log for details\n"
  exit 1
fi
