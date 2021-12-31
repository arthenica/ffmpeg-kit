#!/bin/bash
#
# Creates a new android release from the current branch
#

RELEASE_TYPE=android

source ./common.sh
export PACKAGE_DIRECTORY="${BASEDIR}/../../prebuilt/bundle-android-aar/ffmpeg-kit"

create_package() {
  local NEW_PACKAGE="${PACKAGE_DIRECTORY}/ffmpeg-kit-$1-$2.aar"

  local CURRENT_PACKAGE="${PACKAGE_DIRECTORY}/ffmpeg-kit.aar"
  rm -f "${NEW_PACKAGE}"

  mv "${CURRENT_PACKAGE}" "${NEW_PACKAGE}" || exit 1
}

if [ $# -ne 1 ]; then
  echo "Usage: android.sh <version name>"
  exit 1
fi

VERSION_CODE="${ANDROID_MAIN_MIN_SDK}0"$(echo $1 | sed "s/\.//g")"0"
export VERSION_CODE=${VERSION_CODE:0:6}

# VALIDATE VERSIONS
if [[ "${ANDROID_FFMPEG_KIT_VERSION}" != "$1" ]]; then
  echo "Error: version mismatch. v$1 requested but v${ANDROID_FFMPEG_KIT_VERSION} found. Please perform the following updates and try again."
  echo "1. Update docs"
  echo "2. Update gradle files under the tools/release/android folder"
  echo "3. Update the versions in tools/release/common.sh"
  echo "4. Update ffmpegkit.h versions for both android and ios"
  echo "5. Update versions in Doxyfile"
  exit 1
fi

# MIN RELEASE
cd "${BASEDIR}/../.." || exit 1
./android.sh ${ANDROID_MAIN_OPTIONS} || exit 1
cd "${BASEDIR}"/../../android/ffmpeg-kit-android-lib || exit 1
gradle -p "${BASEDIR}"/../../android/ffmpeg-kit-android-lib -DreleaseFFmpegKit=true -PreleaseVersionCode="${VERSION_CODE}" -PreleaseVersionName="$1" -PreleaseMinSdk="${ANDROID_MAIN_MIN_SDK}" -PreleaseTargetSdk="${ANDROID_TARGET_SDK}" -PreleaseProject=ffmpeg-kit-min -PreleaseProjectDescription="${LIBRARY_DESCRIPTION_MIN}" uploadArchives || exit 1
create_package "min" "$1" || exit 1

# MIN-GPL RELEASE
cd "${BASEDIR}/../.." || exit 1
./android.sh ${ANDROID_MAIN_OPTIONS} ${GPL_PACKAGES} || exit 1
cd "${BASEDIR}"/../../android/ffmpeg-kit-android-lib || exit 1
gradle -p "${BASEDIR}"/../../android/ffmpeg-kit-android-lib -DreleaseFFmpegKit=true -PreleaseVersionCode="${VERSION_CODE}" -PreleaseVersionName="$1" -PreleaseMinSdk="${ANDROID_MAIN_MIN_SDK}" -PreleaseTargetSdk="${ANDROID_TARGET_SDK}" -PreleaseProject=ffmpeg-kit-min-gpl -PreleaseProjectDescription="${LIBRARY_DESCRIPTION_MIN_GPL}" -PreleaseGPL=1 uploadArchives || exit 1
create_package "min-gpl" "$1" || exit 1

# HTTPS RELEASE
cd "${BASEDIR}/../.." || exit 1
./android.sh ${ANDROID_MAIN_OPTIONS} ${HTTPS_PACKAGES} || exit 1
cd "${BASEDIR}"/../../android/ffmpeg-kit-android-lib || exit 1
gradle -p "${BASEDIR}"/../../android/ffmpeg-kit-android-lib -DreleaseFFmpegKit=true -PreleaseVersionCode="${VERSION_CODE}" -PreleaseVersionName="$1" -PreleaseMinSdk="${ANDROID_MAIN_MIN_SDK}" -PreleaseTargetSdk="${ANDROID_TARGET_SDK}" -PreleaseProject=ffmpeg-kit-https -PreleaseProjectDescription="${LIBRARY_DESCRIPTION_HTTPS}" uploadArchives || exit 1
create_package "https" "$1" || exit 1

# HTTPS-GPL RELEASE
cd "${BASEDIR}/../.." || exit 1
./android.sh ${ANDROID_MAIN_OPTIONS} ${HTTPS_PACKAGES} ${GPL_PACKAGES} || exit 1
cd "${BASEDIR}"/../../android/ffmpeg-kit-android-lib || exit 1
gradle -p "${BASEDIR}"/../../android/ffmpeg-kit-android-lib -DreleaseFFmpegKit=true -PreleaseVersionCode="${VERSION_CODE}" -PreleaseVersionName="$1" -PreleaseMinSdk="${ANDROID_MAIN_MIN_SDK}" -PreleaseTargetSdk="${ANDROID_TARGET_SDK}" -PreleaseProject=ffmpeg-kit-https-gpl -PreleaseProjectDescription="${LIBRARY_DESCRIPTION_HTTPS_GPL}" -PreleaseGPL=1 uploadArchives || exit 1
create_package "https-gpl" "$1" || exit 1

# AUDIO RELEASE
cd "${BASEDIR}/../.." || exit 1
./android.sh ${ANDROID_MAIN_OPTIONS} ${AUDIO_PACKAGES} || exit 1
cd "${BASEDIR}"/../../android/ffmpeg-kit-android-lib || exit 1
gradle -p "${BASEDIR}"/../../android/ffmpeg-kit-android-lib -DreleaseFFmpegKit=true -PreleaseVersionCode="${VERSION_CODE}" -PreleaseVersionName="$1" -PreleaseMinSdk="${ANDROID_MAIN_MIN_SDK}" -PreleaseTargetSdk="${ANDROID_TARGET_SDK}" -PreleaseProject=ffmpeg-kit-audio -PreleaseProjectDescription="${LIBRARY_DESCRIPTION_AUDIO}" uploadArchives || exit 1
create_package "audio" "$1" || exit 1

# VIDEO RELEASE
cd "${BASEDIR}/../.." || exit 1
./android.sh ${ANDROID_MAIN_OPTIONS} ${VIDEO_PACKAGES} || exit 1
cd "${BASEDIR}"/../../android/ffmpeg-kit-android-lib || exit 1
gradle -p "${BASEDIR}"/../../android/ffmpeg-kit-android-lib -DreleaseFFmpegKit=true -PreleaseVersionCode="${VERSION_CODE}" -PreleaseVersionName="$1" -PreleaseMinSdk="${ANDROID_MAIN_MIN_SDK}" -PreleaseTargetSdk="${ANDROID_TARGET_SDK}" -PreleaseProject=ffmpeg-kit-video -PreleaseProjectDescription="${LIBRARY_DESCRIPTION_VIDEO}" uploadArchives || exit 1
create_package "video" "$1" || exit 1

# FULL RELEASE
cd "${BASEDIR}/../.." || exit 1
./android.sh ${ANDROID_MAIN_OPTIONS} ${FULL_PACKAGES} || exit 1
cd "${BASEDIR}"/../../android/ffmpeg-kit-android-lib || exit 1
gradle -p "${BASEDIR}"/../../android/ffmpeg-kit-android-lib -DreleaseFFmpegKit=true -PreleaseVersionCode="${VERSION_CODE}" -PreleaseVersionName="$1" -PreleaseMinSdk="${ANDROID_MAIN_MIN_SDK}" -PreleaseTargetSdk="${ANDROID_TARGET_SDK}" -PreleaseProject=ffmpeg-kit-full -PreleaseProjectDescription="${LIBRARY_DESCRIPTION_FULL}" uploadArchives || exit 1
create_package "full" "$1" || exit 1

cd "${BASEDIR}/../.." || exit 1
./android.sh ${ANDROID_MAIN_OPTIONS} ${FULL_PACKAGES} ${GPL_PACKAGES} || exit 1
cd "${BASEDIR}"/../../android/ffmpeg-kit-android-lib || exit 1
gradle -p "${BASEDIR}"/../../android/ffmpeg-kit-android-lib -DreleaseFFmpegKit=true -PreleaseVersionCode="${VERSION_CODE}" -PreleaseVersionName="$1" -PreleaseMinSdk="${ANDROID_MAIN_MIN_SDK}" -PreleaseTargetSdk="${ANDROID_TARGET_SDK}" -PreleaseProject=ffmpeg-kit-full-gpl -PreleaseProjectDescription="${LIBRARY_DESCRIPTION_FULL_GPL}" -PreleaseGPL=1 uploadArchives || exit 1
create_package "full-gpl" "$1" || exit 1
