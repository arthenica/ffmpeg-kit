#!/bin/bash

# DIRECTORY DEFINITIONS
export FFMPEG_KIT_TMPDIR="${BASEDIR}/.tmp"

# ARCH INDEXES
ARCH_ARM_V7A=0              # android
ARCH_ARM_V7A_NEON=1         # android
ARCH_ARMV7=2                # ios
ARCH_ARMV7S=3               # ios
ARCH_ARM64_V8A=4            # android
ARCH_ARM64=5                # ios, tvos
ARCH_ARM64E=6               # ios
ARCH_I386=7                 # ios
ARCH_X86=8                  # android
ARCH_X86_64=9               # android, ios, tvos
ARCH_X86_64_MAC_CATALYST=10 # ios

# LIBRARY INDEXES
LIBRARY_FONTCONFIG=0
LIBRARY_FREETYPE=1
LIBRARY_FRIBIDI=2
LIBRARY_GMP=3
LIBRARY_GNUTLS=4
LIBRARY_LAME=5
LIBRARY_LIBASS=6
LIBRARY_LIBICONV=7
LIBRARY_LIBTHEORA=8
LIBRARY_LIBVORBIS=9
LIBRARY_LIBVPX=10
LIBRARY_LIBWEBP=11
LIBRARY_LIBXML2=12
LIBRARY_OPENCOREAMR=13
LIBRARY_SHINE=14
LIBRARY_SPEEX=15
LIBRARY_WAVPACK=16
LIBRARY_KVAZAAR=17
LIBRARY_X264=18
LIBRARY_XVIDCORE=19
LIBRARY_X265=20
LIBRARY_LIBVIDSTAB=21
LIBRARY_RUBBERBAND=22
LIBRARY_LIBILBC=23
LIBRARY_OPUS=24
LIBRARY_SNAPPY=25
LIBRARY_SOXR=26
LIBRARY_LIBAOM=27
LIBRARY_CHROMAPRINT=28
LIBRARY_TWOLAME=29
LIBRARY_SDL=30
LIBRARY_TESSERACT=31
LIBRARY_OPENH264=32
LIBRARY_VO_AMRWBENC=33
LIBRARY_GIFLIB=34
LIBRARY_JPEG=35
LIBRARY_LIBOGG=36
LIBRARY_LIBPNG=37
LIBRARY_LIBUUID=38
LIBRARY_NETTLE=39
LIBRARY_TIFF=40
LIBRARY_EXPAT=41
LIBRARY_SNDFILE=42
LIBRARY_LEPTONICA=43
LIBRARY_LIBSAMPLERATE=44
LIBRARY_CPU_FEATURES=45
LIBRARY_ANDROID_ZLIB=46
LIBRARY_ANDROID_MEDIA_CODEC=47
LIBRARY_IOS_ZLIB=48
LIBRARY_IOS_AUDIOTOOLBOX=49
LIBRARY_IOS_BZIP2=50
LIBRARY_IOS_VIDEOTOOLBOX=51
LIBRARY_IOS_AVFOUNDATION=52
LIBRARY_IOS_LIBICONV=53
LIBRARY_IOS_LIBUUID=54
LIBRARY_TVOS_ZLIB=55
LIBRARY_TVOS_AUDIOTOOLBOX=56
LIBRARY_TVOS_BZIP2=57
LIBRARY_TVOS_VIDEOTOOLBOX=58
LIBRARY_TVOS_LIBICONV=59
LIBRARY_TVOS_LIBUUID=60

get_library_name() {
  case $1 in
  0) echo "fontconfig" ;;
  1) echo "freetype" ;;
  2) echo "fribidi" ;;
  3) echo "gmp" ;;
  4) echo "gnutls" ;;
  5) echo "lame" ;;
  6) echo "libass" ;;
  7) echo "libiconv" ;;
  8) echo "libtheora" ;;
  9) echo "libvorbis" ;;
  10) echo "libvpx" ;;
  11) echo "libwebp" ;;
  12) echo "libxml2" ;;
  13) echo "opencore-amr" ;;
  14) echo "shine" ;;
  15) echo "speex" ;;
  16) echo "wavpack" ;;
  17) echo "kvazaar" ;;
  18) echo "x264" ;;
  19) echo "xvidcore" ;;
  20) echo "x265" ;;
  21) echo "libvidstab" ;;
  22) echo "rubberband" ;;
  23) echo "libilbc" ;;
  24) echo "opus" ;;
  25) echo "snappy" ;;
  26) echo "soxr" ;;
  27) echo "libaom" ;;
  28) echo "chromaprint" ;;
  29) echo "twolame" ;;
  30) echo "sdl" ;;
  31) echo "tesseract" ;;
  32) echo "openh264" ;;
  33) echo "vo-amrwbenc" ;;
  34) echo "giflib" ;;
  35) echo "jpeg" ;;
  36) echo "libogg" ;;
  37) echo "libpng" ;;
  38) echo "libuuid" ;;
  39) echo "nettle" ;;
  40) echo "tiff" ;;
  41) echo "expat" ;;
  42) echo "libsndfile" ;;
  43) echo "leptonica" ;;
  44) echo "libsamplerate" ;;
  45) echo "cpu-features" ;;
  46) echo "android-zlib" ;;
  47) echo "android-media-codec" ;;
  48) echo "ios-zlib" ;;
  49) echo "ios-audiotoolbox" ;;
  50) echo "ios-bzip2" ;;
  51) echo "ios-videotoolbox" ;;
  52) echo "ios-avfoundation" ;;
  53) echo "ios-libiconv" ;;
  54) echo "ios-libuuid" ;;
  55) echo "tvos-zlib" ;;
  56) echo "tvos-audiotoolbox" ;;
  57) echo "tvos-bzip2" ;;
  58) echo "tvos-videotoolbox" ;;
  59) echo "tvos-libiconv" ;;
  60) echo "tvos-libuuid" ;;
  esac
}

#
# 1. <library index>
#
is_library_supported_on_platform() {
  case $1 in
  0 | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20)
    echo "1"
    ;;
  21 | 22 | 23 | 24 | 25 | 26 | 27 | 28 | 29 | 30 | 31 | 32 | 33 | 34 | 35 | 36 | 37 | 39 | 40)
    echo "1"
    ;;
  41 | 42 | 43 | 44)
    echo "1"
    ;;

  # ANDROID
  7 | 38 | 45 | 46 | 47)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]]; then
      echo "1"
    else
      echo "0"
    fi
    ;;

  # IOS
  48 | 49 | 50 | 51 | 52 | 53 | 54)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "1"
    else
      echo "0"
    fi
    ;;

  # TVOS
  55 | 56 | 57 | 58 | 59 | 60)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "1"
    else
      echo "0"
    fi
    ;;
  *)
    echo "0"
    ;;
  esac
}

#
# 1. <library index>
#
is_arch_supported_on_platform() {
  case $1 in
  ARCH_X86_64)
    echo "1"
    ;;

  # ANDROID
  ARCH_ARM_V7A | ARCH_ARM_V7A_NEON | ARCH_ARM64_V8A | ARCH_X86)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]]; then
      echo "1"
    else
      echo "0"
    fi
    ;;

  # IOS
  ARCH_ARMV7 | ARCH_ARMV7S | ARCH_ARM64E | ARCH_I386 | ARCH_X86_64_MAC_CATALYST)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "1"
    else
      echo "0"
    fi
    ;;

  # IOS OR TVOS
  ARCH_ARM64)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "1"
    else
      echo "0"
    fi
    ;;
  *)
    echo "0"
    ;;
  esac
}

get_arch_name() {
  case $1 in
  0) echo "arm-v7a" ;; # android
  1) echo "arm-v7a-neon" ;; # android
  2) echo "armv7" ;; # ios
  3) echo "armv7s" ;; # ios
  4) echo "arm64-v8a" ;; # android
  5) echo "arm64" ;; # ios, tvos
  6) echo "arm64e" ;; # ios
  7) echo "i386" ;; # ios
  8) echo "x86" ;; # android
  9) echo "x86-64" ;; # android, ios, tvos
  10) echo "x86-64-mac-catalyst" ;; # ios
  esac
}

get_package_config_file_name() {
  case $1 in
  1) echo "freetype2" ;;
  5) echo "libmp3lame" ;;
  8) echo "theora" ;;
  9) echo "vorbis" ;;
  10) echo "vpx" ;;
  12) echo "libxml-2.0" ;;
  13) echo "opencore-amrnb" ;;
  21) echo "vidstab" ;;
  27) echo "aom" ;;
  28) echo "libchromaprint" ;;
  30) echo "sdl2" ;;
  35) echo "libjpeg" ;;
  36) echo "ogg" ;;
  40) echo "libtiff-4" ;;
  42) echo "sndfile" ;;
  43) echo "lept" ;;
  44) echo "samplerate" ;;
  54 | 60) echo "uuid" ;;
  *) echo "$(get_library_name "$1")" ;;
  esac
}

get_static_archive_name() {
  case $1 in
  5) echo "libmp3lame.a" ;;
  6) echo "libass.a" ;;
  10) echo "libvpx.a" ;;
  12) echo "libxml2.a" ;;
  21) echo "libvidstab.a" ;;
  23) echo "libilbc.a" ;;
  27) echo "libaom.a" ;;
  29) echo "libtwolame.a" ;;
  30) echo "libSDL2.a" ;;
  31) echo "libtesseract.a" ;;
  34) echo "libgif.a" ;;
  36) echo "libogg.a" ;;
  37) echo "libpng.a" ;;
  42) echo "libsndfile.a" ;;
  43) echo "liblept.a" ;;
  44) echo "libsamplerate.a" ;;
  *) echo lib"$(get_library_name "$1")".a ;;
  esac
}

get_build_host() {
  case ${ARCH} in
  arm-v7a | arm-v7a-neon)
    echo "arm-linux-androideabi"
    ;;
  armv7 | armv7s | arm64e | i386 | x86-64-mac-catalyst)
    echo "$(get_target_arch)-ios-darwin"
    ;;
  arm64-v8a)
    echo "aarch64-linux-android"
    ;;
  arm64)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "$(get_target_arch)-ios-darwin"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "$(get_target_arch)-tvos-darwin"
    fi
    ;;
  x86)
    echo "i686-linux-android"
    ;;
  x86-64)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]]; then
      echo "x86_64-linux-android"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "$(get_target_arch)-ios-darwin"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "$(get_target_arch)-tvos-darwin"
    fi
    ;;
  esac
}

skip_library() {
  SKIP_VARIABLE=$(echo "SKIP_$1" | sed "s/\-/\_/g")

  export ${SKIP_VARIABLE}=1
}

no_output_redirection() {
  export NO_OUTPUT_REDIRECTION=1
}

no_workspace_cleanup_library() {
  NO_WORKSPACE_CLEANUP_VARIABLE=$(echo "NO_WORKSPACE_CLEANUP_$1" | sed "s/\-/\_/g")

  export ${NO_WORKSPACE_CLEANUP_VARIABLE}=1
}

no_link_time_optimization() {
  export NO_LINK_TIME_OPTIMIZATION=1
}

enable_debug() {
  export FFMPEG_KIT_DEBUG="-g"

  BUILD_TYPE_ID+="debug "
}

optimize_for_speed() {
  export FFMPEG_KIT_OPTIMIZED_FOR_SPEED="1"
}

print_unknown_option() {
  echo -e "Unknown option \"$1\".\nSee $0 --help for available options."
  exit 1
}

print_unknown_library() {
  echo -e "Unknown library \"$1\".\nSee $0 --help for available libraries."
  exit 1
}

print_unknown_arch() {
  echo -e "Unknown architecture \"$1\".\nSee $0 --help for available architectures."
  exit 1
}

display_version() {
  COMMAND=$(echo $0 | sed -e 's/\.\///g')

  echo -e "\
$COMMAND v$(get_ffmpeg_kit_version)\n
Copyright (c) 2020 Taner Sener\n
License LGPLv3.0: GNU LGPL version 3 or later\n\
<https://www.gnu.org/licenses/lgpl-3.0.en.html>\n\
This is free software: you can redistribute it and/or modify it under the terms of the \
GNU Lesser General Public License as published by the Free Software Foundation, \
either version 3 of the License, or (at your option) any later version."
}

display_help_options() {
  echo -e "Options:"
  echo -e "  -h, --help\t\t\tdisplay this help and exit"
  echo -e "  -v, --version\t\t\tdisplay version information and exit"
  echo -e "  -d, --debug\t\t\tbuild with debug information"
  echo -e "  -s, --speed\t\t\toptimize for speed instead of size"
  echo -e "  -l, --lts\t\t\tbuild lts packages to support API 16+ devices"
  echo -e "  -f, --force\t\t\tignore warnings"
  if [ -n "$1" ]; then
    echo -e "$1"
  fi
  echo -e ""
}

display_help_licensing() {
  echo -e "Licensing options:"
  echo -e "  --enable-gpl\t\t\tallow use of GPL libraries, created libs will be licensed under GPLv3.0 [no]\n"
}

display_help_common_libraries() {
  echo -e "  --enable-chromaprint\t\tbuild with chromaprint [no]"
  echo -e "  --enable-fontconfig\t\tbuild with fontconfig [no]"
  echo -e "  --enable-freetype\t\tbuild with freetype [no]"
  echo -e "  --enable-fribidi\t\tbuild with fribidi [no]"
  echo -e "  --enable-gmp\t\t\tbuild with gmp [no]"
  echo -e "  --enable-gnutls\t\tbuild with gnutls [no]"
  echo -e "  --enable-kvazaar\t\tbuild with kvazaar [no]"
  echo -e "  --enable-lame\t\t\tbuild with lame [no]"
  echo -e "  --enable-libaom\t\tbuild with libaom [no]"
  echo -e "  --enable-libass\t\tbuild with libass [no]"
  echo -e "  --enable-libiconv\t\tbuild with libiconv [no]"
  echo -e "  --enable-libilbc\t\tbuild with libilbc [no]"
  echo -e "  --enable-libtheora\t\tbuild with libtheora [no]"
  echo -e "  --enable-libvorbis\t\tbuild with libvorbis [no]"
  echo -e "  --enable-libvpx\t\tbuild with libvpx [no]"
  echo -e "  --enable-libwebp\t\tbuild with libwebp [no]"
  echo -e "  --enable-libxml2\t\tbuild with libxml2 [no]"
  echo -e "  --enable-opencore-amr\t\tbuild with opencore-amr [no]"
  echo -e "  --enable-openh264\t\tbuild with openh264 [no]"
  echo -e "  --enable-opus\t\t\tbuild with opus [no]"
  echo -e "  --enable-sdl\t\t\tbuild with sdl [no]"
  echo -e "  --enable-shine\t\tbuild with shine [no]"
  echo -e "  --enable-snappy\t\tbuild with snappy [no]"
  echo -e "  --enable-soxr\t\t\tbuild with soxr [no]"
  echo -e "  --enable-speex\t\tbuild with speex [no]"
  echo -e "  --enable-tesseract\t\tbuild with tesseract [no]"
  echo -e "  --enable-twolame\t\tbuild with twolame [no]"
  echo -e "  --enable-vo-amrwbenc\t\tbuild with vo-amrwbenc [no]"
  echo -e "  --enable-wavpack\t\tbuild with wavpack [no]\n"
}

display_help_gpl_libraries() {
  echo -e "GPL libraries:"
  echo -e "  --enable-libvidstab\t\tbuild with libvidstab [no]"
  echo -e "  --enable-rubberband\t\tbuild with rubber band [no]"
  echo -e "  --enable-x264\t\t\tbuild with x264 [no]"
  echo -e "  --enable-x265\t\t\tbuild with x265 [no]"
  echo -e "  --enable-xvidcore\t\tbuild with xvidcore [no]\n"
}

display_help_advanced_options() {
  echo -e "Advanced options:"
  echo -e "  --reconf-LIBRARY\t\trun autoreconf before building LIBRARY [no]"
  echo -e "  --redownload-LIBRARY\t\tdownload LIBRARY even if it is detected as already downloaded [no]"
  echo -e "  --rebuild-LIBRARY\t\tbuild LIBRARY even if it is detected as already built [no]\n"
}

#
# 1. <library name>
#
reconf_library() {
  local RECONF_VARIABLE=$(echo "RECONF_$1" | sed "s/\-/\_/g")
  local library_supported=0

  for library in {0..60}; do
    library_name=$(get_library_name ${library})
    local library_supported_on_platform=$(is_library_supported_on_platform ${library})

    if [[ $1 != "ffmpeg" ]] && [[ ${library_name} == $1 ]] && [[ ${library_supported_on_platform} -eq 1 ]]; then
      export ${RECONF_VARIABLE}=1
      RECONF_LIBRARIES+=($1)
      library_supported=1
    fi
  done

  if [[ ${library_supported} -eq 0 ]]; then
    echo -e "INFO: --reconf flag detected for library $1 is not supported.\n" 1>>${BASEDIR}/build.log 2>&1
  fi
}

#
# 1. <library name>
#
rebuild_library() {
  local REBUILD_VARIABLE=$(echo "REBUILD_$1" | sed "s/\-/\_/g")
  local library_supported=0

  for library in {0..45}; do
    library_name=$(get_library_name ${library})
    local library_supported_on_platform=$(is_library_supported_on_platform ${library})

    if [[ $1 != "ffmpeg" ]] && [[ ${library_name} == $1 ]] && [[ ${library_supported_on_platform} -eq 1 ]]; then
      export ${REBUILD_VARIABLE}=1
      REBUILD_LIBRARIES+=($1)
      library_supported=1
    fi
  done

  if [[ ${library_supported} -eq 0 ]]; then
    echo -e "INFO: --rebuild flag detected for library $1 is not supported.\n" 1>>${BASEDIR}/build.log 2>&1
  fi
}

#
# 1. <library name>
#
redownload_library() {
  local REDOWNLOAD_VARIABLE=$(echo "REDOWNLOAD_$1" | sed "s/\-/\_/g")
  local library_supported=0

  for library in {0..45}; do
    library_name=$(get_library_name ${library})
    local library_supported_on_platform=$(is_library_supported_on_platform ${library})

    if [[ ${library_name} == $1 ]] && [[ ${library_supported_on_platform} -eq 1 ]]; then
      export ${REDOWNLOAD_VARIABLE}=1
      REDOWNLOAD_LIBRARIES+=($1)
      library_supported=1
    fi
  done

  if [[ "ffmpeg" == $1 ]]; then
    export ${REDOWNLOAD_VARIABLE}=1
    REDOWNLOAD_LIBRARIES+=($1)
    library_supported=1
  fi

  if [[ ${library_supported} -eq 0 ]]; then
    echo -e "INFO: --redownload flag detected for library $1 is not supported.\n" 1>>${BASEDIR}/build.log 2>&1
  fi
}

enable_library() {
  local library_supported_on_platform=$(is_library_supported_on_platform $1)
  if [[ $library_supported_on_platform == "1" ]]; then
    set_library $1 1
  else
    print_unknown_library $1
  fi
}

set_library() {
  case $1 in
  android-zlib)
    ENABLED_LIBRARIES[LIBRARY_ANDROID_ZLIB]=$2
    ;;
  android-media-codec)
    ENABLED_LIBRARIES[LIBRARY_ANDROID_MEDIA_CODEC]=$2
    ;;
  ios-zlib)
    ENABLED_LIBRARIES[LIBRARY_IOS_ZLIB]=$2
    ;;
  ios-audiotoolbox)
    ENABLED_LIBRARIES[LIBRARY_IOS_AUDIOTOOLBOX]=$2
    ;;
  ios-bzip2)
    ENABLED_LIBRARIES[LIBRARY_IOS_BZIP2]=$2
    ;;
  ios-videotoolbox)
    ENABLED_LIBRARIES[LIBRARY_IOS_VIDEOTOOLBOX]=$2
    ;;
  ios-avfoundation)
    ENABLED_LIBRARIES[LIBRARY_IOS_AVFOUNDATION]=$2
    ;;
  ios-libiconv)
    ENABLED_LIBRARIES[LIBRARY_IOS_LIBICONV]=$2
    ;;
  ios-libuuid)
    ENABLED_LIBRARIES[LIBRARY_IOS_LIBUUID]=$2
    ;;
  tvos-zlib)
    ENABLED_LIBRARIES[LIBRARY_TVOS_ZLIB]=$2
    ;;
  tvos-audiotoolbox)
    ENABLED_LIBRARIES[LIBRARY_TVOS_AUDIOTOOLBOX]=$2
    ;;
  tvos-bzip2)
    ENABLED_LIBRARIES[LIBRARY_TVOS_BZIP2]=$2
    ;;
  tvos-videotoolbox)
    ENABLED_LIBRARIES[LIBRARY_TVOS_VIDEOTOOLBOX]=$2
    ;;
  tvos-libiconv)
    ENABLED_LIBRARIES[LIBRARY_TVOS_LIBICONV]=$2
    ;;
  tvos-libuuid)
    ENABLED_LIBRARIES[LIBRARY_TVOS_LIBUUID]=$2
    ;;
  chromaprint)
    ENABLED_LIBRARIES[LIBRARY_CHROMAPRINT]=$2
    ;;
  fontconfig)
    ENABLED_LIBRARIES[LIBRARY_FONTCONFIG]=$2
    ENABLED_LIBRARIES[LIBRARY_LIBUUID]=$2
    ENABLED_LIBRARIES[LIBRARY_EXPAT]=$2
    ENABLED_LIBRARIES[LIBRARY_LIBICONV]=$2
    set_library "freetype" $2
    ;;
  freetype)
    ENABLED_LIBRARIES[LIBRARY_FREETYPE]=$2
    ENABLED_LIBRARIES[LIBRARY_ZLIB]=$2
    set_library "libpng" $2
    ;;
  fribidi)
    ENABLED_LIBRARIES[LIBRARY_FRIBIDI]=$2
    ;;
  gmp)
    ENABLED_LIBRARIES[LIBRARY_GMP]=$2
    ;;
  gnutls)
    ENABLED_LIBRARIES[LIBRARY_GNUTLS]=$2
    ENABLED_LIBRARIES[LIBRARY_ZLIB]=$2
    set_library "nettle" $2
    set_library "gmp" $2
    set_library "libiconv" $2
    ;;
  kvazaar)
    ENABLED_LIBRARIES[LIBRARY_KVAZAAR]=$2
    ;;
  lame)
    ENABLED_LIBRARIES[LIBRARY_LAME]=$2
    set_library "libiconv" $2
    ;;
  libaom)
    ENABLED_LIBRARIES[LIBRARY_LIBAOM]=$2
    ;;
  libass)
    ENABLED_LIBRARIES[LIBRARY_LIBASS]=$2
    ENABLED_LIBRARIES[LIBRARY_LIBUUID]=$2
    ENABLED_LIBRARIES[LIBRARY_EXPAT]=$2
    set_library "freetype" $2
    set_library "fribidi" $2
    set_library "fontconfig" $2
    set_library "libiconv" $2
    ;;
  libiconv)
    ENABLED_LIBRARIES[LIBRARY_LIBICONV]=$2
    ;;
  libilbc)
    ENABLED_LIBRARIES[LIBRARY_LIBILBC]=$2
    ;;
  libpng)
    ENABLED_LIBRARIES[LIBRARY_LIBPNG]=$2
    ENABLED_LIBRARIES[LIBRARY_ZLIB]=$2
    ;;
  libtheora)
    ENABLED_LIBRARIES[LIBRARY_LIBTHEORA]=$2
    ENABLED_LIBRARIES[LIBRARY_LIBOGG]=$2
    set_library "libvorbis" $2
    ;;
  libvidstab)
    ENABLED_LIBRARIES[LIBRARY_LIBVIDSTAB]=$2
    ;;
  libvorbis)
    ENABLED_LIBRARIES[LIBRARY_LIBVORBIS]=$2
    ENABLED_LIBRARIES[LIBRARY_LIBOGG]=$2
    ;;
  libvpx)
    ENABLED_LIBRARIES[LIBRARY_LIBVPX]=$2
    ;;
  libwebp)
    ENABLED_LIBRARIES[LIBRARY_LIBWEBP]=$2
    ENABLED_LIBRARIES[LIBRARY_GIFLIB]=$2
    ENABLED_LIBRARIES[LIBRARY_JPEG]=$2
    set_library "tiff" $2
    set_library "libpng" $2
    ;;
  libxml2)
    ENABLED_LIBRARIES[LIBRARY_LIBXML2]=$2
    set_library "libiconv" $2
    ;;
  opencore-amr)
    ENABLED_LIBRARIES[LIBRARY_OPENCOREAMR]=$2
    ;;
  openh264)
    ENABLED_LIBRARIES[LIBRARY_OPENH264]=$2
    ;;
  opus)
    ENABLED_LIBRARIES[LIBRARY_OPUS]=$2
    ;;
  rubberband)
    ENABLED_LIBRARIES[LIBRARY_RUBBERBAND]=$2
    ENABLED_LIBRARIES[LIBRARY_SNDFILE]=$2
    ENABLED_LIBRARIES[LIBRARY_LIBSAMPLERATE]=$2
    ;;
  sdl)
    ENABLED_LIBRARIES[LIBRARY_SDL]=$2
    ;;
  shine)
    ENABLED_LIBRARIES[LIBRARY_SHINE]=$2
    ;;
  snappy)
    ENABLED_LIBRARIES[LIBRARY_SNAPPY]=$2
    ENABLED_LIBRARIES[LIBRARY_ZLIB]=$2
    ;;
  soxr)
    ENABLED_LIBRARIES[LIBRARY_SOXR]=$2
    ;;
  speex)
    ENABLED_LIBRARIES[LIBRARY_SPEEX]=$2
    ;;
  tesseract)
    ENABLED_LIBRARIES[LIBRARY_TESSERACT]=$2
    ENABLED_LIBRARIES[LIBRARY_LEPTONICA]=$2
    ENABLED_LIBRARIES[LIBRARY_LIBWEBP]=$2
    ENABLED_LIBRARIES[LIBRARY_GIFLIB]=$2
    ENABLED_LIBRARIES[LIBRARY_JPEG]=$2
    ENABLED_LIBRARIES[LIBRARY_ZLIB]=$2
    set_library "tiff" $2
    set_library "libpng" $2
    ;;
  twolame)
    ENABLED_LIBRARIES[LIBRARY_TWOLAME]=$2
    ENABLED_LIBRARIES[LIBRARY_SNDFILE]=$2
    ;;
  vo-amrwbenc)
    ENABLED_LIBRARIES[LIBRARY_VO_AMRWBENC]=$2
    ;;
  wavpack)
    ENABLED_LIBRARIES[LIBRARY_WAVPACK]=$2
    ;;
  x264)
    ENABLED_LIBRARIES[LIBRARY_X264]=$2
    ;;
  x265)
    ENABLED_LIBRARIES[LIBRARY_X265]=$2
    ;;
  xvidcore)
    ENABLED_LIBRARIES[LIBRARY_XVIDCORE]=$2
    ;;
  expat | giflib | jpeg | leptonica | libogg | libsamplerate | libsndfile | libuuid)
    # THESE LIBRARIES ARE NOT ENABLED DIRECTLY
    ;;
  nettle)
    ENABLED_LIBRARIES[LIBRARY_NETTLE]=$2
    set_library "gmp" $2
    ;;
  tiff)
    ENABLED_LIBRARIES[LIBRARY_TIFF]=$2
    ENABLED_LIBRARIES[LIBRARY_JPEG]=$2
    ;;
  *)
    print_unknown_library $1
    ;;
  esac
}

disable_arch() {
  local arch_supported_on_platform=$(is_arch_supported_on_platform $1)
  if [[ $arch_supported_on_platform == "1" ]]; then
    set_arch $1 0
  else
    print_unknown_arch $1
  fi
}

set_arch() {
  case $1 in
  arm-v7a)
    ENABLED_ARCHITECTURES[ARCH_ARM_V7A]=$2
    ;;
  arm-v7a-neon)
    ENABLED_ARCHITECTURES[ARCH_ARM_V7A_NEON]=$2
    ;;
  armv7)
    ENABLED_ARCHITECTURES[ARCH_ARMV7]=$2
    ;;
  armv7s)
    ENABLED_ARCHITECTURES[ARCH_ARMV7S]=$2
    ;;
  arm64-v8a)
    ENABLED_ARCHITECTURES[ARCH_ARM64_V8A]=$2
    ;;
  arm64)
    ENABLED_ARCHITECTURES[ARCH_ARM64]=$2
    ;;
  arm64e)
    ENABLED_ARCHITECTURES[ARCH_ARM64E]=$2
    ;;
  i386)
    ENABLED_ARCHITECTURES[ARCH_I386]=$2
    ;;
  x86)
    ENABLED_ARCHITECTURES[ARCH_X86]=$2
    ;;
  x86-64)
    ENABLED_ARCHITECTURES[ARCH_X86_64]=$2
    ;;
  x86-64-mac-catalyst)
    ENABLED_ARCHITECTURES[ARCH_X86_64_MAC_CATALYST]=$2
    ;;
  *)
    print_unknown_arch $1
    ;;
  esac
}

print_enabled_architectures() {
  echo -n "Architectures: "

  let enabled=0
  for print_arch in {0..10}; do
    if [[ ${ENABLED_ARCHITECTURES[$print_arch]} -eq 1 ]]; then
      if [[ ${enabled} -ge 1 ]]; then
        echo -n ", "
      fi
      echo -n $(get_arch_name $print_arch)
      enabled=$((${enabled} + 1))
    fi
  done

  if [ ${enabled} -gt 0 ]; then
    echo ""
  else
    echo "none"
  fi
}

print_enabled_libraries() {
  echo -n "Libraries: "

  let enabled=0

  for library in {48..60} {0..33}; do
    if [[ ${ENABLED_LIBRARIES[$library]} -eq 1 ]]; then
      if [[ ${enabled} -ge 1 ]]; then
        echo -n ", "
      fi
      echo -n $(get_library_name $library)
      enabled=$((${enabled} + 1))
    fi
  done

  if [ ${enabled} -gt 0 ]; then
    echo ""
  else
    echo "none"
  fi
}

print_reconfigure_requested_libraries() {
  local counter=0

  for RECONF_LIBRARY in "${RECONF_LIBRARIES[@]}"; do
    if [[ ${counter} -eq 0 ]]; then
      echo -n "Reconfigure: "
    else
      echo -n ", "
    fi

    echo -n ${RECONF_LIBRARY}

    counter=$((${counter} + 1))
  done

  if [[ ${counter} -gt 0 ]]; then
    echo ""
  fi
}

print_rebuild_requested_libraries() {
  local counter=0

  for REBUILD_LIBRARY in "${REBUILD_LIBRARIES[@]}"; do
    if [[ ${counter} -eq 0 ]]; then
      echo -n "Rebuild: "
    else
      echo -n ", "
    fi

    echo -n ${REBUILD_LIBRARY}

    counter=$((${counter} + 1))
  done

  if [[ ${counter} -gt 0 ]]; then
    echo ""
  fi
}

print_redownload_requested_libraries() {
  local counter=0

  for REDOWNLOAD_LIBRARY in "${REDOWNLOAD_LIBRARIES[@]}"; do
    if [[ ${counter} -eq 0 ]]; then
      echo -n "Redownload: "
    else
      echo -n ", "
    fi

    echo -n ${REDOWNLOAD_LIBRARY}

    counter=$((${counter} + 1))
  done

  if [[ ${counter} -gt 0 ]]; then
    echo ""
  fi
}

build_modulemap() {
  local FILE_PATH="$1"

  cat >"${FILE_PATH}" <<EOF
framework module ffmpegkit {

  header "ArchDetect.h"
  header "AtomicLong.h"
  header "ExecuteDelegate.h"
  header "FFmpegExecution.h"
  header "LogDelegate.h"
  header "MediaInformation.h"
  header "MediaInformationParser.h"
  header "FFmpegKit.h"
  header "FFmpegKitConfig.h"
  header "FFprobeKit.h"
  header "Statistics.h"
  header "StatisticsDelegate.h"
  header "StreamInformation.h"
  header "ffmpegkit_exception.h"

  export *
}
EOF
}

build_info_plist() {
  local FILE_PATH="$1"
  local FRAMEWORK_NAME="$2"
  local FRAMEWORK_ID="$3"
  local FRAMEWORK_SHORT_VERSION="$4"
  local FRAMEWORK_VERSION="$5"

  cat >${FILE_PATH} <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>${FRAMEWORK_NAME}</string>
	<key>CFBundleIdentifier</key>
	<string>${FRAMEWORK_ID}</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>${FRAMEWORK_NAME}</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>${FRAMEWORK_SHORT_VERSION}</string>
	<key>CFBundleVersion</key>
	<string>${FRAMEWORK_VERSION}</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>MinimumOSVersion</key>
	<string>$6</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>$7</string>
	</array>
	<key>NSPrincipalClass</key>
	<string></string>
</dict>
</plist>
EOF
}

# 1 - library name
# 2 - static library name
# 3 - library version
create_static_framework() {
  local FRAMEWORK_PATH=${BASEDIR}/prebuilt/ios-framework/$1.framework

  mkdir -p "${FRAMEWORK_PATH}" 1>>"${BASEDIR}/build.log" 2>&1 || exit 1

  local CAPITAL_CASE_LIBRARY_NAME=$(to_capital_case "$1")

  build_info_plist "${FRAMEWORK_PATH}/Info.plist" "${FFMPEG_LIB}" "com.arthenica.ffmpegkit.${CAPITAL_CASE_LIBRARY_NAME}" "$3" "$3"

  cp "${BASEDIR}/prebuilt/ios-universal/$1-universal/lib/$2" "${FRAMEWORK_PATH}/$1" 1>>"${BASEDIR}/build.log" 2>&1

  echo "$?"
}

# 1 - library index
get_external_library_license_path() {
  case $1 in
  1) echo "${BASEDIR}/src/$(get_library_name "$1")/docs/LICENSE.TXT" ;;
  3) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYING.LESSERv3" ;;
  25) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYING.LGPL" ;;
  27) echo "${BASEDIR}/src/$(get_library_name "$1")/LICENSE.md" ;;
  29) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYING.txt" ;;
  34) echo "${BASEDIR}/src/$(get_library_name "$1")/LICENSE.md " ;;
  37) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYING.LESSERv3" ;;
  38) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYRIGHT" ;;
  41) echo "${BASEDIR}/src/$(get_library_name "$1")/leptonica-license.txt" ;;
  4 | 9 | 12 | 18 | 20 | 26 | 31 | 36) echo "${BASEDIR}/src/$(get_library_name "$1")/LICENSE" ;;
  *) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYING" ;;
  esac
}

#
# 1. <library name>
#
autoreconf_library() {
  echo -e "\nDEBUG: Running full autoreconf for $1\n" 1>>${BASEDIR}/build.log 2>&1

  # FORCE INSTALL
  (autoreconf --force --install)

  local EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    return
  fi

  echo -e "\nDEBUG: Full autoreconf failed. Running full autoreconf with include for $1\n" 1>>${BASEDIR}/build.log 2>&1

  # FORCE INSTALL WITH m4
  (autoreconf --force --install -I m4)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    return
  fi

  echo -e "\nDEBUG: Full autoreconf with include failed. Running autoreconf without force for $1\n" 1>>${BASEDIR}/build.log 2>&1

  # INSTALL WITHOUT FORCE
  (autoreconf --install)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    return
  fi

  echo -e "\nDEBUG: Autoreconf without force failed. Running autoreconf without force with include for $1\n" 1>>${BASEDIR}/build.log 2>&1

  # INSTALL WITHOUT FORCE WITH m4
  (autoreconf --install -I m4)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    return
  fi

  echo -e "\nDEBUG: Autoreconf without force with include failed. Running default autoreconf for $1\n" 1>>${BASEDIR}/build.log 2>&1

  # INSTALL DEFAULT
  (autoreconf)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    return
  fi

  echo -e "\nDEBUG: Default autoreconf failed. Running default autoreconf with include for $1\n" 1>>${BASEDIR}/build.log 2>&1

  # INSTALL DEFAULT WITH m4
  (autoreconf -I m4)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    return
  fi
}

#
# 1. <repo url>
# 2. <local folder path>
# 3. <commit id>
#
clone_git_repository_with_commit_id() {
  local RC

  (mkdir -p $2 1>>${BASEDIR}/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nDEBUG: Failed to create local directory $2\n" 1>>${BASEDIR}/build.log 2>&1
    rm -rf $2 1>>${BASEDIR}/build.log 2>&1
    echo ${RC}
    return
  fi

  (git clone $1 $2 --depth 1 1>>${BASEDIR}/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nDEBUG: Failed to clone $1\n" 1>>${BASEDIR}/build.log 2>&1
    rm -rf $2 1>>${BASEDIR}/build.log 2>&1
    echo ${RC}
    return
  fi

  cd $2 1>>${BASEDIR}/build.log 2>&1

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nDEBUG: Failed to cd into $2\n" 1>>${BASEDIR}/build.log 2>&1
    rm -rf $2 1>>${BASEDIR}/build.log 2>&1
    echo ${RC}
    return
  fi

  (git fetch --depth 1 origin $3 1>>${BASEDIR}/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nDEBUG: Failed to fetch commit id $3 from $1\n" 1>>${BASEDIR}/build.log 2>&1
    rm -rf $2 1>>${BASEDIR}/build.log 2>&1
    echo ${RC}
    return
  fi

  (git checkout $3 1>>${BASEDIR}/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nDEBUG: Failed to checkout commit id $3 from $1\n" 1>>${BASEDIR}/build.log 2>&1
    echo ${RC}
    return
  fi

  echo ${RC}
}

#
# 1. <repo url>
# 2. <tag name>
# 3. <local folder path>
#
clone_git_repository_with_tag() {
  local RC

  (mkdir -p $3 1>>${BASEDIR}/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nDEBUG: Failed to create local directory $3\n" 1>>${BASEDIR}/build.log 2>&1
    rm -rf $3 1>>${BASEDIR}/build.log 2>&1
    echo ${RC}
    return
  fi

  (git clone --depth 1 --branch $2 $1 $3 1>>${BASEDIR}/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nDEBUG: Failed to clone $1 -> $2\n" 1>>${BASEDIR}/build.log 2>&1
    rm -rf $3 1>>${BASEDIR}/build.log 2>&1
    echo ${RC}
    return
  fi

  echo ${RC}
}

#
# 1. <url>
# 2. <local file name>
# 3. <on error action>
#
download() {
  if [ ! -d "${FFMPEG_KIT_TMPDIR}" ]; then
    mkdir -p "${FFMPEG_KIT_TMPDIR}"
  fi

  (curl --fail --location $1 -o ${FFMPEG_KIT_TMPDIR}/$2 1>>${BASEDIR}/build.log 2>&1)

  local RC=$?

  if [ ${RC} -eq 0 ]; then
    echo -e "\nDEBUG: Downloaded $1 to ${FFMPEG_KIT_TMPDIR}/$2\n" 1>>${BASEDIR}/build.log 2>&1
  else
    rm -f ${FFMPEG_KIT_TMPDIR}/$2 1>>${BASEDIR}/build.log 2>&1

    echo -e -n "\nINFO: Failed to download $1 to ${FFMPEG_KIT_TMPDIR}/$2, rc=${RC}. " 1>>${BASEDIR}/build.log 2>&1

    if [ "$3" == "exit" ]; then
      echo -e "DEBUG: Build will now exit.\n" 1>>${BASEDIR}/build.log 2>&1
      exit 1
    else
      echo -e "DEBUG: Build will continue.\n" 1>>${BASEDIR}/build.log 2>&1
    fi
  fi

  echo ${RC}
}

download_library_source() {
  local LIB_REPO_URL=""
  local LIB_NAME="$1"
  local LIB_LOCAL_PATH=${BASEDIR}/src/${LIB_NAME}
  local SOURCE_ID=""
  local LIBRARY_RC=""
  local DOWNLOAD_RC=""
  local SOURCE_TYPE=""

  echo -e "\nDEBUG: Downloading library source: $1\n" 1>>${BASEDIR}/build.log 2>&1

  case $1 in
  cpu-features)
    LIB_REPO_URL="https://github.com/tanersener/cpu_features"
    SOURCE_ID="v0.4.1.1" # TAG
    SOURCE_TYPE="TAG"
    ;;
  ffmpeg)
    LIB_REPO_URL="https://github.com/tanersener/FFmpeg"
    SOURCE_ID="d222da435e63a2665b85c0305ad2cf8a07b1af6d" # COMMIT -> v4.4-dev-416
    SOURCE_TYPE="COMMIT"
    ;;
  esac

  LIBRARY_RC=$(library_is_downloaded "${LIB_NAME}")

  if [ ${LIBRARY_RC} -eq 0 ]; then
    echo -e "INFO: $1 already downloaded. Source folder found at ${LIB_LOCAL_PATH}\n" 1>>${BASEDIR}/build.log 2>&1
    echo 0
    return
  fi

  if [ ${SOURCE_TYPE} == "TAG" ]; then
    DOWNLOAD_RC=$(clone_git_repository_with_tag "${LIB_REPO_URL}" "${SOURCE_ID}" "${LIB_LOCAL_PATH}")
  else
    DOWNLOAD_RC=$(clone_git_repository_with_commit_id "${LIB_REPO_URL}" "${LIB_LOCAL_PATH}" "${SOURCE_ID}")
  fi

  if [ ${DOWNLOAD_RC} -ne 0 ]; then
    echo -e "INFO: Downloading library $1 failed. Can not get library from ${LIB_REPO_URL}\n" 1>>${BASEDIR}/build.log 2>&1
    echo ${DOWNLOAD_RC}
  else
    echo -e "DEBUG: $1 library downloaded\n" 1>>${BASEDIR}/build.log 2>&1
  fi
}

download_gpl_library_source() {
  local GPL_LIB_URL=""
  local GPL_LIB_FILE=""
  local GPL_LIB_ORIG_DIR=""
  local GPL_LIB_DEST_DIR="$1"
  local GPL_LIB_SOURCE_PATH="${BASEDIR}/src/${GPL_LIB_DEST_DIR}"
  local LIBRARY_RC=""
  local DOWNLOAD_RC=""

  echo -e "\nDEBUG: Downloading GPL library source: $1\n" 1>>${BASEDIR}/build.log 2>&1

  case $1 in
  libvidstab)
    GPL_LIB_URL="https://github.com/georgmartius/vid.stab/archive/v1.1.0.tar.gz"
    GPL_LIB_FILE="v1.1.0.tar.gz"
    GPL_LIB_ORIG_DIR="vid.stab-1.1.0"
    ;;
  x264)
    GPL_LIB_URL="https://code.videolan.org/videolan/x264/-/archive/cde9a93319bea766a92e306d69059c76de970190/x264-cde9a93319bea766a92e306d69059c76de970190.tar.bz2"
    GPL_LIB_FILE="x264-cde9a93319bea766a92e306d69059c76de970190.tar.bz2"
    GPL_LIB_ORIG_DIR="x264-cde9a93319bea766a92e306d69059c76de970190"
    ;;
  x265)
    GPL_LIB_URL="https://bitbucket.org/multicoreware/x265/downloads/x265_3.4.tar.gz"
    GPL_LIB_FILE="x265_3.4.tar.gz"
    GPL_LIB_ORIG_DIR="x265_3.4"
    ;;
  xvidcore)
    GPL_LIB_URL="https://downloads.xvid.com/downloads/xvidcore-1.3.7.tar.gz"
    GPL_LIB_FILE="xvidcore-1.3.7.tar.gz"
    GPL_LIB_ORIG_DIR="xvidcore"
    ;;
  rubberband)
    GPL_LIB_URL="https://breakfastquay.com/files/releases/rubberband-1.8.2.tar.bz2"
    GPL_LIB_FILE="rubberband-1.8.2.tar.bz2"
    GPL_LIB_ORIG_DIR="rubberband-1.8.2"
    ;;
  esac

  LIBRARY_RC=$(library_is_downloaded "${GPL_LIB_DEST_DIR}")

  if [ ${LIBRARY_RC} -eq 0 ]; then
    echo -e "INFO: $1 already downloaded. Source folder found at ${GPL_LIB_SOURCE_PATH}\n" 1>>${BASEDIR}/build.log 2>&1
    echo 0
    return
  fi

  local GPL_LIB_PACKAGE_PATH="${FFMPEG_KIT_TMPDIR}/${GPL_LIB_FILE}"

  echo -e "DEBUG: $1 source not found. Checking if library package ${GPL_LIB_FILE} is downloaded at ${GPL_LIB_PACKAGE_PATH} \n" 1>>${BASEDIR}/build.log 2>&1

  if [ ! -f "${GPL_LIB_PACKAGE_PATH}" ]; then
    echo -e "DEBUG: $1 library package not found. Downloading from ${GPL_LIB_URL}\n" 1>>${BASEDIR}/build.log 2>&1

    DOWNLOAD_RC=$(download "${GPL_LIB_URL}" "${GPL_LIB_FILE}")

    if [ ${DOWNLOAD_RC} -ne 0 ]; then
      echo -e "INFO: Downloading GPL library $1 failed. Can not get library package from ${GPL_LIB_URL}\n" 1>>${BASEDIR}/build.log 2>&1
      echo ${DOWNLOAD_RC}
      return
    else
      echo -e "DEBUG: $1 library package downloaded\n" 1>>${BASEDIR}/build.log 2>&1
    fi
  else
    echo -e "DEBUG: $1 library package already downloaded\n" 1>>${BASEDIR}/build.log 2>&1
  fi

  local EXTRACT_COMMAND=""

  if [[ ${GPL_LIB_FILE} == *bz2 ]]; then
    EXTRACT_COMMAND="tar jxf ${GPL_LIB_PACKAGE_PATH} --directory ${FFMPEG_KIT_TMPDIR}"
  else
    EXTRACT_COMMAND="tar zxf ${GPL_LIB_PACKAGE_PATH} --directory ${FFMPEG_KIT_TMPDIR}"
  fi

  echo -e "DEBUG: Extracting library package ${GPL_LIB_FILE} inside ${FFMPEG_KIT_TMPDIR}\n" 1>>${BASEDIR}/build.log 2>&1

  ${EXTRACT_COMMAND} 1>>${BASEDIR}/build.log 2>&1

  local EXTRACT_RC=$?

  if [ ${EXTRACT_RC} -ne 0 ]; then
    echo -e "\nINFO: Downloading GPL library $1 failed. Extract for library package ${GPL_LIB_FILE} completed with rc=${EXTRACT_RC}. Deleting failed files.\n" 1>>${BASEDIR}/build.log 2>&1
    rm -f ${GPL_LIB_PACKAGE_PATH} 1>>${BASEDIR}/build.log 2>&1
    rm -rf ${FFMPEG_KIT_TMPDIR}/${GPL_LIB_ORIG_DIR} 1>>${BASEDIR}/build.log 2>&1
    echo ${EXTRACT_RC}
    return
  fi

  echo -e "DEBUG: Extract completed. Copying library source to ${GPL_LIB_SOURCE_PATH}\n" 1>>${BASEDIR}/build.log 2>&1

  COPY_COMMAND="cp -r ${FFMPEG_KIT_TMPDIR}/${GPL_LIB_ORIG_DIR} ${GPL_LIB_SOURCE_PATH}"

  ${COPY_COMMAND} 1>>${BASEDIR}/build.log 2>&1

  local COPY_RC=$?

  if [ ${COPY_RC} -eq 0 ]; then
    echo -e "DEBUG: Downloading GPL library source $1 completed successfully\n" 1>>${BASEDIR}/build.log 2>&1
  else
    echo -e "\nINFO: Downloading GPL library $1 failed. Copying library source to ${GPL_LIB_SOURCE_PATH} completed with rc=${COPY_RC}\n" 1>>${BASEDIR}/build.log 2>&1
    rm -rf ${GPL_LIB_SOURCE_PATH} 1>>${BASEDIR}/build.log 2>&1
    echo ${COPY_RC}
    return
  fi
}

get_cpu_count() {
  if [ "$(uname)" == "Darwin" ]; then
    echo $(sysctl -n hw.physicalcpu)
  else
    echo $(nproc)
  fi
}

#
# 1. <lib name>
#
library_is_downloaded() {
  local LOCAL_PATH
  local LIB_NAME=$1
  local FILE_COUNT
  local REDOWNLOAD_VARIABLE
  REDOWNLOAD_VARIABLE=$(echo "REDOWNLOAD_$1" | sed "s/\-/\_/g")

  LOCAL_PATH=${BASEDIR}/src/${LIB_NAME}

  echo -e "DEBUG: Checking if ${LIB_NAME} is already downloaded at ${LOCAL_PATH}\n" 1>>${BASEDIR}/build.log 2>&1

  if [ ! -d ${LOCAL_PATH} ]; then
    echo -e "DEBUG: ${LOCAL_PATH} directory not found\n" 1>>${BASEDIR}/build.log 2>&1
    echo 1
    return
  fi

  FILE_COUNT=$(ls -l ${LOCAL_PATH} | wc -l)

  if [[ ${FILE_COUNT} -eq 0 ]]; then
    echo -e "DEBUG: No files found under ${LOCAL_PATH}\n" 1>>${BASEDIR}/build.log 2>&1
    echo 1
    return
  fi

  if [[ ${REDOWNLOAD_VARIABLE} -eq 1 ]]; then
    echo -e "INFO: ${LIB_NAME} library already downloaded but re-download requested\n" 1>>${BASEDIR}/build.log 2>&1
    rm -rf ${LOCAL_PATH} 1>>${BASEDIR}/build.log 2>&1
    echo 1
  else
    echo -e "INFO: ${LIB_NAME} library already downloaded\n" 1>>${BASEDIR}/build.log 2>&1
    echo 0
  fi
}

library_is_installed() {
  local INSTALL_PATH=$1
  local LIB_NAME=$2
  local HEADER_COUNT
  local LIB_COUNT

  echo -e "DEBUG: Checking if ${LIB_NAME} is already built and installed at ${INSTALL_PATH}/${LIB_NAME}\n" 1>>${BASEDIR}/build.log 2>&1

  if [ ! -d ${INSTALL_PATH}/${LIB_NAME} ]; then
    echo -e "DEBUG: ${INSTALL_PATH}/${LIB_NAME} directory not found\n" 1>>${BASEDIR}/build.log 2>&1
    echo 1
    return
  fi

  if [ ! -d ${INSTALL_PATH}/${LIB_NAME}/lib ]; then
    echo -e "DEBUG: ${INSTALL_PATH}/${LIB_NAME}/lib directory not found\n" 1>>${BASEDIR}/build.log 2>&1
    echo 1
    return
  fi

  if [ ! -d ${INSTALL_PATH}/${LIB_NAME}/include ]; then
    echo -e "DEBUG: ${INSTALL_PATH}/${LIB_NAME}/include directory not found\n" 1>>${BASEDIR}/build.log 2>&1
    echo 1
    return
  fi

  HEADER_COUNT=$(ls -l ${INSTALL_PATH}/${LIB_NAME}/include | wc -l)
  LIB_COUNT=$(ls -l ${INSTALL_PATH}/${LIB_NAME}/lib | wc -l)

  if [[ ${HEADER_COUNT} -eq 0 ]]; then
    echo -e "DEBUG: No headers found under ${INSTALL_PATH}/${LIB_NAME}/include\n" 1>>${BASEDIR}/build.log 2>&1
    echo 1
    return
  fi

  if [[ ${LIB_COUNT} -eq 0 ]]; then
    echo -e "DEBUG: No libraries found under ${INSTALL_PATH}/${LIB_NAME}/lib\n" 1>>${BASEDIR}/build.log 2>&1
    echo 1
    return
  fi

  echo -e "INFO: ${LIB_NAME} library is already built and installed\n" 1>>${BASEDIR}/build.log 2>&1

  echo 0
}

prepare_inline_sed() {
  if [ "$(uname)" == "Darwin" ]; then
    export SED_INLINE="sed -i .tmp"
  else
    export SED_INLINE="sed -i"
  fi
}

to_capital_case() {
  echo "$(echo ${1:0:1} | tr '[a-z]' '[A-Z]')${1:1}"
}
