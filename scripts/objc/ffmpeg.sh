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
FFMPEG_CFLAGS=""
FFMPEG_LDFLAGS=""
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

# PREPARE BUILD OPTIONS
TARGET_CPU=""
TARGET_ARCH=""
ARCH_OPTIONS=""
BITCODE_FLAGS=""
case ${ARCH} in
armv7)
  TARGET_CPU="armv7"
  TARGET_ARCH="armv7"
  ARCH_OPTIONS=" --enable-neon --enable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
armv7s)
  TARGET_CPU="armv7s"
  TARGET_ARCH="armv7s"
  ARCH_OPTIONS=" --enable-neon --enable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
arm64)
  TARGET_CPU="armv8"
  TARGET_ARCH="aarch64"
  ARCH_OPTIONS=" --enable-neon --enable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
arm64e)
  TARGET_CPU="armv8.3-a"
  TARGET_ARCH="aarch64"
  ARCH_OPTIONS=" --enable-neon --enable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
i386)
  TARGET_CPU="i386"
  TARGET_ARCH="i386"
  ARCH_OPTIONS=" --disable-neon --enable-asm"
  BITCODE_FLAGS=""
  ;;
x86-64)
  TARGET_CPU="x86_64"
  TARGET_ARCH="x86_64"
  ARCH_OPTIONS=" --disable-neon --disable-asm"
  BITCODE_FLAGS=""
  ;;
x86-64-mac-catalyst)
  TARGET_CPU="x86_64"
  TARGET_ARCH="x86_64"
  ARCH_OPTIONS=" --disable-neon --disable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
esac

CONFIGURE_POSTFIX=""

# PREPARE CONFIGURE OPTIONS
for library in {1..58}; do
  if [[ ${!library} -eq 1 ]]; then
    ENABLED_LIBRARY=$(get_library_name $((library - 1)))

    echo -e "INFO: Enabling library ${ENABLED_LIBRARY}\n" 1>>"${BASEDIR}"/build.log 2>&1

    case ${ENABLED_LIBRARY} in
    chromaprint)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libchromaprint 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libchromaprint 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-chromaprint"
      ;;
    fontconfig)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags fontconfig 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static fontconfig 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libfontconfig"
      ;;
    freetype)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags freetype2 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static freetype2 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libfreetype"
      ;;
    fribidi)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags fribidi 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static fribidi 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libfribidi"
      ;;
    gmp)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags gmp 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static gmp 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-gmp"
      ;;
    gnutls)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags gnutls 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static gnutls 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-gnutls"
      ;;
    kvazaar)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags kvazaar 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static kvazaar 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libkvazaar"
      ;;
    lame)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libmp3lame 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libmp3lame 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libmp3lame"
      ;;
    libaom)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags aom 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static aom 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libaom"
      ;;
    libass)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libass 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libass 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libass"
      ;;
    libilbc)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libilbc 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libilbc 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libilbc"
      ;;
    libtheora)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags theora 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static theora 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libtheora"
      ;;
    libvidstab)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags vidstab 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static vidstab 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libvidstab --enable-gpl"
      ;;
    libvorbis)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags vorbis 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static vorbis 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libvorbis"
      ;;
    libvpx)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags vpx 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static vpx 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libvpx"
      ;;
    libwebp)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libwebp 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libwebp 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libwebp"
      ;;
    libxml2)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libxml-2.0 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libxml-2.0 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libxml2"
      ;;
    opencore-amr)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags opencore-amrnb 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static opencore-amrnb 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libopencore-amrnb"
      ;;
    openh264)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags openh264 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static openh264 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libopenh264"
      ;;
    opus)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags opus 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static opus 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libopus"
      ;;
    rubberband)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags rubberband 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static rubberband 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" -framework Accelerate"
      CONFIGURE_POSTFIX+=" --enable-librubberband --enable-gpl"
      ;;
    sdl)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags sdl2 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static sdl2 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-sdl2"
      ;;
    shine)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags shine 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static shine 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libshine"
      ;;
    snappy)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags snappy 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static snappy 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libsnappy"
      ;;
    soxr)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags soxr 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static soxr 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libsoxr"
      ;;
    speex)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags speex 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static speex 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libspeex"
      ;;
    tesseract)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags tesseract 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static tesseract 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_CFLAGS+=" $(pkg-config --cflags giflib 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static giflib 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libtesseract"
      ;;
    twolame)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags twolame 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static twolame 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libtwolame"
      ;;
    vo-amrwbenc)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags vo-amrwbenc 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static vo-amrwbenc 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libvo-amrwbenc"
      ;;
    wavpack)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags wavpack 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static wavpack 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libwavpack"
      ;;
    x264)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags x264 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static x264 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libx264 --enable-gpl"
      ;;
    x265)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags x265 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static x265 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libx265 --enable-gpl"
      ;;
    xvidcore)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags xvidcore 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static xvidcore 1>>"${BASEDIR}"/build.log 2>&1)"
      CONFIGURE_POSTFIX+=" --enable-libxvid --enable-gpl"
      ;;
    expat)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags expat 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static expat 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    libogg)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags ogg 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static ogg 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    libpng)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libpng 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libpng 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    nettle)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags nettle 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static nettle 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_CFLAGS+=" $(pkg-config --cflags hogweed 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static hogweed 1>>"${BASEDIR}"/build.log 2>&1)"
      ;;
    ios-* | tvos-* | macos-*)

      # BUILT-IN LIBRARIES SHARE INCLUDE AND LIB DIRECTORIES
      # INCLUDING ONLY ONE OF THEM IS ENOUGH
      FFMPEG_CFLAGS+=" $(pkg-config --cflags zlib 1>>"${BASEDIR}"/build.log 2>&1)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static zlib 1>>"${BASEDIR}"/build.log 2>&1)"

      case ${ENABLED_LIBRARY} in
      *-audiotoolbox)
        CONFIGURE_POSTFIX+=" --enable-audiotoolbox"

        if [[ ${FFMPEG_KIT_BUILD_TYPE} != "macos" ]]; then

          # NOT AVAILABLE ON IOS, TVOS
          CONFIGURE_POSTFIX+=" --disable-outdev=audiotoolbox"
        fi
        ;;
      *-avfoundation)
        CONFIGURE_POSTFIX+=" --enable-avfoundation"
        ;;
      *-bzip2)
        CONFIGURE_POSTFIX+=" --enable-bzlib"
        ;;
      *-coreimage)
        CONFIGURE_POSTFIX+=" --enable-coreimage"
        ;;
      *-libiconv)
        CONFIGURE_POSTFIX+=" --enable-iconv"
        ;;
      *-opencl)
        CONFIGURE_POSTFIX+=" --enable-opencl"
        ;;
      *-opengl)
        CONFIGURE_POSTFIX+=" --enable-opengl"
        ;;
      *-videotoolbox)
        CONFIGURE_POSTFIX+=" --enable-videotoolbox"
        ;;
      *-zlib)
        CONFIGURE_POSTFIX+=" --enable-zlib"
        ;;
      esac
      ;;
    esac
  else

    # THE FOLLOWING LIBRARIES SHOULD BE EXPLICITLY DISABLED TO PREVENT AUTODETECT
    # NOTE THAT IDS MUST BE +1 OF THE INDEX VALUE
    if [[ ${library} -eq $((LIBRARY_SDL + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-sdl2"
    elif [[ ${library} -eq $((LIBRARY_OBJC_AUDIOTOOLBOX + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-audiotoolbox"
    elif [[ ${library} -eq $((LIBRARY_OBJC_AVFOUNDATION + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-avfoundation"
    elif [[ ${library} -eq $((LIBRARY_OBJC_BZIP2 + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-bzlib"
    elif [[ ${library} -eq $((LIBRARY_OBJC_COREIMAGE + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-coreimage"
    elif [[ ${library} -eq $((LIBRARY_OBJC_LIBICONV + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-iconv"
    elif [[ ${library} -eq $((LIBRARY_OBJC_OPENCL + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-opencl"
    elif [[ ${library} -eq $((LIBRARY_OBJC_OPENGL + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-opengl"
    elif [[ ${library} -eq $((LIBRARY_OBJC_VIDEOTOOLBOX + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-videotoolbox"
    elif [[ ${library} -eq $((LIBRARY_OBJC_ZLIB + 1)) ]]; then
      CONFIGURE_POSTFIX+=" --disable-zlib"
    fi
  fi

  ((library++))
done

# ALWAYS BUILD STATIC LIBRARIES
BUILD_LIBRARY_OPTIONS="--enable-static --disable-shared"

# OPTIMIZE FOR SPEED INSTEAD OF SIZE
if [[ -z ${FFMPEG_KIT_OPTIMIZED_FOR_SPEED} ]]; then
  SIZE_OPTIONS="--enable-small"
else
  SIZE_OPTIONS=""
fi

# SET DEBUG OPTIONS
if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
  DEBUG_OPTIONS="--disable-debug"
else
  DEBUG_OPTIONS="--enable-debug --disable-stripping"
fi

# PREPARE CFLAGS PARTS BEFORE COMBINING THEM
ARCH_CFLAGS=$(get_arch_specific_cflags)
APP_CFLAGS=$(get_app_specific_cflags ${LIB_NAME})
COMMON_CFLAGS=$(get_common_cflags)
if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
  OPTIMIZATION_CFLAGS="$(get_size_optimization_cflags ${LIB_NAME})"
else
  OPTIMIZATION_CFLAGS="${FFMPEG_KIT_DEBUG}"
fi
MIN_VERSION_CFLAGS=$(get_min_version_cflags)
COMMON_INCLUDES=$(get_common_includes)

# PREPARE CFLAGS LDFLAGS BEFORE COMBINING THEM
ARCH_LDFLAGS=$(get_arch_specific_ldflags)
if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
  OPTIMIZATION_FLAGS="$(get_size_optimization_ldflags ${LIB_NAME})"
else
  OPTIMIZATION_FLAGS="${FFMPEG_KIT_DEBUG}"
fi
LINKED_LIBRARIES=$(get_common_linked_libraries)
COMMON_LDFLAGS=$(get_common_ldflags)

# SET BUILD FLAGS
export CFLAGS="${ARCH_CFLAGS} ${APP_CFLAGS} ${COMMON_CFLAGS} ${OPTIMIZATION_CFLAGS} ${MIN_VERSION_CFLAGS}${FFMPEG_CFLAGS} ${COMMON_INCLUDES}"
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS="${ARCH_LDFLAGS}${FFMPEG_LDFLAGS} ${LINKED_LIBRARIES} ${COMMON_LDFLAGS} ${BITCODE_FLAGS} ${OPTIMIZATION_FLAGS}"

echo -n -e "\n${LIB_NAME}: "

cd "${BASEDIR}"/src/${LIB_NAME} || exit 1

if [[ -z ${NO_WORKSPACE_CLEANUP_ffmpeg} ]]; then
  echo -e "INFO: Cleaning workspace for ${LIB_NAME}\n" 1>>"${BASEDIR}"/build.log 2>&1
  make distclean 2>/dev/null 1>/dev/null
fi

########################### CUSTOMIZATIONS #######################

# 1. Workaround to prevent adding of -mdynamic-no-pic flag
${SED_INLINE} 's/check_cflags -mdynamic-no-pic && add_asflags -mdynamic-no-pic;/check_cflags -mdynamic-no-pic;/g' ./configure 1>>"${BASEDIR}"/build.log 2>&1

# 2. Workaround for videotoolbox on mac catalyst
if [ ${ARCH} == "x86-64-mac-catalyst" ]; then
  ${SED_INLINE} 's/    CFDictionarySetValue(buffer_attributes\, kCVPixelBufferOpenGLESCompatibilityKey/   \/\/ CFDictionarySetValue(buffer_attributes\, kCVPixelBufferOpenGLESCompatibilityKey/g' "${BASEDIR}"/src/${LIB_NAME}/libavcodec/videotoolbox.c
else
  ${SED_INLINE} 's/   \/\/ CFDictionarySetValue(buffer_attributes\, kCVPixelBufferOpenGLESCompatibilityKey/    CFDictionarySetValue(buffer_attributes\, kCVPixelBufferOpenGLESCompatibilityKey/g' "${BASEDIR}"/src/${LIB_NAME}/libavcodec/videotoolbox.c
fi

# 3. Use thread local log levels
${SED_INLINE} 's/static int av_log_level/__thread int av_log_level/g' "${BASEDIR}"/src/${LIB_NAME}/libavutil/log.c 1>>"${BASEDIR}"/build.log 2>&1

###################################################################

./configure \
  --sysroot=${SDK_PATH} \
  --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
  --enable-version3 \
  --arch="${TARGET_ARCH}" \
  --cpu="${TARGET_CPU}" \
  --target-os=darwin \
  ${ARCH_OPTIONS} \
  --ar="${AR}" \
  --cc="${CC}" \
  --cxx="${CXX}" \
  --as="${AS}" \
  --ranlib="${RANLIB}" \
  --strip="${STRIP}" \
  --disable-autodetect \
  --enable-cross-compile \
  --enable-pic \
  --enable-inline-asm \
  --enable-optimizations \
  --enable-swscale \
  ${BUILD_LIBRARY_OPTIONS} \
  --enable-pthreads \
  --disable-v4l2-m2m \
  --disable-outdev=v4l2 \
  --disable-outdev=fbdev \
  --disable-indev=v4l2 \
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
  --disable-appkit \
  --disable-alsa \
  --disable-cuda \
  --disable-cuvid \
  --disable-nvenc \
  --disable-vaapi \
  --disable-vdpau \
  ${CONFIGURE_POSTFIX} ${PLATFORM_OPTIONS} 1>>"${BASEDIR}"/build.log 2>&1

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

rm -rf "${BASEDIR}/prebuilt/$(get_target_build_directory)"/${LIB_NAME} 1>>"${BASEDIR}"/build.log 2>&1
make install 1>>"${BASEDIR}"/build.log 2>&1

if [ $? -ne 0 ]; then
  echo "failed"
  exit 1
fi

# MANUALLY ADD REQUIRED HEADERS
mkdir -p "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil/x86
mkdir -p "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil/arm
mkdir -p "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil/aarch64
mkdir -p "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavcodec/x86
mkdir -p "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavcodec/arm
cp -f "${BASEDIR}"/src/ffmpeg/config.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include
cp -f "${BASEDIR}"/src/ffmpeg/libavcodec/mathops.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavcodec
cp -f "${BASEDIR}"/src/ffmpeg/libavcodec/x86/mathops.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavcodec/x86
cp -f "${BASEDIR}"/src/ffmpeg/libavcodec/arm/mathops.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavcodec/arm
cp -f "${BASEDIR}"/src/ffmpeg/libavformat/network.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavformat
cp -f "${BASEDIR}"/src/ffmpeg/libavformat/os_support.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavformat
cp -f "${BASEDIR}"/src/ffmpeg/libavformat/url.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavformat
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/internal.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/libm.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/reverse.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/thread.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/timer.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/x86/asm.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil/x86
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/x86/timer.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil/x86
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/arm/timer.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil/arm
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/aarch64/timer.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil/aarch64
cp -f "${BASEDIR}"/src/ffmpeg/libavutil/x86/emms.h "${BASEDIR}/prebuilt/$(get_target_build_directory)"/ffmpeg/include/libavutil/x86

if [ $? -eq 0 ]; then
  echo "ok"
else
  echo "failed"
  exit 1
fi
