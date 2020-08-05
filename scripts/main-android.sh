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

# ENABLE COMMON FUNCTIONS
. "${BASEDIR}"/scripts/function-android.sh

echo -e "\nBuilding ${ARCH} platform on API level ${API}\n"
echo -e "\nINFO: Starting new build for ${ARCH} on API level ${API} at $(date)\n" 1>>"${BASEDIR}"/build.log 2>&1

# SET BASE INSTALLATION DIRECTORY FOR THIS ARCHITECTURE
INSTALL_BASE="${BASEDIR}/prebuilt/android-$(get_target_build)"

# CREATE PACKAGE CONFIG DIRECTORY FOR THIS ARCHITECTURE
PKG_CONFIG_DIRECTORY="${INSTALL_BASE}/pkgconfig"
if [ ! -d "${PKG_CONFIG_DIRECTORY}" ]; then
  mkdir -p "${PKG_CONFIG_DIRECTORY}" || exit 1
fi

# FILTER WHICH EXTERNAL LIBRARIES WILL BE BUILT
# NOTE THAT BUILT-IN LIBRARIES ARE FORWARDED TO FFMPEG SCRIPT WITHOUT ANY PROCESSING
enabled_library_list=()
for library in {1..46}; do
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
      if [[ -n $OK_libuuid ]] && [[ -n $OK_expat ]] && [[ -n $OK_libiconv ]] && [[ -n $OK_freetype ]]; then
        run=1
      fi
      ;;
    freetype)
      if [[ -n $OK_libpng ]]; then
        run=1
      fi
      ;;
    gnutls)
      if [[ -n $OK_nettle ]] && [[ -n $OK_gmp ]] && [[ -n $OK_libiconv ]]; then
        run=1
      fi
      ;;
    lame)
      if [[ -n $OK_libiconv ]]; then
        run=1
      fi
      ;;
    leptonica)
      if [[ -n $OK_giflib ]] && [[ -n $OK_jpeg ]] && [[ -n $OK_libpng ]] && [[ -n $OK_tiff ]] && [[ -n $OK_libwebp ]]; then
        run=1
      fi
      ;;
    libass)
      if [[ -n $OK_libuuid ]] && [[ -n $OK_expat ]] && [[ -n $OK_libiconv ]] && [[ -n $OK_freetype ]] && [[ -n $OK_fribidi ]] && [[ -n $OK_fontconfig ]] && [[ -n $OK_libpng ]]; then
        run=1
      fi
      ;;
    libtheora)
      if [[ -n $OK_libvorbis ]] && [[ -n $OK_libogg ]]; then
        run=1
      fi
      ;;
    libvorbis)
      if [[ -n $OK_libogg ]]; then
        run=1
      fi
      ;;
    libwebp)
      if [[ -n $OK_giflib ]] && [[ -n $OK_jpeg ]] && [[ -n $OK_libpng ]] && [[ -n $OK_tiff ]]; then
        run=1
      fi
      ;;
    libxml2)
      if [[ -n $OK_libiconv ]]; then
        run=1
      fi
      ;;
    nettle)
      if [[ -n $OK_gmp ]]; then
        run=1
      fi
      ;;
    rubberband)
      if [[ -n $OK_libsndfile ]] && [[ -n $OK_libsamplerate ]]; then
        run=1
      fi
      ;;
    tesseract)
      if [[ -n $OK_leptonica ]]; then
        run=1
      fi
      ;;
    tiff)
      if [[ -n $OK_jpeg ]]; then
        run=1
      fi
      ;;
    twolame)
      if [[ -n $OK_libsndfile ]]; then
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

    if [ $run -eq 1 ] && [[ -z ${!BUILD_COMPLETED_FLAG} ]]; then
      ENABLED_LIBRARY_PATH="${INSTALL_BASE}/${library}"

      LIBRARY_IS_INSTALLED=$(library_is_installed "${INSTALL_BASE}" "${library}")

      echo -e "INFO: Flags detected for ${library}: already installed=${LIBRARY_IS_INSTALLED}, rebuild=${!REBUILD_FLAG}, dependency rebuilt=${!DEPENDENCY_REBUILT_FLAG}\n" 1>>"${BASEDIR}"/build.log 2>&1

      # CHECK IF BUILD IS NECESSARY OR NOT
      if [[ ${LIBRARY_IS_INSTALLED} -ne 0 ]] || [[ ${!REBUILD_FLAG} -eq 1 ]] || [[ ${!DEPENDENCY_REBUILT_FLAG} -eq 1 ]]; then

        echo -e "----------------------------------------------------------------" 1>>"${BASEDIR}"/build.log 2>&1
        echo -e "\nINFO: Building $library with the following environment variables\n" 1>>"${BASEDIR}"/build.log 2>&1
        env 1>>"${BASEDIR}"/build.log 2>&1
        echo -e "----------------------------------------------------------------\n" 1>>"${BASEDIR}"/build.log 2>&1
        echo -e "INFO: System information\n" 1>>"${BASEDIR}"/build.log 2>&1
        echo -e "INFO: $(uname -a)\n" 1>>"${BASEDIR}"/build.log 2>&1
        echo -e "----------------------------------------------------------------\n" 1>>"${BASEDIR}"/build.log 2>&1

        echo -n "${library}: "

        # DELETE THE PREVIOUS BUILD OF THE LIBRARY
        if [ -d "${ENABLED_LIBRARY_PATH}" ]; then
          rm -rf "${INSTALL_BASE}"/"${library}" || exit 1
        fi

        SCRIPT_PATH="${BASEDIR}/scripts/android/${library}.sh"

        cd "${BASEDIR}"

        # EXECUTE BUILD SCRIPT OF EACH ENABLED LIBRARY
        ${SCRIPT_PATH} 1>>"${BASEDIR}"/build.log 2>&1

        # SET SOME FLAGS AFTER THE BUILD
        if [ $? -eq 0 ]; then
          ((completed += 1))
          declare "$BUILD_COMPLETED_FLAG=1"
          check_if_dependency_rebuilt "${library}"
          echo "ok"
        else
          echo "failed"
          exit 1
        fi
      else
        ((completed += 1))
        declare "$BUILD_COMPLETED_FLAG=1"
        echo "${library}: already built"
      fi
    else
      echo -e "INFO: Skipping $library, run=$run, completed=${!BUILD_COMPLETED_FLAG}\n" 1>>"${BASEDIR}"/build.log 2>&1
    fi
  done
done

# SKIP TO SPEED UP THE BUILD
if [[ ${SKIP_ffmpeg} -ne 1 ]]; then

  # BUILD FFMPEG
  . "${BASEDIR}"/scripts/android/ffmpeg.sh "$@"
else
  echo -e "\nffmpeg: skipped"
fi

echo -e "\nINFO: Completed build for ${ARCH} on API level ${API} at $(date)\n" 1>>"${BASEDIR}"/build.log 2>&1
