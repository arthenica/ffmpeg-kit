#!/bin/bash

# CHECK IF XCODE IS INSTALLED
if [ ! -x "$(command -v xcrun)" ]; then
  echo -e "\n(*) xcrun command not found. Please check your Xcode installation\n"
  exit 1
fi

# LOAD INITIAL SETTINGS
export BASEDIR="$(pwd)"
export FFMPEG_KIT_BUILD_TYPE="macos"
source "${BASEDIR}"/scripts/variable.sh
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh

# SET DEFAULTS SETTINGS
enable_default_macos_architectures
enable_main_build

# SELECT XCODE VERSION USED FOR BUILDING
XCODE_FOR_FFMPEG_KIT=$(ls ~/.xcode.for.ffmpeg.kit.sh)
if [[ -f ${XCODE_FOR_FFMPEG_KIT} ]]; then
  source "${XCODE_FOR_FFMPEG_KIT}" 1>>"${BASEDIR}"/build.log 2>&1
fi

# DETECT MACOS SDK VERSION
DETECTED_MACOS_SDK_VERSION="$(xcrun --sdk macosx --show-sdk-version)"
echo -e "INFO: Using SDK ${DETECTED_MACOS_SDK_VERSION} by Xcode provided at $(xcode-select -p)\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "\nINFO: Build options: $*\n" 1>>"${BASEDIR}"/build.log 2>&1

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

# VALIDATE THAT LTS RELEASES ARE BUILT USING THE CORRECT VERSION
if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]] && [[ "${DETECTED_MACOS_SDK_VERSION}" != "${MACOS_MIN_VERSION}" ]]; then
  if [[ -z ${BUILD_FORCE} ]]; then
    echo -e "\n(*) LTS packages should be built using SDK ${MACOS_MIN_VERSION} but current configuration uses SDK ${DETECTED_MACOS_SDK_VERSION}\n"
    exit 1
  fi
fi

# PROCESS FULL OPTION AS LAST OPTION
if [[ -n ${BUILD_FULL} ]]; then
  for library in {0..57}; do
    if [ ${GPL_ENABLED} == "yes" ]; then
      enable_library "$(get_library_name $library)" 1
    else
      if [[ $(is_gpl_licensed $library) -eq 1 ]]; then
        enable_library "$(get_library_name $library)" 1
      fi
    fi
  done
fi

# IF HELP DISPLAYED EXIT
if [[ -n ${DISPLAY_HELP} ]]; then
  display_help
  exit 0
fi

# CHECK SOME RULES FOR .xcframework BUNDLES

# 1. DO NOT ALLOW --lts AND --xcframework OPTIONS TOGETHER
if [[ -n ${FFMPEG_KIT_XCF_BUILD} ]] && [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
  echo -e "\n(*) LTS packages does not support xcframework bundles.\n"
  exit 1
fi

echo -e "\nBuilding ffmpeg-kit ${BUILD_TYPE_ID}static library for macOS\n"
echo -e -n "INFO: Building ffmpeg-kit ${BUILD_VERSION} ${BUILD_TYPE_ID}for macOS: " 1>>"${BASEDIR}"/build.log 2>&1
echo -e "$(date)\n" 1>>"${BASEDIR}"/build.log 2>&1

# PRINT BUILD SUMMARY
print_enabled_architectures
print_enabled_libraries
print_reconfigure_requested_libraries
print_rebuild_requested_libraries
print_redownload_requested_libraries

# VALIDATE GPL FLAGS
for gpl_library in {$LIBRARY_X264,$LIBRARY_XVIDCORE,$LIBRARY_X265,$LIBRARY_LIBVIDSTAB,$LIBRARY_RUBBERBAND}; do
  if [[ ${ENABLED_LIBRARIES[$gpl_library]} -eq 1 ]]; then
    library_name=$(get_library_name ${gpl_library})

    if [ ${GPL_ENABLED} != "yes" ]; then
      echo -e "\n(*) Invalid configuration detected. GPL library ${library_name} enabled without --enable-gpl flag.\n"
      echo -e "\n(*) Invalid configuration detected. GPL library ${library_name} enabled without --enable-gpl flag.\n" 1>>"${BASEDIR}"/build.log 2>&1
      exit 1
    fi
  fi
done

echo -n -e "\nDownloading sources: "
echo -e "INFO: Downloading source code of ffmpeg and enabled external libraries.\n" 1>>"${BASEDIR}"/build.log 2>&1

# DOWNLOAD LIBRARY SOURCES
downloaded_enabled_library_sources "${ENABLED_LIBRARIES[@]}"

# THIS WILL SAVE ARCHITECTURES TO BUILD
TARGET_ARCH_LIST=()

# BUILD ENABLED LIBRARIES ON ENABLED ARCHITECTURES
for run_arch in {0..10}; do
  if [[ ${ENABLED_ARCHITECTURES[$run_arch]} -eq 1 ]]; then
    export ARCH=$(get_arch_name $run_arch)
    export TARGET_SDK=$(get_target_sdk)
    export SDK_PATH=$(get_sdk_path)
    export SDK_NAME=$(get_sdk_name)

    export LIPO="$(xcrun --sdk "$(get_sdk_name)" -f lipo)"

    # EXECUTE MAIN BUILD SCRIPT
    . "${BASEDIR}"/scripts/main-macos.sh "${ENABLED_LIBRARIES[@]}"
    case ${ARCH} in
    x86-64)
      TARGET_ARCH="x86_64"
      ;;
    *)
      TARGET_ARCH="${ARCH}"
      ;;
    esac
    TARGET_ARCH_LIST+=("${TARGET_ARCH}")

    # CLEAR FLAGS
    for library in {0..57}; do
      library_name=$(get_library_name ${library})
      unset "$(echo "OK_${library_name}" | sed "s/\-/\_/g")"
      unset "$(echo "DEPENDENCY_REBUILT_${library_name}" | sed "s/\-/\_/g")"
    done
  fi
done

FFMPEG_LIBS="libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale"

# BUILD STATIC LIBRARIES
BUILD_LIBRARY_EXTENSION="a"

# BUILD FFMPEG-KIT
if [[ -n ${TARGET_ARCH_LIST[0]} ]]; then

  # INITIALIZE TARGET FOLDERS
  if [[ -n ${FFMPEG_KIT_XCF_BUILD} ]]; then
    echo -e -n "\n\nCreating xcframeworks under prebuilt: "

    rm -rf "${BASEDIR}/prebuilt/macos-xcframework" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${BASEDIR}/prebuilt/macos-xcframework" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
  else
    echo -e -n "\n\nCreating frameworks and universal libraries under prebuilt: "

    rm -rf "${BASEDIR}/prebuilt/macos-universal" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${BASEDIR}/prebuilt/macos-universal" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    rm -rf "${BASEDIR}/prebuilt/macos-framework" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${BASEDIR}/prebuilt/macos-framework" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
  fi

  # CREATE ENABLED LIBRARY PACKAGES. IT IS EITHER
  # .framework and fat/universal library
  # OR
  # .xcframework
  for library in {0..57}; do
    if [[ ${ENABLED_LIBRARIES[$library]} -eq 1 ]]; then
      library_name=$(get_library_name ${library})
      package_config_file_name=$(get_package_config_file_name ${library})

      # EACH ENABLED LIBRARY HAS TO HAVE A .pc FILE AND A VERSION
      library_version=$(get_external_library_version "${package_config_file_name}")
      if [[ -z ${library_version} ]]; then
        echo -e "Failed to detect version for ${library_name} from ${package_config_file_name}.pc\n" 1>>"${BASEDIR}"/build.log 2>&1
        echo -e "failed\n"
        exit 1
      fi

      echo -e "Creating external library package for ${library_name}\n" 1>>"${BASEDIR}"/build.log 2>&1

      # SOME CUSTOM CODE TO HANDLE LIBRARIES THAT PRODUCE MULTIPLE LIBRARY FILES
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

        # LIBRARIES WHICH HAVE ONLY ONE LIBRARY FILE ARE CREATED HERE
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

  # CREATE FFMPEG & FFMPEG KIT PACKAGES
  if [[ -n ${FFMPEG_KIT_XCF_BUILD} ]]; then

    # CREATE .xcframework BUNDLE IF ENABLED

    # CREATE FFMPEG
    for FFMPEG_LIB in ${FFMPEG_LIBS}; do

      # INITIALIZE FFMPEG FRAMEWORK DIRECTORY
      XCFRAMEWORK_PATH=${BASEDIR}/prebuilt/macos-xcframework/${FFMPEG_LIB}.xcframework
      mkdir -p "${XCFRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

      echo -e "Creating package for ${FFMPEG_LIB}\n" 1>>"${BASEDIR}"/build.log 2>&1

      BUILD_COMMAND="xcodebuild -create-xcframework "

      for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do

        FFMPEG_LIB_UPPERCASE=$(echo "${FFMPEG_LIB}" | tr '[a-z]' '[A-Z]')
        FFMPEG_LIB_CAPITALCASE=$(to_capital_case "${FFMPEG_LIB}")

        # EXTRACT FFMPEG VERSION
        FFMPEG_LIB_MAJOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR" "${BASEDIR}/prebuilt/macos-${TARGET_ARCH}/ffmpeg/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR//g;s/\ //g")
        FFMPEG_LIB_MINOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR" "${BASEDIR}/prebuilt/macos-${TARGET_ARCH}/ffmpeg/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR//g;s/\ //g")
        FFMPEG_LIB_MICRO=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO" "${BASEDIR}/prebuilt/macos-${TARGET_ARCH}/ffmpeg/include/${FFMPEG_LIB}/version.h" | sed "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO//g;s/\ //g")
        FFMPEG_LIB_VERSION="${FFMPEG_LIB_MAJOR}.${FFMPEG_LIB_MINOR}.${FFMPEG_LIB_MICRO}"

        # INITIALIZE SUB-FRAMEWORK DIRECTORY
        FFMPEG_LIB_FRAMEWORK_PATH=${BASEDIR}/prebuilt/macos-xcframework/.tmp/macos-${TARGET_ARCH}/${FFMPEG_LIB}.framework
        rm -rf "${FFMPEG_LIB_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
        mkdir -p "${FFMPEG_LIB_FRAMEWORK_PATH}/Headers" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

        # COPY HEADER FILES
        cp -r "${BASEDIR}"/prebuilt/macos-${TARGET_ARCH}/ffmpeg/include/${FFMPEG_LIB}/* ${FFMPEG_LIB_FRAMEWORK_PATH}/Headers 1>>"${BASEDIR}"/build.log 2>&1

        # COPY LIBRARY FILE
        cp "${BASEDIR}/prebuilt/macos-${TARGET_ARCH}/ffmpeg/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}" "${FFMPEG_LIB_FRAMEWORK_PATH}/${FFMPEG_LIB}" 1>>"${BASEDIR}"/build.log 2>&1

        # COPY THE LICENSES
        if [ ${GPL_ENABLED} == "yes" ]; then
          cp "${BASEDIR}/LICENSE.GPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
        else
          cp "${BASEDIR}/LICENSE.LGPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
        fi

        build_info_plist "${FFMPEG_LIB_FRAMEWORK_PATH}/Info.plist" "${FFMPEG_LIB}" "com.arthenica.ffmpegkit.${FFMPEG_LIB_CAPITALCASE}" "${FFMPEG_LIB_VERSION}" "${FFMPEG_LIB_VERSION}"

        BUILD_COMMAND+=" -framework ${FFMPEG_LIB_FRAMEWORK_PATH}"

      done

      BUILD_COMMAND+=" -output ${XCFRAMEWORK_PATH}"

      # EXECUTE CREATE FRAMEWORK COMMAND
      COMMAND_OUTPUT=$(${BUILD_COMMAND} 2>&1)
      echo "${COMMAND_OUTPUT}" 1>>"${BASEDIR}"/build.log 2>&1
      echo "" 1>>"${BASEDIR}"/build.log 2>&1

      # DO NOT ALLOW EMPTY FRAMEWORKS
      if [[ ${COMMAND_OUTPUT} == *"is empty in library"* ]]; then
        echo -e "failed\n"
        exit 1
      fi

      echo -e "Created ${FFMPEG_LIB} xcframework successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1

    done

    # CREATE FFMPEG

    # INITIALIZE FFMPEG KIT FRAMEWORK DIRECTORY
    XCFRAMEWORK_PATH=${BASEDIR}/prebuilt/macos-xcframework/ffmpegkit.xcframework
    mkdir -p "${XCFRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

    BUILD_COMMAND="xcodebuild -create-xcframework "

    for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do

      # INITIALIZE SUB-FRAMEWORK DIRECTORY
      FFMPEG_KIT_FRAMEWORK_PATH="${BASEDIR}/prebuilt/macos-xcframework/.tmp/macos-${TARGET_ARCH}/ffmpegkit.framework"
      rm -rf "${FFMPEG_KIT_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
      mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}/Headers" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
      mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}/Modules" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
      build_modulemap "${FFMPEG_KIT_FRAMEWORK_PATH}/Modules/module.modulemap"

      # COPY HEADER FILES
      cp -r "${BASEDIR}"/prebuilt/macos-"${TARGET_ARCH}"/ffmpeg-kit/include/* "${FFMPEG_KIT_FRAMEWORK_PATH}"/Headers 1>>"${BASEDIR}"/build.log 2>&1

      # COPY LIBRARY FILE
      cp "${BASEDIR}/prebuilt/macos-${TARGET_ARCH}/ffmpeg-kit/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION}" "${FFMPEG_KIT_FRAMEWORK_PATH}/ffmpegkit" 1>>"${BASEDIR}"/build.log 2>&1

      # COPY THE LICENSES
      if [ ${GPL_ENABLED} == "yes" ]; then
        cp "${BASEDIR}/LICENSE.GPLv3" "${FFMPEG_KIT_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
      else
        cp "${BASEDIR}/LICENSE.LGPLv3" "${FFMPEG_KIT_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
      fi

      BUILD_COMMAND+=" -framework ${FFMPEG_KIT_FRAMEWORK_PATH}"

    done

    BUILD_COMMAND+=" -output ${XCFRAMEWORK_PATH}"

    # EXECUTE CREATE FRAMEWORK COMMAND
    COMMAND_OUTPUT=$(${BUILD_COMMAND} 2>&1)
    echo "${COMMAND_OUTPUT}" 1>>"${BASEDIR}"/build.log 2>&1
    echo "" 1>>"${BASEDIR}"/build.log 2>&1

    # DO NOT ALLOW EMPTY FRAMEWORKS
    if [[ ${COMMAND_OUTPUT} == *"is empty in library"* ]]; then
      echo -e "failed\n"
      exit 1
    fi

    echo -e "Created ffmpegkit xcframework successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "ok\n"

  else

    # CREATE .framework AND FAT/UNIVERSAL LIBRARY IF ENABLED

    # CREATE FFMPEG

    # INITIALIZE UNIVERSAL LIBRARY DIRECTORY
    FFMPEG_UNIVERSAL="${BASEDIR}/prebuilt/macos-universal/ffmpeg-universal"
    mkdir -p "${FFMPEG_UNIVERSAL}/include" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${FFMPEG_UNIVERSAL}/lib" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

    # COPY HEADER FILES
    cp -r "${BASEDIR}"/prebuilt/macos-"${TARGET_ARCH_LIST[0]}"/ffmpeg/include/* ${FFMPEG_UNIVERSAL}/include 1>>"${BASEDIR}"/build.log 2>&1
    cp "${BASEDIR}"/prebuilt/macos-"${TARGET_ARCH_LIST[0]}"/ffmpeg/include/config.h "${FFMPEG_UNIVERSAL}/include" 1>>"${BASEDIR}"/build.log 2>&1

    for FFMPEG_LIB in ${FFMPEG_LIBS}; do
      LIPO_COMMAND="${LIPO} -create"

      for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
        LIPO_COMMAND+=" "${BASEDIR}"/prebuilt/macos-${TARGET_ARCH}/ffmpeg/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}"
      done

      LIPO_COMMAND+=" -output ${FFMPEG_UNIVERSAL}/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}"

      # EXECUTE CREATE UNIVERSAL LIBRARY COMMAND
      ${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1
      if [ $? -ne 0 ]; then
        echo -e "failed\n"
        exit 1
      fi

      FFMPEG_LIB_UPPERCASE=$(echo "${FFMPEG_LIB}" | tr '[a-z]' '[A-Z]')
      FFMPEG_LIB_CAPITALCASE=$(to_capital_case "${FFMPEG_LIB}")

      # EXTRACT FFMPEG VERSION
      FFMPEG_LIB_MAJOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR" "${FFMPEG_UNIVERSAL}/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR//g;s/\ //g")
      FFMPEG_LIB_MINOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR" "${FFMPEG_UNIVERSAL}/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR//g;s/\ //g")
      FFMPEG_LIB_MICRO=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO" "${FFMPEG_UNIVERSAL}/include/${FFMPEG_LIB}/version.h" | sed "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO//g;s/\ //g")
      FFMPEG_LIB_VERSION="${FFMPEG_LIB_MAJOR}.${FFMPEG_LIB_MINOR}.${FFMPEG_LIB_MICRO}"

      # INITIALIZE FRAMEWORK DIRECTORY
      FFMPEG_LIB_FRAMEWORK_PATH="${BASEDIR}/prebuilt/macos-framework/${FFMPEG_LIB}.framework"
      rm -rf "${FFMPEG_LIB_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
      mkdir -p "${FFMPEG_LIB_FRAMEWORK_PATH}/Headers" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

      # COPY HEADER FILES
      cp -r ${FFMPEG_UNIVERSAL}/include/${FFMPEG_LIB}/* ${FFMPEG_LIB_FRAMEWORK_PATH}/Headers 1>>"${BASEDIR}"/build.log 2>&1

      # COPY LIBRARY FILE
      cp "${FFMPEG_UNIVERSAL}/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}" "${FFMPEG_LIB_FRAMEWORK_PATH}/${FFMPEG_LIB}" 1>>"${BASEDIR}"/build.log 2>&1

      # COPY FRAMEWORK LICENSES
      if [ ${GPL_ENABLED} == "yes" ]; then
        cp "${BASEDIR}/LICENSE.GPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
      else
        cp "${BASEDIR}/LICENSE.LGPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
      fi

      build_info_plist "${FFMPEG_LIB_FRAMEWORK_PATH}/Info.plist" "${FFMPEG_LIB}" "com.arthenica.ffmpegkit.${FFMPEG_LIB_CAPITALCASE}" "${FFMPEG_LIB_VERSION}" "${FFMPEG_LIB_VERSION}"

      echo -e "Created ${FFMPEG_LIB} framework successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1
    done

    # COPY UNIVERSAL LIBRARY LICENSES
    if [ ${GPL_ENABLED} == "yes" ]; then
      cp "${BASEDIR}"/LICENSE.GPLv3 "${FFMPEG_UNIVERSAL}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
    else
      cp "${BASEDIR}"/LICENSE.LGPLv3 "${FFMPEG_UNIVERSAL}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
    fi

    # FFMPEG KIT

    # INITIALIZE FRAMEWORK AND UNIVERSAL LIBRARY DIRECTORIES
    FFMPEG_KIT_VERSION=$(get_ffmpeg_kit_version)
    FFMPEG_KIT_UNIVERSAL="${BASEDIR}/prebuilt/macos-universal/ffmpeg-kit-universal"
    FFMPEG_KIT_FRAMEWORK_PATH="${BASEDIR}/prebuilt/macos-framework/ffmpegkit.framework"
    mkdir -p "${FFMPEG_KIT_UNIVERSAL}/include" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${FFMPEG_KIT_UNIVERSAL}/lib" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    rm -rf "${FFMPEG_KIT_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
    mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}/Headers" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
    mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}/Modules" 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

    LIPO_COMMAND="${LIPO} -create"
    for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
      LIPO_COMMAND+=" ${BASEDIR}/prebuilt/macos-${TARGET_ARCH}/ffmpeg-kit/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION}"
    done
    LIPO_COMMAND+=" -output ${FFMPEG_KIT_UNIVERSAL}/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION}"

    # EXECUTE CREATE UNIVERSAL LIBRARY COMMAND
    ${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1
    if [ $? -ne 0 ]; then
      echo -e "failed\n"
      exit 1
    fi

    # COPY HEADER FILES
    cp -r "${BASEDIR}"/prebuilt/macos-"${TARGET_ARCH_LIST[0]}"/ffmpeg-kit/include/* "${FFMPEG_KIT_UNIVERSAL}"/include 1>>"${BASEDIR}"/build.log 2>&1
    cp -r "${FFMPEG_KIT_UNIVERSAL}"/include/* "${FFMPEG_KIT_FRAMEWORK_PATH}"/Headers 1>>"${BASEDIR}"/build.log 2>&1

    # COPY LIBRARY FILE
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
