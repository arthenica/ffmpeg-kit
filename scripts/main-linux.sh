#!/bin/bash

if [[ -z ${ARCH} ]]; then
  echo -e "\n(*) ARCH not defined\n"
  exit 1
fi

if [[ -z ${BASEDIR} ]]; then
  echo -e "\n(*) BASEDIR not defined\n"
  exit 1
fi

echo -e "\nBuilding ${ARCH} platform\n"
echo -e "\nINFO: Starting new build for ${ARCH} at $(date)\n" 1>>"${BASEDIR}"/build.log 2>&1

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

# BUILD ENABLED LIBRARIES AND THEIR DEPENDENCIES
let completed=0
while [ ${#enabled_library_list[@]} -gt $completed ]; do
  for library in "${enabled_library_list[@]}"; do
    let run=0
    case $library in
    srt)
      if [[ $OK_openssl -eq 1 ]]; then
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

        "${BASEDIR}"/scripts/run-linux.sh "${library}" 1>>"${BASEDIR}"/build.log 2>&1

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

    "${BASEDIR}"/scripts/run-linux.sh "${!library_name}" 1>>"${BASEDIR}"/build.log 2>&1

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

  # PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
  LIB_NAME="ffmpeg"
  set_toolchain_paths "${LIB_NAME}"

  # SET BUILD FLAGS
  HOST=$(get_host)
  export CFLAGS=$(get_cflags "${LIB_NAME}")
  export CXXFLAGS=$(get_cxxflags "${LIB_NAME}")
  export LDFLAGS=$(get_ldflags "${LIB_NAME}")
  export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

  cd "${BASEDIR}"/src/"${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1

  LIB_INSTALL_PREFIX="${LIB_INSTALL_BASE}/${LIB_NAME}"

  # BUILD FFMPEG
  source "${BASEDIR}"/scripts/linux/ffmpeg.sh

  if [[ $? -ne 0 ]]; then
    exit 1
  fi
else
  echo -e "\nffmpeg: skipped"
fi

# SKIP TO SPEED UP THE BUILD
if [[ ${SKIP_ffmpeg_kit} -ne 1 ]]; then

  # BUILD FFMPEG KIT
  . "${BASEDIR}"/scripts/linux/ffmpeg-kit.sh "$@" || return 1
else
  echo -e "\nffmpeg-kit: skipped"
fi

echo -e "\nINFO: Completed build for ${ARCH} at $(date)\n" 1>>"${BASEDIR}"/build.log 2>&1
