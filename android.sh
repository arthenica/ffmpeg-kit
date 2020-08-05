#!/bin/bash

export FFMPEG_KIT_BUILD_TYPE="android"
export BASEDIR="$(pwd)"

source "${BASEDIR}"/scripts/common-${FFMPEG_KIT_BUILD_TYPE}.sh

# ENABLE ARCH
ENABLED_ARCHITECTURES=(1 1 0 0 1 0 0 0 1 1 0)

# ENABLE LIBRARIES
ENABLED_LIBRARIES=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)

# USING API LEVEL 24 / Android 7.0 (NOUGAT)
export API=24

RECONF_LIBRARIES=()
REBUILD_LIBRARIES=()
REDOWNLOAD_LIBRARIES=()

get_ffmpeg_kit_version() {
  local FFMPEG_KIT_VERSION=$(grep '#define FFMPEG_KIT_VERSION' "${BASEDIR}"/android/app/src/main/cpp/ffmpegkit.h | grep -Eo '\".*\"' | sed -e 's/\"//g')

  echo "${FFMPEG_KIT_VERSION}"
}

display_help() {
  local COMMAND=$(echo "$0" | sed -e 's/\.\///g')

  echo -e "\n'$COMMAND' builds FFmpegKit for Android platform. By default five Android ABIs (armeabi-v7a, \
armeabi-v7a-neon, arm64-v8a, x86 and x86_64) are built without any external libraries enabled. Options can be used to \
disable ABIs and/or enable external libraries. Please note that GPL libraries (external libraries with GPL license) \
need --enable-gpl flag to be set explicitly. When compilation ends an Android Archive (AAR) file is created under the \
prebuilt folder.\n"
  echo -e "Usage: ./$COMMAND [OPTION]... [VAR=VALUE]...\n"
  echo -e "Specify environment variables as VARIABLE=VALUE to override default build options.\n"

  display_help_options "      --api-level=api\t\tset Android api level [${API}]"
  display_help_licensing

  echo -e "Architectures:"
  echo -e "  --disable-arm-v7a\t\tdo not build arm-v7a architecture [yes]"
  echo -e "  --disable-arm-v7a-neon\tdo not build arm-v7a-neon architecture [yes]"
  echo -e "  --disable-arm64-v8a\t\tdo not build arm64-v8a architecture [yes]"
  echo -e "  --disable-x86\t\t\tdo not build x86 architecture [yes]"
  echo -e "  --disable-x86-64\t\tdo not build x86-64 architecture [yes]\n"

  echo -e "Libraries:"
  echo -e "  --full\t\t\tenables all external libraries"
  echo -e "  --enable-android-media-codec\tbuild with built-in Android MediaCodec support[no]"
  echo -e "  --enable-android-zlib\t\tbuild with built-in zlib support[no]"

  display_help_common_libraries
  display_help_gpl_libraries
  display_help_advanced_options
}

enable_lts_build() {
  export FFMPEG_KIT_LTS_BUILD="1"

  # USING API LEVEL 16 / Android 4.1 (JELLY BEAN)
  export API=16
}

build_application_mk() {
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    local LTS_BUILD_FLAG="-DFFMPEG_KIT_LTS "
  fi

  if [[ ${ENABLED_LIBRARIES[$LIBRARY_X265]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_TESSERACT]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_OPENH264]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_SNAPPY]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_RUBBERBAND]} -eq 1 ]]; then
    local APP_STL="c++_shared"
  else
    local APP_STL="none"
  fi

  local BUILD_DATE="-DFFMPEG_KIT_BUILD_DATE=$(date +%Y%m%d 2>>"${BASEDIR}"/build.log)"

  rm -f "${BASEDIR}/android/jni/Application.mk"

  cat >"${BASEDIR}/android/jni/Application.mk" <<EOF
APP_OPTIM := release

APP_ABI := ${ANDROID_ARCHITECTURES}

APP_STL := ${APP_STL}

APP_PLATFORM := android-${API}

APP_CFLAGS := -O3 -DANDROID ${LTS_BUILD_FLAG}${BUILD_DATE} -Wall -Wno-deprecated-declarations -Wno-pointer-sign -Wno-switch -Wno-unused-result -Wno-unused-variable

APP_LDFLAGS := -Wl,--hash-style=both
EOF
}

if [[ -z ${ANDROID_SDK_ROOT} ]]; then
  echo -e "(*) ANDROID_SDK_ROOT not defined\n"
  exit 1
fi

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
  echo -e "(*) ANDROID_NDK_ROOT not defined\n"
  exit 1
fi

DETECTED_NDK_VERSION=$(grep -Eo "Revision.*" "${ANDROID_NDK_ROOT}"/source.properties | sed 's/Revision//g;s/=//g;s/ //g')

echo -e "\nINFO: Using Android NDK v${DETECTED_NDK_VERSION} provided at ${ANDROID_NDK_ROOT}\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: Build options: $*\n" 1>>"${BASEDIR}"/build.log 2>&1

GPL_ENABLED="no"
DISPLAY_HELP=""
BUILD_LTS=""
BUILD_FULL=""
BUILD_TYPE_ID=""
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
  --no-link-time-optimization)
    no_link_time_optimization
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
  --api-level=*)
    API_LEVEL=$(echo $1 | sed -e 's/^--[A-Za-z]*-[A-Za-z]*=//g')

    export API=${API_LEVEL}
    ;;
  *)
    print_unknown_option "$1"
    ;;
  esac
  shift
done

if [[ -z ${BUILD_VERSION} ]]; then
  echo -e "\n(*) error: Can not run git commands in this folder. See build.log.\n"
  exit 1
fi

# DETECT BUILD TYPE
rm -f "${BASEDIR}"/android/app/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
if [[ -n ${BUILD_LTS} ]]; then
  enable_lts_build
  BUILD_TYPE_ID+="LTS "

  cp "${BASEDIR}"/tools/release/android/build.lts.gradle "${BASEDIR}"/android/app/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
else
  cp "${BASEDIR}"/tools/release/android/build.gradle "${BASEDIR}"/android/app/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
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

echo -e "\nBuilding ffmpeg-kit ${BUILD_TYPE_ID}library for Android\n"
echo -e -n "INFO: Building ffmpeg-kit ${BUILD_VERSION} ${BUILD_TYPE_ID}library for Android: " 1>>"${BASEDIR}"/build.log 2>&1
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

# SAVE API VALUE
export ORIGINAL_API=${API}

# BUILD ALL ENABLED ARCHITECTURES
for run_arch in {0..10}; do
  if [[ ${ENABLED_ARCHITECTURES[$run_arch]} -eq 1 ]]; then
    if [[ (${run_arch} -eq ${ARCH_ARM64_V8A} || ${run_arch} -eq ${ARCH_X86_64}) && ${API} -lt 21 ]]; then

      # 64 bit ABIs supported after API 21
      export API=21
    else
      export API=${ORIGINAL_API}
    fi

    export ARCH=$(get_arch_name $run_arch)
    export TOOLCHAIN=$(get_toolchain)
    export TOOLCHAIN_ARCH=$(get_toolchain_arch)

    . "${BASEDIR}"/scripts/main-android.sh "${ENABLED_LIBRARIES[@]}" || exit 1

    # CLEAR FLAGS
    for library in {0..60}; do
      library_name=$(get_library_name ${library})
      unset "$(echo "OK_${library_name}" | sed "s/\-/\_/g")"
      unset "$(echo "DEPENDENCY_REBUILT_${library_name}" | sed "s/\-/\_/g")"
    done
  fi
done

export API=${ORIGINAL_API}

# SET ARCHITECTURES INSIDE Application.mk
rm -f "${BASEDIR}"/android/build/.armv7 1>>"${BASEDIR}"/build.log 2>&1
rm -f "${BASEDIR}"/android/build/.armv7neon 1>>"${BASEDIR}"/build.log 2>&1
ANDROID_ARCHITECTURES=""
if [[ ${ENABLED_ARCHITECTURES[0]} -eq 1 ]] || [[ ${ENABLED_ARCHITECTURES[1]} -eq 1 ]]; then
  ANDROID_ARCHITECTURES+="$(get_android_arch 0) "
fi
if [[ ${ENABLED_ARCHITECTURES[0]} -eq 1 ]]; then
  mkdir -p "${BASEDIR}"/android/build 1>>"${BASEDIR}"/build.log 2>&1
  cat >"${BASEDIR}"/android/build/.armv7 <<EOF
EOF
fi
if [[ ${ENABLED_ARCHITECTURES[1]} -eq 1 ]]; then
  mkdir -p "${BASEDIR}"/android/build 1>>"${BASEDIR}"/build.log 2>&1
  cat >"${BASEDIR}"/android/build/.armv7neon <<EOF
EOF
fi
if [[ ${ENABLED_ARCHITECTURES[2]} -eq 1 ]]; then
  ANDROID_ARCHITECTURES+="$(get_android_arch 2) "
fi
if [[ ${ENABLED_ARCHITECTURES[3]} -eq 1 ]]; then
  ANDROID_ARCHITECTURES+="$(get_android_arch 3) "
fi
if [[ ${ENABLED_ARCHITECTURES[4]} -eq 1 ]]; then
  ANDROID_ARCHITECTURES+="$(get_android_arch 4) "
fi

if [[ -n ${ANDROID_ARCHITECTURES} ]]; then

  echo -n -e "\nffmpeg-kit: "

  build_application_mk

  FFMPEG_KIT_AAR="${BASEDIR}"/prebuilt/android-aar/ffmpeg-kit

  # BUILDING ANDROID ARCHIVE LIBRARY
  rm -rf "${BASEDIR}"/android/libs 1>>"${BASEDIR}"/build.log 2>&1

  mkdir -p "${FFMPEG_KIT_AAR}" 1>>"${BASEDIR}"/build.log 2>&1

  cd "${BASEDIR}"/android 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

  # CLEAR OLD NDK LIBS
  rm -rf "${BASEDIR}"/android/libs 1>>"${BASEDIR}"/build.log 2>&1
  rm -rf "${BASEDIR}"/android/obj 1>>"${BASEDIR}"/build.log 2>&1

  "${ANDROID_NDK_ROOT}"/ndk-build -B 1>>"${BASEDIR}"/build.log 2>&1

  if [ $? -eq 0 ]; then
    echo "ok"
  else
    echo "failed"
    exit 1
  fi

  echo -e -n "\n\nCreating Android archive under prebuilt/android-aar: "

  ./gradlew app:clean app:assembleRelease app:testReleaseUnitTest 1>>"${BASEDIR}"/build.log 2>&1

  if [ $? -ne 0 ]; then
    echo -e "failed\n"
    exit 1
  fi

  cp "${BASEDIR}"/android/app/build/outputs/aar/ffmpeg-kit-release.aar "${FFMPEG_KIT_AAR}"/ffmpeg-kit.aar 1>>"${BASEDIR}"/build.log 2>&1

  if [ $? -ne 0 ]; then
    echo -e "failed\n"
    exit 1
  fi

  echo -e "Created ffmpeg-kit Android archive successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1

  echo -e "ok\n"
fi
