#!/bin/bash

#
# 1. library name
# 2. source type 1/2/3
#
get_library_source() {
  case $1 in
  cpu-features)
    SOURCE_REPO_URL="https://github.com/tanersener/cpu_features"
    SOURCE_ID="v0.4.1.1" # TAG
    SOURCE_TYPE="TAG"
    ;;
  ffmpeg)
    SOURCE_REPO_URL="https://github.com/tanersener/FFmpeg"
    SOURCE_ID="d222da435e63a2665b85c0305ad2cf8a07b1af6d" # COMMIT -> v4.4-dev-416
    SOURCE_TYPE="COMMIT"
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
