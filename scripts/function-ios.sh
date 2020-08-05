#!/bin/bash

source "${BASEDIR}/scripts/function.sh"

enable_default_ios_architectures() {
  ENABLED_ARCHITECTURES[ARCH_ARMV7]=1
  ENABLED_ARCHITECTURES[ARCH_ARMV7S]=1
  ENABLED_ARCHITECTURES[ARCH_ARM64]=1
  ENABLED_ARCHITECTURES[ARCH_ARM64E]=1
  ENABLED_ARCHITECTURES[ARCH_I386]=1
  ENABLED_ARCHITECTURES[ARCH_X86_64]=1
  ENABLED_ARCHITECTURES[ARCH_X86_64_MAC_CATALYST]=1
}

get_ffmpeg_kit_version() {
  local FFMPEG_KIT_VERSION=$(grep 'const FFMPEG_KIT_VERSION' "${BASEDIR}"/objc/src/FFmpegKit.m | grep -Eo '\".*\"' | sed -e 's/\"//g')

  if [[ -z ${FFMPEG_KIT_LTS_BUILD} ]]; then
    echo "${FFMPEG_KIT_VERSION}"
  else
    echo "${FFMPEG_KIT_VERSION}.LTS"
  fi
}

display_help() {
  COMMAND=$(echo "$0" | sed -e 's/\.\///g')

  echo -e "\n'$COMMAND' builds FFmpegKit for iOS platform. By default seven architectures (armv7, armv7s, arm64, arm64e, \
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
  echo -e "  --enable-ios-audiotoolbox\tbuild with built-in Apple AudioToolbox support [no]"
  echo -e "  --enable-ios-avfoundation\tbuild with built-in Apple AVFoundation support [no]"
  echo -e "  --enable-ios-bzip2\t\tbuild with built-in bzip2 support [no]"
  echo -e "  --enable-ios-videotoolbox\tbuild with built-in Apple VideoToolbox support [no]"
  echo -e "  --enable-ios-zlib\t\tbuild with built-in zlib [no]"
  echo -e "  --enable-ios-libiconv\t\tbuild with built-in libiconv [no]"

  display_help_common_libraries
  display_help_gpl_libraries
  display_help_advanced_options
}

enable_main_build() {
  export IOS_MIN_VERSION=12.1
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

      # arm64e NOT INCLUDED IN .xcframework BUNDLES
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
  for output_path in "${output_path_array[@]}"; do
    $(cp $(get_external_library_license_path "$1") "${output_path}/LICENSE" 1>>"${BASEDIR}"/build.log 2>&1)
    if [ $? -ne 0 ]; then
      echo 1
      return
    fi
  done
  echo 0
}

get_external_library_version() {
  local library_version=$(grep Version "${BASEDIR}"/prebuilt/ios-"${TARGET_ARCH_LIST[0]}"/pkgconfig/"$1".pc 2>>"${BASEDIR}"/build.log | sed 's/Version://g;s/\ //g')

  echo "${library_version}"
}

#
# 1. architecture index
# 2. detected sdk version
#
disable_architecture_not_supported_on_detected_sdk_version() {
  local ARCH_NAME=$(get_arch_name $1)

  case ${ARCH_NAME} in
  armv7 | armv7s | i386)

    # SUPPORTED UNTIL IOS SDK 10
    if [[ $2 == 11* ]] || [[ $2 == 12* ]] || [[ $2 == 13* ]] || [[ $2 == 14* ]]; then
      local SUPPORTED=0
    else
      local SUPPORTED=1
    fi
    ;;
  arm64e)

    # INTRODUCED IN IOS SDK 10
    if [[ $2 == 10* ]] || [[ $2 == 11* ]] || [[ $2 == 12* ]] || [[ $2 == 13* ]] || [[ $2 == 14* ]]; then
      local SUPPORTED=1
    else
      local SUPPORTED=0
    fi
    ;;
  x86-64-mac-catalyst)

    # INTRODUCED IN IOS SDK 13
    if [[ $2 == 13* ]] || [[ $2 == 14* ]]; then
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

get_target_host() {
  case ${ARCH} in
  x86-64-mac-catalyst)
    echo "x86_64-apple-ios13.0-macabi"
    ;;
  *)
    echo "$(get_target_arch)-ios-darwin"
    ;;
  esac
}

get_target_build_directory() {
  case ${ARCH} in
  x86-64)
    echo "ios-x86_64"
    ;;
  x86-64-mac-catalyst)
    echo "ios-x86_64-mac-catalyst"
    ;;
  *)
    echo "ios-${ARCH}"
    ;;
  esac
}

get_target_arch() {
  case ${ARCH} in
  arm64 | arm64e)
    echo "aarch64"
    ;;
  x86-64 | x86-64-mac-catalyst)
    echo "x86_64"
    ;;
  *)
    echo "${ARCH}"
    ;;
  esac
}

get_target_sdk() {
  echo "$(get_target_arch)-apple-ios${IOS_MIN_VERSION}"
}

get_sdk_name() {
  case ${ARCH} in
  armv7 | armv7s | arm64 | arm64e)
    echo "iphoneos"
    ;;
  i386 | x86-64)
    echo "iphonesimulator"
    ;;
  x86-64-mac-catalyst)
    echo "macosx"
    ;;
  esac
}

get_sdk_path() {
  echo "$(xcrun --sdk "$(get_sdk_name)" --show-sdk-path)"
}

get_min_version_cflags() {
  case ${ARCH} in
  armv7 | armv7s | arm64 | arm64e)
    echo "-miphoneos-version-min=${IOS_MIN_VERSION}"
    ;;
  i386 | x86-64)
    echo "-mios-simulator-version-min=${IOS_MIN_VERSION}"
    ;;
  x86-64-mac-catalyst)
    echo "-miphoneos-version-min=13.0"
    ;;
  esac
}

get_common_includes() {
  echo "-I${SDK_PATH}/usr/include"
}

get_common_cflags() {
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    local LTS_BUILD_FLAG="-DFFMPEG_KIT_LTS "
  fi

  local BUILD_DATE="-DFFMPEG_KIT_BUILD_DATE=$(date +%Y%m%d 2>>"${BASEDIR}"/build.log)"

  case ${ARCH} in
  i386 | x86-64)
    echo "-fstrict-aliasing -DIOS ${LTS_BUILD_FLAG}${BUILD_DATE} -isysroot ${SDK_PATH}"
    ;;
  x86-64-mac-catalyst)
    echo "-fstrict-aliasing -fembed-bitcode ${LTS_BUILD_FLAG}${BUILD_DATE} -isysroot ${SDK_PATH}"
    ;;
  *)
    echo "-fstrict-aliasing -fembed-bitcode -DIOS ${LTS_BUILD_FLAG}${BUILD_DATE} -isysroot ${SDK_PATH}"
    ;;
  esac
}

get_arch_specific_cflags() {
  case ${ARCH} in
  armv7)
    echo "-arch armv7 -target $(get_target_host) -march=armv7 -mcpu=cortex-a8 -mfpu=neon -mfloat-abi=softfp -DFFMPEG_KIT_ARMV7"
    ;;
  armv7s)
    echo "-arch armv7s -target $(get_target_host) -march=armv7s -mcpu=generic -mfpu=neon -mfloat-abi=softfp -DFFMPEG_KIT_ARMV7S"
    ;;
  arm64)
    echo "-arch arm64 -target $(get_target_host) -march=armv8-a+crc+crypto -mcpu=generic -DFFMPEG_KIT_ARM64"
    ;;
  arm64e)
    echo "-arch arm64e -target $(get_target_host) -march=armv8.3-a+crc+crypto -mcpu=generic -DFFMPEG_KIT_ARM64E"
    ;;
  i386)
    echo "-arch i386 -target $(get_target_host) -march=i386 -mtune=intel -mssse3 -mfpmath=sse -m32 -DFFMPEG_KIT_I386"
    ;;
  x86-64)
    echo "-arch x86_64 -target $(get_target_host) -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -DFFMPEG_KIT_X86_64"
    ;;
  x86-64-mac-catalyst)
    echo "-arch x86_64 -target $(get_target_host) -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -DFFMPEG_KIT_X86_64_MAC_CATALYST -isysroot ${SDK_PATH} -isystem ${SDK_PATH}/System/iOSSupport/usr/include -iframework ${SDK_PATH}/System/iOSSupport/System/Library/Frameworks"
    ;;
  esac
}

get_size_optimization_cflags() {

  local ARCH_OPTIMIZATION=""
  case ${ARCH} in
  armv7 | armv7s | arm64 | arm64e | x86-64-mac-catalyst)
    ARCH_OPTIMIZATION="-Oz -Wno-ignored-optimization-argument"
    ;;
  i386 | x86-64)
    ARCH_OPTIMIZATION="-O2 -Wno-ignored-optimization-argument"
    ;;
  esac

  echo "${ARCH_OPTIMIZATION}"
}

get_size_optimization_asm_cflags() {

  local ARCH_OPTIMIZATION=""
  case $1 in
  jpeg | ffmpeg)
    case ${ARCH} in
    armv7 | armv7s | arm64 | arm64e | x86-64-mac-catalyst)
      ARCH_OPTIMIZATION="-Oz"
      ;;
    i386 | x86-64)
      ARCH_OPTIMIZATION="-O2"
      ;;
    esac
    ;;
  *)
    ARCH_OPTIMIZATION=$(get_size_optimization_cflags "$1")
    ;;
  esac

  echo "${ARCH_OPTIMIZATION}"
}

get_app_specific_cflags() {

  local APP_FLAGS=""
  case $1 in
  fontconfig)
    case ${ARCH} in
    armv7 | armv7s | arm64 | arm64e)
      APP_FLAGS="-std=c99 -Wno-unused-function -D__IPHONE_OS_MIN_REQUIRED -D__IPHONE_VERSION_MIN_REQUIRED=30000"
      ;;
    *)
      APP_FLAGS="-std=c99 -Wno-unused-function"
      ;;
    esac
    ;;
  ffmpeg)
    APP_FLAGS="-Wno-unused-function -Wno-deprecated-declarations"
    ;;
  ffmpeg-kit)
    APP_FLAGS="-std=c99 -Wno-unused-function -Wall -Wno-deprecated-declarations -Wno-pointer-sign -Wno-switch -Wno-unused-result -Wno-unused-variable -DPIC -fobjc-arc"
    ;;
  jpeg)
    APP_FLAGS="-Wno-nullability-completeness"
    ;;
  kvazaar)
    APP_FLAGS="-std=gnu99 -Wno-unused-function"
    ;;
  leptonica)
    APP_FLAGS="-std=c99 -Wno-unused-function -DOS_IOS"
    ;;
  libwebp | xvidcore)
    APP_FLAGS="-fno-common -DPIC"
    ;;
  sdl2)
    APP_FLAGS="-DPIC -Wno-unused-function -D__IPHONEOS__"
    ;;
  shine)
    APP_FLAGS="-Wno-unused-function"
    ;;
  soxr | snappy)
    APP_FLAGS="-std=gnu99 -Wno-unused-function -DPIC"
    ;;
  openh264 | x265)
    APP_FLAGS="-Wno-unused-function"
    ;;
  *)
    APP_FLAGS="-std=c99 -Wno-unused-function"
    ;;
  esac

  echo "${APP_FLAGS}"
}

get_cflags() {
  local ARCH_FLAGS=$(get_arch_specific_cflags)
  local APP_FLAGS=$(get_app_specific_cflags "$1")
  local COMMON_FLAGS=$(get_common_cflags)
  if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
    local OPTIMIZATION_FLAGS=$(get_size_optimization_cflags "$1")
  else
    local OPTIMIZATION_FLAGS="${FFMPEG_KIT_DEBUG}"
  fi
  local MIN_VERSION_FLAGS=$(get_min_version_cflags "$1")
  local COMMON_INCLUDES=$(get_common_includes)

  echo "${ARCH_FLAGS} ${APP_FLAGS} ${COMMON_FLAGS} ${OPTIMIZATION_FLAGS} ${MIN_VERSION_FLAGS} ${COMMON_INCLUDES}"
}

get_asmflags() {
  local ARCH_FLAGS=$(get_arch_specific_cflags)
  local APP_FLAGS=$(get_app_specific_cflags "$1")
  local COMMON_FLAGS=$(get_common_cflags)
  if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
    local OPTIMIZATION_FLAGS=$(get_size_optimization_asm_cflags "$1")
  else
    local OPTIMIZATION_FLAGS="${FFMPEG_KIT_DEBUG}"
  fi
  local MIN_VERSION_FLAGS=$(get_min_version_cflags "$1")
  local COMMON_INCLUDES=$(get_common_includes)

  echo "${ARCH_FLAGS} ${APP_FLAGS} ${COMMON_FLAGS} ${OPTIMIZATION_FLAGS} ${MIN_VERSION_FLAGS} ${COMMON_INCLUDES}"
}

get_cxxflags() {
  local COMMON_CFLAGS="$(get_common_cflags "$1") $(get_common_includes "$1") $(get_arch_specific_cflags) $(get_min_version_cflags "$1")"
  if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
    local OPTIMIZATION_FLAGS="-Oz"
  else
    local OPTIMIZATION_FLAGS="${FFMPEG_KIT_DEBUG}"
  fi

  local BITCODE_FLAGS=""
  case ${ARCH} in
  armv7 | armv7s | arm64 | arm64e | x86-64-mac-catalyst)
    local BITCODE_FLAGS="-fembed-bitcode"
    ;;
  esac

  case $1 in
  x265)
    echo "-std=c++11 -fno-exceptions ${BITCODE_FLAGS} ${COMMON_CFLAGS}"
    ;;
  gnutls)
    echo "-std=c++11 -fno-rtti ${BITCODE_FLAGS} ${COMMON_CFLAGS} ${OPTIMIZATION_FLAGS}"
    ;;
  libwebp | xvidcore)
    echo "-std=c++11 -fno-exceptions -fno-rtti ${BITCODE_FLAGS} -fno-common -DPIC ${COMMON_CFLAGS} ${OPTIMIZATION_FLAGS}"
    ;;
  libaom)
    echo "-std=c++11 -fno-exceptions ${BITCODE_FLAGS} ${COMMON_CFLAGS} ${OPTIMIZATION_FLAGS}"
    ;;
  opencore-amr)
    echo "-fno-rtti ${BITCODE_FLAGS} ${COMMON_CFLAGS} ${OPTIMIZATION_FLAGS}"
    ;;
  rubberband)
    echo "-fno-rtti ${BITCODE_FLAGS} ${COMMON_CFLAGS} ${OPTIMIZATION_FLAGS}"
    ;;
  *)
    echo "-std=c++11 -fno-exceptions -fno-rtti ${BITCODE_FLAGS} ${COMMON_CFLAGS} ${OPTIMIZATION_FLAGS}"
    ;;
  esac
}

get_common_linked_libraries() {
  echo "-L${SDK_PATH}/usr/lib -lc++"
}

get_common_ldflags() {
  echo "-isysroot ${SDK_PATH}"
}

get_size_optimization_ldflags() {
  case ${ARCH} in
  armv7 | armv7s | arm64 | arm64e | x86-64-mac-catalyst)
    case $1 in
    ffmpeg | ffmpeg-kit)
      echo "-Oz -dead_strip"
      ;;
    *)
      echo "-Oz -dead_strip"
      ;;
    esac
    ;;
  *)
    case $1 in
    ffmpeg)
      echo "-O2"
      ;;
    *)
      echo "-O2"
      ;;
    esac
    ;;
  esac
}

get_arch_specific_ldflags() {
  case ${ARCH} in
  armv7)
    echo "-arch armv7 -march=armv7 -mfpu=neon -mfloat-abi=softfp -fembed-bitcode -target $(get_target_host)"
    ;;
  armv7s)
    echo "-arch armv7s -march=armv7s -mfpu=neon -mfloat-abi=softfp -fembed-bitcode -target $(get_target_host)"
    ;;
  arm64)
    echo "-arch arm64 -march=armv8-a+crc+crypto -fembed-bitcode -target $(get_target_host)"
    ;;
  arm64e)
    echo "-arch arm64e -march=armv8.3-a+crc+crypto -fembed-bitcode -target $(get_target_host)"
    ;;
  i386)
    echo "-arch i386 -march=i386 -target $(get_target_host)"
    ;;
  x86-64)
    echo "-arch x86_64 -march=x86-64 -target $(get_target_host)"
    ;;
  x86-64-mac-catalyst)
    echo "-arch x86_64 -march=x86-64 -target $(get_target_host) -isysroot ${SDK_PATH} -L${SDK_PATH}/System/iOSSupport/usr/lib -iframework ${SDK_PATH}/System/iOSSupport/System/Library/Frameworks"
    ;;
  esac
}

get_ldflags() {
  local ARCH_FLAGS=$(get_arch_specific_ldflags)
  local LINKED_LIBRARIES=$(get_common_linked_libraries)
  if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
    local OPTIMIZATION_FLAGS="$(get_size_optimization_ldflags $1)"
  else
    local OPTIMIZATION_FLAGS="${FFMPEG_KIT_DEBUG}"
  fi
  local COMMON_FLAGS=$(get_common_ldflags)

  case $1 in
  ffmpeg-kit)
    case ${ARCH} in
    armv7 | armv7s | arm64 | arm64e | x86-64-mac-catalyst)
      echo "${ARCH_FLAGS} ${LINKED_LIBRARIES} ${COMMON_FLAGS} -fembed-bitcode -Wc,-fembed-bitcode ${OPTIMIZATION_FLAGS}"
      ;;
    *)
      echo "${ARCH_FLAGS} ${LINKED_LIBRARIES} ${COMMON_FLAGS} ${OPTIMIZATION_FLAGS}"
      ;;
    esac
    ;;
  *)
    echo "${ARCH_FLAGS} ${LINKED_LIBRARIES} ${COMMON_FLAGS} ${OPTIMIZATION_FLAGS}"
    ;;
  esac
}

create_fontconfig_package_config() {
  local FONTCONFIG_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/fontconfig.pc" <<EOF
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/fontconfig
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/freetype
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/giflib
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/gmp
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/gnutls
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/lame
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
  local LIB_ICONV_VERSION=$(grep '_LIBICONV_VERSION' ${SDK_PATH}/usr/include/iconv.h | grep -Eo '0x.*' | grep -Eo '.*    ')

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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/libpng
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/libvorbis
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/libvorbis
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/libvorbis
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/libxml2
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/snappy
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/soxr
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/tesseract
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
prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/xvidcore
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

set_toolchain_paths() {
  if [ ! -f "${FFMPEG_KIT_TMPDIR}/gas-preprocessor.pl" ]; then
    DOWNLOAD_RESULT=$(download "https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl" "gas-preprocessor.pl" "exit")
    if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
      exit 1
    fi
    (chmod +x "${FFMPEG_KIT_TMPDIR}"/gas-preprocessor.pl 1>>"${BASEDIR}"/build.log 2>&1) || exit 1

    # patch gas-preprocessor.pl against the following warning
    # Unescaped left brace in regex is deprecated here (and will be fatal in Perl 5.32), passed through in regex; marked by <-- HERE in m/(?:ld|st)\d\s+({ <-- HERE \s*v(\d+)\.(\d[bhsdBHSD])\s*-\s*v(\d+)\.(\d[bhsdBHSD])\s*})/ at /Users/taner/Projects/ffmpeg-kit/.tmp/gas-preprocessor.pl line 1065.
    sed -i .tmp "s/s\+({/s\+(\\\\{/g;s/s\*})/s\*\\\\})/g" "${FFMPEG_KIT_TMPDIR}"/gas-preprocessor.pl
  fi

  LOCAL_GAS_PREPROCESSOR="${FFMPEG_KIT_TMPDIR}/gas-preprocessor.pl"
  if [ "$1" == "x264" ]; then
    LOCAL_GAS_PREPROCESSOR="${BASEDIR}/src/x264/tools/gas-preprocessor.pl"
  fi

  export AR="$(xcrun --sdk "$(get_sdk_name)" -f ar)"
  export CC="clang"
  export OBJC="$(xcrun --sdk "$(get_sdk_name)" -f clang)"
  export CXX="clang++"

  LOCAL_ASMFLAGS="$(get_asmflags $1)"
  case ${ARCH} in
  armv7 | armv7s)
    if [ "$1" == "x265" ]; then
      export AS="${LOCAL_GAS_PREPROCESSOR}"
      export AS_ARGUMENTS="-arch arm"
      export ASM_FLAGS="${LOCAL_ASMFLAGS}"
    else
      export AS="${LOCAL_GAS_PREPROCESSOR} -arch arm -- ${CC} ${LOCAL_ASMFLAGS}"
    fi
    ;;
  arm64 | arm64e)
    if [ "$1" == "x265" ]; then
      export AS="${LOCAL_GAS_PREPROCESSOR}"
      export AS_ARGUMENTS="-arch aarch64"
      export ASM_FLAGS="${LOCAL_ASMFLAGS}"
    else
      export AS="${LOCAL_GAS_PREPROCESSOR} -arch aarch64 -- ${CC} ${LOCAL_ASMFLAGS}"
    fi
    ;;
  *)
    export AS="${CC} ${LOCAL_ASMFLAGS}"
    ;;
  esac

  export LD="$(xcrun --sdk "$(get_sdk_name)" -f ld)"
  export RANLIB="$(xcrun --sdk "$(get_sdk_name)" -f ranlib)"
  export STRIP="$(xcrun --sdk "$(get_sdk_name)" -f strip)"

  export INSTALL_PKG_CONFIG_DIR="${BASEDIR}/prebuilt/$(get_target_build_directory)/pkgconfig"
  export ZLIB_PACKAGE_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}/zlib.pc"
  export BZIP2_PACKAGE_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}/bzip2.pc"
  export LIB_ICONV_PACKAGE_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}/libiconv.pc"
  export LIB_UUID_PACKAGE_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}/uuid.pc"

  if [ ! -d "${INSTALL_PKG_CONFIG_DIR}" ]; then
    mkdir -p "${INSTALL_PKG_CONFIG_DIR}"
  fi

  if [ ! -f "${ZLIB_PACKAGE_CONFIG_PATH}" ]; then
    create_zlib_system_package_config
  fi

  if [ ! -f "${LIB_ICONV_PACKAGE_CONFIG_PATH}" ]; then
    create_libiconv_system_package_config
  fi

  if [ ! -f "${BZIP2_PACKAGE_CONFIG_PATH}" ]; then
    create_bzip2_system_package_config
  fi

  if [ ! -f "${LIB_UUID_PACKAGE_CONFIG_PATH}" ]; then
    create_libuuid_system_package_config
  fi

  prepare_inline_sed
}
