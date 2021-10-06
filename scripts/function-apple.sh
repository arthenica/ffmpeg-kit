#!/bin/bash

source "${BASEDIR}/scripts/function.sh"

export FFMPEG_LIBS=("libavcodec" "libavdevice" "libavfilter" "libavformat" "libavutil" "libswresample" "libswscale")

get_ffmpeg_kit_version() {
  local FFMPEG_KIT_VERSION=$(grep 'const FFMPEG_KIT_VERSION' "${BASEDIR}"/apple/src/FFmpegKit.m | grep -Eo '\".*\"' | sed -e 's/\"//g')

  if [[ -z ${FFMPEG_KIT_LTS_BUILD} ]]; then
    echo "${FFMPEG_KIT_VERSION}"
  else
    echo "${FFMPEG_KIT_VERSION}.LTS"
  fi
}

get_external_library_version() {
  local library_version=$(grep Version "${BASEDIR}"/prebuilt/"$(get_build_directory)"/pkgconfig/"$1".pc 2>>"${BASEDIR}"/build.log | sed 's/Version://g;s/\ //g')

  echo "${library_version}"
}

#
# 1. architecture index
# 2. detected sdk version
#
disable_ios_architecture_not_supported_on_detected_sdk_version() {
  local ARCH_NAME=$(get_arch_name $1)

  case ${ARCH_NAME} in
  armv7 | armv7s | i386)

    # SUPPORTED UNTIL IOS SDK 10.3.1
    if [[ $(echo "$2 > 10.4" | bc) -eq 1 ]]; then
      local SUPPORTED=0
    else
      local SUPPORTED=1
    fi
    ;;
  arm64e)

    # INTRODUCED IN IOS SDK 10.1
    if [[ $(echo "$2 > 10" | bc) -eq 1 ]]; then
      local SUPPORTED=1
    else
      local SUPPORTED=0
    fi
    ;;
  x86-64-mac-catalyst)

    # INTRODUCED IN IOS SDK 13
    if [[ $(echo "$2 > 12.4" | bc) -eq 1 ]]; then
      local SUPPORTED=1
    else
      local SUPPORTED=0
    fi
    ;;
  arm64-*)

    # INTRODUCED IN IOS SDK 14
    if [[ $(echo "$2 > 13.7" | bc) -eq 1 ]]; then
      local SUPPORTED=1
    else
      local SUPPORTED=0
    fi
    ;;
  *)
    local SUPPORTED=1
    ;;
  esac

  if [[ ${SUPPORTED} -ne 1 ]]; then
    if [[ -z ${BUILD_FORCE} ]]; then
      echo -e "INFO: Disabled ${ARCH_NAME} architecture which is not supported on SDK $2\n" 1>>"${BASEDIR}"/build.log 2>&1
      disable_arch "${ARCH_NAME}"
    fi
  fi
}

#
# 1. architecture index
# 2. detected sdk version
#
disable_tvos_architecture_not_supported_on_detected_sdk_version() {
  local ARCH_NAME=$(get_arch_name $1)

  case ${ARCH_NAME} in
  arm64-simulator)

    # INTRODUCED IN TVOS SDK 14
    if [[ $(echo "$2 > 13.4" | bc) -eq 1 ]]; then
      local SUPPORTED=1
    else
      local SUPPORTED=0
    fi
    ;;
  *)
    local SUPPORTED=1
    ;;
  esac

  if [[ ${SUPPORTED} -ne 1 ]]; then
    if [[ -z ${BUILD_FORCE} ]]; then
      echo -e "INFO: Disabled ${ARCH_NAME} architecture which is not supported on SDK $2\n" 1>>"${BASEDIR}"/build.log 2>&1
      disable_arch "${ARCH_NAME}"
    fi
  fi
}

#
# 1. architecture index
# 2. detected sdk version
#
disable_macos_architecture_not_supported_on_detected_sdk_version() {
  local ARCH_NAME=$(get_arch_name $1)

  case ${ARCH_NAME} in
  arm64)

    # INTRODUCED IN MACOS SDK 11
    if [[ $(echo "$2 > 10.16" | bc) -eq 1 ]]; then
      local SUPPORTED=1
    else
      local SUPPORTED=0
    fi
    ;;
  *)
    local SUPPORTED=1
    ;;
  esac

  if [[ ${SUPPORTED} -ne 1 ]]; then
    if [[ -z ${BUILD_FORCE} ]]; then
      echo -e "INFO: Disabled ${ARCH_NAME} architecture which is not supported on SDK $2\n" 1>>"${BASEDIR}"/build.log 2>&1
      disable_arch "${ARCH_NAME}"
    fi
  fi
}

build_apple_architecture_variant_strings() {
  export ALL_IOS_ARCHITECTURES="$(get_apple_architectures_for_variant "${ARCH_VAR_IOS}")"
  export IPHONEOS_ARCHITECTURES="$(get_apple_architectures_for_variant "${ARCH_VAR_IPHONEOS}")"
  export IPHONE_SIMULATOR_ARCHITECTURES="$(get_apple_architectures_for_variant "${ARCH_VAR_IPHONESIMULATOR}")"
  export MAC_CATALYST_ARCHITECTURES="$(get_apple_architectures_for_variant "${ARCH_VAR_MAC_CATALYST}")"
  export ALL_TVOS_ARCHITECTURES="$(get_apple_architectures_for_variant "${ARCH_VAR_TVOS}")"
  export APPLETVOS_ARCHITECTURES="$(get_apple_architectures_for_variant "${ARCH_VAR_APPLETVOS}")"
  export APPLETV_SIMULATOR_ARCHITECTURES="$(get_apple_architectures_for_variant "${ARCH_VAR_APPLETVSIMULATOR}")"
  export MACOSX_ARCHITECTURES="$(get_apple_architectures_for_variant "${ARCH_VAR_MACOS}")"
}

#
# 1. architecture variant
#
# DEPENDS TARGET_ARCH_LIST VARIABLE
#
is_apple_architecture_variant_supported() {
  local ARCHITECTURE_VARIANT="$1"
  local TARGET_ARCHITECTURES=("$(get_apple_architectures_for_variant "${ARCHITECTURE_VARIANT}")")
  local SUPPORTED="0"

  for ARCH in "${TARGET_ARCH_LIST[@]}"; do
    if [[ " ${TARGET_ARCHITECTURES[*]} " == *" ${ARCH} "* ]]; then
      SUPPORTED="1"
    fi
  done

  echo "${SUPPORTED}"
}

#
# 1. folder path
#
initialize_folder() {
  rm -rf "$1" 1>>"${BASEDIR}"/build.log 2>&1
  if [[ $? -ne 0 ]]; then
    return 1
  fi

  mkdir -p "$1" 1>>"${BASEDIR}"/build.log 2>&1
  if [[ $? -ne 0 ]]; then
    return 1
  fi

  return 0
}

#
# 1. library index
# 2. static library name
# 3. universal library directory
# 4. target architectures array
#
# DEPENDS TARGET_ARCH_LIST VARIABLE
#
create_single_universal_library() {
  local LIBRARY_INDEX="$1"
  local STATIC_LIBRARY_NAME="$2"
  local UNIVERSAL_DIRECTORY_PATH="$3"
  local TARGET_ARCHITECTURES=("$4")
  local LIBRARY_NAME=$(get_library_name "${LIBRARY_INDEX}")
  local LIPO="$(xcrun --sdk "$(get_default_sdk_name)" -f lipo)"

  local LIPO_COMMAND="${LIPO} -create"

  for ARCH in "${TARGET_ARCH_LIST[@]}"; do
    if [[ " ${TARGET_ARCHITECTURES[*]} " == *" ${ARCH} "* ]]; then
      local FULL_LIBRARY_PATH="${BASEDIR}/prebuilt/$(get_build_directory)/${LIBRARY_NAME}/lib/${STATIC_LIBRARY_NAME}"
      LIPO_COMMAND+=" ${FULL_LIBRARY_PATH}"
    fi
  done

  LIPO_COMMAND+=" -output ${UNIVERSAL_DIRECTORY_PATH}/lib/${STATIC_LIBRARY_NAME}"

  mkdir -p "${UNIVERSAL_DIRECTORY_PATH}/lib" 1>>"${BASEDIR}"/build.log 2>&1

  ${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1

  if [[ $? -ne 0 ]]; then
    echo -e "\nINFO: Failed to build universal ${LIBRARY_NAME} library\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi

  RC=$(copy_external_library_license "$LIBRARY_INDEX" "${UNIVERSAL_DIRECTORY_PATH}")

  if [[ ${RC} -ne 0 ]]; then
    echo -e "\nINFO: Failed to build universal ${LIBRARY_NAME} library\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi
}

#
# 1. library index
# 2. architecture variant
#
# DEPENDS TARGET_ARCH_LIST VARIABLE
#
create_universal_library() {
  local LIBRARY_INDEX="$1"
  local ARCHITECTURE_VARIANT="$2"
  local TARGET_ARCHITECTURES=("$(get_apple_architectures_for_variant "${ARCHITECTURE_VARIANT}")")
  local LIBRARY_NAME=$(get_library_name "${LIBRARY_INDEX}")
  local UNIVERSAL_LIBRARY_PATH="${BASEDIR}/prebuilt/$(get_universal_library_directory "${ARCHITECTURE_VARIANT}")"

  if [[ $(is_apple_architecture_variant_supported "${ARCHITECTURE_VARIANT}") -eq 0 ]]; then

    # THERE ARE NO ARCHITECTURES ENABLED FOR THIS LIBRARY TYPE
    return
  fi

  initialize_folder "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}"

  if [[ ${LIBRARY_LIBTHEORA} == "${LIBRARY_INDEX}" ]]; then

    create_single_universal_library "${LIBRARY_INDEX}" "libtheora.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"
    create_single_universal_library "${LIBRARY_INDEX}" "libtheoraenc.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"
    create_single_universal_library "${LIBRARY_INDEX}" "libtheoradec.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"

  elif [[ ${LIBRARY_LIBVORBIS} == "${LIBRARY_INDEX}" ]]; then

    create_single_universal_library "${LIBRARY_INDEX}" "libvorbisfile.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"
    create_single_universal_library "${LIBRARY_INDEX}" "libvorbisenc.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"
    create_single_universal_library "${LIBRARY_INDEX}" "libvorbis.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"

  elif [[ ${LIBRARY_LIBWEBP} == "${LIBRARY_INDEX}" ]]; then

    create_single_universal_library "${LIBRARY_INDEX}" "libwebpmux.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"
    create_single_universal_library "${LIBRARY_INDEX}" "libwebpdemux.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"
    create_single_universal_library "${LIBRARY_INDEX}" "libwebp.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"

  elif [[ ${LIBRARY_OPENCOREAMR} == "${LIBRARY_INDEX}" ]]; then

    create_single_universal_library "${LIBRARY_INDEX}" "libopencore-amrnb.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"

  elif [[ ${LIBRARY_NETTLE} == "${LIBRARY_INDEX}" ]]; then

    create_single_universal_library "${LIBRARY_INDEX}" "libnettle.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"
    create_single_universal_library "${LIBRARY_INDEX}" "libhogweed.a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"

  else

    create_single_universal_library "${LIBRARY_INDEX}" "$(get_static_archive_name "${LIBRARY_INDEX}").a" "${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}" "${TARGET_ARCHITECTURES[@]}"

  fi

  echo -e "DEBUG: ${LIBRARY_NAME} universal library built for $(get_apple_architecture_variant "${ARCHITECTURE_VARIANT}") platform successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
}

#
# 1. architecture variant
#
# DEPENDS TARGET_ARCH_LIST VARIABLE
#
create_ffmpeg_universal_library() {
  local ARCHITECTURE_VARIANT="$1"
  local TARGET_ARCHITECTURES=("$(get_apple_architectures_for_variant "${ARCHITECTURE_VARIANT}")")
  local LIBRARY_NAME="ffmpeg"
  local UNIVERSAL_LIBRARY_PATH="${BASEDIR}/prebuilt/$(get_universal_library_directory "${ARCHITECTURE_VARIANT}")"
  local FFMPEG_UNIVERSAL_LIBRARY_PATH="${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}"
  local LIPO="$(xcrun --sdk "$(get_default_sdk_name)" -f lipo)"

  if [[ $(is_apple_architecture_variant_supported "${ARCHITECTURE_VARIANT}") -eq 0 ]]; then

    # THERE ARE NO ARCHITECTURES ENABLED FOR THIS LIBRARY TYPE
    return
  fi

  # INITIALIZE UNIVERSAL LIBRARY DIRECTORY
  initialize_folder "${FFMPEG_UNIVERSAL_LIBRARY_PATH}"
  initialize_folder "${FFMPEG_UNIVERSAL_LIBRARY_PATH}/include"
  initialize_folder "${FFMPEG_UNIVERSAL_LIBRARY_PATH}/lib"

  local FFMPEG_DEFAULT_BUILD_PATH="${BASEDIR}/prebuilt/$(get_default_build_directory)/ffmpeg"

  # COPY HEADER FILES
  cp -r "${FFMPEG_DEFAULT_BUILD_PATH}"/include/* "${FFMPEG_UNIVERSAL_LIBRARY_PATH}"/include 1>>"${BASEDIR}"/build.log 2>&1
  cp "${FFMPEG_DEFAULT_BUILD_PATH}"/include/config.h "${FFMPEG_UNIVERSAL_LIBRARY_PATH}"/include 1>>"${BASEDIR}"/build.log 2>&1

  for FFMPEG_LIB in "${FFMPEG_LIBS[@]}"; do
    LIPO_COMMAND="${LIPO} -create"

    for ARCH in "${TARGET_ARCH_LIST[@]}"; do
      if [[ " ${TARGET_ARCHITECTURES[*]} " == *" ${ARCH} "* ]]; then
        local FULL_LIBRARY_PATH="${BASEDIR}/prebuilt/$(get_build_directory)/${LIBRARY_NAME}/lib/${FFMPEG_LIB}.a"
        LIPO_COMMAND+=" ${FULL_LIBRARY_PATH}"
      fi
    done

    LIPO_COMMAND+=" -output ${FFMPEG_UNIVERSAL_LIBRARY_PATH}/lib/${FFMPEG_LIB}.a"

    ${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1

    if [[ $? -ne 0 ]]; then
      echo -e "\nINFO: Failed to build universal ${LIBRARY_NAME} library\n" 1>>"${BASEDIR}"/build.log 2>&1
      echo -e "failed\n\nSee build.log for details\n"
      exit 1
    fi
  done

  # COPY UNIVERSAL LIBRARY LICENSES
  if [[ ${GPL_ENABLED} == "yes" ]]; then
    cp "${BASEDIR}"/LICENSE.GPLv3 "${FFMPEG_UNIVERSAL_LIBRARY_PATH}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
  else
    cp "${BASEDIR}"/LICENSE.LGPLv3 "${FFMPEG_UNIVERSAL_LIBRARY_PATH}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
  fi

  echo -e "DEBUG: ${LIBRARY_NAME} universal library built for $(get_apple_architecture_variant "${ARCHITECTURE_VARIANT}") platform successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
}

#
# 1. architecture variant
#
# DEPENDS TARGET_ARCH_LIST VARIABLE
#
create_ffmpeg_kit_universal_library() {
  local ARCHITECTURE_VARIANT="$1"
  local TARGET_ARCHITECTURES=("$(get_apple_architectures_for_variant "${ARCHITECTURE_VARIANT}")")
  local LIBRARY_NAME="ffmpeg-kit"
  local UNIVERSAL_LIBRARY_PATH="${BASEDIR}/prebuilt/$(get_universal_library_directory "${ARCHITECTURE_VARIANT}")"
  local FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH="${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}"
  local LIPO="$(xcrun --sdk "$(get_default_sdk_name)" -f lipo)"

  if [[ $(is_apple_architecture_variant_supported "${ARCHITECTURE_VARIANT}") -eq 0 ]]; then

    # THERE ARE NO ARCHITECTURES ENABLED FOR THIS LIBRARY TYPE
    return
  fi

  # INITIALIZE UNIVERSAL LIBRARY DIRECTORY
  initialize_folder "${FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH}"
  initialize_folder "${FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH}/include"
  initialize_folder "${FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH}/lib"

  local FFMPEG_KIT_DEFAULT_BUILD_PATH="${BASEDIR}/prebuilt/$(get_default_build_directory)/ffmpeg-kit"

  # COPY HEADER FILES
  cp -r "${FFMPEG_KIT_DEFAULT_BUILD_PATH}"/include/* "${FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH}"/include 1>>"${BASEDIR}"/build.log 2>&1

  LIPO_COMMAND="${LIPO} -create"

  for ARCH in "${TARGET_ARCH_LIST[@]}"; do
    if [[ " ${TARGET_ARCHITECTURES[*]} " == *" ${ARCH} "* ]]; then
      local FULL_LIBRARY_PATH="${BASEDIR}/prebuilt/$(get_build_directory)/${LIBRARY_NAME}/lib/libffmpegkit.a"
      LIPO_COMMAND+=" ${FULL_LIBRARY_PATH}"
    fi
  done

  LIPO_COMMAND+=" -output ${FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH}/lib/libffmpegkit.a"

  ${LIPO_COMMAND} 1>>"${BASEDIR}"/build.log 2>&1

  if [[ $? -ne 0 ]]; then
    echo -e "\nINFO: Failed to build universal ${LIBRARY_NAME} library\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi

  # COPY UNIVERSAL LIBRARY LICENSES
  if [[ ${GPL_ENABLED} == "yes" ]]; then
    cp "${BASEDIR}"/LICENSE.GPLv3 "${FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
  else
    cp "${BASEDIR}"/LICENSE.LGPLv3 "${FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH}"/LICENSE 1>>"${BASEDIR}"/build.log 2>&1
  fi

  echo -e "DEBUG: ${LIBRARY_NAME} universal library built for $(get_apple_architecture_variant "${ARCHITECTURE_VARIANT}") platform successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
}

#
# 1. library index
# 2. library version
# 3. static library name
# 4. framework name
# 5. architecture variant
#
create_single_framework() {
  local LIBRARY_INDEX="$1"
  local LIBRARY_VERSION="$2"
  local STATIC_LIBRARY_NAME="$3"
  local FRAMEWORK_NAME="$4"
  local ARCHITECTURE_VARIANT="$5"
  local LIBRARY_NAME=$(get_library_name "${LIBRARY_INDEX}")
  local FRAMEWORK_PATH=${BASEDIR}/prebuilt/$(get_framework_directory "${ARCHITECTURE_VARIANT}")/${FRAMEWORK_NAME}.framework

  initialize_folder "${FRAMEWORK_PATH}"

  local CAPITAL_CASE_FRAMEWORK_NAME=$(to_capital_case "${FRAMEWORK_NAME}")

  build_info_plist "${FRAMEWORK_PATH}/Info.plist" "${LIBRARY_NAME}" "com.arthenica.ffmpegkit.${CAPITAL_CASE_FRAMEWORK_NAME}" "${LIBRARY_VERSION}" "${LIBRARY_VERSION}"

  cp "${BASEDIR}/prebuilt/$(get_universal_library_directory "${ARCHITECTURE_VARIANT}")/${LIBRARY_NAME}/lib/${STATIC_LIBRARY_NAME}.a" "${FRAMEWORK_PATH}/${FRAMEWORK_NAME}" 1>>"${BASEDIR}/build.log" 2>&1

  if [[ $? -ne 0 ]]; then
    echo -e "\nINFO: Failed to build ${LIBRARY_NAME} framework\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi

  RC=$(copy_external_library_license "$LIBRARY_INDEX" "${FRAMEWORK_PATH}")

  if [[ ${RC} -ne 0 ]]; then
    echo -e "\nINFO: Failed to build ${LIBRARY_NAME} framework\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi
}

#
# 1. library index
# 2. architecture variant
#
create_framework() {
  local LIBRARY_INDEX="$1"
  local ARCHITECTURE_VARIANT="$2"
  local LIBRARY_NAME=$(get_library_name "${LIBRARY_INDEX}")
  local PACKAGE_CONFIG_FILE_NAME=$(get_package_config_file_name "${LIBRARY_INDEX}")

  if [[ $(is_apple_architecture_variant_supported "${ARCHITECTURE_VARIANT}") -eq 0 ]]; then

    # THERE ARE NO ARCHITECTURES ENABLED FOR THIS LIBRARY TYPE
    return
  fi

  # EACH ENABLED LIBRARY HAS TO HAVE A .pc FILE AND A VERSION
  local LIBRARY_VERSION=$(get_external_library_version "${PACKAGE_CONFIG_FILE_NAME}")
  if [[ -z ${LIBRARY_VERSION} ]]; then
    echo -e "Failed to detect the version off ${LIBRARY_NAME} from ${PACKAGE_CONFIG_FILE_NAME}.pc\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi

  if [[ ${LIBRARY_LIBTHEORA} == "${LIBRARY_INDEX}" ]]; then

    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libtheora" "libtheora" "${ARCHITECTURE_VARIANT}"
    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libtheoraenc" "libtheoraenc" "${ARCHITECTURE_VARIANT}"
    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libtheoradec" "libtheoradec" "${ARCHITECTURE_VARIANT}"

  elif [[ ${LIBRARY_LIBVORBIS} == "${LIBRARY_INDEX}" ]]; then

    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libvorbisfile" "libvorbisfile" "${ARCHITECTURE_VARIANT}"
    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libvorbisenc" "libvorbisenc" "${ARCHITECTURE_VARIANT}"
    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libvorbis" "libvorbis" "${ARCHITECTURE_VARIANT}"

  elif [[ ${LIBRARY_LIBWEBP} == "${LIBRARY_INDEX}" ]]; then

    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libwebpmux" "libwebpmux" "${ARCHITECTURE_VARIANT}"
    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libwebpdemux" "libwebpdemux" "${ARCHITECTURE_VARIANT}"
    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libwebp" "libwebp" "${ARCHITECTURE_VARIANT}"

  elif [[ ${LIBRARY_OPENCOREAMR} == "${LIBRARY_INDEX}" ]]; then

    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libopencore-amrnb" "libopencore-amrnb" "${ARCHITECTURE_VARIANT}"

  elif [[ ${LIBRARY_NETTLE} == "${LIBRARY_INDEX}" ]]; then

    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libnettle" "libnettle" "${ARCHITECTURE_VARIANT}"
    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "libhogweed" "libhogweed" "${ARCHITECTURE_VARIANT}"

  else

    create_single_framework "${LIBRARY_INDEX}" "${LIBRARY_VERSION}" "$(get_static_archive_name "${LIBRARY_INDEX}")" "${LIBRARY_NAME}" "${ARCHITECTURE_VARIANT}"

  fi

  echo -e "DEBUG: ${LIBRARY_NAME} framework built for $(get_apple_architecture_variant "${ARCHITECTURE_VARIANT}") platform successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
}

#
# 1. architecture variant
#
create_ffmpeg_framework() {
  local ARCHITECTURE_VARIANT="$1"
  local LIBRARY_NAME="ffmpeg"
  local UNIVERSAL_LIBRARY_PATH="${BASEDIR}/prebuilt/$(get_universal_library_directory "${ARCHITECTURE_VARIANT}")"
  local FFMPEG_UNIVERSAL_LIBRARY_PATH="${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}"

  if [[ $(is_apple_architecture_variant_supported "${ARCHITECTURE_VARIANT}") -eq 0 ]]; then

    # THERE ARE NO ARCHITECTURES ENABLED FOR THIS LIBRARY TYPE
    return
  fi

  for FFMPEG_LIB in "${FFMPEG_LIBS[@]}"; do
    local FFMPEG_LIB_UPPERCASE=$(echo "${FFMPEG_LIB}" | tr '[a-z]' '[A-Z]')
    local CAPITAL_CASE_FFMPEG_LIB_NAME=$(to_capital_case "${FFMPEG_LIB}")

    # EXTRACT FFMPEG VERSION
    local FFMPEG_LIB_MAJOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR" "${FFMPEG_UNIVERSAL_LIBRARY_PATH}/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MAJOR//g;s/\ //g")
    local FFMPEG_LIB_MINOR=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR" "${FFMPEG_UNIVERSAL_LIBRARY_PATH}/include/${FFMPEG_LIB}/version.h" | sed -e "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MINOR//g;s/\ //g")
    local FFMPEG_LIB_MICRO=$(grep "#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO" "${FFMPEG_UNIVERSAL_LIBRARY_PATH}/include/${FFMPEG_LIB}/version.h" | sed "s/#define ${FFMPEG_LIB_UPPERCASE}_VERSION_MICRO//g;s/\ //g")
    local FFMPEG_LIB_VERSION="${FFMPEG_LIB_MAJOR}.${FFMPEG_LIB_MINOR}.${FFMPEG_LIB_MICRO}"

    # INITIALIZE FRAMEWORK DIRECTORY
    local FFMPEG_LIB_FRAMEWORK_PATH="${BASEDIR}/prebuilt/$(get_framework_directory "${ARCHITECTURE_VARIANT}")/${FFMPEG_LIB}.framework"
    initialize_folder "${FFMPEG_LIB_FRAMEWORK_PATH}"
    initialize_folder "${FFMPEG_LIB_FRAMEWORK_PATH}/Headers"

    # COPY HEADER FILES
    cp -r "${FFMPEG_UNIVERSAL_LIBRARY_PATH}/include/${FFMPEG_LIB}"/* "${FFMPEG_LIB_FRAMEWORK_PATH}"/Headers 1>>"${BASEDIR}"/build.log 2>&1

    # COPY LIBRARY FILE
    cp "${FFMPEG_UNIVERSAL_LIBRARY_PATH}/lib/${FFMPEG_LIB}.a" "${FFMPEG_LIB_FRAMEWORK_PATH}/${FFMPEG_LIB}" 1>>"${BASEDIR}"/build.log 2>&1

    # COPY FRAMEWORK LICENSES
    if [[ "${GPL_ENABLED}" == "yes" ]]; then
      cp "${BASEDIR}/LICENSE.GPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
    else
      cp "${BASEDIR}/LICENSE.LGPLv3" "${FFMPEG_LIB_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
    fi

    build_info_plist "${FFMPEG_LIB_FRAMEWORK_PATH}/Info.plist" "${FFMPEG_LIB}" "com.arthenica.ffmpegkit.${CAPITAL_CASE_FFMPEG_LIB_NAME}" "${FFMPEG_LIB_VERSION}" "${FFMPEG_LIB_VERSION}"

    echo -e "DEBUG: ${FFMPEG_LIB} framework built for $(get_apple_architecture_variant "${ARCHITECTURE_VARIANT}") platform successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
  done
}

#
# 1. architecture variant
#
create_ffmpeg_kit_framework() {
  local ARCHITECTURE_VARIANT="$1"
  local LIBRARY_NAME="ffmpeg-kit"
  local UNIVERSAL_LIBRARY_PATH="${BASEDIR}/prebuilt/$(get_universal_library_directory "${ARCHITECTURE_VARIANT}")"
  local FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH="${UNIVERSAL_LIBRARY_PATH}/${LIBRARY_NAME}"

  if [[ $(is_apple_architecture_variant_supported "${ARCHITECTURE_VARIANT}") -eq 0 ]]; then

    # THERE ARE NO ARCHITECTURES ENABLED FOR THIS LIBRARY TYPE
    return
  fi

  local FFMPEG_KIT_VERSION=$(get_ffmpeg_kit_version)

  # INITIALIZE FRAMEWORK DIRECTORY
  local FFMPEG_KIT_FRAMEWORK_PATH="${BASEDIR}/prebuilt/$(get_framework_directory "${ARCHITECTURE_VARIANT}")/ffmpegkit.framework"
  initialize_folder "${FFMPEG_KIT_FRAMEWORK_PATH}"
  initialize_folder "${FFMPEG_KIT_FRAMEWORK_PATH}/Headers"
  initialize_folder "${FFMPEG_KIT_FRAMEWORK_PATH}/Modules"

  # COPY HEADER FILES
  cp -r "${FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH}"/include/* "${FFMPEG_KIT_FRAMEWORK_PATH}"/Headers 1>>"${BASEDIR}"/build.log 2>&1

  # COPY LIBRARY FILE
  cp "${FFMPEG_KIT_UNIVERSAL_LIBRARY_PATH}/lib/libffmpegkit.a" "${FFMPEG_KIT_FRAMEWORK_PATH}"/ffmpegkit 1>>"${BASEDIR}"/build.log 2>&1

  # COPY FRAMEWORK LICENSES
  if [[ "${GPL_ENABLED}" == "yes" ]]; then
    cp "${BASEDIR}/LICENSE.GPLv3" "${FFMPEG_KIT_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
  else
    cp "${BASEDIR}/LICENSE.LGPLv3" "${FFMPEG_KIT_FRAMEWORK_PATH}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1
  fi

  build_info_plist "${FFMPEG_KIT_FRAMEWORK_PATH}/Info.plist" "ffmpegkit" "com.arthenica.ffmpegkit.FFmpegKit" "${FFMPEG_KIT_VERSION}" "${FFMPEG_KIT_VERSION}"
  build_modulemap "${FFMPEG_KIT_FRAMEWORK_PATH}/Modules/module.modulemap"

  echo -e "DEBUG: ffmpeg-kit framework built for $(get_apple_architecture_variant "${ARCHITECTURE_VARIANT}") platform successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
}

#
# 1. framework name
#
create_single_xcframework() {
  local FRAMEWORK_NAME="$1"
  local XCFRAMEWORK_PATH=${BASEDIR}/prebuilt/$(get_xcframework_directory)/${FRAMEWORK_NAME}.xcframework

  initialize_folder "${XCFRAMEWORK_PATH}"

  local BUILD_COMMAND="xcodebuild -create-xcframework "

  for ARCHITECTURE_VARIANT in "${ARCHITECTURE_VARIANT_ARRAY[@]}"; do
    if [[ $(is_apple_architecture_variant_supported "${ARCHITECTURE_VARIANT}") -eq 1 ]]; then
      local FRAMEWORK_PATH=${BASEDIR}/prebuilt/$(get_framework_directory "${ARCHITECTURE_VARIANT}")/${FRAMEWORK_NAME}.framework
      BUILD_COMMAND+=" -framework ${FRAMEWORK_PATH}"
    fi
  done

  BUILD_COMMAND+=" -output ${XCFRAMEWORK_PATH}"

  # EXECUTE CREATE FRAMEWORK COMMAND
  COMMAND_OUTPUT=$(${BUILD_COMMAND} 2>&1)
  RC=$?
  echo -e "DEBUG: ${COMMAND_OUTPUT}\n" 1>>"${BASEDIR}"/build.log 2>&1

  if [[ ${RC} -ne 0 ]]; then
    echo -e "INFO: Building ${FRAMEWORK_NAME} xcframework failed\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi

  # DO NOT ALLOW EMPTY FRAMEWORKS
  if [[ ${COMMAND_OUTPUT} == *"is empty in library"* ]]; then
    echo -e "INFO: Building ${FRAMEWORK_NAME} xcframework failed\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi
}

#
# 1. library index
#
create_xcframework() {
  local LIBRARY_INDEX="$1"
  local LIBRARY_NAME=$(get_library_name "${LIBRARY_INDEX}")

  if [[ ${LIBRARY_LIBTHEORA} == "${LIBRARY_INDEX}" ]]; then

    create_single_xcframework "libtheora"
    create_single_xcframework "libtheoraenc"
    create_single_xcframework "libtheoradec"

  elif [[ ${LIBRARY_LIBVORBIS} == "${LIBRARY_INDEX}" ]]; then

    create_single_xcframework "libvorbisfile"
    create_single_xcframework "libvorbisenc"
    create_single_xcframework "libvorbis"

  elif [[ ${LIBRARY_LIBWEBP} == "${LIBRARY_INDEX}" ]]; then

    create_single_xcframework "libwebpmux"
    create_single_xcframework "libwebpdemux"
    create_single_xcframework "libwebp"

  elif [[ ${LIBRARY_OPENCOREAMR} == "${LIBRARY_INDEX}" ]]; then

    create_single_xcframework "libopencore-amrnb"

  elif [[ ${LIBRARY_NETTLE} == "${LIBRARY_INDEX}" ]]; then

    create_single_xcframework "libnettle"
    create_single_xcframework "libhogweed"

  else

    create_single_xcframework "${LIBRARY_NAME}"

  fi

  echo -e "DEBUG: xcframework for ${LIBRARY_NAME} built successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
}

create_ffmpeg_xcframework() {
  for FFMPEG_LIB in "${FFMPEG_LIBS[@]}"; do

    # INITIALIZE FRAMEWORK DIRECTORY
    local FRAMEWORK_NAME="${FFMPEG_LIB}"
    local XCFRAMEWORK_PATH=${BASEDIR}/prebuilt/$(get_xcframework_directory)/${FRAMEWORK_NAME}.xcframework

    initialize_folder "${XCFRAMEWORK_PATH}"

    local BUILD_COMMAND="xcodebuild -create-xcframework "

    for ARCHITECTURE_VARIANT in "${ARCHITECTURE_VARIANT_ARRAY[@]}"; do
      if [[ $(is_apple_architecture_variant_supported "${ARCHITECTURE_VARIANT}") -eq 1 ]]; then
        local FRAMEWORK_PATH=${BASEDIR}/prebuilt/$(get_framework_directory "${ARCHITECTURE_VARIANT}")/${FRAMEWORK_NAME}.framework
        BUILD_COMMAND+=" -framework ${FRAMEWORK_PATH}"
      fi
    done

    BUILD_COMMAND+=" -output ${XCFRAMEWORK_PATH}"

    # EXECUTE CREATE FRAMEWORK COMMAND
    COMMAND_OUTPUT=$(${BUILD_COMMAND} 2>&1)
    RC=$?
    echo -e "DEBUG: ${COMMAND_OUTPUT}\n" 1>>"${BASEDIR}"/build.log 2>&1

    if [[ ${RC} -ne 0 ]]; then
      echo -e "INFO: Building ${FRAMEWORK_NAME} xcframework failed\n" 1>>"${BASEDIR}"/build.log 2>&1
      echo -e "failed\n\nSee build.log for details\n"
      exit 1
    fi

    # DO NOT ALLOW EMPTY FRAMEWORKS
    if [[ ${COMMAND_OUTPUT} == *"is empty in library"* ]]; then
      echo -e "INFO: Building ${FRAMEWORK_NAME} xcframework failed\n" 1>>"${BASEDIR}"/build.log 2>&1
      echo -e "failed\n\nSee build.log for details\n"
      exit 1
    fi

    echo -e "DEBUG: xcframework for ${FFMPEG_LIB} built successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
  done
}

create_ffmpeg_kit_xcframework() {
  local FRAMEWORK_NAME="ffmpegkit"

  # INITIALIZE FRAMEWORK DIRECTORY
  local XCFRAMEWORK_PATH=${BASEDIR}/prebuilt/$(get_xcframework_directory)/${FRAMEWORK_NAME}.xcframework

  initialize_folder "${XCFRAMEWORK_PATH}"
  local BUILD_COMMAND="xcodebuild -create-xcframework "

  for ARCHITECTURE_VARIANT in "${ARCHITECTURE_VARIANT_ARRAY[@]}"; do
    if [[ $(is_apple_architecture_variant_supported "${ARCHITECTURE_VARIANT}") -eq 1 ]]; then
      local FRAMEWORK_PATH=${BASEDIR}/prebuilt/$(get_framework_directory "${ARCHITECTURE_VARIANT}")/${FRAMEWORK_NAME}.framework
      BUILD_COMMAND+=" -framework ${FRAMEWORK_PATH}"
    fi
  done

  BUILD_COMMAND+=" -output ${XCFRAMEWORK_PATH}"

  # EXECUTE CREATE FRAMEWORK COMMAND
  COMMAND_OUTPUT=$(${BUILD_COMMAND} 2>&1)
  RC=$?
  echo -e "DEBUG: ${COMMAND_OUTPUT}\n" 1>>"${BASEDIR}"/build.log 2>&1

  if [[ ${RC} -ne 0 ]]; then
    echo -e "INFO: Building ${FRAMEWORK_NAME} xcframework failed\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi

  # DO NOT ALLOW EMPTY FRAMEWORKS
  if [[ ${COMMAND_OUTPUT} == *"is empty in library"* ]]; then
    echo -e "INFO: Building ${FRAMEWORK_NAME} xcframework failed\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "failed\n\nSee build.log for details\n"
    exit 1
  fi

  echo -e "DEBUG: xcframework for ffmpeg-kit built successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
}

#
# DEPENDS TARGET_ARCH_LIST VARIABLE
#
get_default_build_directory() {
  ARCH=${TARGET_ARCH_LIST[0]}
  get_build_directory
}

get_build_directory() {
  local LTS_POSTFIX=""
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    LTS_POSTFIX="-lts"
  fi

  case ${ARCH} in
  x86-64)
    echo "apple-${FFMPEG_KIT_BUILD_TYPE}-x86_64${LTS_POSTFIX}"
    ;;
  x86-64-mac-catalyst)
    echo "apple-${FFMPEG_KIT_BUILD_TYPE}-x86_64-mac-catalyst${LTS_POSTFIX}"
    ;;
  *)
    echo "apple-${FFMPEG_KIT_BUILD_TYPE}-${ARCH}${LTS_POSTFIX}"
    ;;
  esac
}

#
# 1. framework type
#
get_framework_directory() {
  local FRAMEWORK_TYPE="$1"
  local LTS_POSTFIX=""
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    LTS_POSTFIX="-lts"
  fi

  case $FRAMEWORK_TYPE in
  "${ARCH_VAR_IOS}")
    echo "bundle-apple-framework-ios${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_IPHONEOS}")
    echo "bundle-apple-framework-iphoneos${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_IPHONESIMULATOR}")
    echo "bundle-apple-framework-iphonesimulator${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_MAC_CATALYST}")
    echo "bundle-apple-framework-mac-catalyst${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_TVOS}")
    echo "bundle-apple-framework-tvos${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_APPLETVOS}")
    echo "bundle-apple-framework-appletvos${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_APPLETVSIMULATOR}")
    echo "bundle-apple-framework-appletvsimulator${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_MACOS}")
    echo "bundle-apple-framework-macos${LTS_POSTFIX}"
    ;;
  esac
}

get_xcframework_directory() {
  local LTS_POSTFIX=""
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    LTS_POSTFIX="-lts"
  fi

  echo "bundle-apple-xcframework-${FFMPEG_KIT_BUILD_TYPE}${LTS_POSTFIX}"
}

get_umbrella_xcframework_directory() {
  local LTS_POSTFIX=""
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    LTS_POSTFIX="-lts"
  fi

  echo "bundle-apple-xcframework${LTS_POSTFIX}"
}

#
# 1. architecture variant
#
get_universal_library_directory() {
  local ARCHITECTURE_VARIANT="$1"
  local LTS_POSTFIX=""
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    LTS_POSTFIX="-lts"
  fi

  case ${ARCHITECTURE_VARIANT} in
  "${ARCH_VAR_IOS}")
    echo "bundle-apple-universal-ios${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_IPHONEOS}")
    echo "bundle-apple-universal-iphoneos${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_IPHONESIMULATOR}")
    echo "bundle-apple-universal-iphonesimulator${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_MAC_CATALYST}")
    echo "bundle-apple-universal-mac-catalyst${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_TVOS}")
    echo "bundle-apple-universal-tvos${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_APPLETVOS}")
    echo "bundle-apple-universal-appletvos${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_APPLETVSIMULATOR}")
    echo "bundle-apple-universal-appletvsimulator${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_MACOS}")
    echo "bundle-apple-universal-macos${LTS_POSTFIX}"
    ;;
  esac
}

#
# 1. architecture variant
#
get_apple_architecture_variant() {
  local ARCHITECTURE_VARIANT="$1"
  local LTS_POSTFIX=""
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    LTS_POSTFIX="-lts"
  fi

  case ${ARCHITECTURE_VARIANT} in
  "${ARCH_VAR_IOS}")
    echo "ios${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_IPHONEOS}")
    echo "iphoneos${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_IPHONESIMULATOR}")
    echo "iphonesimulator${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_MAC_CATALYST}")
    echo "mac-catalyst${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_TVOS}")
    echo "tvos${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_APPLETVOS}")
    echo "appletvos${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_APPLETVSIMULATOR}")
    echo "appletvsimulator${LTS_POSTFIX}"
    ;;
  "${ARCH_VAR_MACOS}")
    echo "macos${LTS_POSTFIX}"
    ;;
  esac
}

#
# 1. architecture variant
#
get_apple_architectures_for_variant() {
  local ARCHITECTURE_VARIANT="$1"

  local ARCHITECTURES=""

  case ${ARCHITECTURE_VARIANT} in
  "${ARCH_VAR_IOS}")
    for index in ${ARCH_ARMV7} ${ARCH_ARMV7S} ${ARCH_ARM64} ${ARCH_ARM64E} ${ARCH_I386} ${ARCH_X86_64} ${ARCH_X86_64_MAC_CATALYST} ${ARCH_ARM64_MAC_CATALYST} ${ARCH_ARM64_SIMULATOR}; do
      ARCHITECTURES+=" $(get_full_arch_name "${index}") "
    done
    ;;
  "${ARCH_VAR_IPHONEOS}")
    for index in ${ARCH_ARMV7} ${ARCH_ARMV7S} ${ARCH_ARM64} ${ARCH_ARM64E}; do
      ARCHITECTURES+=" $(get_full_arch_name "${index}") "
    done
    ;;
  "${ARCH_VAR_IPHONESIMULATOR}")
    for index in ${ARCH_I386} ${ARCH_X86_64} ${ARCH_ARM64_SIMULATOR}; do
      ARCHITECTURES+=" $(get_full_arch_name "${index}") "
    done
    ;;
  "${ARCH_VAR_MAC_CATALYST}")
    for index in ${ARCH_X86_64_MAC_CATALYST} ${ARCH_ARM64_MAC_CATALYST}; do
      ARCHITECTURES+=" $(get_full_arch_name "${index}") "
    done
    ;;
  "${ARCH_VAR_TVOS}")
    for index in ${ARCH_ARM64} ${ARCH_X86_64} ${ARCH_ARM64_SIMULATOR}; do
      ARCHITECTURES+=" $(get_full_arch_name "${index}") "
    done
    ;;
  "${ARCH_VAR_APPLETVOS}")
    for index in ${ARCH_ARM64}; do
      ARCHITECTURES+=" $(get_full_arch_name "${index}") "
    done
    ;;
  "${ARCH_VAR_APPLETVSIMULATOR}")
    for index in ${ARCH_X86_64} ${ARCH_ARM64_SIMULATOR}; do
      ARCHITECTURES+=" $(get_full_arch_name "${index}") "
    done
    ;;
  "${ARCH_VAR_MACOS}")
    for index in ${ARCH_ARM64} ${ARCH_X86_64}; do
      ARCHITECTURES+=" $(get_full_arch_name "${index}") "
    done
    ;;
  esac

  echo "${ARCHITECTURES}"
}

get_cmake_osx_architectures() {
  case ${ARCH} in
  arm64 | arm64-*)
    echo "arm64"
    ;;
  arm64e)
    echo "arm64e"
    ;;
  x86-64*)
    echo "x86_64"
    ;;
  *)
    echo "${ARCH}"
    ;;
  esac
}

get_target_cpu() {
  case ${ARCH} in
  arm64*)
    echo "arm64"
    ;;
  x86-64*)
    echo "x86_64"
    ;;
  *)
    echo "${ARCH}"
    ;;
  esac
}

get_static_archive_name() {
  case $1 in
  5) echo "libmp3lame" ;;
  6) echo "libass" ;;
  10) echo "libvpx" ;;
  12) echo "libxml2" ;;
  21) echo "libvidstab" ;;
  23) echo "libilbc" ;;
  27) echo "libaom" ;;
  29) echo "libtwolame" ;;
  30) echo "libSDL2" ;;
  31) echo "libtesseract" ;;
  34) echo "libgif" ;;
  36) echo "libogg" ;;
  37) echo "libpng" ;;
  42) echo "libsndfile" ;;
  43) echo "liblept" ;;
  44) echo "libsamplerate" ;;
  *) echo lib"$(get_library_name "$1")" ;;
  esac
}

build_modulemap() {
  local FILE_PATH="$1"

  cat >"${FILE_PATH}" <<EOF
framework module ffmpegkit {

  header "AbstractSession.h"
  header "ArchDetect.h"
  header "AtomicLong.h"
  header "ExecuteCallback.h"
  header "FFmpegKit.h"
  header "FFmpegKitConfig.h"
  header "FFmpegSession.h"
  header "FFprobeKit.h"
  header "FFprobeSession.h"
  header "Level.h"
  header "Log.h"
  header "LogCallback.h"
  header "LogRedirectionStrategy.h"
  header "MediaInformation.h"
  header "MediaInformationJsonParser.h"
  header "MediaInformationSession.h"
  header "Packages.h"
  header "ReturnCode.h"
  header "Session.h"
  header "SessionState.h"
  header "Statistics.h"
  header "StatisticsCallback.h"
  header "StreamInformation.h"
  header "ffmpegkit_exception.h"

  export *
}
EOF
}

build_info_plist() {
  local FILE_PATH="$1"
  local FRAMEWORK_NAME="$2"
  local FRAMEWORK_ID="$3"
  local FRAMEWORK_SHORT_VERSION="$4"
  local FRAMEWORK_VERSION="$5"
  case ${FFMPEG_KIT_BUILD_TYPE} in
  ios)
    local MINIMUM_OS_VERSION="${IOS_MIN_VERSION}"
    local SUPPORTED_PLATFORMS="iPhoneOS"
    ;;
  tvos)
    local MINIMUM_OS_VERSION="${TVOS_MIN_VERSION}"
    local SUPPORTED_PLATFORMS="AppleTVOS"
    ;;
  macos)
    local MINIMUM_OS_VERSION="${MACOS_MIN_VERSION}"
    local SUPPORTED_PLATFORMS="MacOSX"
    ;;
  esac

  cat >${FILE_PATH} <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>${FRAMEWORK_NAME}</string>
	<key>CFBundleIdentifier</key>
	<string>${FRAMEWORK_ID}</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>${FRAMEWORK_NAME}</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>${FRAMEWORK_SHORT_VERSION}</string>
	<key>CFBundleVersion</key>
	<string>${FRAMEWORK_VERSION}</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>MinimumOSVersion</key>
	<string>${MINIMUM_OS_VERSION}</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>${SUPPORTED_PLATFORMS}</string>
	</array>
	<key>NSPrincipalClass</key>
	<string></string>
</dict>
</plist>
EOF
}

get_default_sdk_name() {
  case ${FFMPEG_KIT_BUILD_TYPE} in
  ios)
    echo "iphoneos"
    ;;
  tvos)
    echo "appletvos"
    ;;
  macos)
    echo "macosx"
    ;;
  esac
}

get_sdk_name() {
  case ${ARCH} in
  armv7 | armv7s | arm64e)
    echo "iphoneos"
    ;;
  arm64)
    case ${FFMPEG_KIT_BUILD_TYPE} in
    ios)
      echo "iphoneos"
      ;;
    tvos)
      echo "appletvos"
      ;;
    macos)
      echo "macosx"
      ;;
    esac
    ;;
  x86-64)
    case ${FFMPEG_KIT_BUILD_TYPE} in
    ios)
      echo "iphonesimulator"
      ;;
    tvos)
      echo "appletvsimulator"
      ;;
    macos)
      echo "macosx"
      ;;
    esac
    ;;
  i386)
    echo "iphonesimulator"
    ;;
  arm64-simulator)
    case ${FFMPEG_KIT_BUILD_TYPE} in
    ios)
      echo "iphonesimulator"
      ;;
    tvos)
      echo "appletvsimulator"
      ;;
    esac
    ;;
  *-mac-catalyst)
    echo "macosx"
    ;;
  esac
}

get_min_version_cflags() {
  case ${ARCH} in
  armv7 | armv7s | arm64e)
    echo "-miphoneos-version-min=$(get_min_sdk_version)"
    ;;
  arm64)
    case ${FFMPEG_KIT_BUILD_TYPE} in
    ios)
      echo "-miphoneos-version-min=$(get_min_sdk_version)"
      ;;
    tvos)
      echo "-mappletvos-version-min=$(get_min_sdk_version)"
      ;;
    macos)
      echo "-mmacosx-version-min=$(get_min_sdk_version)"
      ;;
    esac
    ;;
  x86-64)
    case ${FFMPEG_KIT_BUILD_TYPE} in
    ios)
      echo "-mios-simulator-version-min=$(get_min_sdk_version)"
      ;;
    tvos)
      echo "-mappletvsimulator-version-min=$(get_min_sdk_version)"
      ;;
    macos)
      echo "-mmacosx-version-min=$(get_min_sdk_version)"
      ;;
    esac
    ;;
  i386)
    echo "-mios-simulator-version-min=$(get_min_sdk_version)"
    ;;
  arm64-simulator)
    case ${FFMPEG_KIT_BUILD_TYPE} in
    ios)
      echo "-mios-simulator-version-min=$(get_min_sdk_version)"
      ;;
    tvos)
      echo "-mappletvsimulator-version-min=$(get_min_sdk_version)"
      ;;
    esac
    ;;
  *-mac-catalyst)
    echo "-miphoneos-version-min=$(get_min_sdk_version)"
    ;;
  esac
}

get_min_sdk_version() {
  case ${ARCH} in
  *-mac-catalyst)
    echo "13.0"
    ;;
  *)
    case ${FFMPEG_KIT_BUILD_TYPE} in
    ios)
      echo "${IOS_MIN_VERSION}"
      ;;
    tvos)
      echo "${TVOS_MIN_VERSION}"
      ;;
    macos)
      echo "${MACOS_MIN_VERSION}"
      ;;
    esac
    ;;
  esac
}

get_sdk_path() {
  echo "$(xcrun --sdk "$(get_sdk_name)" --show-sdk-path 2>>"${BASEDIR}"/build.log)"
}

create_mason_cross_file() {
  cat >"$1" <<EOF
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
strip = '$STRIP'
pkgconfig = 'pkg-config'

[properties]
sys_root = '$SDK_PATH'
has_function_printf = true

[host_machine]
system = '$(get_meson_target_host_family)'
cpu_family = '$(get_meson_target_cpu_family)'
cpu = '$(get_target_cpu)'
endian = 'little'

[built-in options]
default_library = 'static'
prefix = '${LIB_INSTALL_PREFIX}'
EOF
}

create_fontconfig_package_config() {
  local FONTCONFIG_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/fontconfig.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/fontconfig
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
sysconfdir=\${prefix}/etc
localstatedir=\${prefix}/var
PACKAGE=fontconfig
confdir=\${sysconfdir}/fonts
cachedir=\${localstatedir}/cache/\${PACKAGE}

Name: Fontconfig
Description: Font configuration and customization library
Version: ${FONTCONFIG_VERSION}
Requires:  freetype2 >= 21.0.15, uuid, expat >= 2.2.0, libiconv
Requires.private:
Libs: -L\${libdir} -lfontconfig
Libs.private:
Cflags: -I\${includedir}
EOF
}

create_freetype_package_config() {
  local FREETYPE_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/freetype2.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/freetype
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: FreeType 2
URL: https://freetype.org
Description: A free, high-quality, and portable font engine.
Version: ${FREETYPE_VERSION}
Requires: libpng
Requires.private:
Libs: -L\${libdir} -lfreetype
Libs.private:
Cflags: -I\${includedir}/freetype2
EOF
}

create_giflib_package_config() {
  local GIFLIB_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/giflib.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/giflib
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: giflib
Description: gif library
Version: ${GIFLIB_VERSION}

Requires:
Libs: -L\${libdir} -lgif
Cflags: -I\${includedir}
EOF
}

create_gmp_package_config() {
  local GMP_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/gmp.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/gmp
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: gmp
Description: gnu mp library
Version: ${GMP_VERSION}

Requires:
Libs: -L\${libdir} -lgmp
Cflags: -I\${includedir}
EOF
}

create_gnutls_package_config() {
  local GNUTLS_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/gnutls.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/gnutls
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: gnutls
Description: GNU TLS Implementation

Version: ${GNUTLS_VERSION}
Requires: nettle, hogweed
Cflags: -I\${includedir}
Libs: -L\${libdir} -lgnutls
Libs.private: -lgmp
EOF
}

create_libmp3lame_package_config() {
  local LAME_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/libmp3lame.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/lame
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libmp3lame
Description: lame mp3 encoder library
Version: ${LAME_VERSION}

Requires:
Libs: -L\${libdir} -lmp3lame
Cflags: -I\${includedir}
EOF
}

create_libiconv_system_package_config() {
  local LIB_ICONV_VERSION=$(grep '_LIBICONV_VERSION' "${SDK_PATH}"/usr/include/iconv.h | grep -Eo '0x.*' | grep -Eo '.*    ')

  cat >"${INSTALL_PKG_CONFIG_DIR}/libiconv.pc" <<EOF
prefix=${SDK_PATH}/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libiconv
Description: Character set conversion library
Version: ${LIB_ICONV_VERSION}

Requires:
Libs: -L\${libdir} -liconv -lcharset
Cflags: -I\${includedir}
EOF
}

create_libpng_package_config() {
  local LIBPNG_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/libpng.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/libpng
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: libpng
Description: Loads and saves PNG files
Version: ${LIBPNG_VERSION}
Requires:
Cflags: -I\${includedir}
Libs: -L\${libdir} -lpng
EOF
}

create_libvorbis_package_config() {
  local LIBVORBIS_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/vorbis.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/libvorbis
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: vorbis
Description: vorbis is the primary Ogg Vorbis library
Version: ${LIBVORBIS_VERSION}

Requires: ogg
Libs: -L\${libdir} -lvorbis -lm
Cflags: -I\${includedir}
EOF

  cat >"${INSTALL_PKG_CONFIG_DIR}/vorbisenc.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/libvorbis
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: vorbisenc
Description: vorbisenc is a library that provides a convenient API for setting up an encoding environment using libvorbis
Version: ${LIBVORBIS_VERSION}

Requires: vorbis
Conflicts:
Libs: -L\${libdir} -lvorbisenc
Cflags: -I\${includedir}
EOF

  cat >"${INSTALL_PKG_CONFIG_DIR}/vorbisfile.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/libvorbis
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: vorbisfile
Description: vorbisfile is a library that provides a convenient high-level API for decoding and basic manipulation of all Vorbis I audio streams
Version: ${LIBVORBIS_VERSION}

Requires: vorbis
Conflicts:
Libs: -L\${libdir} -lvorbisfile
Cflags: -I\${includedir}
EOF
}

create_libxml2_package_config() {
  local LIBXML2_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/libxml-2.0.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/libxml2
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
modules=1

Name: libXML
Version: ${LIBXML2_VERSION}
Description: libXML library version2.
Requires: libiconv
Libs: -L\${libdir} -lxml2
Libs.private:   -lz -lm
Cflags: -I\${includedir} -I\${includedir}/libxml2
EOF
}

create_snappy_package_config() {
  local SNAPPY_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/snappy.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/snappy
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: snappy
Description: a fast compressor/decompressor
Version: ${SNAPPY_VERSION}

Requires:
Libs: -L\${libdir} -lz -lc++
Cflags: -I\${includedir}
EOF
}

create_soxr_package_config() {
  local SOXR_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/soxr.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/soxr
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: soxr
Description: High quality, one-dimensional sample-rate conversion library
Version: ${SOXR_VERSION}

Requires:
Libs: -L\${libdir} -lsoxr
Cflags: -I\${includedir}
EOF
}

create_tesseract_package_config() {
  local TESSERACT_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/tesseract.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/tesseract
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin
datarootdir=\${prefix}/share
datadir=\${datarootdir}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: tesseract
Description: An OCR Engine that was developed at HP Labs between 1985 and 1995... and now at Google.
URL: https://github.com/tesseract-ocr/tesseract
Version: ${TESSERACT_VERSION}

Requires: lept
Libs: -L\${libdir} -ltesseract
Cflags: -I\${includedir}
EOF
}

create_libuuid_system_package_config() {
  local UUID_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/uuid.pc" <<EOF
prefix=${SDK_PATH}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/usr/lib
includedir=\${prefix}/include

Name: uuid
Description: Universally unique id library
Version: ${UUID_VERSION}
Requires:
Cflags: -I\${includedir}
Libs: -L\${libdir}
EOF
}

create_xvidcore_package_config() {
  local XVIDCORE_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/xvidcore.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_build_directory)/xvidcore
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: xvidcore
Description: the main MPEG-4 de-/encoding library
Version: ${XVIDCORE_VERSION}

Requires:
Libs: -L\${libdir}
Cflags: -I\${includedir}
EOF
}

create_zlib_system_package_config() {
  ZLIB_VERSION=$(grep '#define ZLIB_VERSION' "${SDK_PATH}"/usr/include/zlib.h | grep -Eo '\".*\"' | sed -e 's/\"//g')

  cat >"${INSTALL_PKG_CONFIG_DIR}/zlib.pc" <<EOF
prefix=${SDK_PATH}/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: zlib
Description: zlib compression library
Version: ${ZLIB_VERSION}

Requires:
Libs: -L\${libdir} -lz
Cflags: -I\${includedir}
EOF
}

create_bzip2_system_package_config() {
  BZIP2_VERSION=$(grep -Eo 'version.*of' "${SDK_PATH}"/usr/include/bzlib.h | sed -e 's/of//;s/version//g;s/\ //g')

  cat >"${INSTALL_PKG_CONFIG_DIR}/bzip2.pc" <<EOF
prefix=${SDK_PATH}/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: bzip2
Description: library for lossless, block-sorting data compression
Version: ${BZIP2_VERSION}

Requires:
Libs: -L\${libdir} -lbz2
Cflags: -I\${includedir}
EOF
}
