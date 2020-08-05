#!/bin/bash

export FFMPEG_KIT_BUILD_TYPE="ios"
export BASEDIR="$(pwd)"

source "${BASEDIR}"/scripts/common-${FFMPEG_KIT_BUILD_TYPE}.sh

# ENABLE ARCH
ENABLED_ARCHITECTURES=(0 0 1 1 0 1 1 1 0 1 1)

# ENABLE LIBRARIES
ENABLED_LIBRARIES=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)

# USE 12.1 AS DEFAULT IOS_MIN_VERSION
export IOS_MIN_VERSION=12.1

RECONF_LIBRARIES=()
REBUILD_LIBRARIES=()
REDOWNLOAD_LIBRARIES=()

get_ffmpeg_kit_version() {
  local FFMPEG_KIT_VERSION=$(grep 'const FFMPEG_KIT_VERSION' "${BASEDIR}"/ios/src/FFmpegKit.m | grep -Eo '\".*\"' | sed -e 's/\"//g')

  if [[ -z ${FFMPEG_KIT_LTS_BUILD} ]]; then
    echo "${FFMPEG_KIT_VERSION}"
  else
    echo "${FFMPEG_KIT_VERSION}.LTS"
  fi
}

display_help() {
  COMMAND=$(echo "$0" | sed -e 's/\.\///g')

  echo -e "\n$COMMAND builds FFmpegKit for iOS platform. By default seven architectures (armv7, armv7s, arm64, arm64e, \
i386, x86-64 and x86-64-mac-catalyst) are built without any external libraries enabled. Options can be used to disable \
architectures and/or enable external libraries. Please note that GPL libraries (external libraries with GPL license) \
need --enable-gpl flag to be set explicitly. When compilation ends, library bundles are created under the prebuilt \
folder. By default framework bundles and universal fat binaries are created. If --xcframework option is provided then \
xcframework bundles are created.\n"
  echo -e "Usage: ./$COMMAND [OPTION]...\n"
  echo -e "Specify environment variables as VARIABLE=VALUE to override default build options.\n"

  display_help_options "  -x, --xcframework\t\tbuild xcframework bundles instead of framework bundles and universal libraries"
  display_help_licensing

  echo -e "Architectures:"
  echo -e "  --disable-armv7\t\tdo not build armv7 architecture [yes]"
  echo -e "  --disable-armv7s\t\tdo not build armv7s architecture [yes]"
  echo -e "  --disable-arm64\t\tdo not build arm64 architecture [yes]"
  echo -e "  --disable-arm64e\t\tdo not build arm64e architecture [yes]"
  echo -e "  --disable-i386\t\tdo not build i386 architecture [yes]"
  echo -e "  --disable-x86-64\t\tdo not build x86-64 architecture [yes]"
  echo -e "  --disable-x86-64-mac-catalyst\tdo not build x86-64-mac-catalyst architecture [yes]\n"

  echo -e "Libraries:"

  echo -e "  --full\t\t\tenables all non-GPL external libraries"
  echo -e "  --enable-ios-audiotoolbox\tbuild with built-in Apple AudioToolbox support[no]"
  echo -e "  --enable-ios-avfoundation\tbuild with built-in Apple AVFoundation support[no]"
  echo -e "  --enable-ios-bzip2\t\tbuild with built-in bzip2 support[no]"
  echo -e "  --enable-ios-videotoolbox\tbuild with built-in Apple VideoToolbox support[no]"
  echo -e "  --enable-ios-zlib\t\tbuild with built-in zlib [no]"
  echo -e "  --enable-ios-libiconv\t\tbuild with built-in libiconv [no]"

  display_help_common_libraries
  display_help_gpl_libraries
  display_help_advanced_options
}

enable_lts_build() {
  export FFMPEG_KIT_LTS_BUILD="1"

  # XCODE 7.3 HAS IOS SDK 9.3
  export IOS_MIN_VERSION=9.3
}

# 1 - library index
# 2 - library name
# 3 - static library name
# 4 - library version
create_external_library_package() {
  if [[ -n ${FFMPEG_KIT_XCF_BUILD} ]]; then

    # 1. CREATE INDIVIDUAL FRAMEWORKS
    for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
      if [[ ${TARGET_ARCH} != "arm64e" ]]; then
        local FRAMEWORK_PATH=${BASEDIR}/prebuilt/ios-xcframework/.tmp/ios-${TARGET_ARCH}/$2.framework
        mkdir -p "${FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
        local STATIC_LIBRARY_PATH=$(find "${BASEDIR}"/prebuilt/ios-${TARGET_ARCH} -name $3)
        local CAPITAL_CASE_LIBRARY_NAME=$(to_capital_case "$2")

        build_info_plist "${FRAMEWORK_PATH}/Info.plist" "$2" "com.arthenica.ffmpegkit.${CAPITAL_CASE_LIBRARY_NAME}" "$4" "$4"
        cp "${STATIC_LIBRARY_PATH}" "${FRAMEWORK_PATH}/$2" 1>>"${BASEDIR}"/build.log 2>&1
      fi
    done

    # 2. CREATE XCFRAMEWORKS
    local XCFRAMEWORK_PATH=${BASEDIR}/prebuilt/ios-xcframework/$2.xcframework
    mkdir -p "${XCFRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

    BUILD_COMMAND="xcodebuild -create-xcframework "

    for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
      if [[ ${TARGET_ARCH} != "arm64e" ]]; then
        local FRAMEWORK_PATH=${BASEDIR}/prebuilt/ios-xcframework/.tmp/ios-${TARGET_ARCH}/$2.framework
        BUILD_COMMAND+=" -framework ${FRAMEWORK_PATH}"
      fi
    done

    BUILD_COMMAND+=" -output ${XCFRAMEWORK_PATH}"

    COMMAND_OUTPUT=$(${BUILD_COMMAND} 2>&1)

    echo "${COMMAND_OUTPUT}" 1>>"${BASEDIR}"/build.log 2>&1

    echo "" 1>>"${BASEDIR}"/build.log 2>&1

    if [[ ${COMMAND_OUTPUT} == *"is empty in library"* ]]; then
      RC=1
    else
      RC=0
    fi

  else

    # 1. CREATE FAT LIBRARY
    local FAT_LIBRARY_PATH=${BASEDIR}/prebuilt/ios-universal/$2-universal

    mkdir -p "${FAT_LIBRARY_PATH}/lib" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

    LIPO_COMMAND="${LIPO} -create"

    for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
      LIPO_COMMAND+=" $(find "${BASEDIR}"/prebuilt/ios-"${TARGET_ARCH}" -name $3)"
    done

    LIPO_COMMAND+=" -output ${FAT_LIBRARY_PATH}/lib/$3"

    RC=$(${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1)

    if [[ ${RC} -eq 0 ]]; then

      # 2. CREATE FRAMEWORK
      RC=$(create_static_framework "$2" "$3" "$4")

      if [[ ${RC} -eq 0 ]]; then

        # 3. COPY LICENSES
        if [[ ${LIBRARY_LIBTHEORA} == "$1" ]]; then
          license_directories=("${BASEDIR}/prebuilt/ios-universal/libtheora-universal" "${BASEDIR}/prebuilt/ios-universal/libtheoraenc-universal" "${BASEDIR}/prebuilt/ios-universal/libtheoradec-universal" "${BASEDIR}/prebuilt/ios-framework/libtheora.framework" "${BASEDIR}/prebuilt/ios-framework/libtheoraenc.framework" "${BASEDIR}/prebuilt/ios-framework/libtheoradec.framework")
        elif [[ ${LIBRARY_LIBVORBIS} == "$1" ]]; then
          license_directories=("${BASEDIR}/prebuilt/ios-universal/libvorbisfile-universal" "${BASEDIR}/prebuilt/ios-universal/libvorbisenc-universal" "${BASEDIR}/prebuilt/ios-universal/libvorbis-universal" "${BASEDIR}/prebuilt/ios-framework/libvorbisfile.framework" "${BASEDIR}/prebuilt/ios-framework/libvorbisenc.framework" "${BASEDIR}/prebuilt/ios-framework/libvorbis.framework")
        elif [[ ${LIBRARY_LIBWEBP} == "$1" ]]; then
          license_directories=("${BASEDIR}/prebuilt/ios-universal/libwebpmux-universal" "${BASEDIR}/prebuilt/ios-universal/libwebpdemux-universal" "${BASEDIR}/prebuilt/ios-universal/libwebp-universal" "${BASEDIR}/prebuilt/ios-framework/libwebpmux.framework" "${BASEDIR}/prebuilt/ios-framework/libwebpdemux.framework" "${BASEDIR}/prebuilt/ios-framework/libwebp.framework")
        elif [[ ${LIBRARY_OPENCOREAMR} == "$1" ]]; then
          license_directories=("${BASEDIR}/prebuilt/ios-universal/libopencore-amrnb-universal" "${BASEDIR}/prebuilt/ios-framework/libopencore-amrnb.framework")
        elif [[ ${LIBRARY_NETTLE} == "$1" ]]; then
          license_directories=("${BASEDIR}/prebuilt/ios-universal/libnettle-universal" "${BASEDIR}/prebuilt/ios-universal/libhogweed-universal" "${BASEDIR}/prebuilt/ios-framework/libnettle.framework" "${BASEDIR}/prebuilt/ios-framework/libhogweed.framework")
        else
          license_directories=("${BASEDIR}/prebuilt/ios-universal/$2-universal" "${BASEDIR}/prebuilt/ios-framework/$2.framework")
        fi

        RC=$(copy_external_library_license "$1" "${license_directories[@]}")
      fi

    fi

  fi

  echo "${RC}"
}

# 1 - library index
# 2 - output path
copy_external_library_license() {
  output_path_array="$2"
  for output_path in "${output_path_array[@]}"
  do
    $(cp $(get_external_library_license_path "$1") "${output_path}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1)
    if [ $? -ne 0 ]; then
      echo 1
      return
    fi
  done;
  echo 0
}

get_external_library_version() {
  local library_version=$(grep Version "${BASEDIR}"/prebuilt/ios-"${TARGET_ARCH_LIST[0]}"/pkgconfig/"$1".pc 2>>"${BASEDIR}"/build.log | sed 's/Version://g;s/\ //g')

  echo "${library_version}"
}

# CHECKING IF XCODE IS INSTALLED
if ! [ -x "$(command -v xcrun)" ]; then
  echo -e "\n(*) xcrun command not found. Please check your Xcode installation.\n"
  exit 1
fi

# SELECT XCODE VERSION USED FOR BUILDING
XCODE_FOR_FFMPEG_KIT=source ~/.xcode.for.ffmpeg.kit.sh
if [[ -f ${XCODE_FOR_FFMPEG_KIT} ]]; then
  source "${XCODE_FOR_FFMPEG_KIT}" 1>>"${BASEDIR}"/build.log 2>&1
fi

DETECTED_IOS_SDK_VERSION="$(xcrun --sdk iphoneos --show-sdk-version)"

echo -e "INFO: Using SDK ${DETECTED_IOS_SDK_VERSION} by Xcode provided at $(xcode-select -p)\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "\nINFO: Build options: $*\n" 1>>"${BASEDIR}"/build.log 2>&1

if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]] && [[ "${DETECTED_IOS_SDK_VERSION}" != "${IOS_MIN_VERSION}" ]]; then
  echo -e "\n(*) LTS packages should be built using SDK ${IOS_MIN_VERSION} but current configuration uses SDK ${DETECTED_IOS_SDK_VERSION}\n"

  if [[ -z ${BUILD_FORCE} ]]; then
    exit 1
  fi
fi

GPL_ENABLED="no"
DISPLAY_HELP=""
BUILD_TYPE_ID=""
BUILD_LTS=""
BUILD_FULL=""
FFMPEG_KIT_XCF_BUILD=""
BUILD_FORCE=""
BUILD_VERSION=$(git describe --tags 2>>"${BASEDIR}"/build.log)

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
  -l | --lts)
    BUILD_LTS="1"
    ;;
  -x | --xcframework)
    FFMPEG_KIT_XCF_BUILD="1"
    ;;
  -f | --force)
    BUILD_FORCE="1"
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
    GPL_ENABLED="yes"
    ;;
  --enable-*)
    ENABLED_LIBRARY=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    enable_library "${ENABLED_LIBRARY}"
    ;;
  --disable-*)
    DISABLED_ARCH=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    disable_arch "${DISABLED_ARCH}"
    ;;
  *)
    print_unknown_option "$1"
    ;;
  esac
  shift
done

if [[ -z ${BUILD_VERSION} ]]; then
  echo -e "\nerror: Can not run git commands in this folder. See build.log.\n"
  exit 1
fi

# DETECT BUILD TYPE
if [[ -n ${BUILD_LTS} ]]; then
  enable_lts_build
  BUILD_TYPE_ID+="LTS "
fi

# HELP DISPLAYED AFTER SETTING LTS FLAG
if [[ -n ${DISPLAY_HELP} ]]; then
  display_help
  exit 0
fi

# PROCESS FULL FLAG
if [[ -n ${BUILD_FULL} ]]; then
  for library in {0..60}; do
    if [ ${GPL_ENABLED} == "yes" ]; then
      enable_library "$(get_library_name $library)"
    else
      if [[ $library -ne $LIBRARY_X264 ]] && [[ $library -ne $LIBRARY_XVIDCORE ]] && [[ $library -ne $LIBRARY_X265 ]] && [[ $library -ne $LIBRARY_LIBVIDSTAB ]] && [[ $library -ne $LIBRARY_RUBBERBAND ]]; then
        enable_library "$(get_library_name $library)"
      fi
    fi
  done
fi

# DISABLE 32-bit architectures on newer IOS versions
if [[ ${DETECTED_IOS_SDK_VERSION} == 11* ]] || [[ ${DETECTED_IOS_SDK_VERSION} == 12* ]] || [[ ${DETECTED_IOS_SDK_VERSION} == 13* ]]; then
  if [[ -z ${BUILD_FORCE} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_ARMV7}]} -eq 1 ]]; then
    echo -e "INFO: Disabled armv7 architecture which is not supported on SDK ${DETECTED_IOS_SDK_VERSION}\n" 1>>"${BASEDIR}"/build.log 2>&1
    disable_arch "armv7"
  fi
  if [[ -z ${BUILD_FORCE} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_ARMV7S}]} -eq 1 ]]; then
    echo -e "INFO: Disabled armv7s architecture which is not supported on SDK ${DETECTED_IOS_SDK_VERSION}\n" 1>>"${BASEDIR}"/build.log 2>&1
    disable_arch "armv7s"
  fi
  if [[ -z ${BUILD_FORCE} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_I386}]} -eq 1 ]]; then
    echo -e "INFO: Disabled i386 architecture which is not supported on SDK ${DETECTED_IOS_SDK_VERSION}\n" 1>>"${BASEDIR}"/build.log 2>&1
    disable_arch "i386"
  fi

# DISABLE arm64e architecture on older IOS versions
elif [[ ${DETECTED_IOS_SDK_VERSION} != 10* ]]; then
  if [[ -z ${BUILD_FORCE} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_ARM64E}]} -eq 1 ]]; then
    echo -e "INFO: Disabled arm64e architecture which is not supported on SDK ${DETECTED_IOS_SDK_VERSION}\n" 1>>"${BASEDIR}"/build.log 2>&1
    disable_arch "arm64e"
  fi
fi

# DISABLE x86-64-mac-catalyst architecture on IOS versions lower than 13
if [[ ${DETECTED_IOS_SDK_VERSION} != 13* ]] && [[ -z ${BUILD_FORCE} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_X86_64_MAC_CATALYST}]} -eq 1 ]]; then
  echo -e "INFO: Disabled x86-64-mac-catalyst architecture which is not supported on SDK ${DETECTED_IOS_SDK_VERSION}\n" 1>>"${BASEDIR}"/build.log 2>&1
  disable_arch "x86-64-mac-catalyst"
fi

# DISABLE x86-64-mac-catalyst when x86-64 is enabled in xcf bundles
if [[ -z ${FFMPEG_KIT_XCF_BUILD} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_X86_64}]} -eq 1 ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_X86_64_MAC_CATALYST}]} -eq 1 ]]; then
  echo -e "INFO: Disabled x86-64-mac-catalyst architecture which can not co-exist with x86-64 in a framework bundle / universal fat library.\n" 1>>"${BASEDIR}"/build.log 2>&1
  disable_arch "x86-64-mac-catalyst"
fi

# DISABLE arm64e when arm64 is enabled in xcf bundles
if [[ -n ${FFMPEG_KIT_XCF_BUILD} ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_ARM64E}]} -eq 1 ]] && [[ ${ENABLED_ARCHITECTURES[${ARCH_ARM64}]} -eq 1 ]]; then
  echo -e "INFO: Disabled arm64e architecture which can not co-exist with arm64 in an xcframework bundle.\n" 1>>"${BASEDIR}"/build.log 2>&1
  disable_arch "arm64e"
fi

echo -e "\nBuilding ffmpeg-kit ${BUILD_TYPE_ID}static library for iOS\n"
echo -e -n "INFO: Building ffmpeg-kit ${BUILD_VERSION} ${BUILD_TYPE_ID}for iOS: " 1>>"${BASEDIR}"/build.log 2>&1
echo -e "$(date)" 1>>"${BASEDIR}"/build.log 2>&1

# PRINT BUILD SUMMARY
print_enabled_architectures
print_enabled_libraries
print_reconfigure_requested_libraries
print_rebuild_requested_libraries
print_redownload_requested_libraries

# CHECK GPL FLAG AND DOWNLOAD LIBRARIES
for gpl_library in {$LIBRARY_X264,$LIBRARY_XVIDCORE,$LIBRARY_X265,$LIBRARY_LIBVIDSTAB,$LIBRARY_RUBBERBAND}; do
  if [[ ${ENABLED_LIBRARIES[$gpl_library]} -eq 1 ]]; then
    library_name=$(get_library_name ${gpl_library})

    if [ ${GPL_ENABLED} != "yes" ]; then
      echo -e "\n(*) Invalid configuration detected. GPL library ${library_name} enabled without --enable-gpl flag.\n"
      echo -e "\n(*) Invalid configuration detected. GPL library ${library_name} enabled without --enable-gpl flag.\n" 1>>"${BASEDIR}"/build.log 2>&1
      exit 1
    else
      DOWNLOAD_RESULT=$(download_gpl_library_source "${library_name}")
      if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
        echo -e "\n(*) Failed to download GPL library ${library_name} source. Please check build.log file for details. If the problem persists refer to offline building instructions.\n"
        echo -e "\n(*) Failed to download GPL library ${library_name} source.\n" 1>>"${BASEDIR}"/build.log 2>&1
        exit 1
      fi
    fi
  fi
done

TARGET_ARCH_LIST=()

# BUILD ALL ENABLED ARCHITECTURES
for run_arch in {0..10}; do
  if [[ ${ENABLED_ARCHITECTURES[$run_arch]} -eq 1 ]]; then
    export ARCH=$(get_arch_name $run_arch)
    export TARGET_SDK=$(get_target_sdk)
    export SDK_PATH=$(get_sdk_path)
    export SDK_NAME=$(get_sdk_name)

    export LIPO="$(xcrun --sdk "$(get_sdk_name)" -f lipo)"

    . "${BASEDIR}"/scripts/main-ios.sh "${ENABLED_LIBRARIES[@]}"
    case ${ARCH} in
    x86-64)
      TARGET_ARCH="x86_64"
      ;;
    x86-64-mac-catalyst)
      TARGET_ARCH="x86_64-mac-catalyst"
      ;;
    *)
      TARGET_ARCH="${ARCH}"
      ;;
    esac
    TARGET_ARCH_LIST+=("${TARGET_ARCH}")

    # CLEAR FLAGS
    for library in {0..60}; do
      library_name=$(get_library_name ${library})
      unset "$(echo "OK_${library_name}" | sed "s/\-/\_/g")"
      unset "$(echo "DEPENDENCY_REBUILT_${library_name}" | sed "s/\-/\_/g")"
    done
  fi
done

FFMPEG_LIBS="libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale"

BUILD_LIBRARY_EXTENSION="a"

if [[ -n ${TARGET_ARCH_LIST[0]} ]]; then

  # BUILDING PACKAGES
  if [[ -n ${FFMPEG_KIT_XCF_BUILD} ]]; then
    echo -e -n "\n\nCreating xcframeworks under prebuilt: "

    rm -rf "${BASEDIR}/prebuilt/ios-xcframework" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${BASEDIR}/prebuilt/ios-xcframework" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
  else
    echo -e -n "\n\nCreating frameworks and universal libraries under prebuilt: "

    rm -rf "${BASEDIR}/prebuilt/ios-universal" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${BASEDIR}/prebuilt/ios-universal" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    rm -rf "${BASEDIR}/prebuilt/ios-framework" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${BASEDIR}/prebuilt/ios-framework" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
  fi

  # 1. EXTERNAL LIBRARIES
  for library in {0..6} {8..37} {39..44}; do
    if [[ ${ENABLED_LIBRARIES[$library]} -eq 1 ]]; then

      library_name=$(get_library_name ${library})
      package_config_file_name=$(get_package_config_file_name ${library})
      library_version=$(get_external_library_version "${package_config_file_name}")
      if [[ -z ${library_version} ]]; then
        echo -e "Failed to detect version for ${library_name} from ${package_config_file_name}.pc\n" 1>>"${BASEDIR}"/build.log 2>&1
        echo -e "failed\n"
        exit 1
      fi

      echo -e "Creating external library package for ${library_name}\n" 1>>"${BASEDIR}"/build.log 2>&1

      if [[ ${LIBRARY_LIBTHEORA} == "$library" ]]; then

        LIBRARY_CREATED=$(create_external_library_package $library "libtheora" "libtheora.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_external_library_package $library "libtheoraenc" "libtheoraenc.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_external_library_package $library "libtheoradec" "libtheoradec.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

      elif [[ ${LIBRARY_LIBVORBIS} == "$library" ]]; then

        LIBRARY_CREATED=$(create_external_library_package $library "libvorbisfile" "libvorbisfile.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_external_library_package $library "libvorbisenc" "libvorbisenc.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_external_library_package $library "libvorbis" "libvorbis.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

      elif [[ ${LIBRARY_LIBWEBP} == "$library" ]]; then

        LIBRARY_CREATED=$(create_external_library_package $library "libwebpmux" "libwebpmux.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_external_library_package $library "libwebpdemux" "libwebpdemux.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_external_library_package $library "libwebp" "libwebp.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

      elif [[ ${LIBRARY_OPENCOREAMR} == "$library" ]]; then

        LIBRARY_CREATED=$(create_external_library_package $library "libopencore-amrnb" "libopencore-amrnb.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

      elif [[ ${LIBRARY_NETTLE} == "$library" ]]; then

        LIBRARY_CREATED=$(create_external_library_package $library "libnettle" "libnettle.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_external_library_package $library "libhogweed" "libhogweed.a" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

      else

        library_name=$(get_library_name $((library)))
        static_archive_name=$(get_static_archive_name $((library)))
        LIBRARY_CREATED=$(create_external_library_package $library "$library_name" "$static_archive_name" "${library_version}")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

      fi

    fi
  done

  # 2. FFMPEG & FFMPEG KIT
  if [[ -n ${FFMPEG_KIT_XCF_BUILD} ]]; then

    # FFMPEG
    for FFMPEG_LIB in ${FFMPEG_LIBS}; do

      XCFRAMEWORK_PATH=${BASEDIR}/prebuilt/ios-xcframework/${FFMPEG_LIB}.xcframework
      mkdir -p "${XCFRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

      echo -e "Creating package for ${FFMPEG_LIB}\n" 1>>"${BASEDIR}"/build.log 2>&1

      BUILD_COMMAND="xcodebuild -create-xcframework "

      for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do

        if [[ ${TARGET_ARCH} != "arm64e" ]]; then

          FFMPEG_LIB_UPPERCASE=$(echo "${FFMPEG_LIB}" | tr '[a-z]' '[A-Z]')
          FFMPEG_LIB_CAPITALCASE=$(to_capital_case "${FFMPEG_LIB}")

          FFMPEG_LIB_MAJOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR" "${BASEDIR}/prebuilt/ios-${TARGET_ARCH}/ffmpeg/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR//g;s/\ //g")
          FFMPEG_LIB_MINOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR" "${BASEDIR}/prebuilt/ios-${TARGET_ARCH}/ffmpeg/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR//g;s/\ //g")
          FFMPEG_LIB_MICRO=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO" "${BASEDIR}/prebuilt/ios-${TARGET_ARCH}/ffmpeg/include/${FFMPEG_LIB}/version.h" | sed "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO//g;s/\ //g")

          FFMPEG_LIB_VERSION="${FFMPEG_LIB_MAJOR}.${FFMPEG_LIB_MINOR}.${FFMPEG_LIB_MICRO}"

          FFMPEG_LIB_FRAMEWORK_PATH=${BASEDIR}/prebuilt/ios-xcframework/.tmp/ios-${TARGET_ARCH}/${FFMPEG_LIB}.framework

          rm -rf "${FFMPEG_LIB_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
          mkdir -p "${FFMPEG_LIB_FRAMEWORK_PATH}/Headers" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

          cp -r "${BASEDIR}"/prebuilt/ios-${TARGET_ARCH}/ffmpeg/include/${FFMPEG_LIB}/* ${FFMPEG_LIB_FRAMEWORK_PATH}/Headers 1>>"${BASEDIR}"/build.log 2>&1
          cp "${BASEDIR}/prebuilt/ios-${TARGET_ARCH}/ffmpeg/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}" "${FFMPEG_LIB_FRAMEWORK_PATH}/${FFMPEG_LIB}" 1>>"${BASEDIR}"/build.log 2>&1

          # COPY THE LICENSES
          if [ ${GPL_ENABLED} == "yes" ]; then

            # GPLv3.0
            cp "${BASEDIR}/LICENSE.GPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
          else

            # LGPLv3.0
            cp "${BASEDIR}/LICENSE.LGPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
          fi

          build_info_plist "${FFMPEG_LIB_FRAMEWORK_PATH}/Info.plist" "${FFMPEG_LIB}" "com.arthenica.ffmpegkit.${FFMPEG_LIB_CAPITALCASE}" "${FFMPEG_LIB_VERSION}" "${FFMPEG_LIB_VERSION}"

          BUILD_COMMAND+=" -framework ${FFMPEG_LIB_FRAMEWORK_PATH}"
        fi

      done

      BUILD_COMMAND+=" -output ${XCFRAMEWORK_PATH}"

      COMMAND_OUTPUT=$(${BUILD_COMMAND} 2>&1)

      echo "${COMMAND_OUTPUT}" 1>>"${BASEDIR}"/build.log 2>&1

      echo "" 1>>"${BASEDIR}"/build.log 2>&1

      if [[ ${COMMAND_OUTPUT} == *"is empty in library"* ]]; then
        echo -e "failed\n"
        exit 1
      fi

      echo -e "Created ${FFMPEG_LIB} xcframework successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1

    done

    # FFMPEG KIT
    XCFRAMEWORK_PATH=${BASEDIR}/prebuilt/ios-xcframework/ffmpegkit.xcframework
    mkdir -p "${XCFRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

    BUILD_COMMAND="xcodebuild -create-xcframework "

    for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do

      if [[ ${TARGET_ARCH} != "arm64e" ]]; then

        FFMPEG_KIT_FRAMEWORK_PATH="${BASEDIR}/prebuilt/ios-xcframework/.tmp/ios-${TARGET_ARCH}/ffmpegkit.framework"

        rm -rf "${FFMPEG_KIT_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
        mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}/Headers" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
        mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}/Modules" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
        build_modulemap "${FFMPEG_KIT_FRAMEWORK_PATH}/Modules/module.modulemap"

        cp -r "${BASEDIR}"/prebuilt/ios-"${TARGET_ARCH}"/ffmpeg-kit/include/* "${FFMPEG_KIT_FRAMEWORK_PATH}"/Headers 1>>"${BASEDIR}"/build.log 2>&1
        cp "${BASEDIR}/prebuilt/ios-${TARGET_ARCH}/ffmpeg-kit/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION}" "${FFMPEG_KIT_FRAMEWORK_PATH}/ffmpegkit" 1>>"${BASEDIR}"/build.log 2>&1

        # COPY THE LICENSES
        if [ ${GPL_ENABLED} == "yes" ]; then
          cp "${BASEDIR}/LICENSE.GPLv3" "${FFMPEG_KIT_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
        else
          cp "${BASEDIR}/LICENSE.LGPLv3" "${FFMPEG_KIT_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
        fi

        BUILD_COMMAND+=" -framework ${FFMPEG_KIT_FRAMEWORK_PATH}"

      fi
    done;

    BUILD_COMMAND+=" -output ${XCFRAMEWORK_PATH}"

    COMMAND_OUTPUT=$(${BUILD_COMMAND} 2>&1)

    echo "${COMMAND_OUTPUT}" 1>>"${BASEDIR}"/build.log 2>&1

    echo "" 1>>"${BASEDIR}"/build.log 2>&1

    if [[ ${COMMAND_OUTPUT} == *"is empty in library"* ]]; then
      echo -e "failed\n"
      exit 1
    fi

    echo -e "Created ffmpegkit xcframework successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1

    echo -e "ok\n"

  else

    FFMPEG_UNIVERSAL="${BASEDIR}/prebuilt/ios-universal/ffmpeg-universal"
    mkdir -p "${FFMPEG_UNIVERSAL}/include" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${FFMPEG_UNIVERSAL}/lib" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

    cp -r "${BASEDIR}"/prebuilt/ios-"${TARGET_ARCH_LIST[0]}"/ffmpeg/include/* ${FFMPEG_UNIVERSAL}/include 1>>"${BASEDIR}"/build.log 2>&1
    cp "${BASEDIR}"/prebuilt/ios-"${TARGET_ARCH_LIST[0]}"/ffmpeg/include/config.h "${FFMPEG_UNIVERSAL}/include" 1>>"${BASEDIR}"/build.log 2>&1

    for FFMPEG_LIB in ${FFMPEG_LIBS}; do
      LIPO_COMMAND="${LIPO} -create"

      for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
        LIPO_COMMAND+=" "${BASEDIR}"/prebuilt/ios-${TARGET_ARCH}/ffmpeg/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}"
      done

      LIPO_COMMAND+=" -output ${FFMPEG_UNIVERSAL}/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}"

      ${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1

      if [ $? -ne 0 ]; then
        echo -e "failed\n"
        exit 1
      fi

      FFMPEG_LIB_UPPERCASE=$(echo "${FFMPEG_LIB}" | tr '[a-z]' '[A-Z]')
      FFMPEG_LIB_CAPITALCASE=$(to_capital_case "${FFMPEG_LIB}")

      FFMPEG_LIB_MAJOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR" "${FFMPEG_UNIVERSAL}/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR//g;s/\ //g")
      FFMPEG_LIB_MINOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR" "${FFMPEG_UNIVERSAL}/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR//g;s/\ //g")
      FFMPEG_LIB_MICRO=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO" "${FFMPEG_UNIVERSAL}/include/${FFMPEG_LIB}/version.h" | sed "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO//g;s/\ //g")

      FFMPEG_LIB_VERSION="${FFMPEG_LIB_MAJOR}.${FFMPEG_LIB_MINOR}.${FFMPEG_LIB_MICRO}"

      FFMPEG_LIB_FRAMEWORK_PATH="${BASEDIR}/prebuilt/ios-framework/${FFMPEG_LIB}.framework"

      rm -rf "${FFMPEG_LIB_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
      mkdir -p "${FFMPEG_LIB_FRAMEWORK_PATH}/Headers" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

      cp -r ${FFMPEG_UNIVERSAL}/include/${FFMPEG_LIB}/* ${FFMPEG_LIB_FRAMEWORK_PATH}/Headers 1>>"${BASEDIR}"/build.log 2>&1
      cp "${FFMPEG_UNIVERSAL}/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}" "${FFMPEG_LIB_FRAMEWORK_PATH}/${FFMPEG_LIB}" 1>>"${BASEDIR}"/build.log 2>&1

      # COPY THE LICENSES
      if [ ${GPL_ENABLED} == "yes" ]; then

        # GPLv3.0
        cp "${BASEDIR}/LICENSE.GPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
      else

        # LGPLv3.0
        cp "${BASEDIR}/LICENSE.LGPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
      fi

      build_info_plist "${FFMPEG_LIB_FRAMEWORK_PATH}/Info.plist" "${FFMPEG_LIB}" "com.arthenica.ffmpegkit.${FFMPEG_LIB_CAPITALCASE}" "${FFMPEG_LIB_VERSION}" "${FFMPEG_LIB_VERSION}"

      echo -e "Created ${FFMPEG_LIB} framework successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1
    done

    # COPY THE LICENSES
    if [ ${GPL_ENABLED} == "yes" ]; then
      cp "${BASEDIR}"/LICENSE.GPLv3 "${FFMPEG_UNIVERSAL}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
    else
      cp "${BASEDIR}"/LICENSE.LGPLv3 "${FFMPEG_UNIVERSAL}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
    fi

    # 3. FFMPEG KIT
    FFMPEG_KIT_VERSION=$(get_ffmpeg_kit_version)
    FFMPEG_KIT_UNIVERSAL="${BASEDIR}/prebuilt/ios-universal/ffmpeg-kit-universal"
    FFMPEG_KIT_FRAMEWORK_PATH="${BASEDIR}/prebuilt/ios-framework/ffmpegkit.framework"
    mkdir -p "${FFMPEG_KIT_UNIVERSAL}/include" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${FFMPEG_KIT_UNIVERSAL}/lib" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    rm -rf "${FFMPEG_KIT_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
    mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}/Headers" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}/Modules" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

    LIPO_COMMAND="${LIPO} -create"
    for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
      LIPO_COMMAND+=" ${BASEDIR}/prebuilt/ios-${TARGET_ARCH}/ffmpeg-kit/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION}"
    done
    LIPO_COMMAND+=" -output ${FFMPEG_KIT_UNIVERSAL}/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION}"

    ${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1

    if [ $? -ne 0 ]; then
      echo -e "failed\n"
      exit 1
    fi

    cp -r "${BASEDIR}"/prebuilt/ios-"${TARGET_ARCH_LIST[0]}"/ffmpeg-kit/include/* "${FFMPEG_KIT_UNIVERSAL}"/include 1>>"${BASEDIR}"/build.log 2>&1
    cp -r "${FFMPEG_KIT_UNIVERSAL}"/include/* "${FFMPEG_KIT_FRAMEWORK_PATH}"/Headers 1>>"${BASEDIR}"/build.log 2>&1
    cp "${FFMPEG_KIT_UNIVERSAL}/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION}" "${FFMPEG_KIT_FRAMEWORK_PATH}/ffmpegkit" 1>>"${BASEDIR}"/build.log 2>&1

    # COPY THE LICENSES
    if [ ${GPL_ENABLED} == "yes" ]; then
      cp "${BASEDIR}"/LICENSE.GPLv3 "${FFMPEG_KIT_UNIVERSAL}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
      cp "${BASEDIR}"/LICENSE.GPLv3 "${FFMPEG_KIT_FRAMEWORK_PATH}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
    else
      cp "${BASEDIR}"/LICENSE.LGPLv3 "${FFMPEG_KIT_UNIVERSAL}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
      cp "${BASEDIR}"/LICENSE.LGPLv3 "${FFMPEG_KIT_FRAMEWORK_PATH}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
    fi

    build_info_plist "${FFMPEG_KIT_FRAMEWORK_PATH}/Info.plist" "ffmpegkit" "com.arthenica.ffmpegkit.FFmpegKit" "${FFMPEG_KIT_VERSION}" "${FFMPEG_KIT_VERSION}"
    build_modulemap "${FFMPEG_KIT_FRAMEWORK_PATH}/Modules/module.modulemap"

    echo -e "Created ffmpegkit.framework and universal library successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1

    echo -e "ok\n"
  fi
fi
