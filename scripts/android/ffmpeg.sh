#!/bin/bash

# ENABLE COMMON FUNCTIONS
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh

# FIND pkg-config PATH
HOST_PKG_CONFIG_PATH=$(command -v pkg-config)
if [ -z "${HOST_PKG_CONFIG_PATH}" ]; then
  echo -e "\n(*) pkg-config command not found\n"
  exit 1
fi

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="ffmpeg"
set_toolchain_paths ${LIB_NAME}

# PREPARE BUILD FLAGS
BUILD_HOST=$(get_build_host)
CFLAGS=$(get_cflags ${LIB_NAME})
CXXFLAGS=$(get_cxxflags ${LIB_NAME})
LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

# PREPARE BUILD OPTIONS
TARGET_CPU=""
TARGET_ARCH=""
ARCH_OPTIONS=""
case ${ARCH} in
arm-v7a)
  TARGET_CPU="armv7-a"
  TARGET_ARCH="armv7-a"
  ARCH_OPTIONS=" --disable-neon --enable-asm --enable-inline-asm"
  ;;
arm-v7a-neon)
  TARGET_CPU="armv7-a"
  TARGET_ARCH="armv7-a"
  ARCH_OPTIONS=" --enable-neon --enable-asm --enable-inline-asm --build-suffix=_neon"
  ;;
arm64-v8a)
  TARGET_CPU="armv8-a"
  TARGET_ARCH="aarch64"
  ARCH_OPTIONS=" --enable-neon --enable-asm --enable-inline-asm"
  ;;
x86)
  TARGET_CPU="i686"
  TARGET_ARCH="i686"

  # asm disabled due to this ticket https://trac.ffmpeg.org/ticket/4928
  ARCH_OPTIONS=" --disable-neon --disable-asm --disable-inline-asm"
  ;;
x86-64)
  TARGET_CPU="x86_64"
  TARGET_ARCH="x86_64"
  ARCH_OPTIONS=" --disable-neon --enable-asm --enable-inline-asm"
  ;;
esac

CONFIGURE_POSTFIX=""
HIGH_PRIORITY_INCLUDES=""

# PREPARE CONFIGURE OPTIONS
for library in {1..58}; do
  if [[ ${!library} -eq 1 ]]; then
    ENABLED_LIBRARY=$(get_library_name $((library - 1)))

    echo -e "INFO: Enabling library ${ENABLED_LIBRARY}\n" 1>>"${BASEDIR}"/build.log 2>&1

    case $ENABLED_LIBRARY in
    chromaprint)
      CFLAGS+=" $(pkg-config --cflags libchromaprint 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static libchromaprint 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-chromaprint"
      ;;
    cpu-features)
      pkg-config --libs --static cpu-features 1>>"${BASEDIR}"/build.log 2>&1
      if [[ $? -eq 1 ]]; then
        echo -e "\nffmpeg: failed\n"
        exit 1
      fi
      ;;
    fontconfig)
      CFLAGS+=" $(pkg-config --cflags fontconfig 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static fontconfig 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libfontconfig"
      ;;
    freetype)
      CFLAGS+=" $(pkg-config --cflags freetype2 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static freetype2 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libfreetype"
      ;;
    fribidi)
      CFLAGS+=" $(pkg-config --cflags fribidi 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static fribidi 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libfribidi"
      ;;
    gmp)
      CFLAGS+=" $(pkg-config --cflags gmp 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static gmp 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-gmp"
      ;;
    gnutls)
      CFLAGS+=" $(pkg-config --cflags gnutls 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static gnutls 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-gnutls"
      ;;
    kvazaar)
      CFLAGS+=" $(pkg-config --cflags kvazaar 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static kvazaar 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libkvazaar"
      ;;
    lame)
      CFLAGS+=" $(pkg-config --cflags libmp3lame 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static libmp3lame 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libmp3lame"
      ;;
    libaom)
      CFLAGS+=" $(pkg-config --cflags aom 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static aom 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libaom"
      ;;
    libass)
      CFLAGS+=" $(pkg-config --cflags libass 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static libass 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libass"
      ;;
    libiconv)
      CFLAGS+=" $(pkg-config --cflags libiconv 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static libiconv 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-iconv"
      HIGH_PRIORITY_INCLUDES+=" $(pkg-config --cflags libiconv 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    libilbc)
      CFLAGS+=" $(pkg-config --cflags libilbc 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static libilbc 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libilbc"
      ;;
    libtheora)
      CFLAGS+=" $(pkg-config --cflags theora 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static theora 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libtheora"
      ;;
    libvidstab)
      CFLAGS+=" $(pkg-config --cflags vidstab 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static vidstab 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libvidstab --enable-gpl"
      ;;
    libvorbis)
      CFLAGS+=" $(pkg-config --cflags vorbis 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static vorbis 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libvorbis"
      ;;
    libvpx)
      CFLAGS+=" $(pkg-config --cflags vpx 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs vpx 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs cpu-features 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libvpx"
      ;;
    libwebp)
      CFLAGS+=" $(pkg-config --cflags libwebp 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static libwebp 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libwebp"
      ;;
    libxml2)
      CFLAGS+=" $(pkg-config --cflags libxml-2.0 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static libxml-2.0 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libxml2"
      ;;
    opencore-amr)
      CFLAGS+=" $(pkg-config --cflags opencore-amrnb 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static opencore-amrnb 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libopencore-amrnb"
      ;;
    openh264)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags openh264 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static openh264 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libopenh264"
      ;;
    opus)
      CFLAGS+=" $(pkg-config --cflags opus 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static opus 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libopus"
      ;;
    rubberband)
      CFLAGS+=" $(pkg-config --cflags rubberband 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static rubberband 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-librubberband --enable-gpl"
      ;;
    shine)
      CFLAGS+=" $(pkg-config --cflags shine 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static shine 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libshine"
      ;;
    sdl)
      CFLAGS+=" $(pkg-config --cflags sdl2 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static sdl2 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-sdl2"
      ;;
    snappy)
      CFLAGS+=" $(pkg-config --cflags snappy 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static snappy 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libsnappy"
      ;;
    soxr)
      CFLAGS+=" $(pkg-config --cflags soxr 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static soxr 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libsoxr"
      ;;
    speex)
      CFLAGS+=" $(pkg-config --cflags speex 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static speex 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libspeex"
      ;;
    tesseract)
      CFLAGS+=" $(pkg-config --cflags tesseract 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static tesseract 1>>"${BASEDIR}"/build.log 2>&1)"
      CFLAGS+=" $(pkg-config --cflags giflib 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static giflib 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libtesseract"
      ;;
    twolame)
      CFLAGS+=" $(pkg-config --cflags twolame 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static twolame 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libtwolame"
      ;;
    vo-amrwbenc)
      CFLAGS+=" $(pkg-config --cflags vo-amrwbenc 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static vo-amrwbenc 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libvo-amrwbenc"
      ;;
    wavpack)
      CFLAGS+=" $(pkg-config --cflags wavpack 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static wavpack 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libwavpack"
      ;;
    x264)
      CFLAGS+=" $(pkg-config --cflags x264 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static x264 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libx264 --enable-gpl"
      ;;
    x265)
      CFLAGS+=" $(pkg-config --cflags x265 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static x265 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libx265 --enable-gpl"
      ;;
    xvidcore)
      CFLAGS+=" $(pkg-config --cflags xvidcore 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static xvidcore 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libxvid --enable-gpl"
      ;;
    expat)
      CFLAGS+=" $(pkg-config --cflags expat 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static expat 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    libogg)
      CFLAGS+=" $(pkg-config --cflags ogg 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static ogg 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    libpng)
      CFLAGS+=" $(pkg-config --cflags libpng 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static libpng 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    libuuid)
      CFLAGS+=" $(pkg-config --cflags uuid 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static uuid 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    nettle)
      CFLAGS+=" $(pkg-config --cflags nettle 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static nettle 1>>"${BASEDIR}"/build.log 2>&1)"
      CFLAGS+=" $(pkg-config --cflags hogweed 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static hogweed 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    android-zlib)
      CFLAGS+=" $(pkg-config --cflags zlib 1>>"${BASEDIR}"/build.log 2>&1)"
      LDFLAGS+=" $(pkg-config --libs --static zlib 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-zlib"
      ;;
    android-media-codec)
      CONFIGURE_POSTFIX+=" --enable-mediacodec"
      ;;
    esac
  else

    # THE FOLLOWING LIBRARIES SHOULD BE EXPLICITLY DISABLED TO PREVENT AUTODETECT
    # NOTE THAT IDS MUST BE +1 OF THE INDEX VALUE
    if [[ ${library} -eq $((LIBRARY_SDL + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-sdl2"
    elif [[ ${library} -eq $((LIBRARY_ANDROID_ZLIB + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-zlib"
    elif [[ ${library} -eq $((LIBRARY_ANDROID_MEDIA_CODEC + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-mediacodec"
    fi
  fi
done

LDFLAGS+=" -L${ANDROID_NDK_ROOT}/platforms/android-${API}/arch-${TOOLCHAIN_ARCH}/usr/lib"

# LINKING WITH ANDROID LTS SUPPORT LIBRARY IS NECESSARY FOR API < 18
if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]] && [[ ${API} -lt 18 ]]; then
  LDFLAGS+=" -Wl,--whole-archive ${BASEDIR}/android/app/src/main/cpp/libandroidltssupport.a -Wl,--no-whole-archive"
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

cd "${BASEDIR}"/src/${LIB_NAME} || exit 1

if [[ -z ${NO_WORKSPACE_CLEANUP_ffmpeg} ]]; then
  echo -e "INFO: Cleaning workspace for ${LIB_NAME}\n" 1>>"${BASEDIR}"/build.log 2>&1
  make distclean 2>/dev/null 1>/dev/null
fi

# SET BUILD FLAGS
export CFLAGS="${HIGH_PRIORITY_INCLUDES} ${CFLAGS}"
export CXXFLAGS="${CXXFLAGS}"
export LDFLAGS="${LDFLAGS}"

# USE HIGHER LIMITS FOR FFMPEG LINKING
ulimit -n 2048 1>>"${BASEDIR}"/build.log 2>&1

########################### CUSTOMIZATIONS #######################

# 1. Use thread local log levels
${SED_INLINE} 's/static int av_log_level/__thread int av_log_level/g' "${BASEDIR}"/src/${LIB_NAME}/libavutil/log.c 1>>"${BASEDIR}"/build.log 2>&1

###################################################################

./configure \
  --cross-prefix="${BUILD_HOST}-" \
  --sysroot="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot" \
  --prefix="${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME}" \
  --pkg-config="${HOST_PKG_CONFIG_PATH}" \
  --enable-version3 \
  --arch="${TARGET_ARCH}" \
  --cpu="${TARGET_CPU}" \
  --cc="${CC}" \
  --cxx="${CXX}" \
  --extra-libs="$(pkg-config --libs --static cpu-features 1>>"${BASEDIR}"/build.log 2>&1)" \
  --target-os=android \
  ${ARCH_OPTIONS} \
  --enable-cross-compile \
  --enable-pic \
  --enable-jni \
  --enable-optimizations \
  --enable-swscale \
  ${BUILD_LIBRARY_OPTIONS} \
  --enable-v4l2-m2m \
  --disable-outdev=fbdev \
  --disable-indev=fbdev \
  ${SIZE_OPTIONS} \
  --disable-openssl \
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

if [ $? -ne 0 ]; then
  echo "failed"
  exit 1
fi

if [[ -z ${NO_OUTPUT_REDIRECTION} ]]; then
  make -j$(get_cpu_count) 1>>"${BASEDIR}"/build.log 2>&1

  if [ $? -ne 0 ]; then
    echo "failed"
    exit 1
  fi
else
  echo -e "started\n"
  make -j$(get_cpu_count) 1>>"${BASEDIR}"/build.log 2>&1

  if [ $? -ne 0 ]; then
    echo -n -e "\n${LIB_NAME}: failed\n"
    exit 1
  else
    echo -n -e "\n${LIB_NAME}: "
  fi
fi

rm -rf "${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME}"
make install 1>>"${BASEDIR}"/build.log 2>&1

if [ $? -ne 0 ]; then
  echo "failed"
  exit 1
fi

# MANUALLY ADD REQUIRED HEADERS
mkdir -p "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil/x86
mkdir -p "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil/arm
mkdir -p "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil/aarch64
mkdir -p "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavcodec/x86
mkdir -p "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavcodec/arm
cp -f "${BASEDIR}"/src/ffmpeg/config.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include
cp -f "${BASEDIR}"/src/ffmpeg/libavcodec/mathops.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavcodec
cp -f "${BASEDIR}"/src/ffmpeg/libavcodec/x86/mathops.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavcodec/x86
cp -f "${BASEDIR}"/src/ffmpeg/libavcodec/arm/mathops.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavcodec/arm
cp -f "${BASEDIR}"/src/ffmpeg/libavformat/network.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavformat
cp -f "${BASEDIR}"/src/ffmpeg/libavformat/os_support.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavformat
cp -f "${BASEDIR}"/src/ffmpeg/libavformat/url.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavformat
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/internal.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/libm.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/reverse.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/thread.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/timer.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/x86/asm.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil/x86
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/x86/timer.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil/x86
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/arm/timer.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil/arm
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/aarch64/timer.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil/aarch64
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/x86/emms.h "${BASEDIR}/prebuilt/android-$(get_target_build)"/ffmpeg/include/libavutil/x86

if [ $? -eq 0 ]; then
  echo "ok"
else
  echo "failed"
  exit 1
fi
