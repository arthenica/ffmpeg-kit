#!/bin/bash

export FFMPEG_KIT_BUILD_TYPE="tvos"
export BASEDIR="$(pwd)"

source "${BASEDIR}"/scripts/common-${FFMPEG_KIT_BUILD_TYPE}.sh

# ENABLE ARCH
ENABLED_ARCHITECTURES=(0 0 0 0 0 1 0 0 0 1 0)

# ENABLE LIBRARIES
ENABLED_LIBRARIES=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)

# USE 10.2 AS TVOS_MIN_VERSION
export TVOS_MIN_VERSION=10.2

export APPLE_TVOS_BUILD=1

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

  echo -e "\n$COMMAND builds FFmpegKit for tvOS platform. By default two architectures (arm64 and x86-64) are built \
without any external libraries enabled. Options can be used to disable architectures and/or enable external libraries. \
Please note that GPL libraries (external libraries with GPL license) need --enable-gpl flag to be set explicitly. \
When compilation ends, framework bundles and universal fat binaries are created under the prebuilt folder.\n"
  echo -e "Usage: ./$COMMAND [OPTION]...\n"
  echo -e "Specify environment variables as VARIABLE=VALUE to override default build options.\n"

  display_help_options
  display_help_licensing

  echo -e "Architectures:"

  echo -e "  --disable-arm64\t\tdo not build arm64 architecture [yes]"
  echo -e "  --disable-x86-64\t\tdo not build x86-64 architecture [yes]\n"

  echo -e "Libraries:"
  echo -e "  --full\t\t\tenables all non-GPL external libraries"
  echo -e "  --enable-tvos-audiotoolbox\tbuild with built-in Apple AudioToolbox support[no]"
  echo -e "  --enable-tvos-bzip2\t\tbuild with built-in bzip2 support[no]"
  if [[ -z ${FFMPEG_KIT_LTS_BUILD} ]]; then
    echo -e "  --enable-tvos-videotoolbox\tbuild with built-in Apple VideoToolbox support[no]"
  fi
  echo -e "  --enable-tvos-zlib\t\tbuild with built-in zlib [no]"
  echo -e "  --enable-tvos-libiconv\tbuild with built-in libiconv [no]"

  display_help_common_libraries
  display_help_gpl_libraries
  display_help_advanced_options
}

enable_lts_build() {
  export FFMPEG_KIT_LTS_BUILD="1"

  # XCODE 7.3 HAS TVOS SDK 9.2
  export TVOS_MIN_VERSION=9.2

  # TVOS SDK 9.2 DOES NOT INCLUDE VIDEOTOOLBOX
  ENABLED_LIBRARIES[LIBRARY_VIDEOTOOLBOX]=0
}

create_static_fat_library() {
  local FAT_LIBRARY_PATH="${BASEDIR}"/prebuilt/tvos-universal/"$2"-universal

  mkdir -p "${FAT_LIBRARY_PATH}"/lib 1>>"${BASEDIR}"/build.log 2>&1

  LIPO_COMMAND="${LIPO} -create"

  for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
    LIPO_COMMAND+=" $(find "${BASEDIR}"/prebuilt/tvos-"${TARGET_ARCH}"-apple-darwin -name $1)"
  done

  LIPO_COMMAND+=" -output ${FAT_LIBRARY_PATH}/lib/$1"

  RC=$(${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1)

  echo ${RC}
}


get_external_library_version() {
  local library_version=$(grep Version "${BASEDIR}"/prebuilt/tvos-"${TARGET_ARCH_LIST[0]}"-apple-darwin/pkgconfig/"$1".pc 2>>"${BASEDIR}"/build.log | sed 's/Version://g;s/\ //g')

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

DETECTED_TVOS_SDK_VERSION="$(xcrun --sdk appletvos --show-sdk-version)"

echo -e "INFO: Using SDK ${DETECTED_TVOS_SDK_VERSION} by Xcode provided at $(xcode-select -p)\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "\nINFO: Build options: $*\n" 1>>"${BASEDIR}"/build.log 2>&1

if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]] && [[ "${DETECTED_TVOS_SDK_VERSION}" != "${TVOS_MIN_VERSION}" ]]; then
  echo -e "\n(*) LTS packages should be built using SDK ${TVOS_MIN_VERSION} but current configuration uses SDK ${DETECTED_TVOS_SDK_VERSION}\n"

  if [[ -z ${BUILD_FORCE} ]]; then
    exit 1
  fi
fi

GPL_ENABLED="no"
DISPLAY_HELP=""
BUILD_LTS=""
BUILD_FULL=""
BUILD_TYPE_ID=""
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
    SKIP_LIBRARY=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

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

echo -e "\nBuilding ffmpeg-kit ${BUILD_TYPE_ID}static library for tvOS\n"
echo -e -n "INFO: Building ffmpeg-kit ${BUILD_VERSION} ${BUILD_TYPE_ID}for tvOS: " 1>>"${BASEDIR}"/build.log 2>&1
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

for run_arch in {0..10}; do
  if [[ ${ENABLED_ARCHITECTURES[$run_arch]} -eq 1 ]]; then
    export ARCH=$(get_arch_name $run_arch)
    export TARGET_SDK=$(get_target_sdk)
    export SDK_PATH=$(get_sdk_path)
    export SDK_NAME=$(get_sdk_name)

    export LIPO="$(xcrun --sdk "$(get_sdk_name)" -f lipo)"

    . "${BASEDIR}"/scripts/main-tvos.sh "${ENABLED_LIBRARIES[@]}"
    case ${ARCH} in
    x86-64)
      TARGET_ARCH="x86_64"
      ;;
    *)
      TARGET_ARCH="${ARCH}"
      ;;
    esac
    TARGET_ARCH_LIST+=(${TARGET_ARCH})

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

  echo -e -n "\n\nCreating frameworks and universal libraries under prebuilt: "

  # BUILDING UNIVERSAL LIBRARIES
  rm -rf "${BASEDIR}"/prebuilt/tvos-universal 1>>"${BASEDIR}"/build.log 2>&1
  mkdir -p "${BASEDIR}"/prebuilt/tvos-universal 1>>"${BASEDIR}"/build.log 2>&1
  rm -rf "${BASEDIR}"/prebuilt/tvos-framework 1>>"${BASEDIR}"/build.log 2>&1
  mkdir -p "${BASEDIR}"/prebuilt/tvos-framework 1>>"${BASEDIR}"/build.log 2>&1

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

      echo -e "Creating universal library for ${library_name}\n" 1>>"${BASEDIR}"/build.log 2>&1

      if [[ ${LIBRARY_LIBTHEORA} == "$library" ]]; then

        LIBRARY_CREATED=$(create_static_fat_library "libtheora.a" "libtheora")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_static_fat_library "libtheoraenc.a" "libtheoraenc")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_static_fat_library "libtheoradec.a" "libtheoradec")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libtheora" "libtheora.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libtheoraenc" "libtheoraenc.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libtheoradec" "libtheoradec.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libtheora-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libtheoraenc-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libtheoradec-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libtheora.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libtheoraenc.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libtheoradec.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

      elif [[ ${LIBRARY_LIBVORBIS} == "$library" ]]; then

        LIBRARY_CREATED=$(create_static_fat_library "libvorbisfile.a" "libvorbisfile")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_static_fat_library "libvorbisenc.a" "libvorbisenc")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_static_fat_library "libvorbis.a" "libvorbis")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libvorbisfile" "libvorbisfile.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libvorbisenc" "libvorbisenc.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libvorbis" "libvorbis.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libvorbisfile-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libvorbisenc-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libvorbis-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libvorbisfile.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libvorbisenc.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libvorbis.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

      elif [[ ${LIBRARY_LIBWEBP} == "$library" ]]; then

        LIBRARY_CREATED=$(create_static_fat_library "libwebpmux.a" "libwebpmux")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_static_fat_library "libwebpdemux.a" "libwebpdemux")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_static_fat_library "libwebp.a" "libwebp")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libwebpmux" "libwebpmux.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libwebpdemux" "libwebpdemux.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libwebp" "libwebp.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libwebpmux-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libwebpdemux-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libwebp-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libwebpmux.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libwebpdemux.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libwebp.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

      elif
        [[ ${LIBRARY_OPENCOREAMR} == "$library" ]]
      then

        LIBRARY_CREATED=$(create_static_fat_library "libopencore-amrnb.a" "libopencore-amrnb")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libopencore-amrnb" "libopencore-amrnb.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libopencore-amrnb-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libopencore-amrnb.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

      elif [[ ${LIBRARY_NETTLE} == "$library" ]]; then

        LIBRARY_CREATED=$(create_static_fat_library "libnettle.a" "libnettle")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        LIBRARY_CREATED=$(create_static_fat_library "libhogweed.a" "libhogweed")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libnettle" "libnettle.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "libhogweed" "libhogweed.a" $library_version)
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libnettle-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/libhogweed-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libnettle.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/libhogweed.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

      else
        library_name=$(get_library_name $((library)))
        static_archive_name=$(get_static_archive_name $((library)))
        LIBRARY_CREATED=$(create_static_fat_library "$static_archive_name" "$library_name")
        if [[ ${LIBRARY_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        FRAMEWORK_CREATED=$(create_static_framework "$library_name" "$static_archive_name" "$library_version")
        if [[ ${FRAMEWORK_CREATED} -ne 0 ]]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-universal/${library_name}-universal/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

        $(cp $(get_external_library_license_path ${library}) "${BASEDIR}"/prebuilt/tvos-framework/${library_name}.framework/LICENSE 1>>"${BASEDIR}"/build.log 2>&1)
        if [ $? -ne 0 ]; then
          echo -e "failed\n"
          exit 1
        fi

      fi

    fi
  done

  # 2. FFMPEG
  FFMPEG_UNIVERSAL="${BASEDIR}"/prebuilt/tvos-universal/ffmpeg-universal
  mkdir -p "${FFMPEG_UNIVERSAL}"/include 1>>"${BASEDIR}"/build.log 2>&1
  mkdir -p "${FFMPEG_UNIVERSAL}"/lib 1>>"${BASEDIR}"/build.log 2>&1

  cp -r "${BASEDIR}"/prebuilt/tvos-"${TARGET_ARCH_LIST[0]}"-apple-darwin/ffmpeg/include/* "${FFMPEG_UNIVERSAL}"/include 1>>"${BASEDIR}"/build.log 2>&1
  cp "${BASEDIR}"/prebuilt/tvos-"${TARGET_ARCH_LIST[0]}"-apple-darwin/ffmpeg/include/config.h "${FFMPEG_UNIVERSAL}"/include 1>>"${BASEDIR}"/build.log 2>&1

  for FFMPEG_LIB in ${FFMPEG_LIBS}; do
    LIPO_COMMAND="${LIPO} -create"

    for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
      LIPO_COMMAND+=" ${BASEDIR}/prebuilt/tvos-${TARGET_ARCH}-apple-darwin/ffmpeg/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}"
    done

    LIPO_COMMAND+=" -output ${FFMPEG_UNIVERSAL}/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}"

    ${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1

    if [ $? -ne 0 ]; then
      echo -e "failed\n"
      exit 1
    fi

    FFMPEG_LIB_UPPERCASE=$(echo "${FFMPEG_LIB}" | tr '[a-z]' '[A-Z]')
    FFMPEG_LIB_CAPITALCASE=$(to_capital_case "${FFMPEG_LIB}")

    FFMPEG_LIB_MAJOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR" "${FFMPEG_UNIVERSAL}"/include/${FFMPEG_LIB}/version.h | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR//g;s/\ //g")
    FFMPEG_LIB_MINOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR" "${FFMPEG_UNIVERSAL}"/include/${FFMPEG_LIB}/version.h | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR//g;s/\ //g")
    FFMPEG_LIB_MICRO=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO" "${FFMPEG_UNIVERSAL}"/include/${FFMPEG_LIB}/version.h | sed "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO//g;s/\ //g")

    FFMPEG_LIB_VERSION="${FFMPEG_LIB_MAJOR}.${FFMPEG_LIB_MINOR}.${FFMPEG_LIB_MICRO}"

    FFMPEG_LIB_FRAMEWORK_PATH=${BASEDIR}/prebuilt/tvos-framework/${FFMPEG_LIB}.framework

    rm -rf "${FFMPEG_LIB_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
    mkdir -p "${FFMPEG_LIB_FRAMEWORK_PATH}"/Headers 1>>"${BASEDIR}"/build.log 2>&1

    cp -r "${FFMPEG_UNIVERSAL}/include/${FFMPEG_LIB}/*" "${FFMPEG_LIB_FRAMEWORK_PATH}"/Headers 1>>"${BASEDIR}"/build.log 2>&1
    cp "${FFMPEG_UNIVERSAL}/lib/${FFMPEG_LIB}.${BUILD_LIBRARY_EXTENSION}" "${FFMPEG_LIB_FRAMEWORK_PATH}/${FFMPEG_LIB}" 1>>"${BASEDIR}"/build.log 2>&1

    # COPY THE LICENSES
    if [ ${GPL_ENABLED} == "yes" ]; then

      # GPLv3.0
      cp "${BASEDIR}"/LICENSE.GPLv3 "${FFMPEG_LIB_FRAMEWORK_PATH}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
    else

      # LGPLv3.0
      cp "${BASEDIR}"/LICENSE.LGPLv3 "${FFMPEG_LIB_FRAMEWORK_PATH}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
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
  FFMPEG_KIT_UNIVERSAL=${BASEDIR}/prebuilt/tvos-universal/ffmpeg-kit-universal
  FFMPEG_KIT_FRAMEWORK_PATH=${BASEDIR}/prebuilt/tvos-framework/ffmpegkit.framework
  mkdir -p "${FFMPEG_KIT_UNIVERSAL}"/include 1>>"${BASEDIR}"/build.log 2>&1
  mkdir -p "${FFMPEG_KIT_UNIVERSAL}"/lib 1>>"${BASEDIR}"/build.log 2>&1
  rm -rf "${FFMPEG_KIT_FRAMEWORK_PATH}" 1>>"${BASEDIR}"/build.log 2>&1
  mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}"/Headers 1>>"${BASEDIR}"/build.log 2>&1
  mkdir -p "${FFMPEG_KIT_FRAMEWORK_PATH}"/Modules 1>>"${BASEDIR}"/build.log 2>&1

  LIPO_COMMAND="${LIPO} -create"
  for TARGET_ARCH in "${TARGET_ARCH_LIST[@]}"; do
    LIPO_COMMAND+=" ${BASEDIR}/prebuilt/tvos-${TARGET_ARCH}-apple-darwin/ffmpeg-kit/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION}"
  done
  LIPO_COMMAND+=" -output ${FFMPEG_KIT_UNIVERSAL}/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION}"

  ${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1

  if [ $? -ne 0 ]; then
    echo -e "failed\n"
    exit 1
  fi

  cp -r "${BASEDIR}"/prebuilt/tvos-"${TARGET_ARCH_LIST[0]}"-apple-darwin/ffmpeg-kit/include/* "${FFMPEG_KIT_UNIVERSAL}"/include 1>>"${BASEDIR}"/build.log 2>&1
  cp -r "${FFMPEG_KIT_UNIVERSAL}"/include/* "${FFMPEG_KIT_FRAMEWORK_PATH}/Headers" 1>>"${BASEDIR}"/build.log 2>&1
  cp "${FFMPEG_KIT_UNIVERSAL}"/lib/libffmpegkit.${BUILD_LIBRARY_EXTENSION} "${FFMPEG_KIT_FRAMEWORK_PATH}"/ffmpegkit 1>>"${BASEDIR}"/build.log 2>&1

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

  echo -e "Created ffmpeg-kit.framework and universal library successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1

  echo -e "ok\n"
fi
