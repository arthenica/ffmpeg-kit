#!/bin/bash

#
# 1. library name
# 2. source type 1/2/3
#
get_library_source() {
  case $1 in
  cpu-features)
    SOURCE_REPO_URL="https://github.com/tanersener/cpu_features"
    SOURCE_ID="v0.4.1.1"
    SOURCE_TYPE="TAG"
    ;;
  expat)
    SOURCE_REPO_URL="https://github.com/tanersener/libexpat"
    SOURCE_ID="R_2_2_10"
    SOURCE_TYPE="TAG"
    ;;
  ffmpeg)
    SOURCE_REPO_URL="https://github.com/tanersener/FFmpeg"
    SOURCE_ID="d222da435e63a2665b85c0305ad2cf8a07b1af6d" # COMMIT -> v4.4-dev-416
    SOURCE_TYPE="COMMIT"
    ;;
  fontconfig)
    SOURCE_REPO_URL="https://github.com/tanersener/fontconfig"
    SOURCE_ID="2.13.92"
    SOURCE_TYPE="TAG"
    ;;
  freetype)
    SOURCE_REPO_URL="https://github.com/tanersener/freetype2"
    SOURCE_ID="VER-2-10-2"
    SOURCE_TYPE="TAG"
    ;;
  fribidi)
    SOURCE_REPO_URL="https://github.com/tanersener/fribidi"
    SOURCE_ID="v1.0.10"
    SOURCE_TYPE="TAG"
    ;;
  jpeg)
    SOURCE_REPO_URL="https://github.com/tanersener/libjpeg-turbo"
    SOURCE_ID="2.0.5"
    SOURCE_TYPE="TAG"
    ;;
  libass)
    SOURCE_REPO_URL="https://github.com/tanersener/libass"
    SOURCE_ID="0.15.0"
    SOURCE_TYPE="TAG"
    ;;
  libiconv)
    SOURCE_REPO_URL="https://github.com/tanersener/libiconv"
    SOURCE_ID="v1.16"
    SOURCE_TYPE="TAG"
    ;;
  libilbc)
    SOURCE_REPO_URL="https://github.com/tanersener/libilbc"
    SOURCE_ID="v2.0.2"
    SOURCE_TYPE="TAG"
    ;;
  openh264)
    SOURCE_REPO_URL="https://github.com/tanersener/openh264"
    SOURCE_ID="v2.1.1"
    SOURCE_TYPE="TAG"
    ;;
  esac

  case $2 in
  1)
    echo "${SOURCE_REPO_URL}"
    ;;
  2)
    echo "${SOURCE_ID}"
    ;;
  3)
    echo "${SOURCE_TYPE}"
    ;;
  esac
}
