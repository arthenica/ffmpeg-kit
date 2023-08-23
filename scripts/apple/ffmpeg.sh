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
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd "${BASEDIR}"/src/"${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1

# SET EXTRA BUILD FLAGS
FFMPEG_CFLAGS=""
FFMPEG_LDFLAGS=""

# SET BUILD OPTIONS
TARGET_CPU=""
TARGET_ARCH=""
ASM_OPTIONS=""
BITCODE_FLAGS=""
case ${ARCH} in
armv7)
  TARGET_CPU="armv7"
  TARGET_ARCH="armv7"
  ASM_OPTIONS=" --enable-neon --enable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
armv7s)
  TARGET_CPU="armv7s"
  TARGET_ARCH="armv7s"
  ASM_OPTIONS=" --enable-neon --enable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
arm64)
  TARGET_CPU="armv8"
  TARGET_ARCH="aarch64"
  ASM_OPTIONS=" --enable-neon --enable-asm"
  if [[ ${FFMPEG_KIT_BUILD_TYPE} != "macos" ]]; then
    BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  fi
  ;;
arm64-mac-catalyst)
  TARGET_CPU="armv8"
  TARGET_ARCH="aarch64"
  ASM_OPTIONS=" --enable-neon --enable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
arm64-simulator)
  TARGET_CPU="armv8"
  TARGET_ARCH="aarch64"
  ASM_OPTIONS=" --enable-neon --enable-asm"
  BITCODE_FLAGS=""
  ;;
arm64e)
  TARGET_CPU="armv8.3-a"
  TARGET_ARCH="aarch64"
  ASM_OPTIONS=" --enable-neon --enable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
i386)
  TARGET_CPU="i386"
  TARGET_ARCH="i386"
  ASM_OPTIONS=" --disable-neon --enable-asm"
  BITCODE_FLAGS=""
  ;;
x86-64)
  TARGET_CPU="x86_64"
  TARGET_ARCH="x86_64"
  ASM_OPTIONS=" --disable-neon --disable-asm"
  BITCODE_FLAGS=""
  ;;
x86-64-mac-catalyst)
  TARGET_CPU="x86_64"
  TARGET_ARCH="x86_64"
  ASM_OPTIONS=" --disable-neon --disable-asm"
  BITCODE_FLAGS="-fembed-bitcode -Wc,-fembed-bitcode"
  ;;
esac

if [ ! -z $NO_BITCODE ]; then
  BITCODE_FLAGS=""
fi

CONFIGURE_POSTFIX=""
HIGH_PRIORITY_LDFLAGS=""

# SET CONFIGURE OPTIONS
for library in {0..61}; do
  if [[ ${ENABLED_LIBRARIES[$library]} -eq 1 ]]; then
    ENABLED_LIBRARY=$(get_library_name ${library})

    echo -e "INFO: Enabling library ${ENABLED_LIBRARY}\n" 1>>"${BASEDIR}"/build.log 2>&1

    case ${ENABLED_LIBRARY} in
    chromaprint)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libchromaprint 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libchromaprint 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-chromaprint"
      ;;
    dav1d)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags dav1d 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static dav1d 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libdav1d"
      ;;
    fontconfig)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags fontconfig 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static fontconfig 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libfontconfig"
      ;;
    freetype)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags freetype2 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static freetype2 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libfreetype"
      ;;
    fribidi)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags fribidi 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static fribidi 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libfribidi"
      ;;
    gmp)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags gmp 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static gmp 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-gmp"
      ;;
    gnutls)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags gnutls 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static gnutls 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-gnutls"
      ;;
    kvazaar)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags kvazaar 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static kvazaar 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libkvazaar"
      ;;
    lame)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libmp3lame 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libmp3lame 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libmp3lame"
      ;;
    libaom)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags aom 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static aom 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libaom"
      ;;
    libass)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libass 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libass 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libass"
      ;;
    libilbc)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libilbc 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libilbc 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libilbc"
      ;;
    libtheora)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags theora 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static theora 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libtheora"
      ;;
    libvidstab)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags vidstab 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static vidstab 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libvidstab"
      ;;
    libvorbis)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags vorbis 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static vorbis 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libvorbis"
      ;;
    libvpx)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags vpx 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static vpx 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libvpx"
      ;;
    libwebp)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libwebp 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libwebp 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libwebp"
      ;;
    libxml2)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libxml-2.0 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libxml-2.0 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libxml2"
      ;;
    opencore-amr)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags opencore-amrnb 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static opencore-amrnb 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libopencore-amrnb"
      ;;
    openh264)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags openh264 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static openh264 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libopenh264"
      ;;
    openssl)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags openssl 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static openssl 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-openssl"
      ;;
    opus)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags opus 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static opus 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libopus"
      ;;
    rubberband)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags rubberband 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static rubberband 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" -framework Accelerate"
      CONFIGURE_POSTFIX+=" --enable-librubberband"
      ;;
    sdl)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags sdl2 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static sdl2 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-sdl2"
      ;;
    shine)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags shine 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static shine 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libshine"
      ;;
    snappy)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags snappy 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static snappy 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libsnappy"
      ;;
    soxr)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags soxr 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static soxr 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libsoxr"
      ;;
    speex)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags speex 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static speex 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libspeex"
      ;;
    srt)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags srt 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static srt 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libsrt"
      ;;
    tesseract)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags tesseract 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static tesseract 2>>"${BASEDIR}"/build.log)"
      FFMPEG_CFLAGS+=" $(pkg-config --cflags giflib 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static giflib 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libtesseract"
      ;;
    twolame)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags twolame 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static twolame 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libtwolame"
      ;;
    vo-amrwbenc)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags vo-amrwbenc 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static vo-amrwbenc 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libvo-amrwbenc"
      ;;
    x264)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags x264 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static x264 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libx264"
      ;;
    x265)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags x265 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static x265 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libx265"
      ;;
    xvidcore)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags xvidcore 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static xvidcore 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libxvid"
      ;;
    zimg)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags zimg 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static zimg 2>>"${BASEDIR}"/build.log)"
      CONFIGURE_POSTFIX+=" --enable-libzimg"
      ;;
    expat)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags expat 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static expat 2>>"${BASEDIR}"/build.log)"
      HIGH_PRIORITY_LDFLAGS+=" $(pkg-config --libs --static expat 2>>"${BASEDIR}"/build.log)"
      ;;
    libogg)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags ogg 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static ogg 2>>"${BASEDIR}"/build.log)"
      ;;
    libpng)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags libpng 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static libpng 2>>"${BASEDIR}"/build.log)"
      ;;
    nettle)
      FFMPEG_CFLAGS+=" $(pkg-config --cflags nettle 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static nettle 2>>"${BASEDIR}"/build.log)"
      FFMPEG_CFLAGS+=" $(pkg-config --cflags hogweed 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static hogweed 2>>"${BASEDIR}"/build.log)"
      ;;
    ios-* | tvos-* | macos-*)

      # BUILT-IN LIBRARIES SHARE INCLUDE AND LIB DIRECTORIES
      # INCLUDING ONLY ONE OF THEM IS ENOUGH
      FFMPEG_CFLAGS+=" $(pkg-config --cflags zlib 2>>"${BASEDIR}"/build.log)"
      FFMPEG_LDFLAGS+=" $(pkg-config --libs --static zlib 2>>"${BASEDIR}"/build.log)"

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
        FFMPEG_CFLAGS+=" $(pkg-config --cflags bzip2 2>>"${BASEDIR}"/build.log)"
        FFMPEG_LDFLAGS+=" $(pkg-config --libs bzip2 2>>"${BASEDIR}"/build.log)"
        ;;
      *-coreimage)
        CONFIGURE_POSTFIX+=" --enable-coreimage --enable-appkit"
        ;;
      *-libiconv)
        CONFIGURE_POSTFIX+=" --enable-iconv"
        FFMPEG_CFLAGS+=" $(pkg-config --cflags libiconv 2>>"${BASEDIR}"/build.log)"
        FFMPEG_LDFLAGS+=" $(pkg-config --libs libiconv 2>>"${BASEDIR}"/build.log)"
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
        FFMPEG_CFLAGS+=" $(pkg-config --cflags zlib 2>>"${BASEDIR}"/build.log)"
        FFMPEG_LDFLAGS+=" $(pkg-config --libs zlib 2>>"${BASEDIR}"/build.log)"
        ;;
      esac
      ;;
    esac
  else

    # THE FOLLOWING LIBRARIES SHOULD BE EXPLICITLY DISABLED TO PREVENT AUTODETECT
    # NOTE THAT IDS MUST BE +1 OF THE INDEX VALUE
    if [[ ${library} -eq ${LIBRARY_SDL} ]]; then
      CONFIGURE_POSTFIX+=" --disable-sdl2"
    elif [[ ${library} -eq ${LIBRARY_APPLE_AUDIOTOOLBOX} ]]; then
      CONFIGURE_POSTFIX+=" --disable-audiotoolbox"
    elif [[ ${library} -eq ${LIBRARY_APPLE_AVFOUNDATION} ]]; then
      CONFIGURE_POSTFIX+=" --disable-avfoundation"
    elif [[ ${library} -eq ${LIBRARY_APPLE_BZIP2} ]]; then
      CONFIGURE_POSTFIX+=" --disable-bzlib"
    elif [[ ${library} -eq ${LIBRARY_APPLE_COREIMAGE} ]]; then
      CONFIGURE_POSTFIX+=" --disable-coreimage --disable-appkit"
    elif [[ ${library} -eq ${LIBRARY_APPLE_LIBICONV} ]]; then
      CONFIGURE_POSTFIX+=" --disable-iconv"
    elif [[ ${library} -eq ${LIBRARY_APPLE_OPENCL} ]]; then
      CONFIGURE_POSTFIX+=" --disable-opencl"
    elif [[ ${library} -eq ${LIBRARY_APPLE_OPENGL} ]]; then
      CONFIGURE_POSTFIX+=" --disable-opengl"
    elif [[ ${library} -eq ${LIBRARY_APPLE_VIDEOTOOLBOX} ]]; then
      CONFIGURE_POSTFIX+=" --disable-videotoolbox"
    elif [[ ${library} -eq ${LIBRARY_SYSTEM_ZLIB} ]]; then
      CONFIGURE_POSTFIX+=" --disable-zlib"
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

  FFMPEG_CFLAGS+=" $(pkg-config --cflags ${!pc_file_name} 2>>"${BASEDIR}"/build.log)"
  FFMPEG_LDFLAGS+=" $(pkg-config --libs --static ${!pc_file_name} 2>>"${BASEDIR}"/build.log)"
  CONFIGURE_POSTFIX+=" --enable-${!ffmpeg_flag_name}"
done

# SET ENABLE GPL FLAG WHEN REQUESTED
if [ "$GPL_ENABLED" == "yes" ]; then
  CONFIGURE_POSTFIX+=" --enable-gpl"
fi

# ALWAYS BUILD SHARED LIBRARIES
BUILD_LIBRARY_OPTIONS="--enable-shared --disable-static --install-name-dir=@rpath"

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

# UPDATE BUILD FLAGS
export CFLAGS="${ARCH_CFLAGS} ${APP_CFLAGS} ${COMMON_CFLAGS} ${OPTIMIZATION_CFLAGS} ${MIN_VERSION_CFLAGS}${FFMPEG_CFLAGS} ${COMMON_INCLUDES}"
export CXXFLAGS=$(get_cxxflags "${LIB_NAME}")
export LDFLAGS="${ARCH_LDFLAGS}${HIGH_PRIORITY_LDFLAGS}${FFMPEG_LDFLAGS} ${LINKED_LIBRARIES} ${COMMON_LDFLAGS} ${BITCODE_FLAGS} ${OPTIMIZATION_FLAGS}"

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

########################### CUSTOMIZATIONS #######################
git checkout libavformat/file.c 1>>"${BASEDIR}"/build.log 2>&1
git checkout libavformat/protocols.c 1>>"${BASEDIR}"/build.log 2>&1
git checkout libavutil 1>>"${BASEDIR}"/build.log 2>&1

# 1. Workaround to prevent adding of -mdynamic-no-pic flag
${SED_INLINE} 's/check_cflags -mdynamic-no-pic && add_asflags -mdynamic-no-pic;/check_cflags -mdynamic-no-pic;/g' ./configure 1>>"${BASEDIR}"/build.log 2>&1 || return 1

# 2. Workaround for videotoolbox on mac catalyst
if [[ ${ARCH} == *-mac-catalyst ]]; then
  ${SED_INLINE} 's/    CFDictionarySetValue(buffer_attributes\, kCVPixelBufferOpenGLESCompatibilityKey/   \/\/ CFDictionarySetValue(buffer_attributes\, kCVPixelBufferOpenGLESCompatibilityKey/g' "${BASEDIR}"/src/${LIB_NAME}/libavcodec/videotoolbox.c || return 1
else
  ${SED_INLINE} 's/   \/\/ CFDictionarySetValue(buffer_attributes\, kCVPixelBufferOpenGLESCompatibilityKey/    CFDictionarySetValue(buffer_attributes\, kCVPixelBufferOpenGLESCompatibilityKey/g' "${BASEDIR}"/src/${LIB_NAME}/libavcodec/videotoolbox.c || return 1
fi

# 3. Use thread local log levels
${SED_INLINE} 's/static int av_log_level/__thread int av_log_level/g' "${BASEDIR}"/src/${LIB_NAME}/libavutil/log.c 1>>"${BASEDIR}"/build.log 2>&1 || return 1

###################################################################

./configure \
  --cross-prefix="${HOST}-" \
  --sysroot="${SDK_PATH}" \
  --prefix="${FFMPEG_LIBRARY_PATH}" \
  --pkg-config="${HOST_PKG_CONFIG_PATH}" \
  --enable-version3 \
  --arch="${TARGET_ARCH}" \
  --cpu="${TARGET_CPU}" \
  --target-os=darwin \
  ${ASM_OPTIONS} \
  --ar="${AR}" \
  --cc="${CC}" \
  --cxx="${CXX}" \
  --as="${AS}" \
  --ranlib="${RANLIB}" \
  --strip="${STRIP}" \
  --nm="${NM}" \
  --extra-ldflags="$(get_min_version_cflags)" \
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

build_ffmpeg() {
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
}

install_ffmpeg() {

  if [[ -n $1 ]]; then

    # DELETE THE PREVIOUS BUILD
    if [ -d "${FFMPEG_LIBRARY_PATH}" ]; then
      rm -rf "${FFMPEG_LIBRARY_PATH}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
    fi
  else

    # LEAVE EVERYTHING EXCEPT frameworks
    rm -rf "${FFMPEG_LIBRARY_PATH}/include" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
    rm -rf "${FFMPEG_LIBRARY_PATH}/lib" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
    rm -rf "${FFMPEG_LIBRARY_PATH}/share" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
  fi
  make install 1>>"${BASEDIR}"/build.log 2>&1

  if [[ $? -ne 0 ]]; then
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi
}

${SED_INLINE} 's|$(SLIBNAME_WITH_MAJOR),|$(SLIBPREF)$(FULLNAME).framework/$(SLIBPREF)$(FULLNAME),|g' ${BASEDIR}/src/ffmpeg/ffbuild/config.mak 1>>"${BASEDIR}"/build.log 2>&1 || return 1

# BUILD DYNAMIC LIBRARIES WITH DEFAULT OPTIONS
build_ffmpeg
install_ffmpeg "true"

# CLEAN THE OUTPUT OF FIRST BUILD
find . -name "*.dylib" -delete 1>>"${BASEDIR}"/build.log 2>&1

echo -e "\nShared libraries built successfully. Building frameworks.\n" 1>>"${BASEDIR}"/build.log 2>&1

create_temporary_framework() {
  local FRAMEWORK_NAME="$1"
  mkdir -p "${FFMPEG_LIBRARY_PATH}/framework/${FRAMEWORK_NAME}.framework" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
  cp "${FFMPEG_LIBRARY_PATH}/lib/${FRAMEWORK_NAME}.dylib" "${FFMPEG_LIBRARY_PATH}/framework/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
}

create_temporary_framework "libavcodec"
create_temporary_framework "libavdevice"
create_temporary_framework "libavfilter"
create_temporary_framework "libavformat"
create_temporary_framework "libavutil"
create_temporary_framework "libswresample"
create_temporary_framework "libswscale"

${SED_INLINE} 's|$(SLIBNAME_WITH_MAJOR),|$(SLIBPREF)$(FULLNAME).framework/$(SLIBPREF)$(FULLNAME),|g' ${BASEDIR}/src/ffmpeg/ffbuild/config.mak 1>>"${BASEDIR}"/build.log 2>&1 || return 1
${SED_INLINE} 's|$(LD_LIB)|-framework lib% |g' ${BASEDIR}/src/ffmpeg/ffbuild/common.mak 1>>"${BASEDIR}"/build.log 2>&1 || return 1
${SED_INLINE} "s|\$(LD_PATH)lib%|-F ${FFMPEG_LIBRARY_PATH}/framework|g" ${BASEDIR}/src/ffmpeg/ffbuild/common.mak 1>>"${BASEDIR}"/build.log 2>&1 || return 1

# BUILD FRAMEWORKS AS DYNAMIC LIBRARIES
build_ffmpeg
install_ffmpeg

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
