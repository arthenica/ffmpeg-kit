#!/bin/bash

if [[ -z ${ARCH} ]]; then
  echo -e "\n(*) ARCH not defined\n"
  exit 1
fi

if [[ -z ${API} ]]; then
  echo -e "\n(*) API not defined\n"
  exit 1
fi

if [[ -z ${BASEDIR} ]]; then
  echo -e "\n(*) BASEDIR not defined\n"
  exit 1
fi

if [[ -z ${TOOLCHAIN} ]]; then
  echo -e "\n(*) TOOLCHAIN not defined\n"
  exit 1
fi

if [[ -z ${TOOLCHAIN_ARCH} ]]; then
  echo -e "\n(*) TOOLCHAIN_ARCH not defined\n"
  exit 1
fi

echo -e "\nBuilding ${ARCH} platform on API level ${API}\n"
echo -e "\nINFO: Starting new build for ${ARCH} on API level ${API} at $(date)\n" 1>>"${BASEDIR}"/build.log 2>&1

# SET BASE INSTALLATION DIRECTORY FOR THIS ARCHITECTURE
export LIB_INSTALL_BASE="${BASEDIR}/prebuilt/$(get_build_directory)"

# CREATE PACKAGE CONFIG DIRECTORY FOR THIS ARCHITECTURE
PKG_CONFIG_DIRECTORY="${LIB_INSTALL_BASE}/pkgconfig"
if [ ! -d "${PKG_CONFIG_DIRECTORY}" ]; then
  mkdir -p "${PKG_CONFIG_DIRECTORY}" || return 1
fi

# FILTER WHICH EXTERNAL LIBRARIES WILL BE BUILT
# NOTE THAT BUILT-IN LIBRARIES ARE FORWARDED TO FFMPEG SCRIPT WITHOUT ANY PROCESSING
enabled_library_list=()
for library in {1..50}; do
  if [[ ${!library} -eq 1 ]]; then
    ENABLED_LIBRARY=$(get_library_name $((library - 1)))
    enabled_library_list+=(${ENABLED_LIBRARY})

    echo -e "INFO: Enabled library ${ENABLED_LIBRARY} will be built\n" 1>>"${BASEDIR}"/build.log 2>&1
  fi
done

# BUILD LTS SUPPORT LIBRARY FOR API < 18
if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]] && [[ ${API} -lt 18 ]]; then
  build_android_lts_support
fi

# BUILD ENABLED LIBRARIES AND THEIR DEPENDENCIES
let completed=0
while [ ${#enabled_library_list[@]} -gt $completed ]; do
  for library in "${enabled_library_list[@]}"; do
    let run=0
    case $library in
    fontconfig)
      if [[ $OK_libuuid -eq 1 ]] && [[ $OK_expat -eq 1 ]] && [[ $OK_libiconv -eq 1 ]] && [[ $OK_freetype -eq 1 ]]; then
        run=1
      fi
      ;;
    freetype)
      if [[ $OK_libpng -eq 1 ]]; then
        run=1
      fi
      ;;
    gnutls)
      if [[ $OK_nettle -eq 1 ]] && [[ $OK_gmp -eq 1 ]] && [[ $OK_libiconv -eq 1 ]]; then
        run=1
      fi
      ;;
    harfbuzz)
      if [[ $OK_fontconfig -eq 1 ]] && [[ $OK_freetype -eq 1 ]]; then
        run=1
      fi
      ;;
    lame)
      if [[ $OK_libiconv -eq 1 ]]; then
        run=1
      fi
      ;;
    leptonica)
      if [[ $OK_giflib -eq 1 ]] && [[ $OK_jpeg -eq 1 ]] && [[ $OK_libpng -eq 1 ]] && [[ $OK_tiff -eq 1 ]] && [[ $OK_libwebp -eq 1 ]]; then
        run=1
      fi
      ;;
    libass)
      if [[ $OK_libuuid -eq 1 ]] && [[ $OK_expat -eq 1 ]] && [[ $OK_libiconv -eq 1 ]] && [[ $OK_freetype -eq 1 ]] && [[ $OK_fribidi -eq 1 ]] && [[ $OK_fontconfig -eq 1 ]] && [[ $OK_libpng -eq 1 ]] && [[ $OK_harfbuzz -eq 1 ]]; then
        run=1
      fi
      ;;
    libtheora)
      if [[ $OK_libvorbis -eq 1 ]] && [[ $OK_libogg -eq 1 ]]; then
        run=1
      fi
      ;;
    libvorbis)
      if [[ $OK_libogg -eq 1 ]]; then
        run=1
      fi
      ;;
    libvpx)
      if [[ $OK_cpu_features -eq 1 ]]; then
        run=1
      fi
      ;;
    libwebp)
      if [[ $OK_giflib -eq 1 ]] && [[ $OK_jpeg -eq 1 ]] && [[ $OK_libpng -eq 1 ]] && [[ $OK_tiff -eq 1 ]]; then
        run=1
      fi
      ;;
    libxml2)
      if [[ $OK_libiconv -eq 1 ]]; then
        run=1
      fi
      ;;
    nettle)
      if [[ $OK_gmp -eq 1 ]]; then
        run=1
      fi
      ;;
    openh264)
      if [[ $OK_cpu_features -eq 1 ]]; then
        run=1
      fi
      ;;
    rubberband)
      if [[ $OK_libsndfile -eq 1 ]] && [[ $OK_libsamplerate -eq 1 ]]; then
        run=1
      fi
      ;;
    srt)
      if [[ $OK_openssl -eq 1 ]]; then
        run=1
      fi
      ;;
    tesseract)
      if [[ $OK_leptonica -eq 1 ]]; then
        run=1
      fi
      ;;
    tiff)
      if [[ $OK_jpeg -eq 1 ]]; then
        run=1
      fi
      ;;
    twolame)
      if [[ $OK_libsndfile -eq 1 ]]; then
        run=1
      fi
      ;;
    *)
      run=1
      ;;
    esac

    # DEFINE SOME FLAGS TO MANAGE DEPENDENCIES AND REBUILD OPTIONS
    BUILD_COMPLETED_FLAG=$(echo "OK_${library}" | sed "s/\-/\_/g")
    REBUILD_FLAG=$(echo "REBUILD_${library}" | sed "s/\-/\_/g")
    DEPENDENCY_REBUILT_FLAG=$(echo "DEPENDENCY_REBUILT_${library}" | sed "s/\-/\_/g")

    if [[ $run -eq 1 ]] && [[ "${!BUILD_COMPLETED_FLAG}" != "1" ]]; then
      LIBRARY_IS_INSTALLED=$(library_is_installed "${LIB_INSTALL_BASE}" "${library}")

      echo -e "INFO: Flags detected for ${library}: already installed=${LIBRARY_IS_INSTALLED}, rebuild requested by user=${!REBUILD_FLAG}, will be rebuilt due to dependency update=${!DEPENDENCY_REBUILT_FLAG}\n" 1>>"${BASEDIR}"/build.log 2>&1

      # CHECK IF BUILD IS NECESSARY OR NOT
      if [[ ${LIBRARY_IS_INSTALLED} -ne 1 ]] || [[ ${!REBUILD_FLAG} -eq 1 ]] || [[ ${!DEPENDENCY_REBUILT_FLAG} -eq 1 ]]; then

        echo -n "${library}: "

        "${BASEDIR}"/scripts/run-android.sh "${library}" 1>>"${BASEDIR}"/build.log 2>&1

        RC=$?

        # SET SOME FLAGS AFTER THE BUILD
        if [ $RC -eq 0 ]; then
          ((completed += 1))
          declare "$BUILD_COMPLETED_FLAG=1"
          check_if_dependency_rebuilt "${library}"
          echo "ok"
        elif [ $RC -eq 200 ]; then
          echo -e "not supported\n\nSee build.log for details\n"
          exit 1
        else
          echo -e "failed\n\nSee build.log for details\n"
          exit 1
        fi
      else
        ((completed += 1))
        declare "$BUILD_COMPLETED_FLAG=1"
        echo "${library}: already built"
      fi
    else
      echo -e "INFO: Skipping $library, dependencies built=$run, already built=${!BUILD_COMPLETED_FLAG}\n" 1>>"${BASEDIR}"/build.log 2>&1
    fi
  done
done

# BUILD CUSTOM LIBRARIES
for custom_library_index in "${CUSTOM_LIBRARIES[@]}"; do
  library_name="CUSTOM_LIBRARY_${custom_library_index}_NAME"

  echo -e "\nDEBUG: Custom library ${!library_name} will be built\n" 1>>"${BASEDIR}"/build.log 2>&1

  # DEFINE SOME FLAGS TO REBUILD OPTIONS
  REBUILD_FLAG=$(echo "REBUILD_${!library_name}" | sed "s/\-/\_/g")
  LIBRARY_IS_INSTALLED=$(library_is_installed "${LIB_INSTALL_BASE}" "${!library_name}")

  echo -e "INFO: Flags detected for custom library ${!library_name}: already installed=${LIBRARY_IS_INSTALLED}, rebuild requested by user=${!REBUILD_FLAG}\n" 1>>"${BASEDIR}"/build.log 2>&1

  if [[ ${LIBRARY_IS_INSTALLED} -ne 1 ]] || [[ ${!REBUILD_FLAG} -eq 1 ]]; then

    echo -n "${!library_name}: "

    "${BASEDIR}"/scripts/run-android.sh "${!library_name}" 1>>"${BASEDIR}"/build.log 2>&1

    RC=$?

    # SET SOME FLAGS AFTER THE BUILD
    if [ $RC -eq 0 ]; then
      echo "ok"
    elif [ $RC -eq 200 ]; then
      echo -e "not supported\n\nSee build.log for details\n"
      exit 1
    else
      echo -e "failed\n\nSee build.log for details\n"
      exit 1
    fi
  else
    echo "${!library_name}: already built"
  fi
done

# SKIP TO SPEED UP THE BUILD
if [[ ${SKIP_ffmpeg} -ne 1 ]]; then

  # BUILD FFMPEG
  source "${BASEDIR}"/scripts/android/ffmpeg.sh

  if [[ $? -ne 0 ]]; then
    exit 1
  fi
else
  echo -e "\nffmpeg: skipped"
fi

echo -e "\nINFO: Completed build for ${ARCH} on API level ${API} at $(date)\n" 1>>"${BASEDIR}"/build.log 2>&1
