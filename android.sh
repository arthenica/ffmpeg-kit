#!/bin/bash

if [[ -z ${ANDROID_SDK_ROOT} ]]; then
  echo -e "\n(*) ANDROID_SDK_ROOT not defined\n"
  exit 1
fi

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
  echo -e "\n(*) ANDROID_NDK_ROOT not defined\n"
  exit 1
fi

# LOAD INITIAL SETTINGS
export BASEDIR="$(pwd)"
export FFMPEG_KIT_BUILD_TYPE="android"
source "${BASEDIR}"/scripts/variable.sh
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh
disabled_libraries=()

# SET DEFAULTS SETTINGS
enable_default_android_architectures
enable_default_android_libraries
enable_main_build

# DETECT ANDROID NDK VERSION
export DETECTED_NDK_VERSION=$(grep -Eo "Revision.*" "${ANDROID_NDK_ROOT}"/source.properties | sed 's/Revision//g;s/=//g;s/ //g')
echo -e "\nINFO: Using Android NDK v${DETECTED_NDK_VERSION} provided at ${ANDROID_NDK_ROOT}\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: Build options: $*\n" 1>>"${BASEDIR}"/build.log 2>&1

# SET DEFAULT BUILD OPTIONS
export GPL_ENABLED="no"
DISPLAY_HELP=""
BUILD_FULL=""
BUILD_TYPE_ID=""
BUILD_VERSION=$(git describe --tags --always 2>>"${BASEDIR}"/build.log)

# PROCESS LTS BUILD OPTION FIRST AND SET BUILD TYPE: MAIN OR LTS
rm -f "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
cp "${BASEDIR}"/tools/android/build.gradle "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
for argument in "$@"; do
  if [[ "$argument" == "-l" ]] || [[ "$argument" == "--lts" ]]; then
    enable_lts_build
    BUILD_TYPE_ID+="LTS "
    rm -f "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
    cp "${BASEDIR}"/tools/android/build.lts.gradle "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
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
    SKIP_LIBRARY=$(echo $1 | sed -e 's/^--[A-Za-z]*-//g')

    skip_library "${SKIP_LIBRARY}"
    ;;
  --no-archive)
    NO_ARCHIVE="1"
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
  -l | --lts) ;;
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
  --api-level=*)
    API_LEVEL=$(echo $1 | sed -e 's/^--[A-Za-z]*-[A-Za-z]*=//g')

    export API=${API_LEVEL}
    ;;
  --no-ffmpeg-kit-protocols)
    export NO_FFMPEG_KIT_PROTOCOLS="1"
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

# PROCESS FULL OPTION AS LAST OPTION
if [[ -n ${BUILD_FULL} ]]; then
  for library in {0..61}; do
    if [ ${GPL_ENABLED} == "yes" ]; then
      enable_library "$(get_library_name $library)" 1
    else
      if [[ $(is_gpl_licensed $library) -eq 1 ]]; then
        enable_library "$(get_library_name $library)" 1
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

# SET API LEVEL IN build.gradle
${SED_INLINE} "s/minSdkVersion .*/minSdkVersion ${API}/g" "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
${SED_INLINE} "s/versionCode ..0/versionCode ${API}0/g" "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1

echo -e "\nBuilding ffmpeg-kit ${BUILD_TYPE_ID}library for Android\n"
echo -e -n "INFO: Building ffmpeg-kit ${BUILD_VERSION} ${BUILD_TYPE_ID}library for Android: " 1>>"${BASEDIR}"/build.log 2>&1
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
    library_name=$(get_library_name ${gpl_library})

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

# SAVE ORIGINAL API LEVEL = NECESSARY TO BUILD 64bit ARCHITECTURES
export ORIGINAL_API=${API}

# BUILD ENABLED LIBRARIES ON ENABLED ARCHITECTURES
for run_arch in {0..12}; do
  if [[ ${ENABLED_ARCHITECTURES[$run_arch]} -eq 1 ]]; then
    if [[ (${run_arch} -eq ${ARCH_ARM64_V8A} || ${run_arch} -eq ${ARCH_X86_64}) && ${ORIGINAL_API} -lt 21 ]]; then

      # 64 bit ABIs supported after API 21
      export API=21
    else
      export API=${ORIGINAL_API}
    fi

    export ARCH=$(get_arch_name $run_arch)
    export TOOLCHAIN=$(get_toolchain)
    export TOOLCHAIN_ARCH=$(get_toolchain_arch)

    # EXECUTE MAIN BUILD SCRIPT
    . "${BASEDIR}"/scripts/main-android.sh "${ENABLED_LIBRARIES[@]}" || exit 1

    # CLEAR FLAGS
    for library in {0..61}; do
      library_name=$(get_library_name ${library})
      unset "$(echo "OK_${library_name}" | sed "s/\-/\_/g")"
      unset "$(echo "DEPENDENCY_REBUILT_${library_name}" | sed "s/\-/\_/g")"
    done
  fi
done

# GET BACK THE ORIGINAL API LEVEL
export API=${ORIGINAL_API}

# SET ARCHITECTURES TO BUILD
rm -f "${BASEDIR}"/android/build/.armv7 1>>"${BASEDIR}"/build.log 2>&1
rm -f "${BASEDIR}"/android/build/.armv7neon 1>>"${BASEDIR}"/build.log 2>&1
rm -f "${BASEDIR}"/android/build/.lts 1>>"${BASEDIR}"/build.log 2>&1
ANDROID_ARCHITECTURES=""
if [[ ${ENABLED_ARCHITECTURES[ARCH_ARM_V7A]} -eq 1 ]] || [[ ${ENABLED_ARCHITECTURES[ARCH_ARM_V7A_NEON]} -eq 1 ]]; then
  ANDROID_ARCHITECTURES+="$(get_android_arch 0) "
fi
if [[ ${ENABLED_ARCHITECTURES[ARCH_ARM_V7A]} -eq 1 ]]; then
  mkdir -p "${BASEDIR}"/android/build 1>>"${BASEDIR}"/build.log 2>&1
  create_file "${BASEDIR}"/android/build/.armv7
fi
if [[ ${ENABLED_ARCHITECTURES[ARCH_ARM_V7A_NEON]} -eq 1 ]]; then
  mkdir -p "${BASEDIR}"/android/build 1>>"${BASEDIR}"/build.log 2>&1
  create_file "${BASEDIR}"/android/build/.armv7neon
fi
if [[ ${ENABLED_ARCHITECTURES[ARCH_ARM64_V8A]} -eq 1 ]]; then
  ANDROID_ARCHITECTURES+="$(get_android_arch 2) "
fi
if [[ ${ENABLED_ARCHITECTURES[ARCH_X86]} -eq 1 ]]; then
  ANDROID_ARCHITECTURES+="$(get_android_arch 3) "
fi
if [[ ${ENABLED_ARCHITECTURES[ARCH_X86_64]} -eq 1 ]]; then
  ANDROID_ARCHITECTURES+="$(get_android_arch 4) "
fi
if [[ ! -z ${FFMPEG_KIT_LTS_BUILD} ]]; then
  mkdir -p "${BASEDIR}"/android/build 1>>"${BASEDIR}"/build.log 2>&1
  create_file "${BASEDIR}"/android/build/.lts
fi

# BUILD FFMPEG-KIT
if [[ -n ${ANDROID_ARCHITECTURES} ]]; then

  echo -n -e "\nffmpeg-kit: "

  # CREATE Application.mk FILE BEFORE STARTING THE NATIVE BUILD
  build_application_mk

  # CLEAR OLD NATIVE LIBRARIES
  rm -rf "${BASEDIR}"/android/libs 1>>"${BASEDIR}"/build.log 2>&1
  rm -rf "${BASEDIR}"/android/obj 1>>"${BASEDIR}"/build.log 2>&1

  cd "${BASEDIR}"/android 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

  # COPY EXTERNAL LIBRARY LICENSES
  LICENSE_BASEDIR="${BASEDIR}"/android/ffmpeg-kit-android-lib/src/main/res/raw
  rm -f "${LICENSE_BASEDIR}"/*.txt 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
  for library in {0..49}; do
    if [[ ${ENABLED_LIBRARIES[$library]} -eq 1 ]]; then
      ENABLED_LIBRARY=$(get_library_name ${library} | sed 's/-/_/g')
      LICENSE_FILE="${LICENSE_BASEDIR}/license_${ENABLED_LIBRARY}.txt"

      RC=$(copy_external_library_license_file ${library} "${LICENSE_FILE}")

      if [[ ${RC} -ne 0 ]]; then
        echo -e "DEBUG: Failed to copy the license file of ${ENABLED_LIBRARY}\n" 1>>"${BASEDIR}"/build.log 2>&1
        echo -e "failed\n\nSee build.log for details\n"
        exit 1
      fi

      echo -e "DEBUG: Copied the license file of ${ENABLED_LIBRARY} successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
    fi
  done

  # COPY CUSTOM LIBRARY LICENSES
  for custom_library_index in "${CUSTOM_LIBRARIES[@]}"; do
    library_name="CUSTOM_LIBRARY_${custom_library_index}_NAME"
    relative_license_path="CUSTOM_LIBRARY_${custom_library_index}_LICENSE_FILE"

    destination_license_path="${LICENSE_BASEDIR}/license_${!library_name}.txt"

    cp "${BASEDIR}/src/${!library_name}/${!relative_license_path}" "${destination_license_path}" 1>>"${BASEDIR}"/build.log 2>&1

    RC=$?

    if [[ ${RC} -ne 0 ]]; then
      echo -e "DEBUG: Failed to copy the license file of custom library ${!library_name}\n" 1>>"${BASEDIR}"/build.log 2>&1
      echo -e "failed\n\nSee build.log for details\n"
      exit 1
    fi

    echo -e "DEBUG: Copied the license file of custom library ${!library_name} successfully\n" 1>>"${BASEDIR}"/build.log 2>&1
  done

  # COPY LIBRARY LICENSES
  if [[ ${GPL_ENABLED} == "yes" ]]; then
    cp "${BASEDIR}"/tools/license/LICENSE.GPLv3 "${LICENSE_BASEDIR}"/license.txt 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
  else
    cp "${BASEDIR}"/LICENSE "${LICENSE_BASEDIR}"/license.txt 1>>"${BASEDIR}"/build.log 2>&1 || exit 1
  fi

  echo -e "DEBUG: Copied the ffmpeg-kit license successfully\n" 1>>"${BASEDIR}"/build.log 2>&1

  overwrite_file "${BASEDIR}"/tools/source/SOURCE "${LICENSE_BASEDIR}"/source.txt 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

  echo -e "DEBUG: Copied source.txt successfully\n" 1>>"${BASEDIR}"/build.log 2>&1

  # BUILD NATIVE LIBRARY
  if [[ ${SKIP_ffmpeg_kit} -ne 1 ]]; then
    if [ "$(is_darwin_arm64)" == "1" ]; then
       arch -x86_64 "${ANDROID_NDK_ROOT}"/ndk-build -B 1>>"${BASEDIR}"/build.log 2>&1
    else
      "${ANDROID_NDK_ROOT}"/ndk-build -B 1>>"${BASEDIR}"/build.log 2>&1
    fi

    if [ $? -eq 0 ]; then
      echo "ok"
    else
      echo "failed"
      exit 1
    fi
  else
    echo "skipped"
  fi

  echo -e -n "\n"

  # DO NOT BUILD ANDROID ARCHIVE
  if [[ ${NO_ARCHIVE} -ne 1 ]]; then

    echo -e -n "\nCreating Android archive under prebuilt: "

    # BUILD ANDROID ARCHIVE
    rm -f "${BASEDIR}"/android/ffmpeg-kit-android-lib/build/outputs/aar/ffmpeg-kit-release.aar 1>>"${BASEDIR}"/build.log 2>&1
    ./gradlew ffmpeg-kit-android-lib:clean ffmpeg-kit-android-lib:assembleRelease ffmpeg-kit-android-lib:testReleaseUnitTest 1>>"${BASEDIR}"/build.log 2>&1
    if [ $? -ne 0 ]; then
      echo -e "failed\n"
      exit 1
    fi

    # COPY ANDROID ARCHIVE TO PREBUILT DIRECTORY
    FFMPEG_KIT_AAR="${BASEDIR}/prebuilt/$(get_aar_directory)/ffmpeg-kit"
    rm -rf "${FFMPEG_KIT_AAR}" 1>>"${BASEDIR}"/build.log 2>&1
    mkdir -p "${FFMPEG_KIT_AAR}" 1>>"${BASEDIR}"/build.log 2>&1
    cp "${BASEDIR}"/android/ffmpeg-kit-android-lib/build/outputs/aar/ffmpeg-kit-release.aar "${FFMPEG_KIT_AAR}"/ffmpeg-kit.aar 1>>"${BASEDIR}"/build.log 2>&1
    if [ $? -ne 0 ]; then
      echo -e "failed\n"
      exit 1
    fi

    echo -e "INFO: Created ffmpeg-kit Android archive successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "ok\n"
  else
    echo -e "INFO: Skipped creating Android archive.\n" 1>>"${BASEDIR}"/build.log 2>&1
  fi
fi
