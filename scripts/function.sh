#!/bin/bash

source "${BASEDIR}"/scripts/source.sh

get_arch_name() {
  case $1 in
  0) echo "arm-v7a" ;; # android
  1) echo "arm-v7a-neon" ;; # android
  2) echo "armv7" ;; # ios
  3) echo "armv7s" ;; # ios
  4) echo "arm64-v8a" ;; # android
  5) echo "arm64" ;; # ios, tvos, macos
  6) echo "arm64e" ;; # ios
  7) echo "i386" ;; # ios
  8) echo "x86" ;; # android
  9) echo "x86-64" ;; # android, ios, linux, macos, tvos
  10) echo "x86-64-mac-catalyst" ;; # ios
  11) echo "arm64-mac-catalyst" ;; # ios
  12) echo "arm64-simulator" ;; # ios, tvos
  esac
}

get_full_arch_name() {
  case $1 in
  9) echo "x86_64" ;;
  10) echo "x86_64-mac-catalyst" ;;
  *) get_arch_name "$1" ;;
  esac
}

from_arch_name() {
  case $1 in
  arm-v7a) echo 0 ;; # android
  arm-v7a-neon) echo 1 ;; # android
  armv7) echo 2 ;; # ios
  armv7s) echo 3 ;; # ios
  arm64-v8a) echo 4 ;; # android
  arm64) echo 5 ;; # ios, tvos, macos
  arm64e) echo 6 ;; # ios
  i386) echo 7 ;; # ios
  x86) echo 8 ;; # android
  x86-64) echo 9 ;; # android, ios, linux, macos, tvos
  x86-64-mac-catalyst) echo 10 ;; # ios
  arm64-mac-catalyst) echo 11 ;; # ios
  arm64-simulator) echo 12 ;; # ios
  esac
}

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
  16) echo "dav1d" ;;
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
  34) echo "zimg" ;;
  35) echo "openssl" ;;
  36) echo "srt" ;;
  37) echo "giflib" ;;
  38) echo "jpeg" ;;
  39) echo "libogg" ;;
  40) echo "libpng" ;;
  41) echo "libuuid" ;;
  42) echo "nettle" ;;
  43) echo "tiff" ;;
  44) echo "expat" ;;
  45) echo "libsndfile" ;;
  46) echo "leptonica" ;;
  47) echo "libsamplerate" ;;
  48) echo "harfbuzz" ;;
  49) echo "cpu-features" ;;
  50)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]]; then
      echo "android-zlib"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "ios-zlib"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "linux" ]]; then
      echo "linux-zlib"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-zlib"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "tvos-zlib"
    fi
    ;;
  51) echo "linux-alsa" ;;
  52) echo "android-media-codec" ;;
  53)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "ios-audiotoolbox"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-audiotoolbox"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "tvos-audiotoolbox"
    fi
    ;;
  54)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "ios-bzip2"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-bzip2"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "tvos-bzip2"
    fi
    ;;
  55)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "ios-videotoolbox"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-videotoolbox"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "tvos-videotoolbox"
    fi
    ;;
  56)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "ios-avfoundation"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-avfoundation"
    fi
    ;;
  57)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "ios-libiconv"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-libiconv"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "tvos-libiconv"
    fi
    ;;
  58)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "ios-libuuid"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-libuuid"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "tvos-libuuid"
    fi
    ;;
  59)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-coreimage"
    fi
    ;;
  60)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-opencl"
    fi
    ;;
  61)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "macos-opengl"
    fi
    ;;
  62) echo "linux-fontconfig" ;;
  63) echo "linux-freetype" ;;
  64) echo "linux-fribidi" ;;
  65) echo "linux-gmp" ;;
  66) echo "linux-gnutls" ;;
  67) echo "linux-lame" ;;
  68) echo "linux-libass" ;;
  69) echo "linux-libiconv" ;;
  70) echo "linux-libtheora" ;;
  71) echo "linux-libvorbis" ;;
  72) echo "linux-libvpx" ;;
  73) echo "linux-libwebp" ;;
  74) echo "linux-libxml2" ;;
  75) echo "linux-opencore-amr" ;;
  76) echo "linux-shine" ;;
  77) echo "linux-speex" ;;
  78) echo "linux-opencl" ;;
  79) echo "linux-xvidcore" ;;
  80) echo "linux-x265" ;;
  81) echo "linux-libvidstab" ;;
  82) echo "linux-rubberband" ;;
  83) echo "linux-v4l2" ;;
  84) echo "linux-opus" ;;
  85) echo "linux-snappy" ;;
  86) echo "linux-soxr" ;;
  87) echo "linux-twolame" ;;
  88) echo "linux-sdl" ;;
  89) echo "linux-tesseract" ;;
  90) echo "linux-vaapi" ;;
  91) echo "linux-vo-amrwbenc" ;;
  esac
}

from_library_name() {
  case $1 in
  fontconfig) echo 0 ;;
  freetype) echo 1 ;;
  fribidi) echo 2 ;;
  gmp) echo 3 ;;
  gnutls) echo 4 ;;
  lame) echo 5 ;;
  libass) echo 6 ;;
  libiconv) echo 7 ;;
  libtheora) echo 8 ;;
  libvorbis) echo 9 ;;
  libvpx) echo 10 ;;
  libwebp) echo 11 ;;
  libxml2) echo 12 ;;
  opencore-amr) echo 13 ;;
  shine) echo 14 ;;
  speex) echo 15 ;;
  dav1d) echo 16 ;;
  kvazaar) echo 17 ;;
  x264) echo 18 ;;
  xvidcore) echo 19 ;;
  x265) echo 20 ;;
  libvidstab) echo 21 ;;
  rubberband) echo 22 ;;
  libilbc) echo 23 ;;
  opus) echo 24 ;;
  snappy) echo 25 ;;
  soxr) echo 26 ;;
  libaom) echo 27 ;;
  chromaprint) echo 28 ;;
  twolame) echo 29 ;;
  sdl) echo 30 ;;
  tesseract) echo 31 ;;
  openh264) echo 32 ;;
  vo-amrwbenc) echo 33 ;;
  zimg) echo 34 ;;
  openssl) echo 35 ;;
  srt) echo 36 ;;
  giflib) echo 37 ;;
  jpeg) echo 38 ;;
  libogg) echo 39 ;;
  libpng) echo 40 ;;
  libuuid) echo 41 ;;
  nettle) echo 42 ;;
  tiff) echo 43 ;;
  expat) echo 44 ;;
  libsndfile) echo 45 ;;
  leptonica) echo 46 ;;
  libsamplerate) echo 47 ;;
  harfbuzz) echo 48 ;;
  cpu-features) echo 49 ;;
  android-zlib | ios-zlib | linux-zlib | macos-zlib | tvos-zlib) echo 50 ;;
  linux-alsa) echo 51 ;;
  android-media-codec) echo 52 ;;
  ios-audiotoolbox | macos-audiotoolbox | tvos-audiotoolbox) echo 53 ;;
  ios-bzip2 | macos-bzip2 | tvos-bzip2) echo 54 ;;
  ios-videotoolbox | macos-videotoolbox | tvos-videotoolbox) echo 55 ;;
  ios-avfoundation | macos-avfoundation) echo 56 ;;
  ios-libiconv | macos-libiconv | tvos-libiconv) echo 57 ;;
  ios-libuuid | macos-libuuid | tvos-libuuid) echo 58 ;;
  macos-coreimage) echo 59 ;;
  macos-opencl) echo 60 ;;
  macos-opengl) echo 61 ;;
  linux-fontconfig) echo 62 ;;
  linux-freetype) echo 63 ;;
  linux-fribidi) echo 64 ;;
  linux-gmp) echo 65 ;;
  linux-gnutls) echo 66 ;;
  linux-lame) echo 67 ;;
  linux-libass) echo 68 ;;
  linux-libiconv) echo 69 ;;
  linux-libtheora) echo 70 ;;
  linux-libvorbis) echo 71 ;;
  linux-libvpx) echo 72 ;;
  linux-libwebp) echo 73 ;;
  linux-libxml2) echo 74 ;;
  linux-opencore-amr) echo 75 ;;
  linux-shine) echo 76 ;;
  linux-speex) echo 77 ;;
  linux-opencl) echo 78 ;;
  linux-xvidcore) echo 79 ;;
  linux-x265) echo 80 ;;
  linux-libvidstab) echo 81 ;;
  linux-rubberband) echo 82 ;;
  linux-v4l2) echo 83 ;;
  linux-opus) echo 84 ;;
  linux-snappy) echo 85 ;;
  linux-soxr) echo 86 ;;
  linux-twolame) echo 87 ;;
  linux-sdl) echo 88 ;;
  linux-tesseract) echo 89 ;;
  linux-vaapi) echo 90 ;;
  linux-vo-amrwbenc) echo 91 ;;
  esac
}

#
# 1. <library name>
#
is_library_supported_on_platform() {
  local library_index=$(from_library_name "$1")
  case ${library_index} in
  # ALL
  16 | 17 | 18 | 23 | 27 | 28 | 32 | 34 | 35 | 36 | 50)
    echo "0"
    ;;

  # ALL EXCEPT LINUX
  0 | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 19 | 20 | 21 | 22 | 24 | 25 | 26 | 29 | 30 | 31 | 33 | 37 | 38 | 39 | 40 | 42 | 43 | 44 | 45 | 46 | 47 | 48)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "linux" ]]; then
      echo "1"
    else
      echo "0"
    fi
    ;;

  # ANDROID
  7 | 41 | 49 | 52)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]]; then
      echo "0"
    else
      echo "1"
    fi
    ;;

  # ONLY LINUX
  51)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "linux" ]]; then
      echo "0"
    else
      echo "1"
    fi
    ;;

  # ONLY IOS AND MACOS
  56)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]] && [[ $1 == "ios-avfoundation" ]]; then
      echo "0"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]] && [[ $1 == "macos-avfoundation" ]]; then
      echo "0"
    else
      echo "1"
    fi
    ;;

  # IOS, MACOS AND TVOS
  53 | 54 | 55 | 57 | 58)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "0"
    else
      echo "1"
    fi
    ;;

  # ONLY MACOS
  59 | 60 | 61)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "0"
    else
      echo "1"
    fi
    ;;

  # ONLY LINUX
  62 | 63 | 64 | 65 | 66 | 67 | 68 | 69 | 70 | 71 | 72 | 73 | 74 | 75 | 76 | 77 | 78 | 79 | 80 | 81 | 82 | 83 | 84 | 85 | 86 | 87 | 88 | 89 | 90 | 91 | 92)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "linux" ]]; then
      echo "0"
    else
      echo "1"
    fi
    ;;
  *)
    echo "1"
    ;;
  esac
}

#
# 1. <arch name>
#
is_arch_supported_on_platform() {
  local arch_index=$(from_arch_name "$1")
  case ${arch_index} in
  $ARCH_X86_64)
    echo 1
    ;;

    # ANDROID
  $ARCH_ARM_V7A | $ARCH_ARM_V7A_NEON | $ARCH_ARM64_V8A | $ARCH_X86)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]]; then
      echo 1
    else
      echo 0
    fi
    ;;

    # IOS
  $ARCH_ARMV7 | $ARCH_ARMV7S | $ARCH_ARM64E | $ARCH_I386 | $ARCH_X86_64_MAC_CATALYST | $ARCH_ARM64_MAC_CATALYST)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo 1
    else
      echo 0
    fi
    ;;

    # IOS OR TVOS
  $ARCH_ARM64_SIMULATOR)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo 1
    else
      echo 0
    fi
    ;;

    # IOS, MACOS OR TVOS
  $ARCH_ARM64)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo 1
    else
      echo 0
    fi
    ;;
  *)
    echo 0
    ;;
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
  38) echo "libjpeg" ;;
  39) echo "ogg" ;;
  43) echo "libtiff-4" ;;
  45) echo "sndfile" ;;
  46) echo "lept" ;;
  47) echo "samplerate" ;;
  58) echo "uuid" ;;
  *) echo "$(get_library_name "$1")" ;;
  esac
}

get_meson_target_host_family() {
  case ${FFMPEG_KIT_BUILD_TYPE} in
  android)
    echo "android"
    ;;
  linux)
    echo "linux"
    ;;
  *)
    echo "darwin"
    ;;
  esac
}

get_meson_target_cpu_family() {
  case ${ARCH} in
  arm*)
    echo "arm"
    ;;
  x86-64*)
    echo "x86_64"
    ;;
  x86*)
    echo "x86"
    ;;
  *)
    echo "${ARCH}"
    ;;
  esac
}

get_target() {
  case ${ARCH} in
  *-mac-catalyst)
    echo "$(get_target_cpu)-apple-ios$(get_min_sdk_version)-macabi"
    ;;
  armv7 | armv7s | arm64e)
    echo "$(get_target_cpu)-apple-ios$(get_min_sdk_version)"
    ;;
  i386)
    echo "$(get_target_cpu)-apple-ios$(get_min_sdk_version)-simulator"
    ;;
  arm64)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "$(get_target_cpu)-apple-ios$(get_min_sdk_version)"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "$(get_target_cpu)-apple-macos$(get_min_sdk_version)"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "$(get_target_cpu)-apple-tvos$(get_min_sdk_version)"
    fi
    ;;
  arm64-simulator)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "$(get_target_cpu)-apple-ios$(get_min_sdk_version)-simulator"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "$(get_target_cpu)-apple-tvos$(get_min_sdk_version)-simulator"
    fi
    ;;
  x86-64)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]]; then
      echo "x86_64-linux-android"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "$(get_target_cpu)-apple-ios$(get_min_sdk_version)-simulator"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "linux" ]]; then
      echo "$(get_target_cpu)-linux-gnu"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "$(get_target_cpu)-apple-darwin$(get_min_sdk_version)"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "$(get_target_cpu)-apple-tvos$(get_min_sdk_version)-simulator"
    fi
    ;;
  *)
    get_host
    ;;
  esac
}

get_host() {
  case ${ARCH} in
  arm-v7a | arm-v7a-neon)
    echo "arm-linux-androideabi"
    ;;
  armv7 | armv7s | arm64e | i386 | *-mac-catalyst)
    echo "$(get_target_cpu)-ios-darwin"
    ;;
  arm64-simulator)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "$(get_target_cpu)-ios-darwin"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "$(get_target_cpu)-tvos-darwin"
    fi
    ;;
  arm64-v8a)
    echo "aarch64-linux-android"
    ;;
  arm64)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "$(get_target_cpu)-ios-darwin"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "$(get_target_cpu)-apple-darwin"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "$(get_target_cpu)-tvos-darwin"
    fi
    ;;
  x86)
    echo "i686-linux-android"
    ;;
  x86-64)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]]; then
      echo "x86_64-linux-android"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]]; then
      echo "$(get_target_cpu)-ios-darwin"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "linux" ]]; then
      echo "$(get_target_cpu)-linux-gnu"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
      echo "$(get_target_cpu)-apple-darwin"
    elif [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
      echo "$(get_target_cpu)-tvos-darwin"
    fi
    ;;
  esac
}

#
# 1. key
# 2. value
#
generate_custom_library_environment_variables() {
  CUSTOM_KEY=$(echo "CUSTOM_$1" | sed "s/\-/\_/g" | tr '[a-z]' '[A-Z]')
  CUSTOM_VALUE="$2"

  export "${CUSTOM_KEY}"="${CUSTOM_VALUE}"

  echo -e "INFO: Custom library env variable generated: ${CUSTOM_KEY}=${CUSTOM_VALUE}\n" 1>>"${BASEDIR}"/build.log 2>&1
}

skip_library() {
  SKIP_VARIABLE=$(echo "SKIP_$1" | sed "s/\-/\_/g")

  export "${SKIP_VARIABLE}"=1
}

no_output_redirection() {
  export NO_OUTPUT_REDIRECTION=1
}

no_workspace_cleanup_library() {
  NO_WORKSPACE_CLEANUP_VARIABLE=$(echo "NO_WORKSPACE_CLEANUP_$1" | sed "s/\-/\_/g")

  export "${NO_WORKSPACE_CLEANUP_VARIABLE}"=1
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
  echo -e "\n(*) Unknown option \"$1\".\n\nSee $0 --help for available options.\n"
  exit 1
}

print_unknown_library() {
  echo -e "\n(*) Unknown library \"$1\".\n\nSee $0 --help for available libraries.\n"
  exit 1
}

print_unknown_virtual_library() {
  echo -e "\n(*) Unknown virtual library \"$1\".\n\nThis is a bug and must be reported to project developers.\n"
  exit 1
}

print_unknown_arch() {
  echo -e "\n(*) Unknown architecture \"$1\".\n\nSee $0 --help for available architectures.\n"
  exit 1
}

print_unknown_arch_variant() {
  echo -e "\n(*) Unknown architecture variant \"$1\".\n\nSee $0 --help for available architecture variants.\n"
  exit 1
}

display_version() {
  COMMAND=$(echo "$0" | sed -e 's/\.\///g')

  echo -e "\
$COMMAND v$(get_ffmpeg_kit_version)
Copyright (c) 2018-2022 Taner Sener\n\
License LGPLv3.0: GNU LGPL version 3 or later\n\
<https://www.gnu.org/licenses/lgpl-3.0.en.html>\n\
This is free software: you can redistribute it and/or modify it under the terms of the \
GNU Lesser General Public License as published by the Free Software Foundation, \
either version 3 of the License, or (at your option) any later version."
}

get_ffmpeg_libavcodec_version() {
  local MAJOR=$(grep -Eo ' LIBAVCODEC_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavcodec/version_major.h | sed -e 's|LIBAVCODEC_VERSION_MAJOR||g;s| ||g')
  local MINOR=$(grep -Eo ' LIBAVCODEC_VERSION_MINOR .*' "${BASEDIR}"/src/ffmpeg/libavcodec/version.h | sed -e 's|LIBAVCODEC_VERSION_MINOR||g;s| ||g')
  local MICRO=$(grep -Eo ' LIBAVCODEC_VERSION_MICRO .*' "${BASEDIR}"/src/ffmpeg/libavcodec/version.h | sed -e 's|LIBAVCODEC_VERSION_MICRO||g;s| ||g')

  echo "${MAJOR}.${MINOR}.${MICRO}"
}

get_ffmpeg_libavcodec_major_version() {
  local MAJOR=$(grep -Eo ' LIBAVCODEC_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavcodec/version_major.h | sed -e 's|LIBAVCODEC_VERSION_MAJOR||g;s| ||g')

  echo "${MAJOR}"
}

get_ffmpeg_libavdevice_version() {
  local MAJOR=$(grep -Eo ' LIBAVDEVICE_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavdevice/version_major.h | sed -e 's|LIBAVDEVICE_VERSION_MAJOR||g;s| ||g')
  local MINOR=$(grep -Eo ' LIBAVDEVICE_VERSION_MINOR .*' "${BASEDIR}"/src/ffmpeg/libavdevice/version.h | sed -e 's|LIBAVDEVICE_VERSION_MINOR||g;s| ||g')
  local MICRO=$(grep -Eo ' LIBAVDEVICE_VERSION_MICRO .*' "${BASEDIR}"/src/ffmpeg/libavdevice/version.h | sed -e 's|LIBAVDEVICE_VERSION_MICRO||g;s| ||g')

  echo "${MAJOR}.${MINOR}.${MICRO}"
}

get_ffmpeg_libavdevice_major_version() {
  local MAJOR=$(grep -Eo ' LIBAVDEVICE_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavdevice/version_major.h | sed -e 's|LIBAVDEVICE_VERSION_MAJOR||g;s| ||g')

  echo "${MAJOR}"
}

get_ffmpeg_libavfilter_version() {
  local MAJOR=$(grep -Eo ' LIBAVFILTER_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavfilter/version_major.h | sed -e 's|LIBAVFILTER_VERSION_MAJOR||g;s| ||g')
  local MINOR=$(grep -Eo ' LIBAVFILTER_VERSION_MINOR .*' "${BASEDIR}"/src/ffmpeg/libavfilter/version.h | sed -e 's|LIBAVFILTER_VERSION_MINOR||g;s| ||g')
  local MICRO=$(grep -Eo ' LIBAVFILTER_VERSION_MICRO .*' "${BASEDIR}"/src/ffmpeg/libavfilter/version.h | sed -e 's|LIBAVFILTER_VERSION_MICRO||g;s| ||g')

  echo "${MAJOR}.${MINOR}.${MICRO}"
}

get_ffmpeg_libavfilter_major_version() {
  local MAJOR=$(grep -Eo ' LIBAVFILTER_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavfilter/version_major.h | sed -e 's|LIBAVFILTER_VERSION_MAJOR||g;s| ||g')

  echo "${MAJOR}"
}

get_ffmpeg_libavformat_version() {
  local MAJOR=$(grep -Eo ' LIBAVFORMAT_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavformat/version_major.h | sed -e 's|LIBAVFORMAT_VERSION_MAJOR||g;s| ||g')
  local MINOR=$(grep -Eo ' LIBAVFORMAT_VERSION_MINOR .*' "${BASEDIR}"/src/ffmpeg/libavformat/version.h | sed -e 's|LIBAVFORMAT_VERSION_MINOR||g;s| ||g')
  local MICRO=$(grep -Eo ' LIBAVFORMAT_VERSION_MICRO .*' "${BASEDIR}"/src/ffmpeg/libavformat/version.h | sed -e 's|LIBAVFORMAT_VERSION_MICRO||g;s| ||g')

  echo "${MAJOR}.${MINOR}.${MICRO}"
}

get_ffmpeg_libavformat_major_version() {
  local MAJOR=$(grep -Eo ' LIBAVFORMAT_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavformat/version_major.h | sed -e 's|LIBAVFORMAT_VERSION_MAJOR||g;s| ||g')

  echo "${MAJOR}"
}

get_ffmpeg_libavutil_version() {
  local MAJOR=$(grep -Eo ' LIBAVUTIL_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavutil/version.h | sed -e 's|LIBAVUTIL_VERSION_MAJOR||g;s| ||g')
  local MINOR=$(grep -Eo ' LIBAVUTIL_VERSION_MINOR .*' "${BASEDIR}"/src/ffmpeg/libavutil/version.h | sed -e 's|LIBAVUTIL_VERSION_MINOR||g;s| ||g')
  local MICRO=$(grep -Eo ' LIBAVUTIL_VERSION_MICRO .*' "${BASEDIR}"/src/ffmpeg/libavutil/version.h | sed -e 's|LIBAVUTIL_VERSION_MICRO||g;s| ||g')

  echo "${MAJOR}.${MINOR}.${MICRO}"
}

get_ffmpeg_libavutil_major_version() {
  local MAJOR=$(grep -Eo ' LIBAVUTIL_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libavutil/version_major.h | sed -e 's|LIBAVUTIL_VERSION_MAJOR||g;s| ||g')

  echo "${MAJOR}"
}

get_ffmpeg_libswresample_version() {
  local MAJOR=$(grep -Eo ' LIBSWRESAMPLE_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libswresample/version_major.h | sed -e 's|LIBSWRESAMPLE_VERSION_MAJOR||g;s| ||g')
  local MINOR=$(grep -Eo ' LIBSWRESAMPLE_VERSION_MINOR .*' "${BASEDIR}"/src/ffmpeg/libswresample/version.h | sed -e 's|LIBSWRESAMPLE_VERSION_MINOR||g;s| ||g')
  local MICRO=$(grep -Eo ' LIBSWRESAMPLE_VERSION_MICRO .*' "${BASEDIR}"/src/ffmpeg/libswresample/version.h | sed -e 's|LIBSWRESAMPLE_VERSION_MICRO||g;s| ||g')

  echo "${MAJOR}.${MINOR}.${MICRO}"
}

get_ffmpeg_libswresample_major_version() {
  local MAJOR=$(grep -Eo ' LIBSWRESAMPLE_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libswresample/version_major.h | sed -e 's|LIBSWRESAMPLE_VERSION_MAJOR||g;s| ||g')

  echo "${MAJOR}"
}

get_ffmpeg_libswscale_version() {
  local MAJOR=$(grep -Eo ' LIBSWSCALE_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libswscale/version_major.h | sed -e 's|LIBSWSCALE_VERSION_MAJOR||g;s| ||g')
  local MINOR=$(grep -Eo ' LIBSWSCALE_VERSION_MINOR .*' "${BASEDIR}"/src/ffmpeg/libswscale/version.h | sed -e 's|LIBSWSCALE_VERSION_MINOR||g;s| ||g')
  local MICRO=$(grep -Eo ' LIBSWSCALE_VERSION_MICRO .*' "${BASEDIR}"/src/ffmpeg/libswscale/version.h | sed -e 's|LIBSWSCALE_VERSION_MICRO||g;s| ||g')

  echo "${MAJOR}.${MINOR}.${MICRO}"
}

get_ffmpeg_libswscale_major_version() {
  local MAJOR=$(grep -Eo ' LIBSWSCALE_VERSION_MAJOR .*' "${BASEDIR}"/src/ffmpeg/libswscale/version_major.h | sed -e 's|LIBSWSCALE_VERSION_MAJOR||g;s| ||g')

  echo "${MAJOR}"
}

#
# 1. LIBRARY NAME
#
get_ffmpeg_library_version() {
  case $1 in
    libavcodec)
      echo "$(get_ffmpeg_libavcodec_version)"
    ;;
    libavdevice)
      echo "$(get_ffmpeg_libavdevice_version)"
    ;;
    libavfilter)
      echo "$(get_ffmpeg_libavfilter_version)"
    ;;
    libavformat)
      echo "$(get_ffmpeg_libavformat_version)"
    ;;
    libavutil)
      echo "$(get_ffmpeg_libavutil_version)"
    ;;
    libswresample)
      echo "$(get_ffmpeg_libswresample_version)"
    ;;
    libswscale)
      echo "$(get_ffmpeg_libswscale_version)"
    ;;
  esac
}

#
# 1. LIBRARY NAME
#
get_ffmpeg_library_major_version() {
  case $1 in
    libavcodec)
      echo "$(get_ffmpeg_libavcodec_major_version)"
    ;;
    libavdevice)
      echo "$(get_ffmpeg_libavdevice_major_version)"
    ;;
    libavfilter)
      echo "$(get_ffmpeg_libavfilter_major_version)"
    ;;
    libavformat)
      echo "$(get_ffmpeg_libavformat_major_version)"
    ;;
    libavutil)
      echo "$(get_ffmpeg_libavutil_major_version)"
    ;;
    libswresample)
      echo "$(get_ffmpeg_libswresample_major_version)"
    ;;
    libswscale)
      echo "$(get_ffmpeg_libswscale_major_version)"
    ;;
  esac
}

display_help_options() {
  echo -e "Options:"
  echo -e "  -h, --help\t\t\tdisplay this help and exit"
  echo -e "  -v, --version\t\t\tdisplay version information and exit"
  echo -e "  -d, --debug\t\t\tbuild with debug information"
  echo -e "  -s, --speed\t\t\toptimize for speed instead of size"
  echo -e "  -f, --force\t\t\tignore warnings"
  if [ -n "$1" ]; then
    echo -e "$1"
  fi
  if [ -n "$2" ]; then
    echo -e "$2"
  fi
  if [ -n "$3" ]; then
    echo -e "$3"
  fi
  if [ -n "$4" ]; then
    echo -e "$4"
  fi
  echo -e ""
}

display_help_licensing() {
  echo -e "Licensing options:"
  echo -e "  --enable-gpl\t\t\tallow building GPL libraries, created libs will be licensed under the GPLv3.0 [no]\n"
}

display_help_common_libraries() {
  echo -e "  --enable-chromaprint\t\tbuild with chromaprint [no]"
  echo -e "  --enable-dav1d\t\tbuild with dav1d [no]"
  echo -e "  --enable-fontconfig\t\tbuild with fontconfig [no]"
  echo -e "  --enable-freetype\t\tbuild with freetype [no]"
  echo -e "  --enable-fribidi\t\tbuild with fribidi [no]"
  echo -e "  --enable-gmp\t\t\tbuild with gmp [no]"
  echo -e "  --enable-gnutls\t\tbuild with gnutls [no]"
  echo -e "  --enable-kvazaar\t\tbuild with kvazaar [no]"
  echo -e "  --enable-lame\t\t\tbuild with lame [no]"
  echo -e "  --enable-libaom\t\tbuild with libaom [no]"
  echo -e "  --enable-libass\t\tbuild with libass [no]"

  case ${FFMPEG_KIT_BUILD_TYPE} in
  android)
    echo -e "  --enable-libiconv\t\tbuild with libiconv [no]"
    ;;
  esac

  echo -e "  --enable-libilbc\t\tbuild with libilbc [no]"
  echo -e "  --enable-libtheora\t\tbuild with libtheora [no]"
  echo -e "  --enable-libvorbis\t\tbuild with libvorbis [no]"
  echo -e "  --enable-libvpx\t\tbuild with libvpx [no]"
  echo -e "  --enable-libwebp\t\tbuild with libwebp [no]"
  echo -e "  --enable-libxml2\t\tbuild with libxml2 [no]"
  echo -e "  --enable-opencore-amr\t\tbuild with opencore-amr [no]"
  echo -e "  --enable-openh264\t\tbuild with openh264 [no]"
  echo -e "  --enable-openssl\t\tbuild with openssl [no]"
  echo -e "  --enable-opus\t\t\tbuild with opus [no]"
  echo -e "  --enable-sdl\t\t\tbuild with sdl [no]"
  echo -e "  --enable-shine\t\tbuild with shine [no]"
  echo -e "  --enable-snappy\t\tbuild with snappy [no]"
  echo -e "  --enable-soxr\t\t\tbuild with soxr [no]"
  echo -e "  --enable-speex\t\tbuild with speex [no]"
  echo -e "  --enable-srt\t\t\tbuild with srt [no]"
  echo -e "  --enable-tesseract\t\tbuild with tesseract [no]"
  echo -e "  --enable-twolame\t\tbuild with twolame [no]"
  echo -e "  --enable-vo-amrwbenc\t\tbuild with vo-amrwbenc [no]"
  echo -e "  --enable-zimg\t\t\tbuild with zimg [no]\n"
}

display_help_gpl_libraries() {
  echo -e "GPL libraries:"
  echo -e "  --enable-libvidstab\t\tbuild with libvidstab [no]"
  echo -e "  --enable-rubberband\t\tbuild with rubber band [no]"
  echo -e "  --enable-x264\t\t\tbuild with x264 [no]"
  echo -e "  --enable-x265\t\t\tbuild with x265 [no]"
  echo -e "  --enable-xvidcore\t\tbuild with xvidcore [no]\n"
}

display_help_custom_libraries() {
  echo -e "Custom libraries:"
  echo -e "  --enable-custom-library-[n]-name=value\t\t\tname of the custom library []"
  echo -e "  --enable-custom-library-[n]-repo=value\t\t\tgit repository of the source code []"
  echo -e "  --enable-custom-library-[n]-repo-commit=value\t\t\tgit commit to download the source code from []"
  echo -e "  --enable-custom-library-[n]-repo-tag=value\t\t\tgit tag to download the source code from []"
  echo -e "  --enable-custom-library-[n]-package-config-file-name=value\tpackage config file installed by the build script []"
  echo -e "  --enable-custom-library-[n]-ffmpeg-enable-flag=value\tlibrary name used in ffmpeg configure script to enable the library []"
  echo -e "  --enable-custom-library-[n]-license-file=value\t\tlicence file path relative to the library source folder []"
  if [ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]; then
    echo -e "  --enable-custom-library-[n]-uses-cpp\t\t\t\tflag to specify that the library uses libc++ []\n"
  else
    echo ""
  fi
}

display_help_advanced_options() {
  echo -e "Advanced options:"
  echo -e "  --reconf-LIBRARY\t\trun autoreconf before building LIBRARY [no]"
  echo -e "  --redownload-LIBRARY\t\tdownload LIBRARY even if it is detected as already downloaded [no]"
  echo -e "  --rebuild-LIBRARY\t\tbuild LIBRARY even if it is detected as already built [no]"
  if [ -n "$1" ]; then
    echo -e "$1"
  fi
  if [ -n "$2" ]; then
    echo -e "$2"
  fi
  echo -e ""
}

#
# 1. <library name>
#
reconf_library() {
  local RECONF_VARIABLE=$(echo "RECONF_$1" | sed "s/\-/\_/g")
  local library_supported=0

  for library in {0..49}; do
    library_name=$(get_library_name ${library})
    local library_supported_on_platform=$(is_library_supported_on_platform "${library_name}")

    if [[ $1 != "ffmpeg" ]] && [[ ${library_name} == "$1" ]] && [[ ${library_supported_on_platform} -eq 0 ]]; then
      export ${RECONF_VARIABLE}=1
      RECONF_LIBRARIES+=($1)
      library_supported=1
    fi
  done

  if [[ ${library_supported} -ne 1 ]]; then
    export ${RECONF_VARIABLE}=1
    RECONF_LIBRARIES+=($1)
    echo -e "INFO: --reconf flag detected for custom library $1.\n" 1>>"${BASEDIR}"/build.log 2>&1
  else
    echo -e "INFO: --reconf flag detected for library $1.\n" 1>>"${BASEDIR}"/build.log 2>&1
  fi
}

#
# 1. <library name>
#
rebuild_library() {
  local REBUILD_VARIABLE=$(echo "REBUILD_$1" | sed "s/\-/\_/g")
  local library_supported=0

  for library in {0..49}; do
    library_name=$(get_library_name ${library})
    local library_supported_on_platform=$(is_library_supported_on_platform "${library_name}")

    if [[ $1 != "ffmpeg" ]] && [[ ${library_name} == "$1" ]] && [[ ${library_supported_on_platform} -eq 0 ]]; then
      export ${REBUILD_VARIABLE}=1
      REBUILD_LIBRARIES+=($1)
      library_supported=1
    fi
  done

  if [[ ${library_supported} -ne 1 ]]; then
    export ${REBUILD_VARIABLE}=1
    REBUILD_LIBRARIES+=($1)
    echo -e "INFO: --rebuild flag detected for custom library $1.\n" 1>>"${BASEDIR}"/build.log 2>&1
  else
    echo -e "INFO: --rebuild flag detected for library $1.\n" 1>>"${BASEDIR}"/build.log 2>&1
  fi
}

#
# 1. <library name>
#
redownload_library() {
  local REDOWNLOAD_VARIABLE=$(echo "REDOWNLOAD_$1" | sed "s/\-/\_/g")
  local library_supported=0

  for library in {0..49}; do
    library_name=$(get_library_name ${library})
    local library_supported_on_platform=$(is_library_supported_on_platform "${library_name}")

    if [[ ${library_name} == "$1" ]] && [[ ${library_supported_on_platform} -eq 0 ]]; then
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

  if [[ ${library_supported} -ne 1 ]]; then
    export ${REDOWNLOAD_VARIABLE}=1
    REDOWNLOAD_LIBRARIES+=($1)
    echo -e "INFO: --redownload flag detected for custom library $1.\n" 1>>"${BASEDIR}"/build.log 2>&1
  else
    echo -e "INFO: --redownload flag detected for library $1.\n" 1>>"${BASEDIR}"/build.log 2>&1
  fi
}

#
# 1. library name
# 2. ignore unknown libraries
#
enable_library() {
  if [ -n "$1" ]; then
    local library_supported_on_platform=$(is_library_supported_on_platform "$1")
    if [[ $library_supported_on_platform == 0 ]]; then
      set_library "$1" 1
    elif [[ $2 -ne 1 ]]; then
      print_unknown_library "$1"
    fi
  fi
}

#
# 1. library name
# 2. enable/disable
#
set_library() {
  local library_supported_on_platform=$(is_library_supported_on_platform "$1")
  if [[ $library_supported_on_platform -ne 0 ]]; then
    return
  fi

  case $1 in
  android-zlib | ios-zlib | linux-zlib | macos-zlib | tvos-zlib)
    ENABLED_LIBRARIES[LIBRARY_SYSTEM_ZLIB]=$2
    ;;
  linux-alsa)
    ENABLED_LIBRARIES[LIBRARY_LINUX_ALSA]=$2
    ;;
  android-media-codec)
    ENABLED_LIBRARIES[LIBRARY_ANDROID_MEDIA_CODEC]=$2
    ;;
  ios-audiotoolbox | macos-audiotoolbox | tvos-audiotoolbox)
    ENABLED_LIBRARIES[LIBRARY_APPLE_AUDIOTOOLBOX]=$2
    ;;
  ios-bzip2 | macos-bzip2 | tvos-bzip2)
    ENABLED_LIBRARIES[LIBRARY_APPLE_BZIP2]=$2
    ;;
  ios-videotoolbox | macos-videotoolbox | tvos-videotoolbox)
    ENABLED_LIBRARIES[LIBRARY_APPLE_VIDEOTOOLBOX]=$2
    ;;
  ios-avfoundation | macos-avfoundation)
    ENABLED_LIBRARIES[LIBRARY_APPLE_AVFOUNDATION]=$2
    ;;
  ios-libiconv | macos-libiconv | tvos-libiconv)
    ENABLED_LIBRARIES[LIBRARY_APPLE_LIBICONV]=$2
    ;;
  ios-libuuid | macos-libuuid | tvos-libuuid)
    ENABLED_LIBRARIES[LIBRARY_APPLE_LIBUUID]=$2
    ;;
  macos-coreimage)
    ENABLED_LIBRARIES[LIBRARY_APPLE_COREIMAGE]=$2
    ;;
  macos-opencl)
    ENABLED_LIBRARIES[LIBRARY_APPLE_OPENCL]=$2
    ;;
  macos-opengl)
    ENABLED_LIBRARIES[LIBRARY_APPLE_OPENGL]=$2
    ;;
  chromaprint)
    ENABLED_LIBRARIES[LIBRARY_CHROMAPRINT]=$2
    ;;
  cpu-features)
    # CPU-FEATURES IS ALWAYS ENABLED
    ENABLED_LIBRARIES[LIBRARY_CPU_FEATURES]=1
    ;;
  dav1d)
    ENABLED_LIBRARIES[LIBRARY_DAV1D]=$2
    ;;
  fontconfig)
    ENABLED_LIBRARIES[LIBRARY_FONTCONFIG]=$2
    ENABLED_LIBRARIES[LIBRARY_EXPAT]=$2
    set_virtual_library "libiconv" $2
    set_virtual_library "libuuid" $2
    set_library "freetype" $2
    ;;
  freetype)
    ENABLED_LIBRARIES[LIBRARY_FREETYPE]=$2
    set_virtual_library "zlib" $2
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
    set_virtual_library "zlib" $2
    set_library "nettle" $2
    set_library "gmp" $2
    set_virtual_library "libiconv" $2
    ;;
  harfbuzz)
    ENABLED_LIBRARIES[LIBRARY_HARFBUZZ]=$2
    set_library "freetype" $2
    ;;
  kvazaar)
    ENABLED_LIBRARIES[LIBRARY_KVAZAAR]=$2
    ;;
  lame)
    ENABLED_LIBRARIES[LIBRARY_LAME]=$2
    set_virtual_library "libiconv" $2
    ;;
  libaom)
    ENABLED_LIBRARIES[LIBRARY_LIBAOM]=$2
    ;;
  libass)
    ENABLED_LIBRARIES[LIBRARY_LIBASS]=$2
    ENABLED_LIBRARIES[LIBRARY_EXPAT]=$2
    set_virtual_library "libuuid" $2
    set_library "freetype" $2
    set_library "fribidi" $2
    set_library "fontconfig" $2
    set_library "harfbuzz" $2
    set_virtual_library "libiconv" $2
    ;;
  libiconv)
    ENABLED_LIBRARIES[LIBRARY_LIBICONV]=$2
    ;;
  libilbc)
    ENABLED_LIBRARIES[LIBRARY_LIBILBC]=$2
    ;;
  libpng)
    ENABLED_LIBRARIES[LIBRARY_LIBPNG]=$2
    set_virtual_library "zlib" $2
    ;;
  libtheora)
    ENABLED_LIBRARIES[LIBRARY_LIBTHEORA]=$2
    ENABLED_LIBRARIES[LIBRARY_LIBOGG]=$2
    set_library "libvorbis" $2
    ;;
  libuuid)
    ENABLED_LIBRARIES[LIBRARY_LIBUUID]=$2
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
    set_virtual_library "libiconv" $2
    ;;
  opencore-amr)
    ENABLED_LIBRARIES[LIBRARY_OPENCOREAMR]=$2
    ;;
  openh264)
    ENABLED_LIBRARIES[LIBRARY_OPENH264]=$2
    ;;
  openssl)
    ENABLED_LIBRARIES[LIBRARY_OPENSSL]=$2
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
    set_virtual_library "zlib" $2
    ;;
  soxr)
    ENABLED_LIBRARIES[LIBRARY_SOXR]=$2
    ;;
  speex)
    ENABLED_LIBRARIES[LIBRARY_SPEEX]=$2
    ;;
  srt)
    ENABLED_LIBRARIES[LIBRARY_SRT]=$2
    set_library "openssl" $2
    ;;
  tesseract)
    ENABLED_LIBRARIES[LIBRARY_TESSERACT]=$2
    ENABLED_LIBRARIES[LIBRARY_LEPTONICA]=$2
    ENABLED_LIBRARIES[LIBRARY_LIBWEBP]=$2
    ENABLED_LIBRARIES[LIBRARY_GIFLIB]=$2
    ENABLED_LIBRARIES[LIBRARY_JPEG]=$2
    set_virtual_library "zlib" $2
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
  x264)
    ENABLED_LIBRARIES[LIBRARY_X264]=$2
    ;;
  x265)
    ENABLED_LIBRARIES[LIBRARY_X265]=$2
    ;;
  xvidcore)
    ENABLED_LIBRARIES[LIBRARY_XVIDCORE]=$2
    ;;
  zimg)
    ENABLED_LIBRARIES[LIBRARY_ZIMG]=$2
    ;;
  expat | giflib | jpeg | leptonica | libogg | libsamplerate | libsndfile)
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
  linux-fontconfig)
    ENABLED_LIBRARIES[LIBRARY_LINUX_FONTCONFIG]=$2
    set_library "linux-libiconv" $2
    set_library "linux-freetype" $2
    ;;
  linux-freetype)
    ENABLED_LIBRARIES[LIBRARY_LINUX_FREETYPE]=$2
    set_virtual_library "zlib" $2
    ;;
  linux-fribidi)
    ENABLED_LIBRARIES[LIBRARY_LINUX_FRIBIDI]=$2
    ;;
  linux-gmp)
    ENABLED_LIBRARIES[LIBRARY_LINUX_GMP]=$2
    ;;
  linux-gnutls)
    ENABLED_LIBRARIES[LIBRARY_LINUX_GNUTLS]=$2
    set_virtual_library "zlib" $2
    set_library "linux-gmp" $2
    set_library "linux-libiconv" $2
    ;;
  linux-lame)
    ENABLED_LIBRARIES[LIBRARY_LINUX_LAME]=$2
    set_library "linux-libiconv" $2
    ;;
  linux-libass)
    ENABLED_LIBRARIES[LIBRARY_LINUX_LIBASS]=$2
    set_library "linux-freetype" $2
    set_library "linux-fribidi" $2
    set_library "linux-fontconfig" $2
    set_library "linux-libiconv" $2
    ;;
  linux-libiconv)
    ENABLED_LIBRARIES[LIBRARY_LINUX_LIBICONV]=$2
    ;;
  linux-libtheora)
    ENABLED_LIBRARIES[LIBRARY_LINUX_LIBTHEORA]=$2
    set_library "linux-libvorbis" $2
    ;;
  linux-libvidstab)
    ENABLED_LIBRARIES[LIBRARY_LINUX_LIBVIDSTAB]=$2
    ;;
  linux-libvorbis)
    ENABLED_LIBRARIES[LIBRARY_LINUX_LIBVORBIS]=$2
    ;;
  linux-libvpx)
    ENABLED_LIBRARIES[LIBRARY_LINUX_LIBVPX]=$2
    ;;
  linux-libwebp)
    ENABLED_LIBRARIES[LIBRARY_LINUX_LIBWEBP]=$2
    set_virtual_library "zlib" $2
    ;;
  linux-libxml2)
    ENABLED_LIBRARIES[LIBRARY_LINUX_LIBXML2]=$2
    set_library "linux-libiconv" $2
    ;;
  linux-vaapi)
    ENABLED_LIBRARIES[LIBRARY_LINUX_VAAPI]=$2
    ;;
  linux-opencl)
    ENABLED_LIBRARIES[LIBRARY_LINUX_OPENCL]=$2
    ;;
  linux-opencore-amr)
    ENABLED_LIBRARIES[LIBRARY_LINUX_OPENCOREAMR]=$2
    ;;
  linux-opus)
    ENABLED_LIBRARIES[LIBRARY_LINUX_OPUS]=$2
    ;;
  linux-rubberband)
    ENABLED_LIBRARIES[LIBRARY_LINUX_RUBBERBAND]=$2
    ;;
  linux-sdl)
    ENABLED_LIBRARIES[LIBRARY_LINUX_SDL]=$2
    ;;
  linux-shine)
    ENABLED_LIBRARIES[LIBRARY_LINUX_SHINE]=$2
    ;;
  linux-snappy)
    ENABLED_LIBRARIES[LIBRARY_LINUX_SNAPPY]=$2
    set_virtual_library "zlib" $2
    ;;
  linux-soxr)
    ENABLED_LIBRARIES[LIBRARY_LINUX_SOXR]=$2
    ;;
  linux-speex)
    ENABLED_LIBRARIES[LIBRARY_LINUX_SPEEX]=$2
    ;;
  linux-tesseract)
    ENABLED_LIBRARIES[LIBRARY_LINUX_TESSERACT]=$2
    ENABLED_LIBRARIES[LIBRARY_LINUX_LIBWEBP]=$2
    set_virtual_library "zlib" $2
    ;;
  linux-twolame)
    ENABLED_LIBRARIES[LIBRARY_LINUX_TWOLAME]=$2
    ;;
  linux-v4l2)
    ENABLED_LIBRARIES[LIBRARY_LINUX_V4L2]=$2
    ;;
  linux-vo-amrwbenc)
    ENABLED_LIBRARIES[LIBRARY_LINUX_VO_AMRWBENC]=$2
    ;;
  linux-x265)
    ENABLED_LIBRARIES[LIBRARY_LINUX_X265]=$2
    ;;
  linux-xvidcore)
    ENABLED_LIBRARIES[LIBRARY_LINUX_XVIDCORE]=$2
    ;;
  *)
    print_unknown_library $1
    ;;
  esac
}

#
# 1. library name
# 2. enable/disable
#
# These libraries are supported by all platforms.
#
set_virtual_library() {
  case $1 in
  libiconv)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "apple" ]]; then
      ENABLED_LIBRARIES[LIBRARY_APPLE_LIBICONV]=$2
    else
      ENABLED_LIBRARIES[LIBRARY_LIBICONV]=$2
    fi
    ;;
  libuuid)
    if [[ ${FFMPEG_KIT_BUILD_TYPE} == "ios" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]] || [[ ${FFMPEG_KIT_BUILD_TYPE} == "apple" ]]; then
      ENABLED_LIBRARIES[LIBRARY_APPLE_LIBUUID]=$2
    else
      ENABLED_LIBRARIES[LIBRARY_LIBUUID]=$2
    fi
    ;;
  zlib)
    ENABLED_LIBRARIES[LIBRARY_SYSTEM_ZLIB]=$2
    ;;
  *)
    print_unknown_virtual_library $1
    ;;
  esac
}

disable_arch() {
  local arch_supported_on_platform=$(is_arch_supported_on_platform "$1")
  if [[ $arch_supported_on_platform == 1 ]]; then
    set_arch "$1" 0
  else
    print_unknown_arch "$1"
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
  arm64-mac-catalyst)
    ENABLED_ARCHITECTURES[ARCH_ARM64_MAC_CATALYST]=$2
    ;;
  arm64-simulator)
    ENABLED_ARCHITECTURES[ARCH_ARM64_SIMULATOR]=$2
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
    print_unknown_arch "$1"
    ;;
  esac
}

check_if_dependency_rebuilt() {
  case $1 in
  cpu-features)
    set_dependency_rebuilt_flag "libvpx"
    set_dependency_rebuilt_flag "openh264"
    ;;
  expat)
    set_dependency_rebuilt_flag "fontconfig"
    set_dependency_rebuilt_flag "libass"
    ;;
  fontconfig)
    set_dependency_rebuilt_flag "libass"
    ;;
  freetype)
    set_dependency_rebuilt_flag "fontconfig"
    set_dependency_rebuilt_flag "libass"
    set_dependency_rebuilt_flag "harfbuzz"
    ;;
  fribidi)
    set_dependency_rebuilt_flag "libass"
    ;;
  giflib)
    set_dependency_rebuilt_flag "libwebp"
    set_dependency_rebuilt_flag "leptonica"
    set_dependency_rebuilt_flag "tesseract"
    ;;
  gmp)
    set_dependency_rebuilt_flag "gnutls"
    set_dependency_rebuilt_flag "nettle"
    ;;
  harfbuzz)
    set_dependency_rebuilt_flag "libass"
    ;;
  jpeg)
    set_dependency_rebuilt_flag "tiff"
    set_dependency_rebuilt_flag "libwebp"
    set_dependency_rebuilt_flag "leptonica"
    set_dependency_rebuilt_flag "tesseract"
    ;;
  leptonica)
    set_dependency_rebuilt_flag "tesseract"
    ;;
  libiconv)
    set_dependency_rebuilt_flag "fontconfig"
    set_dependency_rebuilt_flag "gnutls"
    set_dependency_rebuilt_flag "lame"
    set_dependency_rebuilt_flag "libass"
    set_dependency_rebuilt_flag "libxml2"
    ;;
  libogg)
    set_dependency_rebuilt_flag "libvorbis"
    set_dependency_rebuilt_flag "libtheora"
    ;;
  libpng)
    set_dependency_rebuilt_flag "freetype"
    set_dependency_rebuilt_flag "libwebp"
    set_dependency_rebuilt_flag "libass"
    set_dependency_rebuilt_flag "leptonica"
    set_dependency_rebuilt_flag "tesseract"
    ;;
  libsamplerate)
    set_dependency_rebuilt_flag "rubberband"
    ;;
  libsndfile)
    set_dependency_rebuilt_flag "twolame"
    set_dependency_rebuilt_flag "rubberband"
    ;;
  libuuid)
    set_dependency_rebuilt_flag "fontconfig"
    set_dependency_rebuilt_flag "libass"
    ;;
  libvorbis)
    set_dependency_rebuilt_flag "libtheora"
    ;;
  libwebp)
    set_dependency_rebuilt_flag "leptonica"
    set_dependency_rebuilt_flag "tesseract"
    ;;
  nettle)
    set_dependency_rebuilt_flag "gnutls"
    ;;
  openssl)
    set_dependency_rebuilt_flag "srt"
    ;;
  tiff)
    set_dependency_rebuilt_flag "libwebp"
    set_dependency_rebuilt_flag "leptonica"
    set_dependency_rebuilt_flag "tesseract"
    ;;
  esac
}

set_dependency_rebuilt_flag() {
  DEPENDENCY_REBUILT_VARIABLE=$(echo "DEPENDENCY_REBUILT_$1" | sed "s/\-/\_/g")
  export "${DEPENDENCY_REBUILT_VARIABLE}"=1
}

print_enabled_architectures() {
  echo -n "Architectures: "

  let enabled=0
  for print_arch in {0..12}; do
    if [[ ${ENABLED_ARCHITECTURES[$print_arch]} -eq 1 ]]; then
      if [[ ${enabled} -ge 1 ]]; then
        echo -n ", "
      fi
      echo -n "$(get_arch_name "${print_arch}")"
      enabled=$((${enabled} + 1))
    fi
  done

  if [ ${enabled} -gt 0 ]; then
    echo ""
  else
    echo "none"
  fi
}

print_enabled_architecture_variants() {
  echo -n "Architecture variants: "

  let enabled=0
  for print_arch_var in {1..8}; do
    if [[ ${ENABLED_ARCHITECTURE_VARIANTS[$print_arch_var]} -eq 1 ]]; then
      if [[ ${enabled} -ge 1 ]]; then
        echo -n ", "
      fi
      echo -n "$(get_apple_architecture_variant "${print_arch_var}")"
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

  # SUPPLEMENTARY LIBRARIES NOT PRINTED
  for library in {50..57} {59..91} {0..36}; do
    if [[ ${ENABLED_LIBRARIES[$library]} -eq 1 ]]; then
      if [[ ${enabled} -ge 1 ]]; then
        echo -n ", "
      fi
      echo -n "$(get_library_name "${library}")"
      enabled=$((${enabled} + 1))
    fi
  done

  if [ ${enabled} -gt 0 ]; then
    echo ""
  else
    echo "none"
  fi
}

print_enabled_xcframeworks() {
  echo -n "xcframeworks: "

  let enabled=0

  # SUPPLEMENTARY LIBRARIES NOT PRINTED
  for library in {0..49}; do
    if [[ ${ENABLED_LIBRARIES[$library]} -eq 1 ]]; then
      if [[ ${enabled} -ge 1 ]]; then
        echo -n ", "
      fi
      echo -n "$(get_library_name "${library}")"
      enabled=$((${enabled} + 1))
    fi
  done

  if [[ ${enabled} -ge 1 ]]; then
    echo -n ", "
  fi

  for FFMPEG_LIB in "${FFMPEG_LIBS[@]}"; do
    echo -n "${FFMPEG_LIB}, "
  done

  echo "ffmpeg-kit"
}

print_reconfigure_requested_libraries() {
  local counter=0

  for RECONF_LIBRARY in "${RECONF_LIBRARIES[@]}"; do
    if [[ ${counter} -eq 0 ]]; then
      echo -n "Reconfigure: "
    else
      echo -n ", "
    fi

    echo -n "${RECONF_LIBRARY}"

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

    echo -n "${REBUILD_LIBRARY}"

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

    echo -n "${REDOWNLOAD_LIBRARY}"

    counter=$((${counter} + 1))
  done

  if [[ ${counter} -gt 0 ]]; then
    echo ""
  fi
}

print_custom_libraries() {
  local counter=0

  for index in {1..20}; do
    LIBRARY_NAME="CUSTOM_LIBRARY_${index}_NAME"
    LIBRARY_REPO="CUSTOM_LIBRARY_${index}_REPO"
    LIBRARY_REPO_COMMIT="CUSTOM_LIBRARY_${index}_REPO_COMMIT"
    LIBRARY_REPO_TAG="CUSTOM_LIBRARY_${index}_REPO_TAG"
    LIBRARY_PACKAGE_CONFIG_FILE_NAME="CUSTOM_LIBRARY_${index}_PACKAGE_CONFIG_FILE_NAME"
    LIBRARY_FFMPEG_ENABLE_FLAG="CUSTOM_LIBRARY_${index}_FFMPEG_ENABLE_FLAG"
    LIBRARY_LICENSE_FILE="CUSTOM_LIBRARY_${index}_LICENSE_FILE"
    LIBRARY_USES_CPP="CUSTOM_LIBRARY_${index}_USES_CPP"

    if [[ -z "${!LIBRARY_NAME}" ]]; then
      echo -e "INFO: Custom library ${index} not detected\n" 1>>"${BASEDIR}"/build.log 2>&1
      break
    fi

    if [[ -z "${!LIBRARY_REPO}" ]]; then
      echo -e "INFO: Custom library ${index} repo not set\n" 1>>"${BASEDIR}"/build.log 2>&1
      continue
    fi

    if [[ -z "${!LIBRARY_REPO_COMMIT}" ]] && [[ -z "${!LIBRARY_REPO_TAG}" ]]; then
      echo -e "INFO: Custom library ${index} repo source not set. Both commit id and tag are empty\n" 1>>"${BASEDIR}"/build.log 2>&1
      continue
    fi

    if [[ -z "${!LIBRARY_PACKAGE_CONFIG_FILE_NAME}" ]]; then
      echo -e "INFO: Custom library ${index} package config file not set\n" 1>>"${BASEDIR}"/build.log 2>&1
      continue
    fi

    if [[ -z "${!LIBRARY_FFMPEG_ENABLE_FLAG}" ]]; then
      echo -e "INFO: Custom library ${index} ffmpeg enable flag not set\n" 1>>"${BASEDIR}"/build.log 2>&1
      continue
    fi

    if [[ -z "${!LIBRARY_LICENSE_FILE}" ]]; then
      echo -e "INFO: Custom library ${index} license file not set\n" 1>>"${BASEDIR}"/build.log 2>&1
      continue
    fi

    if [[ -n "${!LIBRARY_USES_CPP}" ]] && [[ ${FFMPEG_KIT_BUILD_TYPE} == "android" ]]; then
      echo -e "INFO: Custom library ${index} is marked as uses libc++ \n" 1>>"${BASEDIR}"/build.log 2>&1
      export CUSTOM_LIBRARY_USES_CPP=1
    fi

    CUSTOM_LIBRARIES+=("${index}")

    if [[ ${counter} -eq 0 ]]; then
      echo -n "Custom libraries: "
    else
      echo -n ", "
    fi

    echo -n "${!LIBRARY_NAME}"

    echo -e "INFO: Custom library options found for ${!LIBRARY_NAME}\n" 1>>"${BASEDIR}"/build.log 2>&1

    counter=$((${counter} + 1))
  done

  if [[ ${counter} -gt 0 ]]; then
    echo -e "INFO: ${counter} valid custom library definitions found\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo ""
  fi
}

# 1 - library index
get_external_library_license_path() {
  case $1 in
  1) echo "${BASEDIR}/src/$(get_library_name "$1")/LICENSE.TXT" ;;
  12) echo "${BASEDIR}/src/$(get_library_name "$1")/Copyright" ;;
  35) echo "${BASEDIR}/src/$(get_library_name "$1")/LICENSE.txt" ;;
  3 | 42) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYING.LESSERv3" ;;
  5 | 44) echo "${BASEDIR}/src/$(get_library_name "$1")/$(get_library_name "$1")/COPYING" ;;
  19) echo "${BASEDIR}/src/$(get_library_name "$1")/$(get_library_name "$1")/LICENSE" ;;
  26) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYING.LGPL" ;;
  28 | 38) echo "${BASEDIR}/src/$(get_library_name "$1")/LICENSE.md " ;;
  30) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYING.txt" ;;
  43) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYRIGHT" ;;
  46) echo "${BASEDIR}/src/$(get_library_name "$1")/leptonica-license.txt" ;;
  4 | 10 | 13 | 17 | 21 | 27 | 31 | 32 | 36 | 40 | 49) echo "${BASEDIR}/src/$(get_library_name "$1")/LICENSE" ;;
  *) echo "${BASEDIR}/src/$(get_library_name "$1")/COPYING" ;;
  esac
}

# 1 - library index
# 2 - license path
copy_external_library_license() {
  license_path_array=("$2")
  for license_path in "${license_path_array[@]}"; do
    RESULT=$(copy_external_library_license_file "$1" "${license_path}")
    if [[ ${RESULT} -ne 0 ]]; then
      echo 1
      return
    fi
  done
  echo 0
}

# 1 - library index
# 2 - output path
copy_external_library_license_file() {
  cp $(get_external_library_license_path "$1") "$2" 1>>"${BASEDIR}"/build.log 2>&1
  if [[ $? -ne 0 ]]; then
    echo 1
    return
  fi
  echo 0
}

get_cmake_build_directory() {
  echo "${FFMPEG_KIT_TMPDIR}/cmake/build/$(get_build_directory)/${LIB_NAME}"
}

get_apple_cmake_system_name() {
  case ${FFMPEG_KIT_BUILD_TYPE} in
  macos)
    echo "Darwin"
    ;;
  tvos)
    echo "tvOS"
    ;;
  *)
    case ${ARCH} in
    *-mac-catalyst)
      echo "Darwin"
      ;;
    *)
      echo "iOS"
      ;;
    esac
    ;;
  esac
}

#
# 1. <library name>
#
autoreconf_library() {
  echo -e "\nINFO: Running full autoreconf for $1\n" 1>>"${BASEDIR}"/build.log 2>&1

  # FORCE INSTALL
  (autoreconf --force --install)

  local EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    echo -e "\nDEBUG: autoreconf completed successfully for $1\n" 1>>"${BASEDIR}"/build.log 2>&1
    return
  fi

  echo -e "\nDEBUG: Full autoreconf failed. Running full autoreconf with include for $1\n" 1>>"${BASEDIR}"/build.log 2>&1

  # FORCE INSTALL WITH m4
  (autoreconf --force --install -I m4)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    echo -e "\nDEBUG: autoreconf completed successfully for $1\n" 1>>"${BASEDIR}"/build.log 2>&1
    return
  fi

  echo -e "\nDEBUG: Full autoreconf with include failed. Running autoreconf without force for $1\n" 1>>"${BASEDIR}"/build.log 2>&1

  # INSTALL WITHOUT FORCE
  (autoreconf --install)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    echo -e "\nDEBUG: autoreconf completed successfully for $1\n" 1>>"${BASEDIR}"/build.log 2>&1
    return
  fi

  echo -e "\nDEBUG: Autoreconf without force failed. Running autoreconf without force with include for $1\n" 1>>"${BASEDIR}"/build.log 2>&1

  # INSTALL WITHOUT FORCE WITH m4
  (autoreconf --install -I m4)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    echo -e "\nDEBUG: autoreconf completed successfully for $1\n" 1>>"${BASEDIR}"/build.log 2>&1
    return
  fi

  echo -e "\nDEBUG: Autoreconf without force with include failed. Running default autoreconf for $1\n" 1>>"${BASEDIR}"/build.log 2>&1

  # INSTALL DEFAULT
  (autoreconf)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    echo -e "\nDEBUG: autoreconf completed successfully for $1\n" 1>>"${BASEDIR}"/build.log 2>&1
    return
  fi

  echo -e "\nDEBUG: Default autoreconf failed. Running default autoreconf with include for $1\n" 1>>"${BASEDIR}"/build.log 2>&1

  # INSTALL DEFAULT WITH m4
  (autoreconf -I m4)

  EXTRACT_RC=$?
  if [ ${EXTRACT_RC} -eq 0 ]; then
    echo -e "\nDEBUG: autoreconf completed successfully for $1\n" 1>>"${BASEDIR}"/build.log 2>&1
  else
    echo -e "\nDEBUG: Default autoreconf with include for $1 failed\n" 1>>"${BASEDIR}"/build.log 2>&1
  fi
}

#
# 1. <repo url>
# 2. <local folder path>
# 3. <commit id>
#
clone_git_repository_with_commit_id() {
  local RC

  (mkdir -p "$2" 1>>"${BASEDIR}"/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nINFO: Failed to create local directory $2\n" 1>>"${BASEDIR}"/build.log 2>&1
    rm -rf "$2" 1>>"${BASEDIR}"/build.log 2>&1
    echo ${RC}
    return
  fi

  echo -e "INFO: Cloning commit id $3 from repository $1 into local directory $2\n" 1>>"${BASEDIR}"/build.log 2>&1

  (git clone "$1" "$2" --depth 1 1>>"${BASEDIR}"/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nINFO: Failed to clone $1\n" 1>>"${BASEDIR}"/build.log 2>&1
    rm -rf "$2" 1>>"${BASEDIR}"/build.log 2>&1
    echo ${RC}
    return
  fi

  cd "$2" 1>>"${BASEDIR}"/build.log 2>&1

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nINFO: Failed to cd into $2\n" 1>>"${BASEDIR}"/build.log 2>&1
    rm -rf "$2" 1>>"${BASEDIR}"/build.log 2>&1
    echo ${RC}
    return
  fi

  (git fetch --depth 1 origin "$3" 1>>"${BASEDIR}"/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nINFO: Failed to fetch commit id $3 from $1\n" 1>>"${BASEDIR}"/build.log 2>&1
    rm -rf "$2" 1>>"${BASEDIR}"/build.log 2>&1
    echo ${RC}
    return
  fi

  (git checkout "$3" 1>>"${BASEDIR}"/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nINFO: Failed to checkout commit id $3 from $1\n" 1>>"${BASEDIR}"/build.log 2>&1
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

  (mkdir -p "$3" 1>>"${BASEDIR}"/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nINFO: Failed to create local directory $3\n" 1>>"${BASEDIR}"/build.log 2>&1
    rm -rf "$3" 1>>"${BASEDIR}"/build.log 2>&1
    echo ${RC}
    return
  fi

  echo -e "INFO: Cloning tag $2 from repository $1 into local directory $3\n" 1>>"${BASEDIR}"/build.log 2>&1

  (git clone --depth 1 --branch "$2" "$1" "$3" 1>>"${BASEDIR}"/build.log 2>&1)

  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo -e "\nINFO: Failed to clone $1 -> $2\n" 1>>"${BASEDIR}"/build.log 2>&1
    rm -rf "$3" 1>>"${BASEDIR}"/build.log 2>&1
    echo ${RC}
    return
  fi

  echo ${RC}
}

#
# 1. library index
#
is_gpl_licensed() {
  for gpl_library in {$LIBRARY_X264,$LIBRARY_XVIDCORE,$LIBRARY_X265,$LIBRARY_LIBVIDSTAB,$LIBRARY_RUBBERBAND,$LIBRARY_LINUX_XVIDCORE,$LIBRARY_LINUX_X265,$LIBRARY_LINUX_LIBVIDSTAB,$LIBRARY_LINUX_RUBBERBAND}; do
    if [[ $gpl_library -eq $1 ]]; then
      echo 0
      return
    fi
  done

  echo 1
}

downloaded_library_sources() {

  # DOWNLOAD FFMPEG SOURCE CODE FIRST
  DOWNLOAD_RESULT=$(download_library_source "ffmpeg")
  if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
    echo -e "failed\n"
    exit 1
  fi

  for library in {1..50}; do
    if [[ ${!library} -eq 1 ]]; then
      library_name=$(get_library_name $((library - 1)))

      echo -e "\nDEBUG: Downloading library ${library_name}\n" 1>>"${BASEDIR}"/build.log 2>&1

      DOWNLOAD_RESULT=$(download_library_source "${library_name}")
      if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
        echo -e "failed\n"
        exit 1
      fi
    fi
  done

  for custom_library_index in "${CUSTOM_LIBRARIES[@]}"; do
    library_name="CUSTOM_LIBRARY_${custom_library_index}_NAME"

    echo -e "\nDEBUG: Downloading custom library ${!library_name}\n" 1>>"${BASEDIR}"/build.log 2>&1

    DOWNLOAD_RESULT=$(download_custom_library_source "${custom_library_index}")
    if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
      echo -e "failed\n"
      exit 1
    fi
  done

  echo -e "ok"
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

  (curl --fail --location "$1" -o "${FFMPEG_KIT_TMPDIR}"/"$2" 1>>"${BASEDIR}"/build.log 2>&1)

  local RC=$?

  if [ ${RC} -eq 0 ]; then
    echo -e "\nDEBUG: Downloaded $1 to ${FFMPEG_KIT_TMPDIR}/$2\n" 1>>"${BASEDIR}"/build.log 2>&1
  else
    rm -f "${FFMPEG_KIT_TMPDIR}"/"$2" 1>>"${BASEDIR}"/build.log 2>&1

    echo -e -n "\nINFO: Failed to download $1 to ${FFMPEG_KIT_TMPDIR}/$2, rc=${RC}. " 1>>"${BASEDIR}"/build.log 2>&1

    if [ "$3" == "exit" ]; then
      echo -e "DEBUG: Build will now exit.\n" 1>>"${BASEDIR}"/build.log 2>&1
      exit 1
    else
      echo -e "DEBUG: Build will continue.\n" 1>>"${BASEDIR}"/build.log 2>&1
    fi
  fi

  echo ${RC}
}

#
# 1. library name
#
download_library_source() {
  local SOURCE_REPO_URL=""
  local LIB_NAME="$1"
  local LIB_LOCAL_PATH=${BASEDIR}/src/${LIB_NAME}
  local SOURCE_ID=""
  local LIBRARY_RC=""
  local DOWNLOAD_RC=""
  local SOURCE_TYPE=""

  echo -e "DEBUG: Downloading library source: $1\n" 1>>"${BASEDIR}"/build.log 2>&1

  SOURCE_REPO_URL=$(get_library_source "${LIB_NAME}" 1)
  SOURCE_ID=$(get_library_source "${LIB_NAME}" 2)
  SOURCE_TYPE=$(get_library_source "${LIB_NAME}" 3)

  LIBRARY_RC=$(library_is_downloaded "${LIB_NAME}")

  if [ ${LIBRARY_RC} -eq 0 ]; then
    echo -e "INFO: $1 already downloaded. Source folder found at ${LIB_LOCAL_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
    return
  fi

  if [ "${SOURCE_TYPE}" == "TAG" ]; then
    DOWNLOAD_RC=$(clone_git_repository_with_tag "${SOURCE_REPO_URL}" "${SOURCE_ID}" "${LIB_LOCAL_PATH}")
  else
    DOWNLOAD_RC=$(clone_git_repository_with_commit_id "${SOURCE_REPO_URL}" "${LIB_LOCAL_PATH}" "${SOURCE_ID}")
  fi

  if [ ${DOWNLOAD_RC} -ne 0 ]; then
    echo -e "INFO: Downloading library $1 failed. Can not get library from ${SOURCE_REPO_URL}\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo ${DOWNLOAD_RC}
  else
    echo -e "\nINFO: $1 library downloaded" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
  fi
}

#
# 1. custom library index
#
download_custom_library_source() {
  local LIBRARY_NAME="CUSTOM_LIBRARY_$1_NAME"
  local LIBRARY_REPO="CUSTOM_LIBRARY_$1_REPO"
  local LIBRARY_REPO_COMMIT="CUSTOM_LIBRARY_$1_REPO_COMMIT"
  local LIBRARY_REPO_TAG="CUSTOM_LIBRARY_$1_REPO_TAG"

  local SOURCE_REPO_URL=""
  local LIB_NAME="${!LIBRARY_NAME}"
  local LIB_LOCAL_PATH=${BASEDIR}/src/${LIB_NAME}
  local SOURCE_ID=""
  local LIBRARY_RC=""
  local DOWNLOAD_RC=""
  local SOURCE_TYPE=""

  echo -e "DEBUG: Downloading custom library source: ${LIB_NAME}\n" 1>>"${BASEDIR}"/build.log 2>&1

  SOURCE_REPO_URL=${!LIBRARY_REPO}
  if [ -n "${!LIBRARY_REPO_TAG}" ]; then
    SOURCE_ID=${!LIBRARY_REPO_TAG}
    SOURCE_TYPE="TAG"
  else
    SOURCE_ID=${!LIBRARY_REPO_COMMIT}
    SOURCE_TYPE="COMMIT"
  fi

  LIBRARY_RC=$(library_is_downloaded "${LIB_NAME}")

  if [ ${LIBRARY_RC} -eq 0 ]; then
    echo -e "INFO: ${LIB_NAME} already downloaded. Source folder found at ${LIB_LOCAL_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
    return
  fi

  if [ "${SOURCE_TYPE}" == "TAG" ]; then
    DOWNLOAD_RC=$(clone_git_repository_with_tag "${SOURCE_REPO_URL}" "${SOURCE_ID}" "${LIB_LOCAL_PATH}")
  else
    DOWNLOAD_RC=$(clone_git_repository_with_commit_id "${SOURCE_REPO_URL}" "${LIB_LOCAL_PATH}" "${SOURCE_ID}")
  fi

  if [ ${DOWNLOAD_RC} -ne 0 ]; then
    echo -e "INFO: Downloading custom library ${LIB_NAME} failed. Can not get library from ${SOURCE_REPO_URL}\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo ${DOWNLOAD_RC}
  else
    echo -e "\nINFO: ${LIB_NAME} custom library downloaded" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
  fi
}

download_gnu_config() {
  local SOURCE_REPO_URL=""
  local LIB_NAME="config"
  local LIB_LOCAL_PATH="${FFMPEG_KIT_TMPDIR}/source/${LIB_NAME}"
  local SOURCE_ID=""
  local DOWNLOAD_RC=""
  local SOURCE_TYPE=""
  REDOWNLOAD_VARIABLE=$(echo "REDOWNLOAD_$LIB_NAME")

  echo -e "DEBUG: Downloading gnu config source.\n" 1>>"${BASEDIR}"/build.log 2>&1

  SOURCE_REPO_URL=$(get_library_source "${LIB_NAME}" 1)
  SOURCE_ID=$(get_library_source "${LIB_NAME}" 2)
  SOURCE_TYPE=$(get_library_source "${LIB_NAME}" 3)

  if [[ -d "${LIB_LOCAL_PATH}" ]]; then
    if [[ ${REDOWNLOAD_VARIABLE} -eq 1 ]]; then
      echo -e "INFO: gnu config already downloaded but re-download requested\n" 1>>"${BASEDIR}"/build.log 2>&1
      rm -rf "${LIB_LOCAL_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
    else
      echo -e "INFO: gnu config already downloaded. Source folder found at ${LIB_LOCAL_PATH}\n" 1>>"${BASEDIR}"/build.log 2>&1
      return
    fi
  fi

  DOWNLOAD_RC=$(clone_git_repository_with_tag "${SOURCE_REPO_URL}" "${SOURCE_ID}" "${LIB_LOCAL_PATH}")

  if [[ ${DOWNLOAD_RC} -ne 0 ]]; then
    echo -e "INFO: Downloading gnu config failed. Can not get source from ${SOURCE_REPO_URL}\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n"
    exit 1
  else
    echo -e "\nINFO: gnu config downloaded successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
  fi
}

is_gnu_config_files_up_to_date() {
  echo $(grep aarch64-apple-darwin config.guess | wc -l 2>>"${BASEDIR}"/build.log)
}

get_cpu_count() {
  if [ "$(uname)" == "Darwin" ]; then
    echo $(sysctl -n hw.logicalcpu)
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

  echo -e "DEBUG: Checking if ${LIB_NAME} is already downloaded at ${LOCAL_PATH}\n" 1>>"${BASEDIR}"/build.log 2>&1

  if [ ! -d "${LOCAL_PATH}" ]; then
    echo -e "INFO: ${LOCAL_PATH} directory not found\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo 1
    return
  fi

  FILE_COUNT=$(ls -l "${LOCAL_PATH}" | wc -l)

  if [[ ${FILE_COUNT} -eq 0 ]]; then
    echo -e "INFO: No files found under ${LOCAL_PATH}\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo 1
    return
  fi

  if [[ ${REDOWNLOAD_VARIABLE} -eq 1 ]]; then
    echo -e "INFO: ${LIB_NAME} library already downloaded but re-download requested\n" 1>>"${BASEDIR}"/build.log 2>&1
    rm -rf "${LOCAL_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
    echo 1
  else
    echo -e "INFO: ${LIB_NAME} library already downloaded\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
  fi
}

library_is_installed() {
  local INSTALL_PATH=$1
  local LIB_NAME=$2
  local HEADER_COUNT
  local LIB_COUNT

  echo -e "DEBUG: Checking if ${LIB_NAME} is already built and installed at ${INSTALL_PATH}/${LIB_NAME}\n" 1>>"${BASEDIR}"/build.log 2>&1

  if [ ! -d "${INSTALL_PATH}"/"${LIB_NAME}" ]; then
    echo -e "INFO: ${INSTALL_PATH}/${LIB_NAME} directory not found\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
    return
  fi

  if [ ! -d "${INSTALL_PATH}/${LIB_NAME}/lib" ] && [ ! -d "${INSTALL_PATH}/${LIB_NAME}/lib64" ]; then
    echo -e "INFO: ${INSTALL_PATH}/${LIB_NAME}/lib{lib64} directory not found\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
    return
  fi

  if [ ! -d "${INSTALL_PATH}"/"${LIB_NAME}"/include ]; then
    echo -e "INFO: ${INSTALL_PATH}/${LIB_NAME}/include directory not found\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
    return
  fi

  HEADER_COUNT=$(ls -l "${INSTALL_PATH}"/"${LIB_NAME}"/include | wc -l)
  LIB_COUNT=$(ls -l ${INSTALL_PATH}/${LIB_NAME}/lib* | wc -l)

  if [[ ${HEADER_COUNT} -eq 0 ]]; then
    echo -e "INFO: No headers found under ${INSTALL_PATH}/${LIB_NAME}/include\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
    return
  fi

  if [[ ${LIB_COUNT} -eq 0 ]]; then
    echo -e "INFO: No libraries found under ${INSTALL_PATH}/${LIB_NAME}/lib{lib64}\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo 0
    return
  fi

  echo -e "INFO: ${LIB_NAME} library is already built and installed\n" 1>>"${BASEDIR}"/build.log 2>&1
  echo 1
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

#
# 1. source file
# 2. destination file
#
overwrite_file() {
  rm -f "$2" 2>>"${BASEDIR}"/build.log
  cp "$1" "$2" 2>>"${BASEDIR}"/build.log
}

#
# 1. destination file
#
create_file() {
  rm -f "$1"
  echo "" > "$1" 1>>"${BASEDIR}"/build.log 2>&1
}

compare_versions() {
  VERSION_PARTS_1=($(echo $1 | tr "." " "))
  VERSION_PARTS_2=($(echo $2 | tr "." " "))

  for((i=0;(i<${#VERSION_PARTS_1[@]})&&(i<${#VERSION_PARTS_2[@]});i++))
  do

    local CURRENT_PART_1=${VERSION_PARTS_1[$i]}
    local CURRENT_PART_2=${VERSION_PARTS_2[$i]}

    if [[ -z ${CURRENT_PART_1} ]]; then
      CURRENT_PART_1=0
    fi

    if [[ -z ${CURRENT_PART_2} ]]; then
      CURRENT_PART_2=0
    fi

    if [[ CURRENT_PART_1 -gt CURRENT_PART_2 ]]; then
      echo "1"
      return;
    elif [[ CURRENT_PART_1 -lt CURRENT_PART_2 ]]; then
      echo "-1"
      return;
    fi
  done

  echo "0"
  return;
}

#
# 1. command
#
command_exists() {
  local COMMAND=$1
  if [[ -n "$(command -v $COMMAND)" ]]; then
    echo 0
  else
    echo 1
  fi
}

#
# 1. folder path
#
initialize_folder() {
  rm -rf "$1" 1>>"${BASEDIR}"/build.log 2>&1
  if [[ $? -ne 0 ]]; then
    return 1
  fi

  mkdir -p "$1" 1>>"${BASEDIR}"/build.log 2>&1
  if [[ $? -ne 0 ]]; then
    return 1
  fi

  return 0
}
