#!/bin/bash

HOST_PKG_CONFIG_PATH=$(command -v pkg-config)
if [ -z "${HOST_PKG_CONFIG_PATH}" ]; then
  echo -e "\n(*) pkg-config command not found\n"
  exit 1
fi

LIB_NAME="ffmpeg"

echo -e "----------------------------------------------------------------" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "\nINFO: Building ${LIB_NAME} for ${HOST} with the following environment variables\n" 1>>"${BASEDIR}"/build.log 2>&1
env 1>>"${BASEDIR}"/build.log 2>&1
echo -e "----------------------------------------------------------------\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: System information\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: $(uname -a)\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "----------------------------------------------------------------\n" 1>>"${BASEDIR}"/build.log 2>&1

FFMPEG_LIBRARY_PATH="${LIB_INSTALL_BASE}/${LIB_NAME}"

# SET PATHS
set_toolchain_paths "${LIB_NAME}"

# SET BUILD FLAGS
HOST=$(get_host)
export CFLAGS=$(get_cflags "${LIB_NAME}")
export CXXFLAGS=$(get_cxxflags "${LIB_NAME}")
export LDFLAGS=$(get_ldflags "${LIB_NAME}")
export PKG_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}:$(pkg-config --variable pc_path pkg-config)"

echo -e "\nINFO: Using PKG_CONFIG_PATH: ${PKG_CONFIG_PATH}\n" 1>>"${BASEDIR}"/build.log 2>&1

cd "${BASEDIR}"/src/"${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1

# SET BUILD OPTIONS
TARGET_CPU=""
TARGET_ARCH=""
ASM_OPTIONS=""
case ${ARCH} in
x86-64)
  TARGET_CPU="x86_64"
  TARGET_ARCH="x86_64"
  ASM_OPTIONS=" --disable-neon --enable-asm --enable-inline-asm"
  ;;
esac

CONFIGURE_POSTFIX=""
HIGH_PRIORITY_INCLUDES=""

# SET CONFIGURE OPTIONS
for library in {0..91}; do
  if [[ ${ENABLED_LIBRARIES[$library]} -eq 1 ]]; then
    ENABLED_LIBRARY=$(get_library_name ${library})

    echo -e "INFO: Enabling library ${ENABLED_LIBRARY}\n" 1>>"${BASEDIR}"/build.log 2>&1

    case ${ENABLED_LIBRARY} in
    linux-alsa)
      CONFIGURE_POSTFIX+=" --enable-alsa"
      ;;
    linux-fontconfig)
      CONFIGURE_POSTFIX+=" --enable-libfontconfig"
      ;;
    linux-freetype)
      CONFIGURE_POSTFIX+=" --enable-libfreetype"
      ;;
    linux-fribidi)
      CONFIGURE_POSTFIX+=" --enable-libfribidi"
      ;;
    linux-gmp)
      CONFIGURE_POSTFIX+=" --enable-gmp"
      ;;
    linux-gnutls)
      CONFIGURE_POSTFIX+=" --enable-gnutls"
      ;;
    linux-lame)
      CONFIGURE_POSTFIX+=" --enable-libmp3lame"
      ;;
    linux-libass)
      CONFIGURE_POSTFIX+=" --enable-libass"
      ;;
    linux-libiconv)
      CONFIGURE_POSTFIX+=" --enable-iconv"
      ;;
    linux-libtheora)
      CONFIGURE_POSTFIX+=" --enable-libtheora"
      ;;
    linux-libvidstab)
      CONFIGURE_POSTFIX+=" --enable-libvidstab"
      ;;
    linux-libvorbis)
      CONFIGURE_POSTFIX+=" --enable-libvorbis"
      ;;
    linux-libvpx)
      CONFIGURE_POSTFIX+=" --enable-libvpx"
      ;;
    linux-libwebp)
      CONFIGURE_POSTFIX+=" --enable-libwebp"
      ;;
    linux-libxml2)
      CONFIGURE_POSTFIX+=" --enable-libxml2"
      ;;
    linux-opencl)
      CONFIGURE_POSTFIX+=" --enable-opencl"
      ;;
    linux-opencore-amr)
      CONFIGURE_POSTFIX+=" --enable-libopencore-amrnb"
      ;;
    linux-opus)
      CONFIGURE_POSTFIX+=" --enable-libopus"
      ;;
    linux-rubberband)
      CONFIGURE_POSTFIX+=" --enable-librubberband"
      ;;
    linux-sdl)
      CONFIGURE_POSTFIX+=" --enable-sdl2"
      ;;
    linux-shine)
      CONFIGURE_POSTFIX+=" --enable-libshine"
      ;;
    linux-snappy)
      CONFIGURE_POSTFIX+=" --enable-libsnappy"
      ;;
    linux-soxr)
      CONFIGURE_POSTFIX+=" --enable-libsoxr"
      ;;
    linux-speex)
      CONFIGURE_POSTFIX+=" --enable-libspeex"
      ;;
    linux-tesseract)
      CONFIGURE_POSTFIX+=" --enable-libtesseract"
      ;;
    linux-twolame)
      CONFIGURE_POSTFIX+=" --enable-libtwolame"
      ;;
    linux-vaapi)
      CONFIGURE_POSTFIX+=" --enable-vaapi"
      ;;
    linux-vo-amrwbenc)
      CONFIGURE_POSTFIX+=" --enable-libvo-amrwbenc"
      ;;
    linux-v4l2)
      CONFIGURE_POSTFIX+=" --enable-libv4l2"
      ;;
    linux-x265)
      CONFIGURE_POSTFIX+=" --enable-libx265"
      ;;
    linux-xvidcore)
      CONFIGURE_POSTFIX+=" --enable-libxvid"
      ;;
    linux-zlib)
      CONFIGURE_POSTFIX+=" --enable-zlib"
      ;;
    chromaprint)
      CFLAGS+=" $(pkg-config --cflags libchromaprint 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libchromaprint 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-chromaprint"
      ;;
    dav1d)
      CFLAGS+=" $(pkg-config --cflags dav1d 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static dav1d 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libdav1d"
      ;;
    kvazaar)
      CFLAGS+=" $(pkg-config --cflags kvazaar 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static kvazaar 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libkvazaar"
      ;;
    libilbc)
      CFLAGS+=" $(pkg-config --cflags libilbc 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libilbc 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libilbc"
      ;;
    libaom)
      CFLAGS+=" $(pkg-config --cflags aom 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static aom 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libaom"
      ;;
    openh264)
      CFLAGS+=" $(pkg-config --cflags openh264 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static openh264 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libopenh264"
      ;;
    openssl)
      CFLAGS+=" $(pkg-config --cflags openssl 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static openssl 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-openssl"
      ;;
    srt)
      CFLAGS+=" $(pkg-config --cflags srt 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static srt 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libsrt"
      ;;
    x264)
      CFLAGS+=" $(pkg-config --cflags x264 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static x264 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libx264"
      ;;
    zimg)
      CFLAGS+=" $(pkg-config --cflags zimg 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static zimg 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libzimg"
      ;;
    esac
  else

    # THE FOLLOWING LIBRARIES SHOULD BE EXPLICITLY DISABLED TO PREVENT AUTODETECT
    # NOTE THAT IDS MUST BE +1 OF THE INDEX VALUE
    if [[ ${library} -eq ${LIBRARY_LINUX_ALSA} ]]; then
      CONFIGURE_POSTFIX+=" --disable-alsa"
    elif [[ ${library} -eq ${LIBRARY_LINUX_FONTCONFIG} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libfontconfig"
    elif [[ ${library} -eq ${LIBRARY_LINUX_FREETYPE} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libfreetype"
    elif [[ ${library} -eq ${LIBRARY_LINUX_FRIBIDI} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libfribidi"
    elif [[ ${library} -eq ${LIBRARY_LINUX_GMP} ]]; then
      CONFIGURE_POSTFIX+=" --disable-gmp"
    elif [[ ${library} -eq ${LIBRARY_LINUX_GNUTLS} ]]; then
      CONFIGURE_POSTFIX+=" --disable-gnutls"
    elif [[ ${library} -eq ${LIBRARY_LINUX_LAME} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libmp3lame"
    elif [[ ${library} -eq ${LIBRARY_LINUX_LIBASS} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libass"
    elif [[ ${library} -eq ${LIBRARY_LINUX_LIBICONV} ]]; then
      CONFIGURE_POSTFIX+=" --disable-iconv"
    elif [[ ${library} -eq ${LIBRARY_LINUX_LIBTHEORA} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libtheora"
    elif [[ ${library} -eq ${LIBRARY_LINUX_LIBVIDSTAB} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libvidstab"
    elif [[ ${library} -eq ${LIBRARY_LINUX_LIBVORBIS} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libvorbis"
    elif [[ ${library} -eq ${LIBRARY_LINUX_LIBVPX} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libvpx"
    elif [[ ${library} -eq ${LIBRARY_LINUX_LIBWEBP} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libwebp"
    elif [[ ${library} -eq ${LIBRARY_LINUX_LIBXML2} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libxml2"
    elif [[ ${library} -eq ${LIBRARY_LINUX_OPENCOREAMR} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libopencore-amrnb"
    elif [[ ${library} -eq ${LIBRARY_LINUX_OPUS} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libopus"
    elif [[ ${library} -eq ${LIBRARY_LINUX_RUBBERBAND} ]]; then
      CONFIGURE_POSTFIX+=" --disable-librubberband"
    elif [[ ${library} -eq ${LIBRARY_LINUX_SDL} ]]; then
      CONFIGURE_POSTFIX+=" --disable-sdl2"
    elif [[ ${library} -eq ${LIBRARY_LINUX_SHINE} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libshine"
    elif [[ ${library} -eq ${LIBRARY_LINUX_SNAPPY} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libsnappy"
    elif [[ ${library} -eq ${LIBRARY_LINUX_SOXR} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libsoxr"
    elif [[ ${library} -eq ${LIBRARY_LINUX_SPEEX} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libspeex"
    elif [[ ${library} -eq ${LIBRARY_LINUX_TESSERACT} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libtesseract"
    elif [[ ${library} -eq ${LIBRARY_LINUX_TWOLAME} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libtwolame"
    elif [[ ${library} -eq ${LIBRARY_LINUX_VO_AMRWBENC} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libvo-amrwbenc"
    elif [[ ${library} -eq ${LIBRARY_LINUX_X265} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libx265"
    elif [[ ${library} -eq ${LIBRARY_LINUX_XVIDCORE} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libxvid"
    elif [[ ${library} -eq ${LIBRARY_SYSTEM_ZLIB} ]]; then
      CONFIGURE_POSTFIX+=" --disable-zlib"
    elif [[ ${library} -eq ${LIBRARY_CHROMAPRINT} ]]; then
      CONFIGURE_POSTFIX+=" --disable-chromaprint"
    elif [[ ${library} -eq ${LIBRARY_DAV1D} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libdav1d"
    elif [[ ${library} -eq ${LIBRARY_KVAZAAR} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libkvazaar"
    elif [[ ${library} -eq ${LIBRARY_LIBILBC} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libilbc"
    elif [[ ${library} -eq ${LIBRARY_LIBAOM} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libaom"
    elif [[ ${library} -eq ${LIBRARY_OPENH264} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libopenh264"
    elif [[ ${library} -eq ${LIBRARY_OPENSSL} ]]; then
      CONFIGURE_POSTFIX+=" --disable-openssl"
    elif [[ ${library} -eq ${LIBRARY_SRT} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libsrt"
    elif [[ ${library} -eq ${LIBRARY_X264} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libx264"
    elif [[ ${library} -eq ${LIBRARY_ZIMG} ]]; then
      CONFIGURE_POSTFIX+=" --disable-libzimg"
    fi
  fi
done

# SET CONFIGURE OPTIONS FOR CUSTOM LIBRARIES
for custom_library_index in "${CUSTOM_LIBRARIES[@]}"; do
  library_name="CUSTOM_LIBRARY_${custom_library_index}_NAME"
  pc_file_name="CUSTOM_LIBRARY_${custom_library_index}_PACKAGE_CONFIG_FILE_NAME"
  ffmpeg_flag_name="CUSTOM_LIBRARY_${custom_library_index}_FFMPEG_ENABLE_FLAG"

  echo -e "INFO: Enabling custom library ${!library_name}\n" 1>>"${BASEDIR}"/build.log 2>&1

  CFLAGS+=" $(pkg-config --cflags ${!pc_file_name} 2>>"${BASEDIR}"/build.log)"
  LDFLAGS+=" $(pkg-config --libs --static ${!pc_file_name} 2>>"${BASEDIR}"/build.log)"
  CONFIGURE_POSTFIX+=" --enable-${!ffmpeg_flag_name}"
done

# SET ENABLE GPL FLAG WHEN REQUESTED
if [ "$GPL_ENABLED" == "yes" ]; then
  CONFIGURE_POSTFIX+=" --enable-gpl"
fi

# ALWAYS BUILD SHARED LIBRARIES
BUILD_LIBRARY_OPTIONS="--disable-static --enable-shared"

# OPTIMIZE FOR SPEED INSTEAD OF SIZE
if [[ -z ${FFMPEG_KIT_OPTIMIZED_FOR_SPEED} ]]; then
  SIZE_OPTIONS="--enable-small"
else
  SIZE_OPTIONS=""
fi

# SET DEBUG OPTIONS
if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then

  # SET LTO FLAGS
  if [[ -z ${NO_LINK_TIME_OPTIMIZATION} ]]; then
    DEBUG_OPTIONS="--disable-debug --enable-lto"
  else
    DEBUG_OPTIONS="--disable-debug --disable-lto"
  fi
else
  DEBUG_OPTIONS="--enable-debug --disable-stripping"
fi

echo -n -e "\n${LIB_NAME}: "

if [[ -z ${NO_WORKSPACE_CLEANUP_ffmpeg} ]]; then
  echo -e "INFO: Cleaning workspace for ${LIB_NAME}\n" 1>>"${BASEDIR}"/build.log 2>&1
  make distclean 2>/dev/null 1>/dev/null

  # WORKAROUND TO MANUALLY DELETE UNCLEANED FILES
  rm -f "${BASEDIR}"/src/"${LIB_NAME}"/libavfilter/opencl/*.o 1>>"${BASEDIR}"/build.log 2>&1
  rm -f "${BASEDIR}"/src/"${LIB_NAME}"/libavcodec/neon/*.o 1>>"${BASEDIR}"/build.log 2>&1

  # DELETE SHARED FRAMEWORK WORKAROUNDS
  git checkout "${BASEDIR}/src/ffmpeg/ffbuild" 1>>"${BASEDIR}"/build.log 2>&1
fi

# USE HIGHER LIMITS FOR FFMPEG LINKING
ulimit -n 2048 1>>"${BASEDIR}"/build.log 2>&1

########################### CUSTOMIZATIONS #######################
cd "${BASEDIR}"/src/"${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
git checkout libavformat/file.c 1>>"${BASEDIR}"/build.log 2>&1
git checkout libavformat/protocols.c 1>>"${BASEDIR}"/build.log 2>&1
git checkout libavutil 1>>"${BASEDIR}"/build.log 2>&1

# 1. Use thread local log levels
${SED_INLINE} 's/static int av_log_level/__thread int av_log_level/g' "${BASEDIR}"/src/"${LIB_NAME}"/libavutil/log.c 1>>"${BASEDIR}"/build.log 2>&1 || return 1

###################################################################

./configure \
  --cross-prefix="${HOST}-" \
  --prefix="${FFMPEG_LIBRARY_PATH}" \
  --pkg-config="${HOST_PKG_CONFIG_PATH}" \
  --enable-version3 \
  --arch="${TARGET_ARCH}" \
  --cpu="${TARGET_CPU}" \
  --target-os=linux \
  ${ASM_OPTIONS} \
  --ar="${AR}" \
  --cc="${CC}" \
  --cxx="${CXX}" \
  --ranlib="${RANLIB}" \
  --strip="${STRIP}" \
  --nm="${NM}" \
  --disable-autodetect \
  --enable-cross-compile \
  --enable-pic \
  --enable-optimizations \
  --enable-swscale \
  ${BUILD_LIBRARY_OPTIONS} \
  --enable-pthreads \
  --enable-v4l2-m2m \
  --disable-outdev=fbdev \
  --disable-indev=fbdev \
  ${SIZE_OPTIONS} \
  --disable-xmm-clobber-test \
  ${DEBUG_OPTIONS} \
  --disable-neon-clobber-test \
  --disable-programs \
  --disable-postproc \
  --disable-doc \
  --disable-htmlpages \
  --disable-manpages \
  --disable-podpages \
  --disable-txtpages \
  --disable-sndio \
  --disable-schannel \
  --disable-securetransport \
  --disable-xlib \
  --disable-cuda \
  --disable-cuvid \
  --disable-nvenc \
  --disable-vaapi \
  --disable-vdpau \
  --disable-videotoolbox \
  --disable-audiotoolbox \
  --disable-appkit \
  --disable-cuda \
  --disable-cuvid \
  --disable-nvenc \
  --disable-vaapi \
  --disable-vdpau \
  ${CONFIGURE_POSTFIX} 1>>"${BASEDIR}"/build.log 2>&1

if [[ $? -ne 0 ]]; then
  echo -e "failed\n\nSee build.log for details\n"
  exit 1
fi

if [[ -z ${NO_OUTPUT_REDIRECTION} ]]; then
  make -j$(get_cpu_count) 1>>"${BASEDIR}"/build.log 2>&1

  if [[ $? -ne 0 ]]; then
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi
else
  echo -e "started\n"
  make -j$(get_cpu_count)

  if [[ $? -ne 0 ]]; then
    echo -n -e "\n${LIB_NAME}: failed\n\nSee build.log for details\n"
    exit 1
  else
    echo -n -e "\n${LIB_NAME}: "
  fi
fi

# DELETE THE PREVIOUS BUILD OF THE LIBRARY BEFORE INSTALLING
if [ -d "${FFMPEG_LIBRARY_PATH}" ]; then
  rm -rf "${FFMPEG_LIBRARY_PATH}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi
make install 1>>"${BASEDIR}"/build.log 2>&1

if [[ $? -ne 0 ]]; then
  echo -e "failed\n\nSee build.log for details\n"
  exit 1
fi

# MANUALLY COPY PKG-CONFIG FILES
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavformat.pc "${INSTALL_PKG_CONFIG_DIR}/libavformat.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libswresample.pc "${INSTALL_PKG_CONFIG_DIR}/libswresample.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libswscale.pc "${INSTALL_PKG_CONFIG_DIR}/libswscale.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavdevice.pc "${INSTALL_PKG_CONFIG_DIR}/libavdevice.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavfilter.pc "${INSTALL_PKG_CONFIG_DIR}/libavfilter.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavcodec.pc "${INSTALL_PKG_CONFIG_DIR}/libavcodec.pc" || return 1
overwrite_file "${FFMPEG_LIBRARY_PATH}"/lib/pkgconfig/libavutil.pc "${INSTALL_PKG_CONFIG_DIR}/libavutil.pc" || return 1

# MANUALLY ADD REQUIRED HEADERS
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavutil/x86 1>>"${BASEDIR}"/build.log 2>&1
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavutil/arm 1>>"${BASEDIR}"/build.log 2>&1
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavutil/aarch64 1>>"${BASEDIR}"/build.log 2>&1
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/x86 1>>"${BASEDIR}"/build.log 2>&1
mkdir -p "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/arm 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/config.h "${FFMPEG_LIBRARY_PATH}"/include/config.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavcodec/mathops.h "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/mathops.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavcodec/x86/mathops.h "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/x86/mathops.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavcodec/arm/mathops.h "${FFMPEG_LIBRARY_PATH}"/include/libavcodec/arm/mathops.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavformat/network.h "${FFMPEG_LIBRARY_PATH}"/include/libavformat/network.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavformat/os_support.h "${FFMPEG_LIBRARY_PATH}"/include/libavformat/os_support.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavformat/url.h "${FFMPEG_LIBRARY_PATH}"/include/libavformat/url.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/attributes_internal.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/attributes_internal.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/bprint.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/bprint.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/getenv_utf8.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/getenv_utf8.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/internal.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/internal.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/libm.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/libm.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/reverse.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/reverse.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/thread.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/thread.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/timer.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/timer.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/x86/asm.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/x86/asm.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/x86/timer.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/x86/timer.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/arm/timer.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/arm/timer.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/aarch64/timer.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/aarch64/timer.h 1>>"${BASEDIR}"/build.log 2>&1
overwrite_file "${BASEDIR}"/src/ffmpeg/libavutil/x86/emms.h "${FFMPEG_LIBRARY_PATH}"/include/libavutil/x86/emms.h 1>>"${BASEDIR}"/build.log 2>&1

if [ $? -eq 0 ]; then
  echo "ok"
else
  echo -e "failed\n\nSee build.log for details\n"
  exit 1
fi
