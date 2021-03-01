#!/bin/bash

enable_default_architecture_variants() {
  ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_IPHONEOS]=1
  ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_IPHONESIMULATOR]=1
  ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_MAC_CATALYST]=1
  ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_APPLETVOS]=1
  ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_APPLETVSIMULATOR]=1
  ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_MACOS]=1
}

display_help() {
  COMMAND=$(echo "$0" | sed -e 's/\.\///g')

  echo -e "\n'$COMMAND' combines FFmpegKit frameworks created for apple architecture variants in an xcframework. \
It uses frameworks created under the prebuilt folder for iOS, tvOS and macOS architecture variants (iphoneos, \
iphonesimulator, mac-catalyst, appletvos, appletvsimulator, macosx) as input and builds an umbrella xcframework under \
the prebuilt folder.\n\n\
Additional options can be specified to disable architectures or to build xcframeworks for external libraries as well.\
\n\nPlease note that this script is only responsible of packaging existing frameworks, created by 'ios.sh', 'tvos.sh' \
and 'macos.sh'. Running it will not compile any of these libraries again. Enabling an external library means building \
an xcframework for that library. It does not guarantee that ffmpeg has support for it. Top level build scripts \
('ios.sh', 'tvos.sh', 'macos.sh') must be used to build ffmpeg with support for a specific external library first. \
After that this script should be used to create an umbrella xcframework.\n"
  echo -e "Usage: ./$COMMAND [OPTION]...\n"
  echo -e "Specify environment variables as VARIABLE=VALUE to override default build options.\n"

  echo -e "Options:"
  echo -e "  -h, --help\t\t\tdisplay this help and exit"
  echo -e "  -v, --version\t\t\tdisplay version information and exit"
  echo -e "  -f, --force\t\t\tignore warnings"
  echo -e "  -l, --lts\t\t\tinclude lts packages to support iOS 9.3+, tvOS 9.2+, macOS 10.11+ devices\n"

  echo -e "Licensing options:"
  echo -e "  --enable-gpl\t\t\tallow building umbrella xcframeworks for GPL libraries[no]\n"

  echo -e "Architectures:"
  echo -e "  --disable-iphoneos\t\tdo not include iphoneos architecture variant [yes]"
  echo -e "  --disable-iphonesimulator\tdo not include iphonesimulator architecture variant [yes]"
  echo -e "  --disable-mac-catalyst\tdo not include ios mac-catalyst architecture variant [yes]"
  echo -e "  --disable-appletvos\t\tdo not include appletvos architecture variant [yes]"
  echo -e "  --disable-appletvsimulator\tdo not include appletvsimulator architecture variant [yes]"
  echo -e "  --disable-macosx\t\tdo not include macosx architecture variant [yes]\n"

  echo -e "Libraries:"
  echo -e "  --full\t\t\tbuilds umbrella xcframeworks all non-GPL external libraries"
  echo -e "  --enable-chromaprint\t\tbuild umbrella xcframework for chromaprint [no]"
  echo -e "  --enable-dav1d\t\tbuild umbrella xcframework for dav1d [no]"
  echo -e "  --enable-fontconfig\t\tbuild umbrella xcframework for fontconfig [no]"
  echo -e "  --enable-freetype\t\tbuild umbrella xcframework for freetype [no]"
  echo -e "  --enable-fribidi\t\tbuild umbrella xcframework for fribidi [no]"
  echo -e "  --enable-gmp\t\t\tbuild umbrella xcframework for gmp [no]"
  echo -e "  --enable-gnutls\t\tbuild umbrella xcframework for gnutls [no]"
  echo -e "  --enable-kvazaar\t\tbuild umbrella xcframework for kvazaar [no]"
  echo -e "  --enable-lame\t\t\tbuild umbrella xcframework for lame [no]"
  echo -e "  --enable-libaom\t\tbuild umbrella xcframework for libaom [no]"
  echo -e "  --enable-libass\t\tbuild umbrella xcframework for libass [no]"
  echo -e "  --enable-libilbc\t\tbuild umbrella xcframework for libilbc [no]"
  echo -e "  --enable-libtheora\t\tbuild umbrella xcframework for libtheora [no]"
  echo -e "  --enable-libvorbis\t\tbuild umbrella xcframework for libvorbis [no]"
  echo -e "  --enable-libvpx\t\tbuild umbrella xcframework for libvpx [no]"
  echo -e "  --enable-libwebp\t\tbuild umbrella xcframework for libwebp [no]"
  echo -e "  --enable-libxml2\t\tbuild umbrella xcframework for libxml2 [no]"
  echo -e "  --enable-opencore-amr\t\tbuild umbrella xcframework for opencore-amr [no]"
  echo -e "  --enable-openh264\t\tbuild umbrella xcframework for openh264 [no]"
  echo -e "  --enable-opus\t\t\tbuild umbrella xcframework for opus [no]"
  echo -e "  --enable-sdl\t\t\tbuild umbrella xcframework for sdl [no]"
  echo -e "  --enable-shine\t\tbuild umbrella xcframework for shine [no]"
  echo -e "  --enable-snappy\t\tbuild umbrella xcframework for snappy [no]"
  echo -e "  --enable-soxr\t\t\tbuild umbrella xcframework for soxr [no]"
  echo -e "  --enable-speex\t\tbuild umbrella xcframework for speex [no]"
  echo -e "  --enable-tesseract\t\tbuild umbrella xcframework for tesseract [no]"
  echo -e "  --enable-twolame\t\tbuild umbrella xcframework for twolame [no]"
  echo -e "  --enable-vo-amrwbenc\t\tbuild umbrella xcframework for vo-amrwbenc [no]\n"

  echo -e "GPL libraries:"
  echo -e "  --enable-libvidstab\t\tbuild umbrella xcframework for libvidstab [no]"
  echo -e "  --enable-rubberband\t\tbuild umbrella xcframework for rubber band [no]"
  echo -e "  --enable-x264\t\t\tbuild umbrella xcframework for x264 [no]"
  echo -e "  --enable-x265\t\t\tbuild umbrella xcframework for x265 [no]"
  echo -e "  --enable-xvidcore\t\tbuild umbrella xcframework for xvidcore [no]\n"
}

initialize_prebuilt_umbrella_xcframework_folders() {
  echo -e "DEBUG: Initializing umbrella xcframework directory at ${ROOT_UMBRELLA_XCFRAMEWORK_DIRECTORY}\n" 1>>"${BASEDIR}"/build.log 2>&1

  mkdir -p "${ROOT_UMBRELLA_XCFRAMEWORK_DIRECTORY}" 1>>"${BASEDIR}"/build.log 2>&1
}

#
# 1. framework name
#
create_umbrella_xcframework() {
  local FRAMEWORK_NAME="$1"

  local XCFRAMEWORK_PATH="${ROOT_UMBRELLA_XCFRAMEWORK_DIRECTORY}/${FRAMEWORK_NAME}.xcframework"

  initialize_folder "${XCFRAMEWORK_PATH}"

  local BUILD_COMMAND="xcodebuild -create-xcframework "

  for ARCHITECTURE_VARIANT_INDEX in "${TARGET_ARCHITECTURE_VARIANT_INDEX_ARRAY[@]}"; do
    local FRAMEWORK_PATH=${BASEDIR}/prebuilt/$(get_framework_directory "${ARCHITECTURE_VARIANT_INDEX}")/${FRAMEWORK_NAME}.framework
    BUILD_COMMAND+=" -framework ${FRAMEWORK_PATH}"
  done

  BUILD_COMMAND+=" -output ${XCFRAMEWORK_PATH}"

  # EXECUTE CREATE FRAMEWORK COMMAND
  COMMAND_OUTPUT=$(${BUILD_COMMAND} 2>&1)
  RC=$?
  echo -e "DEBUG: ${COMMAND_OUTPUT}\n" 1>>"${BASEDIR}"/build.log 2>&1

  if [[ ${RC} -ne 0 ]]; then
    echo -e "INFO: Building ${FRAMEWORK_NAME} umbrella xcframework failed\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi

  # DO NOT ALLOW EMPTY FRAMEWORKS
  if [[ ${COMMAND_OUTPUT} == *"is empty in library"* ]]; then
    echo -e "INFO: Building ${FRAMEWORK_NAME} umbrella xcframework failed\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi
}

disable_arch_variant() {
  case $1 in
  iphoneos)
    ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_IPHONEOS]=0
    ;;
  iphonesimulator)
    ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_IPHONESIMULATOR]=0
    ;;
  mac-catalyst)
    ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_MAC_CATALYST]=0
    ;;
  appletvos)
    ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_APPLETVOS]=0
    ;;
  appletvsimulator)
    ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_APPLETVSIMULATOR]=0
    ;;
  macosx)
    ENABLED_ARCHITECTURE_VARIANTS[ARCH_VAR_MACOS]=0
    ;;
  *)
    print_unknown_arch_variant "$1"
    ;;
  esac
}

# CHECK IF XCODE IS INSTALLED
if [ ! -x "$(command -v xcrun)" ]; then
  echo -e "\n(*) xcrun command not found. Please check your Xcode installation\n"
  exit 1
fi

if [ ! -x "$(command -v xcodebuild)" ]; then
  echo -e "\n(*) xcodebuild command not found. Please check your Xcode installation\n"
  exit 1
fi

# LOAD INITIAL SETTINGS
export BASEDIR="$(pwd)"
source "${BASEDIR}"/scripts/variable.sh
export FFMPEG_KIT_BUILD_TYPE="apple"
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh

# SET DEFAULTS SETTINGS
enable_default_architecture_variants

# SELECT XCODE VERSION USED FOR BUILDING
XCODE_FOR_FFMPEG_KIT=$(ls ~/.xcode.for.ffmpeg.kit.sh)
if [[ -f ${XCODE_FOR_FFMPEG_KIT} ]]; then
  source "${XCODE_FOR_FFMPEG_KIT}" 1>>"${BASEDIR}"/build.log 2>&1
fi

# DETECT SDK VERSIONS
DETECTED_IOS_SDK_VERSION="$(xcrun --sdk iphoneos --show-sdk-version 2>>"${BASEDIR}"/build.log)"
DETECTED_TVOS_SDK_VERSION="$(xcrun --sdk appletvos --show-sdk-version 2>>"${BASEDIR}"/build.log)"
DETECTED_MACOS_SDK_VERSION="$(xcrun --sdk macosx --show-sdk-version 2>>"${BASEDIR}"/build.log)"
echo -e "INFO: Using iOS SDK: ${DETECTED_IOS_SDK_VERSION}, tvOS SDK: ${DETECTED_TVOS_SDK_VERSION}, macOS SDK: ${DETECTED_MACOS_SDK_VERSION} by Xcode provided at $(xcode-select -p)\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: Build options: $*\n" 1>>"${BASEDIR}"/build.log 2>&1

# SET DEFAULT BUILD OPTIONS
GPL_ENABLED="no"
DISPLAY_HELP=""
BUILD_TYPE_ID=""
BUILD_FULL=""
FFMPEG_KIT_XCF_BUILD=""
BUILD_FORCE=""
BUILD_VERSION=$(git describe --tags --always 2>>"${BASEDIR}"/build.log)
if [[ -z ${BUILD_VERSION} ]]; then
  echo -e "\n(*): Can not run git commands in this folder. See build.log.\n"
  exit 1
fi

# PROCESS LTS BUILD OPTION FIRST AND SET BUILD TYPE: MAIN OR LTS
for argument in "$@"; do
  if [[ "$argument" == "-l" ]] || [[ "$argument" == "--lts" ]]; then
    export FFMPEG_KIT_LTS_BUILD="1"
    BUILD_TYPE_ID+="LTS "
  fi
done

# PROCESS BUILD OPTIONS
while [ ! $# -eq 0 ]; do
  case $1 in
  -h | --help)
    DISPLAY_HELP="1"
    ;;
  -v | --version)
    display_version
    exit 0
    ;;
  -l | --lts) ;;
  -f | --force)
    export BUILD_FORCE="1"
    ;;
  --full)
    BUILD_FULL="1"
    ;;
  --enable-gpl)
    GPL_ENABLED="yes"
    ;;
  --enable-*)
    ENABLED_LIBRARY=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    enable_library "${ENABLED_LIBRARY}"
    ;;
  --disable-*)
    DISABLED_ARCH_VARIANT=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    disable_arch_variant "${DISABLED_ARCH_VARIANT}"
    ;;
  *)
    print_unknown_option "$1"
    ;;
  esac
  shift
done

# PROCESS FULL OPTION AS LAST OPTION
if [[ -n ${BUILD_FULL} ]]; then
  for library in {0..58}; do
    if [ ${GPL_ENABLED} == "yes" ]; then
      set_library "$(get_library_name "$library")" 1
    else
      if [[ $(is_gpl_licensed "$library") -eq 1 ]]; then
        set_library "$(get_library_name "$library")" 1
      fi
    fi
  done
fi

# IF HELP DISPLAYED EXIT
if [[ -n ${DISPLAY_HELP} ]]; then
  display_help
  exit 0
fi

echo -e "\nBuilding ffmpeg-kit ${BUILD_TYPE_ID}umbrella xcframework\n"
echo -e -n "INFO: Building ffmpeg-kit ${BUILD_VERSION} ${BUILD_TYPE_ID}umbrella xcframework: " 1>>"${BASEDIR}"/build.log 2>&1
echo -e "$(date)\n" 1>>"${BASEDIR}"/build.log 2>&1

# PRINT BUILD SUMMARY
print_enabled_architecture_variants
print_enabled_xcframeworks

echo ""

# VALIDATE GPL FLAGS
for gpl_library in {$LIBRARY_X264,$LIBRARY_XVIDCORE,$LIBRARY_X265,$LIBRARY_LIBVIDSTAB,$LIBRARY_RUBBERBAND}; do
  if [[ ${ENABLED_LIBRARIES[$gpl_library]} -eq 1 ]]; then
    library_name=$(get_library_name "${gpl_library}")

    if [ ${GPL_ENABLED} != "yes" ]; then
      echo -e "\n(*) Invalid configuration detected. GPL library ${library_name} enabled without --enable-gpl flag.\n"
      echo -e "\n(*) Invalid configuration detected. GPL library ${library_name} enabled without --enable-gpl flag.\n" 1>>"${BASEDIR}"/build.log 2>&1
      exit 1
    fi
  fi
done

# THIS WILL SAVE ARCHITECTURE VARIANTS TO BE INCLUDED
TARGET_ARCHITECTURE_VARIANT_INDEX_ARRAY=()

# SAVE ARCHITECTURE VARIANTS
for run_arch_variant in {1..8}; do
  if [[ ${ENABLED_ARCHITECTURE_VARIANTS[$run_arch_variant]} -eq 1 ]]; then
    case "$run_arch_variant" in
    1 | 5) ;;
    *)
      TARGET_ARCHITECTURE_VARIANT_INDEX_ARRAY+=("${run_arch_variant}")
      ;;
    esac
  fi
done

# BUILD XCFRAMEWORKS
if [[ -n ${TARGET_ARCHITECTURE_VARIANT_INDEX_ARRAY[0]} ]]; then

  ROOT_UMBRELLA_XCFRAMEWORK_DIRECTORY=${BASEDIR}/prebuilt/$(get_umbrella_xcframework_directory)

  echo -e -n "Creating umbrella xcframeworks under prebuilt: "

  # INITIALIZE TARGET FOLDERS
  initialize_prebuilt_umbrella_xcframework_folders

  # BUILD XCFRAMEWORKS FOR ENABLED LIBRARIES ON ENABLED ARCHITECTURE VARIANTS
  for library in {0..46}; do
    if [[ ${ENABLED_LIBRARIES[${library}]} -eq 1 ]]; then

      if [[ ${LIBRARY_LIBTHEORA} == "${library}" ]]; then

        create_umbrella_xcframework "libtheora"
        create_umbrella_xcframework "libtheoraenc"
        create_umbrella_xcframework "libtheoradec"

      elif [[ ${LIBRARY_LIBVORBIS} == "${library}" ]]; then

        create_umbrella_xcframework "libvorbisfile"
        create_umbrella_xcframework "libvorbisenc"
        create_umbrella_xcframework "libvorbis"

      elif [[ ${LIBRARY_LIBWEBP} == "${library}" ]]; then

        create_umbrella_xcframework "libwebpmux"
        create_umbrella_xcframework "libwebpdemux"
        create_umbrella_xcframework "libwebp"

      elif [[ ${LIBRARY_OPENCOREAMR} == "${library}" ]]; then

        create_umbrella_xcframework "libopencore-amrnb"

      elif [[ ${LIBRARY_NETTLE} == "${library}" ]]; then

        create_umbrella_xcframework "libnettle"
        create_umbrella_xcframework "libhogweed"

      else

        create_umbrella_xcframework "$(get_static_archive_name "${library}")"

      fi
    fi
  done

  for FFMPEG_LIB in "${FFMPEG_LIBS[@]}"; do
    create_umbrella_xcframework "${FFMPEG_LIB}"
  done

  create_umbrella_xcframework "ffmpegkit"

  echo -e -n "INFO: Umbrella xcframeworks created successfully\n\n" 1>>"${BASEDIR}"/build.log 2>&1
  echo -e "ok\n"
fi
