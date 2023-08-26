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
ANDROID_SYSROOT="${ANDROID_NDK_ROOT}"/toolchains/llvm/prebuilt/"${TOOLCHAIN}"/sysroot

# SET PATHS
set_toolchain_paths "${LIB_NAME}"

# SET BUILD FLAGS
HOST=$(get_host)
export CFLAGS=$(get_cflags "${LIB_NAME}")
export CXXFLAGS=$(get_cxxflags "${LIB_NAME}")
export LDFLAGS=$(get_ldflags "${LIB_NAME}")
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd "${BASEDIR}"/src/"${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1

# SET BUILD OPTIONS
TARGET_CPU=""
TARGET_ARCH=""
ASM_OPTIONS=""
case ${ARCH} in
arm-v7a)
  TARGET_CPU="armv7-a"
  TARGET_ARCH="armv7-a"
  ASM_OPTIONS=" --disable-neon --enable-asm --enable-inline-asm"
  ;;
arm-v7a-neon)
  TARGET_CPU="armv7-a"
  TARGET_ARCH="armv7-a"
  ASM_OPTIONS=" --enable-neon --enable-asm --enable-inline-asm --build-suffix=_neon"
  ;;
arm64-v8a)
  TARGET_CPU="armv8-a"
  TARGET_ARCH="aarch64"
  ASM_OPTIONS=" --enable-neon --enable-asm --enable-inline-asm"
  ;;
x86)
  TARGET_CPU="i686"
  TARGET_ARCH="i686"

  # asm disabled due to this ticket https://trac.ffmpeg.org/ticket/4928
  ASM_OPTIONS=" --disable-neon --disable-asm --disable-inline-asm"
  ;;
x86-64)
  TARGET_CPU="x86_64"
  TARGET_ARCH="x86_64"
  ASM_OPTIONS=" --disable-neon --enable-asm --enable-inline-asm"
  ;;
esac

CONFIGURE_POSTFIX=""
HIGH_PRIORITY_INCLUDES=""

# SET CONFIGURE OPTIONS
for library in {0..61}; do
  if [[ ${ENABLED_LIBRARIES[$library]} -eq 1 ]]; then
    ENABLED_LIBRARY=$(get_library_name ${library})

    echo -e "INFO: Enabling library ${ENABLED_LIBRARY}\n" 1>>"${BASEDIR}"/build.log 2>&1

    case ${ENABLED_LIBRARY} in
    chromaprint)
      CFLAGS+=" $(pkg-config --cflags libchromaprint 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libchromaprint 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-chromaprint"
      ;;
    cpu-features)
      pkg-config --libs --static cpu-features 2>>"${BASEDIR}"/build.log 1>/dev/null
      if [[ $? -eq 1 ]]; then
        echo -e "ERROR: cpu-features was not found in the pkg-config search path\n" 1>>"${BASEDIR}"/build.log 2>&1
        echo -e "\nffmpeg: failed\n\nSee build.log for details\n"
        exit 1
      fi
      ;;
    dav1d)
      CFLAGS+=" $(pkg-config --cflags dav1d 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static dav1d 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libdav1d"
      ;;
    fontconfig)
      CFLAGS+=" $(pkg-config --cflags fontconfig 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static fontconfig 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libfontconfig"
      ;;
    freetype)
      CFLAGS+=" $(pkg-config --cflags freetype2 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static freetype2 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libfreetype"
      ;;
    fribidi)
      CFLAGS+=" $(pkg-config --cflags fribidi 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static fribidi 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libfribidi"
      ;;
    gmp)
      CFLAGS+=" $(pkg-config --cflags gmp 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static gmp 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-gmp"
      ;;
    gnutls)
      CFLAGS+=" $(pkg-config --cflags gnutls 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static gnutls 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-gnutls"
      ;;
    kvazaar)
      CFLAGS+=" $(pkg-config --cflags kvazaar 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static kvazaar 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libkvazaar"
      ;;
    lame)
      CFLAGS+=" $(pkg-config --cflags libmp3lame 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libmp3lame 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libmp3lame"
      ;;
    libaom)
      CFLAGS+=" $(pkg-config --cflags aom 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static aom 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libaom"
      ;;
    libass)
      CFLAGS+=" $(pkg-config --cflags libass 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libass 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libass"
      ;;
    libiconv)
      CFLAGS+=" $(pkg-config --cflags libiconv 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libiconv 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-iconv"
      HIGH_PRIORITY_INCLUDES+=" $(pkg-config --cflags libiconv 2>>"${BASEDIR}"/build.log)"
      ;;
    libilbc)
      CFLAGS+=" $(pkg-config --cflags libilbc 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libilbc 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libilbc"
      ;;
    libtheora)
      CFLAGS+=" $(pkg-config --cflags theora 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static theora 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libtheora"
      ;;
    libvidstab)
      CFLAGS+=" $(pkg-config --cflags vidstab 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static vidstab 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libvidstab"
      ;;
    libvorbis)
      CFLAGS+=" $(pkg-config --cflags vorbis 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static vorbis 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libvorbis"
      ;;
    libvpx)
      CFLAGS+=" $(pkg-config --cflags vpx 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs vpx 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs cpu-features 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libvpx"
      ;;
    libwebp)
      CFLAGS+=" $(pkg-config --cflags libwebp 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libwebp 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libwebp"
      ;;
    libxml2)
      CFLAGS+=" $(pkg-config --cflags libxml-2.0 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libxml-2.0 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libxml2"
      ;;
    opencore-amr)
      CFLAGS+=" $(pkg-config --cflags opencore-amrnb 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static opencore-amrnb 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libopencore-amrnb"
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
    opus)
      CFLAGS+=" $(pkg-config --cflags opus 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static opus 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libopus"
      ;;
    rubberband)
      CFLAGS+=" $(pkg-config --cflags rubberband 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static rubberband 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-librubberband"
      ;;
    sdl)
      CFLAGS+=" $(pkg-config --cflags sdl2 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static sdl2 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-sdl2"
      ;;
    shine)
      CFLAGS+=" $(pkg-config --cflags shine 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static shine 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libshine"
      ;;
    snappy)
      CFLAGS+=" $(pkg-config --cflags snappy 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static snappy 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libsnappy"
      ;;
    soxr)
      CFLAGS+=" $(pkg-config --cflags soxr 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static soxr 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libsoxr"
      ;;
    speex)
      CFLAGS+=" $(pkg-config --cflags speex 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static speex 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libspeex"
      ;;
    srt)
      CFLAGS+=" $(pkg-config --cflags srt 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static srt 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libsrt"
      ;;
    tesseract)
      CFLAGS+=" $(pkg-config --cflags tesseract 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static tesseract 2>>"${BASEDIR}"/build.log)"
      CFLAGS+=" $(pkg-config --cflags giflib 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static giflib 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libtesseract"
      ;;
    twolame)
      CFLAGS+=" $(pkg-config --cflags twolame 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static twolame 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libtwolame"
      ;;
    vo-amrwbenc)
      CFLAGS+=" $(pkg-config --cflags vo-amrwbenc 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static vo-amrwbenc 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libvo-amrwbenc"
      ;;
    x264)
      CFLAGS+=" $(pkg-config --cflags x264 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static x264 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libx264"
      ;;
    x265)
      CFLAGS+=" $(pkg-config --cflags x265 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static x265 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libx265"
      ;;
    xvidcore)
      CFLAGS+=" $(pkg-config --cflags xvidcore 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static xvidcore 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libxvid"
      ;;
    zimg)
      CFLAGS+=" $(pkg-config --cflags zimg 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static zimg 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libzimg"
      ;;
    expat)
      CFLAGS+=" $(pkg-config --cflags expat 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static expat 2>>"${BASEDIR}"/build.log)"
      ;;
    libogg)
      CFLAGS+=" $(pkg-config --cflags ogg 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static ogg 2>>"${BASEDIR}"/build.log)"
      ;;
    libpng)
      CFLAGS+=" $(pkg-config --cflags libpng 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static libpng 2>>"${BASEDIR}"/build.log)"
      ;;
    libuuid)
      CFLAGS+=" $(pkg-config --cflags uuid 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static uuid 2>>"${BASEDIR}"/build.log)"
      ;;
    nettle)
      CFLAGS+=" $(pkg-config --cflags nettle 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static nettle 2>>"${BASEDIR}"/build.log)"
      CFLAGS+=" $(pkg-config --cflags hogweed 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static hogweed 2>>"${BASEDIR}"/build.log)"
      ;;
    android-zlib)
      CFLAGS+=" $(pkg-config --cflags zlib 2>>"${BASEDIR}"/build.log)"
      LDFLAGS+=" $(pkg-config --libs --static zlib 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-zlib"
      ;;
    android-media-codec)
      CONFIGURE_POSTFIX+=" --enable-mediacodec"
      ;;
    esac
  else

    # THE FOLLOWING LIBRARIES SHOULD BE EXPLICITLY DISABLED TO PREVENT AUTODETECT
    # NOTE THAT IDS MUST BE +1 OF THE INDEX VALUE
    if [[ ${library} -eq ${LIBRARY_SDL} ]]; then
      CONFIGURE_POSTFIX+=" --disable-sdl2"
    elif [[ ${library} -eq ${LIBRARY_SYSTEM_ZLIB} ]]; then
      CONFIGURE_POSTFIX+=" --disable-zlib"
    elif [[ ${library} -eq ${LIBRARY_ANDROID_MEDIA_CODEC} ]]; then
      CONFIGURE_POSTFIX+=" --disable-mediacodec"
    elif [[ ${library} -eq ${LIBRARY_OPENSSL} ]]; then
      CONFIGURE_POSTFIX+=" --disable-openssl"
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

export LDFLAGS+=" -L${ANDROID_NDK_ROOT}/platforms/android-${API}/arch-${TOOLCHAIN_ARCH}/usr/lib"

# LINKING WITH ANDROID LTS SUPPORT LIBRARY IS NECESSARY FOR API < 18
if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]] && [[ ${API} -lt 18 ]]; then
  export LDFLAGS+=" -Wl,--whole-archive ${BASEDIR}/android/ffmpeg-kit-android-lib/src/main/cpp/libandroidltssupport.a -Wl,--no-whole-archive"
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

# UPDATE BUILD FLAGS
export CFLAGS="${HIGH_PRIORITY_INCLUDES} ${CFLAGS}"

# USE HIGHER LIMITS FOR FFMPEG LINKING
ulimit -n 2048 1>>"${BASEDIR}"/build.log 2>&1

########################### CUSTOMIZATIONS #######################
cd "${BASEDIR}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
git checkout android/ffmpeg-kit-android-lib/src/main/cpp/ffmpegkit.c 1>>"${BASEDIR}"/build.log 2>&1
cd "${BASEDIR}"/src/"${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
git checkout libavformat/file.c 1>>"${BASEDIR}"/build.log 2>&1
git checkout libavformat/protocols.c 1>>"${BASEDIR}"/build.log 2>&1
git checkout libavutil 1>>"${BASEDIR}"/build.log 2>&1

# 1. Use thread local log levels
${SED_INLINE} 's/static int av_log_level/__thread int av_log_level/g' "${BASEDIR}"/src/"${LIB_NAME}"/libavutil/log.c 1>>"${BASEDIR}"/build.log 2>&1 || return 1

# 2. Enable ffmpeg-kit protocols
if [[ ${NO_FFMPEG_KIT_PROTOCOLS} == "1" ]]; then
  ${SED_INLINE} "s| av_set_saf|//av_set_saf|g" "${BASEDIR}"/android/ffmpeg-kit-android-lib/src/main/cpp/ffmpegkit.c 1>>"${BASEDIR}"/build.log 2>&1
  echo -e "\nINFO: Disabled custom ffmpeg-kit protocols\n" 1>>"${BASEDIR}"/build.log 2>&1
else
  cat ../../tools/protocols/libavformat_file.c >> libavformat/file.c
  cat ../../tools/protocols/libavutil_file.h >> libavutil/file.h
  cat ../../tools/protocols/libavutil_file.c >> libavutil/file.c
  awk '{gsub(/ff_file_protocol;/,"ff_file_protocol;\nextern const URLProtocol ff_saf_protocol;")}1' libavformat/protocols.c > libavformat/protocols.c.tmp
  cat libavformat/protocols.c.tmp > libavformat/protocols.c
  echo -e "\nINFO: Enabled custom ffmpeg-kit protocols\n" 1>>"${BASEDIR}"/build.log 2>&1
fi

###################################################################

./configure \
  --cross-prefix="${HOST}-" \
  --sysroot="${ANDROID_SYSROOT}" \
  --prefix="${FFMPEG_LIBRARY_PATH}" \
  --pkg-config="${HOST_PKG_CONFIG_PATH}" \
  --enable-version3 \
  --arch="${TARGET_ARCH}" \
  --cpu="${TARGET_CPU}" \
  --target-os=android \
  ${ASM_OPTIONS} \
  --ar="${AR}" \
  --cc="${CC}" \
  --cxx="${CXX}" \
  --ranlib="${RANLIB}" \
  --strip="${STRIP}" \
  --nm="${NM}" \
  --extra-libs="$(pkg-config --libs --static cpu-features)" \
  --disable-autodetect \
  --enable-cross-compile \
  --enable-pic \
  --enable-jni \
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
  --disable-alsa \
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
