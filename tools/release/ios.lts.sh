#!/bin/bash
#
# Creates a new ios lts release from the current branch
#

source ./common.sh
export SOURCE_PACKAGE="${BASEDIR}/../../prebuilt/bundle-apple-framework-ios-lts"
export COCOAPODS_DIRECTORY="${BASEDIR}/../../prebuilt/bundle-apple-cocoapods-ios-lts"

create_package() {
    local PACKAGE_NAME="ffmpeg-kit-ios-$1"
    local PACKAGE_VERSION="$2"
    local PACKAGE_DESCRIPTION="$3"

    local CURRENT_PACKAGE="${COCOAPODS_DIRECTORY}/${PACKAGE_NAME}"
    rm -rf "${CURRENT_PACKAGE}"
    mkdir -p "${CURRENT_PACKAGE}" || exit 1

    cp -R "${SOURCE_PACKAGE}"/* "${CURRENT_PACKAGE}" || exit 1
    cd "${CURRENT_PACKAGE}" || exit 1
    zip -r -y "../ffmpeg-kit-$1-${PACKAGE_VERSION}-ios-framework.zip" * || exit 1

    # COPY PODSPEC AS THE LAST ITEM
    cp "${BASEDIR}"/apple/"${PACKAGE_NAME}".podspec "${CURRENT_PACKAGE}" || exit 1
    sed -i '' "s/VERSION/${PACKAGE_VERSION}/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/DESCRIPTION/${PACKAGE_DESCRIPTION}/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/\,\'AVFoundation\'//g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/\,\'VideoToolbox\'//g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
}

if [[ $# -ne 1 ]];
then
    echo "Usage: ios.lts.sh <version name>"
    exit 1
fi

# VALIDATE VERSIONS
if [[ "${APPLE_FFMPEG_KIT_VERSION}" != "$1" ]]; then
    echo "Error: version mismatch. v$1 requested but v${APPLE_FFMPEG_KIT_VERSION} found. Please perform the following updates and try again."
    echo "1. Update docs"
    echo "2. Update gradle files under the tools/release/android folder"
    echo "3. Update the versions in tools/release/common.sh"
    echo "4. Update podspec links"
    echo "5. Update ffmpegkit.h versions for both android and apple"
    echo "6. Update versions in Doxyfile"
    exit 1
fi

# CREATE COCOAPODS DIRECTORY
rm -rf "${COCOAPODS_DIRECTORY}"
mkdir -p "${COCOAPODS_DIRECTORY}" || exit 1

# MIN RELEASE
cd "${BASEDIR}/../.." || exit 1
./ios.sh ${IOS_LTS_OPTIONS} || exit 1
create_package "min" "$1.LTS" "${LIBRARY_DESCRIPTION_MIN}" || exit 1

# MIN-GPL RELEASE
cd "${BASEDIR}/../.." || exit 1
./ios.sh ${IOS_LTS_OPTIONS} ${GPL_PACKAGES} || exit 1
create_package "min-gpl" "$1.LTS" "${LIBRARY_DESCRIPTION_MIN_GPL}" || exit 1

# HTTPS RELEASE
cd "${BASEDIR}/../.." || exit 1
./ios.sh ${IOS_LTS_OPTIONS} ${HTTPS_PACKAGES} || exit 1
create_package "https" "$1.LTS" "${LIBRARY_DESCRIPTION_HTTPS}" || exit 1

# HTTPS-GPL RELEASE
cd "${BASEDIR}/../.." || exit 1
./ios.sh ${IOS_LTS_OPTIONS} ${HTTPS_PACKAGES} ${GPL_PACKAGES} || exit 1
create_package "https-gpl" "$1.LTS" "${LIBRARY_DESCRIPTION_HTTPS_GPL}" || exit 1

# AUDIO RELEASE
cd "${BASEDIR}/../.." || exit 1
./ios.sh ${IOS_LTS_OPTIONS} ${AUDIO_PACKAGES} || exit 1
create_package "audio" "$1.LTS" "${LIBRARY_DESCRIPTION_AUDIO}" || exit 1

# VIDEO RELEASE
cd "${BASEDIR}/../.." || exit 1
./ios.sh ${IOS_LTS_OPTIONS} ${VIDEO_PACKAGES} || exit 1
create_package "video" "$1.LTS" "${LIBRARY_DESCRIPTION_VIDEO}" || exit 1

# FULL RELEASE
cd "${BASEDIR}/../.." || exit 1
./ios.sh ${IOS_LTS_OPTIONS} ${FULL_PACKAGES} || exit 1
create_package "full" "$1.LTS" "${LIBRARY_DESCRIPTION_FULL}" || exit 1

# FULL-GPL RELEASE
cd "${BASEDIR}/../.." || exit 1
./ios.sh ${IOS_LTS_OPTIONS} ${FULL_PACKAGES} ${GPL_PACKAGES} || exit 1
create_package "full-gpl" "$1.LTS" "${LIBRARY_DESCRIPTION_FULL_GPL}" || exit 1
