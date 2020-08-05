#!/bin/bash

# ENABLE COMMON FUNCTIONS
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="ffmpeg-kit"
set_toolchain_paths ${LIB_NAME}

# PREPARE BUILD FLAGS
BUILD_HOST=$(get_build_host)
if [ ${ARCH} == "x86-64-mac-catalyst" ]; then
  BUILD_HOST="x86_64-apple-darwin"
fi
COMMON_CFLAGS=$(get_cflags ${LIB_NAME})
COMMON_LDFLAGS=$(get_ldflags ${LIB_NAME})

# SET BUILD FLAGS
export CFLAGS="${COMMON_CFLAGS} -I${BASEDIR}/prebuilt/$(get_target_build_directory)/ffmpeg/include"
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS="${COMMON_LDFLAGS} -L${BASEDIR}/prebuilt/$(get_target_build_directory)/ffmpeg/lib -framework Foundation -framework CoreVideo -lavdevice"
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

# ALWAYS BUILD STATIC LIBRARIES
BUILD_LIBRARY_OPTIONS="--enable-static --disable-shared"

cd "${BASEDIR}"/objc || exit 1

echo -n -e "\n${LIB_NAME}: "

make distclean 2>/dev/null 1>/dev/null

rm -f "${BASEDIR}"/objc/src/libffmpegkit* 1>>"${BASEDIR}"/build.log 2>&1

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_ffmpeg_kit} -eq 1 ]]; then
  autoreconf_library ${LIB_NAME}
fi

# CHECK IF VIDEOTOOLBOX IS ENABLED
VIDEOTOOLBOX_SUPPORT_FLAG=""
if [[ ${LIBRARY_OBJC_VIDEOTOOLBOX} -eq 1 ]]; then
  VIDEOTOOLBOX_SUPPORT_FLAG="--enable-videotoolbox"
fi

# REMOVE OPTIONS FROM CONFIGURE TO FIX THE FOLLOWING ERROR
# ld: -flat_namespace and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together
${SED_INLINE} 's/$wl-flat_namespace //g' configure
${SED_INLINE} 's/$wl-undefined //g' configure
${SED_INLINE} 's/${wl}suppress//g' configure

./configure \
  --prefix="${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME}" \
  --with-pic \
  --with-sysroot=${SDK_PATH} \
  ${BUILD_LIBRARY_OPTIONS} \
  ${VIDEOTOOLBOX_SUPPORT_FLAG} \
  --disable-fast-install \
  --disable-maintainer-mode \
  --host=${BUILD_HOST} 1>>"${BASEDIR}"/build.log 2>&1

if [ $? -ne 0 ]; then
  echo "failed"
  exit 1
fi

rm -rf "${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1
make -j$(get_cpu_count) install 1>>"${BASEDIR}"/build.log 2>&1

if [ $? -eq 0 ]; then
  echo "ok"
else
  echo "failed"
  exit 1
fi
