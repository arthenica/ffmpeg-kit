#!/bin/bash

CURRENT_DIR=$(pwd)
BASEDIR="${CURRENT_DIR}/../../.."
PACKAGES_DIR_MAIN="${BASEDIR}/prebuilt/bundle-flutter-main"
PACKAGES_DIR_LTS="${BASEDIR}/prebuilt/bundle-flutter-lts"
SOURCE_DIR="${BASEDIR}/flutter/flutter"
PACKAGES=(min min-gpl https https-gpl audio video full full-gpl)

prepare_inline_sed() {
  if [ "$(uname)" == "Darwin" ]; then
    export SED_INLINE="sed -i .tmp"
  else
    export SED_INLINE="sed -i"
  fi
}

create_main_releases() {
  for CURRENT_PACKAGE in "${PACKAGES[@]}"; do
    local FLUTTER_PACKAGE_NAME="$(echo "${CURRENT_PACKAGE}" | sed "s/\-/\_/g")"
    local PACKAGE_PATH="${PACKAGES_DIR_MAIN}/${CURRENT_PACKAGE}"
    cp -R ${SOURCE_DIR} ${PACKAGE_PATH}

    # 1. pubspec
    $SED_INLINE "s|name: ffmpeg_kit_flutter|name: ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME|g" ${PACKAGE_PATH}/pubspec.yaml
    # UPDATE VERSION
    rm -f ${PACKAGE_PATH}/pubspec.yaml.tmp

    # 2. android
    # UPDATE MIN SDK VERSION
    $SED_INLINE "s|com.arthenica:.*|com.arthenica:ffmpeg-kit-$CURRENT_PACKAGE:$NATIVE_VERSION'|g" ${PACKAGE_PATH}/android/build.gradle
    rm -f ${PACKAGE_PATH}/android/build.gradle.tmp

    # 3. ios
    $SED_INLINE "s|ffmpeg_kit_flutter|ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME|g" ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter.podspec
    # UPDATE VERSION
    $SED_INLINE "s|s.default_subspec.*|s.default_subspec = '$CURRENT_PACKAGE'|g" ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter.podspec
    rm -f ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter.podspec.tmp
    mv ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter.podspec ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME.podspec

    # 4. macos
    $SED_INLINE "s|ffmpeg_kit_flutter|ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME|g" ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter.podspec
    # UPDATE VERSION
    $SED_INLINE "s|s.default_subspec.*|s.default_subspec = '$CURRENT_PACKAGE'|g" ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter.podspec
    rm -f ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter.podspec.tmp
    mv ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter.podspec ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME.podspec

  done;

  # CREATE DEFAULT PACKAGE
  cp -R "${SOURCE_DIR}" "${PACKAGES_DIR_MAIN}/default"

  echo "main releases created!"
}

create_lts_releases() {
  for CURRENT_PACKAGE in "${PACKAGES[@]}"; do
    local FLUTTER_PACKAGE_NAME="$(echo "${CURRENT_PACKAGE}" | sed "s/\-/\_/g")"
    local PACKAGE_PATH="${PACKAGES_DIR_LTS}/${CURRENT_PACKAGE}"
    cp -R ${SOURCE_DIR} ${PACKAGE_PATH}

    # 1. pubspec
    $SED_INLINE "s|name: ffmpeg_kit_flutter|name: ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME|g" ${PACKAGE_PATH}/pubspec.yaml
    $SED_INLINE "s|version: .*|version: $VERSION-LTS|g" ${PACKAGE_PATH}/pubspec.yaml
    rm -f ${PACKAGE_PATH}/pubspec.yaml.tmp

    # 2. android
    $SED_INLINE "s|minSdkVersion.*|minSdkVersion 16|g" ${PACKAGE_PATH}/android/build.gradle
    $SED_INLINE "s|com.arthenica:.*|com.arthenica:ffmpeg-kit-$CURRENT_PACKAGE:$NATIVE_VERSION.LTS'|g" ${PACKAGE_PATH}/android/build.gradle
    rm -f ${PACKAGE_PATH}/android/build.gradle.tmp

    # 3. ios
    $SED_INLINE "s|ffmpeg_kit_flutter|ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME|g" ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter.podspec
    $SED_INLINE "s|s.version.*|s.version = '$VERSION.LTS'|g" ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter.podspec
    $SED_INLINE "s|s.default_subspec.*|s.default_subspec = '$CURRENT_PACKAGE-lts'|g" ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter.podspec
    rm -f ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter.podspec.tmp
    mv ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter.podspec ${PACKAGE_PATH}/ios/ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME.podspec

    # 4. macos
    $SED_INLINE "s|ffmpeg_kit_flutter|ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME|g" ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter.podspec
    $SED_INLINE "s|s.version.*|s.version = '$VERSION.LTS'|g" ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter.podspec
    $SED_INLINE "s|s.default_subspec.*|s.default_subspec = '$CURRENT_PACKAGE-lts'|g" ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter.podspec
    rm -f ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter.podspec.tmp
    mv ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter.podspec ${PACKAGE_PATH}/macos/ffmpeg_kit_flutter_$FLUTTER_PACKAGE_NAME.podspec

  done;

  # CREATE DEFAULT PACKAGE
  cp -R "${PACKAGES_DIR_LTS}/https" "${PACKAGES_DIR_LTS}/default"
  $SED_INLINE "s|name: ffmpeg_kit_flutter_https|name: ffmpeg_kit_flutter|g" ${PACKAGES_DIR_LTS}/default/pubspec.yaml
  rm -f ${PACKAGES_DIR_LTS}/default/pubspec.yaml.tmp
  $SED_INLINE "s|ffmpeg_kit_flutter_https|ffmpeg_kit_flutter|g" ${PACKAGES_DIR_LTS}/default/ios/ffmpeg_kit_flutter_https.podspec
  rm -f ${PACKAGES_DIR_LTS}/default/ios/ffmpeg_kit_flutter_https.podspec.tmp
  mv ${PACKAGES_DIR_LTS}/default/ios/ffmpeg_kit_flutter_https.podspec ${PACKAGES_DIR_LTS}/default/ios/ffmpeg_kit_flutter.podspec
  $SED_INLINE "s|ffmpeg_kit_flutter_https|ffmpeg_kit_flutter|g" ${PACKAGES_DIR_LTS}/default/macos/ffmpeg_kit_flutter_https.podspec
  rm -f ${PACKAGES_DIR_LTS}/default/macos/ffmpeg_kit_flutter_https.podspec.tmp
  mv ${PACKAGES_DIR_LTS}/default/macos/ffmpeg_kit_flutter_https.podspec ${PACKAGES_DIR_LTS}/default/macos/ffmpeg_kit_flutter.podspec

  echo "lts releases created!"
}

if [[ $# -ne 2 ]];
then
    echo "Usage: create_package.sh <version name> <native library version>"
    exit 1
fi

VERSION="$1"
NATIVE_VERSION="$2"

rm -rf "${PACKAGES_DIR_MAIN}"
mkdir -p "${PACKAGES_DIR_MAIN}"
rm -rf "${PACKAGES_DIR_LTS}"
mkdir -p "${PACKAGES_DIR_LTS}"

prepare_inline_sed

create_main_releases;

create_lts_releases;
