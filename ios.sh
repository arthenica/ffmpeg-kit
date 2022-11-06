#!/bin/bash

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
export FFMPEG_KIT_BUILD_TYPE="ios"
source "${BASEDIR}"/scripts/variable.sh
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh
disabled_libraries=()

# SET DEFAULTS SETTINGS
enable_default_ios_architectures

# SELECT XCODE VERSION USED FOR BUILDING
XCODE_FOR_FFMPEG_KIT=$(ls ~/.xcode.for.ffmpeg.kit.sh 2>>"${BASEDIR}"/build.log)
if [[ -f ${XCODE_FOR_FFMPEG_KIT} ]]; then
  source "${XCODE_FOR_FFMPEG_KIT}" 1>>"${BASEDIR}"/build.log 2>&1
fi

# DETECT IOS SDK VERSION
export DETECTED_IOS_SDK_VERSION="$(xcrun --sdk iphoneos --show-sdk-version 2>>${BASEDIR}/build.log)"
echo -e "\nINFO: Using SDK ${DETECTED_IOS_SDK_VERSION} by Xcode provided at $(xcode-select -p)\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: Build options: $*\n" 1>>"${BASEDIR}"/build.log 2>&1

# SET DEFAULT BUILD OPTIONS
export GPL_ENABLED="no"
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

# MAIN BUILDS ENABLED BY DEFAULT
enable_main_build

# PROCESS LTS BUILD OPTION FIRST AND SET BUILD TYPE: MAIN OR LTS
for argument in "$@"; do
  if [[ "$argument" == "-l" ]] || [[ "$argument" == "--lts" ]]; then
    enable_lts_build
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
  --skip-*)
    SKIP_LIBRARY=$(echo "$1" | sed -e 's/^--[A-Za-z]*-//g')

    skip_library "${SKIP_LIBRARY}"
    ;;
  --no-bitcode)
    export NO_BITCODE="1"
    ;;
  --no-framework)
    NO_FRAMEWORK="1"
    ;;
  --no-output-redirection)
    no_output_redirection
    ;;
  --no-workspace-cleanup-*)
    NO_WORKSPACE_CLEANUP_LIBRARY=$(echo $1 | sed -e 's/^--[A-Za-z]*-[A-Za-z]*-[A-Za-z]*-//g')

    no_workspace_cleanup_library "${NO_WORKSPACE_CLEANUP_LIBRARY}"
    ;;
  -d | --debug)
    enable_debug
    ;;
  -s | --speed)
    optimize_for_speed
    ;;
  -l | --lts) ;;
  -x | --xcframework)
    FFMPEG_KIT_XCF_BUILD="1"
    ;;
  -f | --force)
    export BUILD_FORCE="1"
    ;;
  --reconf-*)
    CONF_LIBRARY=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    reconf_library "${CONF_LIBRARY}"
    ;;
  --rebuild-*)
    BUILD_LIBRARY=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    rebuild_library "${BUILD_LIBRARY}"
    ;;
  --redownload-*)
    DOWNLOAD_LIBRARY=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    redownload_library "${DOWNLOAD_LIBRARY}"
    ;;
  --full)
    BUILD_FULL="1"
    ;;
  --enable-gpl)
    export GPL_ENABLED="yes"
    ;;
  --enable-custom-library-*)
    CUSTOM_LIBRARY_OPTION_KEY=$(echo $1 | sed -e 's/^--enable-custom-//g;s/=.*$//g')
    CUSTOM_LIBRARY_OPTION_VALUE=$(echo $1 | sed -e 's/^--enable-custom-.*=//g')

    echo -e "INFO: Custom library options detected: ${CUSTOM_LIBRARY_OPTION_KEY} ${CUSTOM_LIBRARY_OPTION_VALUE}\n" 1>>"${BASEDIR}"/build.log 2>&1

    generate_custom_library_environment_variables "${CUSTOM_LIBRARY_OPTION_KEY}" "${CUSTOM_LIBRARY_OPTION_VALUE}"
    ;;
  --enable-*)
    ENABLED_LIBRARY=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    enable_library "${ENABLED_LIBRARY}"
    ;;
  --disable-lib-*)
    DISABLED_LIB=$(echo $1 | sed -e 's/^--[A-Za-z]*-[A-Za-z]*-//g')

    disabled_libraries+=("${DISABLED_LIB}")
    ;;
  --disable-*)
    DISABLED_ARCH=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    disable_arch "${DISABLED_ARCH}"
    ;;
  --target=*)
    TARGET=$(echo $1 | sed -e 's/^--[A-Za-z]*=//g')

    export IOS_MIN_VERSION=${TARGET}
    ;;
  --mac-catalyst-target=*)
    TARGET=$(echo $1 | sed -e 's/^--[A-Za-z]*-[A-Za-z]*-[A-Za-z]*=//g')

    export MAC_CATALYST_MIN_VERSION=${TARGET}
    ;;
  *)
    print_unknown_option "$1"
    ;;
  esac
  shift
done

# PROCESS FULL OPTION AS LAST OPTION
if [[ -n ${BUILD_FULL} ]]; then
  for library in {0..61}; do
    if [ ${GPL_ENABLED} == "yes" ]; then
      enable_library "$(get_library_name "$library")" 1
    else
      if [[ $(is_gpl_licensed "$library") -eq 1 ]]; then
        enable_library "$(get_library_name "$library")" 1
      fi
    fi
  done
fi

# DISABLE SPECIFIED LIBRARIES
for disabled_library in ${disabled_libraries[@]}; do
  set_library "${disabled_library}" 0
done

# IF HELP DISPLAYED EXIT
if [[ -n ${DISPLAY_HELP} ]]; then
  display_help
  exit 0
fi

# DISABLE NOT SUPPORTED ARCHITECTURES
disable_ios_architecture_not_supported_on_detected_sdk_version "${ARCH_ARMV7}"
disable_ios_architecture_not_supported_on_detected_sdk_version "${ARCH_ARMV7S}"
disable_ios_architecture_not_supported_on_detected_sdk_version "${ARCH_I386}"
disable_ios_architecture_not_supported_on_detected_sdk_version "${ARCH_ARM64E}"
disable_ios_architecture_not_supported_on_detected_sdk_version "${ARCH_X86_64_MAC_CATALYST}"
disable_ios_architecture_not_supported_on_detected_sdk_version "${ARCH_ARM64_MAC_CATALYST}"
disable_ios_architecture_not_supported_on_detected_sdk_version "${ARCH_ARM64_SIMULATOR}"

# CHECK SOME RULES FOR .framework BUNDLES

# 1. DISABLE arm64-mac-catalyst IN framework BUNDLES
if [[ ${NO_FRAMEWORK} -ne 1 ]] && [[ -z ${FFMPEG_KIT_XCF_BUILD} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_ARM64_MAC_CATALYST}]} -eq 1 ]]; then
  echo -e "INFO: Disabled arm64-mac-catalyst architecture which cannot exist in a framework bundle.\n" 1>>"${BASEDIR}"/build.log 2>&1
  disable_arch "arm64-mac-catalyst"
fi

# 2. DISABLE x86-64-mac-catalyst IN framework BUNDLES
if [[ ${NO_FRAMEWORK} -ne 1 ]] && [[ -z ${FFMPEG_KIT_XCF_BUILD} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_X86_64_MAC_CATALYST}]} -eq 1 ]]; then
  echo -e "INFO: Disabled x86-64-mac-catalyst architecture which cannot exist in a framework bundle.\n" 1>>"${BASEDIR}"/build.log 2>&1
  disable_arch "x86-64-mac-catalyst"
fi

# 3. DISABLE arm64-simulator WHEN arm64 IS ENABLED IN framework BUNDLES
if [[ ${NO_FRAMEWORK} -ne 1 ]] && [[ -z ${FFMPEG_KIT_XCF_BUILD} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_ARM64}]} -eq 1 ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_ARM64_SIMULATOR}]} -eq 1 ]]; then
  echo -e "INFO: Disabled arm64-simulator architecture which cannot co-exist with arm64 in the same framework bundle.\n" 1>>"${BASEDIR}"/build.log 2>&1
  disable_arch "arm64-simulator"
fi

echo -e "\nBuilding ffmpeg-kit ${BUILD_TYPE_ID}shared library for iOS\n"
echo -e -n "INFO: Building ffmpeg-kit ${BUILD_VERSION} ${BUILD_TYPE_ID}for iOS: " 1>>"${BASEDIR}"/build.log 2>&1
echo -e "$(date)\n" 1>>"${BASEDIR}"/build.log 2>&1

# PRINT BUILD SUMMARY
print_enabled_architectures
print_enabled_libraries
print_reconfigure_requested_libraries
print_rebuild_requested_libraries
print_redownload_requested_libraries
print_custom_libraries

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

echo -n -e "\nDownloading sources: "
echo -e "INFO: Downloading the source code of ffmpeg and external libraries.\n" 1>>"${BASEDIR}"/build.log 2>&1

# DOWNLOAD GNU CONFIG
download_gnu_config

# DOWNLOAD LIBRARY SOURCES
downloaded_library_sources "${ENABLED_LIBRARIES[@]}"

# THIS WILL SAVE ARCHITECTURES TO BUILD
TARGET_ARCH_LIST=()

# BUILD ENABLED LIBRARIES ON ENABLED ARCHITECTURES
for run_arch in {0..12}; do
  if [[ ${ENABLED_ARCHITECTURES[$run_arch]} -eq 1 ]]; then
    export ARCH=$(get_arch_name "$run_arch")
    export FULL_ARCH=$(get_full_arch_name "$run_arch")
    export SDK_PATH=$(get_sdk_path)
    export SDK_NAME=$(get_sdk_name)

    # EXECUTE MAIN BUILD SCRIPT
    . "${BASEDIR}"/scripts/main-ios.sh "${ENABLED_LIBRARIES[@]}"

    TARGET_ARCH_LIST+=("${FULL_ARCH}")

    # CLEAR FLAGS
    for library in {0..61}; do
      library_name=$(get_library_name "${library}")
      unset "$(echo "OK_${library_name}" | sed "s/\-/\_/g")"
      unset "$(echo "DEPENDENCY_REBUILT_${library_name}" | sed "s/\-/\_/g")"
    done
  fi
done

echo -e -n "\n"

# DO NOT BUILD FRAMEWORKS
if [[ ${NO_FRAMEWORK} -ne 1 ]]; then

  # BUILD FFMPEG-KIT
  if [[ -n ${TARGET_ARCH_LIST[0]} ]]; then

    # INITIALIZE TARGET FOLDERS
    initialize_prebuilt_ios_folders

    # PREPARE PLATFORM ARCHITECTURE STRINGS
    build_apple_architecture_variant_strings

    if [[ -n ${FFMPEG_KIT_XCF_BUILD} ]]; then
      echo -e -n "\nCreating xcframeworks under prebuilt: "

      create_universal_libraries_for_ios_xcframeworks

      create_frameworks_for_ios_xcframeworks

      create_ios_xcframeworks
    else
      echo -e -n "\nCreating frameworks under prebuilt: "

      create_universal_libraries_for_ios_default_frameworks

      create_ios_default_frameworks
    fi

    echo -e "ok\n"
  fi

else
  echo -e "INFO: Skipped creating iOS frameworks.\n" 1>>"${BASEDIR}"/build.log 2>&1
fi
