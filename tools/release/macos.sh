#!/bin/bash
#
# Creates a new macos release from the current branch
#

source ./common.sh
export SOURCE_PACKAGE="${BASEDIR}/../../prebuilt/bundle-apple-xcframework-macos"
export COCOAPODS_DIRECTORY="${BASEDIR}/../../prebuilt/bundle-apple-cocoapods-macos"

create_package() {
    local PACKAGE_NAME="ffmpeg-kit-macos-$1"
    local PACKAGE_VERSION="$2"
    local PACKAGE_DESCRIPTION="$3"

    local CURRENT_PACKAGE="${COCOAPODS_DIRECTORY}/${PACKAGE_NAME}"
    rm -rf "${CURRENT_PACKAGE}"
    mkdir -p "${CURRENT_PACKAGE}" || exit 1

    cp -R "${SOURCE_PACKAGE}"/* "${CURRENT_PACKAGE}" || exit 1
    cd "${CURRENT_PACKAGE}" || exit 1
    zip -r -y "../ffmpeg-kit-$1-${PACKAGE_VERSION}-macos-xcframework.zip" * || exit 1

    # COPY PODSPEC AS THE LAST ITEM
    cp "${BASEDIR}"/apple/"${PACKAGE_NAME}".podspec "${CURRENT_PACKAGE}" || exit 1
    sed -i '' "s/VERSION/${PACKAGE_VERSION}/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/DESCRIPTION/${PACKAGE_DESCRIPTION}/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/\.framework/\.xcframework/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/-framework/-xcframework/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/osx\.xcframeworks/osx\.frameworks/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/10\.12/10\.15/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/ffmpegkit\.xcframework\/LICENSE/ffmpegkit\.xcframework\/macos-arm64_x86_64\/ffmpegkit\.framework\/LICENSE/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
}

if [[ $# -ne 1 ]];
then
    echo "Usage: macos.sh <version name>"
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
./macos.sh ${MACOS_MAIN_OPTIONS} || exit 1
create_package "min" "$1" "${LIBRARY_DESCRIPTION_MIN}" || exit 1

# MIN-GPL RELEASE
cd "${BASEDIR}/../.." || exit 1
./macos.sh ${MACOS_MAIN_OPTIONS} ${GPL_PACKAGES} || exit 1
create_package "min-gpl" "$1" "${LIBRARY_DESCRIPTION_MIN_GPL}" || exit 1

# HTTPS RELEASE
cd "${BASEDIR}/../.." || exit 1
./macos.sh ${MACOS_MAIN_OPTIONS} ${HTTPS_PACKAGES} || exit 1
create_package "https" "$1" "${LIBRARY_DESCRIPTION_HTTPS}" || exit 1

# HTTPS-GPL RELEASE
cd "${BASEDIR}/../.." || exit 1
./macos.sh ${MACOS_MAIN_OPTIONS} ${HTTPS_PACKAGES} ${GPL_PACKAGES} || exit 1
create_package "https-gpl" "$1" "${LIBRARY_DESCRIPTION_HTTPS_GPL}" || exit 1

# AUDIO RELEASE
cd "${BASEDIR}/../.." || exit 1
./macos.sh ${MACOS_MAIN_OPTIONS} ${AUDIO_PACKAGES} || exit 1
create_package "audio" "$1" "${LIBRARY_DESCRIPTION_AUDIO}" || exit 1

# VIDEO RELEASE
cd "${BASEDIR}/../.." || exit 1
./macos.sh ${MACOS_MAIN_OPTIONS} ${VIDEO_PACKAGES} || exit 1
create_package "video" "$1" "${LIBRARY_DESCRIPTION_VIDEO}" || exit 1

# FULL RELEASE
cd "${BASEDIR}/../.." || exit 1
./macos.sh ${MACOS_MAIN_OPTIONS} ${FULL_PACKAGES} || exit 1
create_package "full" "$1" "${LIBRARY_DESCRIPTION_FULL}" || exit 1

# FULL-GPL RELEASE
cd "${BASEDIR}/../.." || exit 1
./macos.sh ${MACOS_MAIN_OPTIONS} ${FULL_PACKAGES} ${GPL_PACKAGES} || exit 1
create_package "full-gpl" "$1" "${LIBRARY_DESCRIPTION_FULL_GPL}" || exit 1
