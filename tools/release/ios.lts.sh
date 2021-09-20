#!/bin/bash
#
# Creates a new ios lts release from the current branch
#

source ./common.sh
export SOURCE_PACKAGE="${BASEDIR}/../../prebuilt/bundle-apple-framework-ios-lts"
export COCOAPODS_DIRECTORY="${BASEDIR}/../../prebuilt/bundle-apple-cocoapods-ios-lts"
export SOURCE_UNIVERSAL_PACKAGE="${BASEDIR}/../../prebuilt/bundle-apple-universal-ios-lts"
export ALL_UNIVERSAL_DIRECTORY="${BASEDIR}/../../prebuilt/bundle-apple-all-universal-ios-lts"

create_package() {
    local PACKAGE_NAME="ffmpeg-kit-ios-$1"
    local PACKAGE_VERSION="$2"
    local PACKAGE_DESCRIPTION="$3"

    local CURRENT_PACKAGE="${COCOAPODS_DIRECTORY}/${PACKAGE_NAME}"
    rm -rf "${CURRENT_PACKAGE}"
    mkdir -p "${CURRENT_PACKAGE}" || exit 1

    cp -r "${SOURCE_PACKAGE}"/* "${CURRENT_PACKAGE}" || exit 1
    cd "${CURRENT_PACKAGE}" || exit 1
    zip -r "../ffmpeg-kit-$1-${PACKAGE_VERSION}-ios-framework.zip" * || exit 1

    # COPY PODSPEC AS THE LAST ITEM
    cp "${BASEDIR}"/apple/"${PACKAGE_NAME}".podspec "${CURRENT_PACKAGE}" || exit 1
    sed -i '' "s/VERSION/${PACKAGE_VERSION}/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/DESCRIPTION/${PACKAGE_DESCRIPTION}/g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/\,\'AVFoundation\'//g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1
    sed -i '' "s/\,\'VideoToolbox\'//g" "${CURRENT_PACKAGE}"/"${PACKAGE_NAME}".podspec || exit 1

    mkdir -p "${ALL_UNIVERSAL_DIRECTORY}" || exit 1
    local CURRENT_UNIVERSAL_PACKAGE="${ALL_UNIVERSAL_DIRECTORY}/${PACKAGE_NAME}-universal"
    rm -rf "${CURRENT_UNIVERSAL_PACKAGE}"
    mkdir -p "${CURRENT_UNIVERSAL_PACKAGE}"/include || exit 1
    mkdir -p "${CURRENT_UNIVERSAL_PACKAGE}"/lib || exit 1

    cd "${SOURCE_UNIVERSAL_PACKAGE}" || exit 1
    find . -name "*.a" -exec cp {} "${CURRENT_UNIVERSAL_PACKAGE}"/lib \;  || exit 1

    # COPY THE LICENSE FILE OF EACH LIBRARY
    LICENSE_FILES=$(find . -name LICENSE | grep -vi ffmpeg)

    for LICENSE_FILE in ${LICENSE_FILES[@]}
    do
        LIBRARY_NAME=$(echo "${LICENSE_FILE}" | sed 's/\.\///g;s/\/LICENSE//g')
        cp "${LICENSE_FILE}" "${CURRENT_UNIVERSAL_PACKAGE}"/LICENSE."${LIBRARY_NAME}" || exit 1
    done

    cp -r "${SOURCE_UNIVERSAL_PACKAGE}"/ffmpeg-kit/include/* "${CURRENT_UNIVERSAL_PACKAGE}"/include || exit 1
    cp -r "${SOURCE_UNIVERSAL_PACKAGE}"/ffmpeg/include/* "${CURRENT_UNIVERSAL_PACKAGE}"/include || exit 1
    cp "${SOURCE_UNIVERSAL_PACKAGE}"/ffmpeg/LICENSE "${CURRENT_UNIVERSAL_PACKAGE}"/LICENSE || exit 1

    cd "${ALL_UNIVERSAL_DIRECTORY}" || exit 1
    zip -r "ffmpeg-kit-$1-${PACKAGE_VERSION}-ios-static-universal.zip" "${PACKAGE_NAME}"-universal || exit 1
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

rm -rf "${ALL_UNIVERSAL_DIRECTORY}"
mkdir -p "${ALL_UNIVERSAL_DIRECTORY}" || exit 1

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
