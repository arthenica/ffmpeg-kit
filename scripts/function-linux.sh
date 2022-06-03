#!/bin/bash

source "${BASEDIR}/scripts/function.sh"

prepare_inline_sed

enable_default_linux_architectures() {
  ENABLED_ARCHITECTURES[ARCH_X86_64]=1
}

get_ffmpeg_kit_version() {
  local FFMPEG_KIT_VERSION=$(grep '#define FFMPEG_KIT_VERSION' "${BASEDIR}"/linux/src/main/cpp/ffmpegkit.h | grep -Eo '\".*\"' | sed -e 's/\"//g')

  echo "${FFMPEG_KIT_VERSION}"
}

display_help() {
  local COMMAND=$(echo "$0" | sed -e 's/\.\///g')

  echo -e "\n'$COMMAND' builds FFmpegKit for Linux platform. By default only one Linux architecture \
(x86_64) is built without any external libraries enabled. Options can be used to \
disable architectures and/or enable external libraries. Please note that GPL libraries (external libraries with GPL \
license) need --enable-gpl flag to be set explicitly. When compilation ends, \
libraries are created under the prebuilt folder.\n"
  echo -e "Usage: ./$COMMAND [OPTION]... [VAR=VALUE]...\n"
  echo -e "Specify environment variables as VARIABLE=VALUE to override default build options.\n"

  display_help_options "  -l, --lts\t\t\tbuild lts packages to support older devices"
  display_help_licensing

  echo -e "Architectures:"
  echo -e "  --disable-x86-64\t\tdo not build x86-64 architecture [yes]\n"

  echo -e "Libraries:"
  echo -e "  --full\t\t\tenables all external libraries"
  echo -e "  --enable-linux-alsa\t\tbuild with built-in alsa support [no]"
  echo -e "  --enable-linux-chromaprint\tbuild with built-in chromaprint support [no]"
  echo -e "  --enable-linux-fontconfig\tbuild with built-in fontconfig support [no]"
  echo -e "  --enable-linux-freetype\tbuild with built-in freetype support [no]"
  echo -e "  --enable-linux-fribidi\tbuild with built-in fribidi support [no]"
  echo -e "  --enable-linux-gmp\t\tbuild with built-in gmp support [no]"
  echo -e "  --enable-linux-gnutls\t\tbuild with built-in gnutls support [no]"
  echo -e "  --enable-linux-lame\t\tbuild with built-in lame support [no]"
  echo -e "  --enable-linux-libass\t\tbuild with built-in libass support [no]"
  echo -e "  --enable-linux-libiconv\tbuild with built-in libiconv support [no]"
  echo -e "  --enable-linux-libtheora\tbuild with built-in libtheora support [no]"
  echo -e "  --enable-linux-libvorbis\tbuild with built-in libvorbis support [no]"
  echo -e "  --enable-linux-libvpx\t\tbuild with built-in libvpx support [no]"
  echo -e "  --enable-linux-libwebp\tbuild with built-in libwebp support [no]"
  echo -e "  --enable-linux-libxml2\tbuild with built-in libxml2 support [no]"
  echo -e "  --enable-linux-opencl\t\tbuild with built-in opencl support [no]"
  echo -e "  --enable-linux-opencore-amr\tbuild with built-in opencore-amr support [no]"
  echo -e "  --enable-linux-opus\t\tbuild with built-in opus support [no]"
  echo -e "  --enable-linux-sdl\t\tbuild with built-in sdl support [no]"
  echo -e "  --enable-linux-shine\t\tbuild with built-in shine support [no]"
  echo -e "  --enable-linux-snappy\t\tbuild with built-in snappy support [no]"
  echo -e "  --enable-linux-soxr\t\tbuild with built-in soxr support [no]"
  echo -e "  --enable-linux-speex\t\tbuild with built-in speex support [no]"
  echo -e "  --enable-linux-tesseract\tbuild with built-in tesseract support [no]"
  echo -e "  --enable-linux-twolame\tbuild with built-in twolame support [no]"
  echo -e "  --enable-linux-vaapi\t\tbuild with built-in vaapi support [no]"
  echo -e "  --enable-linux-v4l2\t\tbuild with built-in v4l2 support [no]"
  echo -e "  --enable-linux-vo-amrwbenc\tbuild with built-in vo-amrwbenc support [no]"
  echo -e "  --enable-linux-zlib\t\tbuild with built-in zlib support [no]"
  echo -e "  --enable-dav1d\t\tbuild with dav1d [no]"
  echo -e "  --enable-kvazaar\t\tbuild with kvazaar [no]"
  echo -e "  --enable-libaom\t\tbuild with libaom [no]"
  echo -e "  --enable-libilbc\t\tbuild with libilbc [no]"
  echo -e "  --enable-openh264\t\tbuild with openh264 [no]"
  echo -e "  --enable-openssl\t\tbuild with openssl [no]"
  echo -e "  --enable-srt\t\t\tbuild with srt [no]"
  echo -e "  --enable-zimg\t\t\tbuild with zimg [no]\n"

  echo -e "GPL libraries:"
  echo -e "  --enable-linux-libvidstab\tbuild with built-in libvidstab support [no]"
  echo -e "  --enable-linux-rubberband\tbuild with built-in rubber band support [no]"
  echo -e "  --enable-linux-x265\t\tbuild with built-in x265 support [no]"
  echo -e "  --enable-linux-xvidcore\tbuild with built-in xvidcore support [no]"
  echo -e "  --enable-x264\t\t\tbuild with x264 [no]\n"

  display_help_custom_libraries
  display_help_advanced_options
}

enable_main_build() {
  unset FFMPEG_KIT_LTS_BUILD
}

enable_lts_build() {
  export FFMPEG_KIT_LTS_BUILD="1"
}

get_cmake_system_processor() {
  case ${ARCH} in
  x86-64)
    echo "x86_64"
    ;;
  esac
}

get_target_cpu() {
  case ${ARCH} in
  x86-64)
    echo "x86_64"
    ;;
  esac
}

get_common_includes() {
  echo ""
}

get_common_cflags() {
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    local LTS_BUILD__FLAG="-DFFMPEG_KIT_LTS "
  fi

  echo "-fstrict-aliasing -fPIC -DLINUX ${LTS_BUILD__FLAG} ${LLVM_CONFIG_CFLAGS}"
}

get_arch_specific_cflags() {
  case ${ARCH} in
  x86-64)
    echo "-target $(get_target) -march=x86-64 -msse4.2 -mpopcnt -m64 -DFFMPEG_KIT_X86_64"
    ;;
  esac
}

get_size_optimization_cflags() {
  if [[ -z ${NO_LINK_TIME_OPTIMIZATION} ]]; then
    local LINK_TIME_OPTIMIZATION_FLAGS="-flto"
  else
    local LINK_TIME_OPTIMIZATION_FLAGS=""
  fi

  local ARCH_OPTIMIZATION=""
  case ${ARCH} in
  x86-64)
    case $1 in
    ffmpeg)
      ARCH_OPTIMIZATION="${LINK_TIME_OPTIMIZATION_FLAGS} -Os -ffunction-sections -fdata-sections"
      ;;
    *)
      ARCH_OPTIMIZATION="-Os -ffunction-sections -fdata-sections"
      ;;
    esac
    ;;
  esac

  local LIB_OPTIMIZATION=""

  echo "${ARCH_OPTIMIZATION} ${LIB_OPTIMIZATION}"
}

get_app_specific_cflags() {
  local APP_FLAGS=""
  case $1 in
  ffmpeg)
    APP_FLAGS="-Wno-unused-function -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD"
    ;;
  kvazaar)
    APP_FLAGS="-std=gnu99 -Wno-unused-function"
    ;;
  openh264)
    APP_FLAGS="-std=gnu99 -Wno-unused-function -fstack-protector-all"
    ;;
  openssl | srt)
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
  local COMMON_INCLUDES=$(get_common_includes)

  echo "${ARCH_FLAGS} ${APP_FLAGS} ${COMMON_FLAGS} ${OPTIMIZATION_FLAGS} ${COMMON_INCLUDES}"
}

get_cxxflags() {
  if [[ -z ${NO_LINK_TIME_OPTIMIZATION} ]]; then
    local LINK_TIME_OPTIMIZATION_FLAGS="-flto"
  else
    local LINK_TIME_OPTIMIZATION_FLAGS=""
  fi

  if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
    local OPTIMIZATION_FLAGS="-Os -ffunction-sections -fdata-sections"
  else
    local OPTIMIZATION_FLAGS="${FFMPEG_KIT_DEBUG}"
  fi

  local COMMON_FLAGS="${LLVM_CONFIG_CXXFLAGS} ${OPTIMIZATION_FLAGS}"

  case $1 in
  ffmpeg)
    if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
      echo "${LINK_TIME_OPTIMIZATION_FLAGS} ${LLVM_CONFIG_CXXFLAGS} -O2 -ffunction-sections -fdata-sections"
    else
      echo "${FFMPEG_KIT_DEBUG} ${LLVM_CONFIG_CXXFLAGS}"
    fi
    ;;
  srt | zimg)
    echo "${COMMON_FLAGS} -fcxx-exceptions -fPIC"
    ;;
  *)
    echo "-fno-exceptions -fno-rtti ${COMMON_FLAGS}"
    ;;
  esac
}

get_common_linked_libraries() {
  local COMMON_LIBRARY_PATHS=""

  case $1 in
  ffmpeg)
    echo "-lc -lm -ldl ${COMMON_LIBRARY_PATHS}"
    ;;
  srt)
    echo "-lc -lm -ldl -lstdc++ ${COMMON_LIBRARY_PATHS}"
    ;;
  *)
    echo "-lc -lm -ldl ${COMMON_LIBRARY_PATHS}"
    ;;
  esac
}

get_size_optimization_ldflags() {
  if [[ -z ${NO_LINK_TIME_OPTIMIZATION} ]]; then
    local LINK_TIME_OPTIMIZATION_FLAGS="-flto"
  else
    local LINK_TIME_OPTIMIZATION_FLAGS=""
  fi

  case ${ARCH} in
  x86-64)
    case $1 in
    ffmpeg)
      echo "${LINK_TIME_OPTIMIZATION_FLAGS} -O2 -ffunction-sections -fdata-sections -finline-functions"
      ;;
    *)
      echo "-Os -ffunction-sections -fdata-sections"
      ;;
    esac
    ;;
  esac
}

get_arch_specific_ldflags() {
  case ${ARCH} in
  x86-64)
    echo "-march=x86-64 -Wl,-z,text"
    ;;
  esac
}

get_ldflags() {
  local ARCH_FLAGS=$(get_arch_specific_ldflags)
  if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
    local OPTIMIZATION_FLAGS="$(get_size_optimization_ldflags "$1")"
  else
    local OPTIMIZATION_FLAGS="${FFMPEG_KIT_DEBUG}"
  fi
  local COMMON_LINKED_LIBS=$(get_common_linked_libraries "$1")

  echo "${ARCH_FLAGS} ${OPTIMIZATION_FLAGS} ${COMMON_LINKED_LIBS} ${LLVM_CONFIG_LDFLAGS} -Wl,--hash-style=both -fuse-ld=lld"
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
has_function_printf = true

[host_machine]
system = '$(get_meson_target_host_family)'
cpu_family = '$(get_meson_target_cpu_family)'
cpu = '$(get_cmake_system_processor)'
endian = 'little'

[built-in options]
default_library = 'static'
prefix = '${LIB_INSTALL_PREFIX}'
EOF
}

create_libaom_package_config() {
  local AOM_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/aom.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/libaom
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: aom
Description: AV1 codec library v${AOM_VERSION}.
Version: ${AOM_VERSION}

Requires:
Libs: -L\${libdir} -laom -lm
Cflags: -I\${includedir}
EOF
}

create_srt_package_config() {
  local SRT_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/srt.pc" <<EOF
prefix=${LIB_INSTALL_BASE}/srt
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: srt
Description: SRT library set
Version: ${SRT_VERSION}

Libs: -L\${libdir} -lsrt
Libs.private: -lc -lm -ldl -lstdc++
Cflags: -I\${includedir} -I\${includedir}/srt
Requires: openssl libcrypto
EOF
}

create_zimg_package_config() {
  local ZIMG_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/zimg.pc" <<EOF
prefix=${LIB_INSTALL_BASE}/zimg
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: zimg
Description: Scaling, colorspace conversion, and dithering library
Version: ${ZIMG_VERSION}

Libs: -L\${libdir} -lzimg -lstdc++
Cflags: -I\${includedir}
EOF
}

get_build_directory() {
  local LTS_POSTFIX=""
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    LTS_POSTFIX="-lts"
  fi

  echo "linux-$(get_target_cpu)${LTS_POSTFIX}"
}

detect_clang_version() {
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    for clang_version in 6 .. 10; do
      if [[ $(command_exists "clang-$clang_version") -eq 0 ]]; then
        echo "$clang_version"
        return
      elif [[ $(command_exists "clang-$clang_version.0") -eq 0 ]]; then
        echo "$clang_version.0"
        return
      fi
    done
    echo "none"
  else
    for clang_version in 11 .. 20; do
      if [[ $(command_exists "clang-$clang_version") -eq 0 ]]; then
        echo "$clang_version"
        return
      elif [[ $(command_exists "clang-$clang_version.0") -eq 0 ]]; then
        echo "$clang_version.0"
        return
      fi
    done
    echo "none"
  fi
}

set_toolchain_paths() {
  HOST=$(get_host)
  CLANG_VERSION=$(detect_clang_version)

  if [[ $CLANG_VERSION != "none" ]]; then
    local CLANG_POSTFIX="-$CLANG_VERSION"
    export LLVM_CONFIG_CFLAGS=$(llvm-config-$CLANG_VERSION --cflags 2>>"${BASEDIR}"/build.log)
    export LLVM_CONFIG_CXXFLAGS=$(llvm-config-$CLANG_VERSION --cxxflags 2>>"${BASEDIR}"/build.log)
    export LLVM_CONFIG_LDFLAGS=$(llvm-config-$CLANG_VERSION --ldflags 2>>"${BASEDIR}"/build.log)
  else
    local CLANG_POSTFIX=""
    export LLVM_CONFIG_CFLAGS=$(llvm-config --cflags 2>>"${BASEDIR}"/build.log)
    export LLVM_CONFIG_CXXFLAGS=$(llvm-config --cxxflags 2>>"${BASEDIR}"/build.log)
    export LLVM_CONFIG_LDFLAGS=$(llvm-config --ldflags 2>>"${BASEDIR}"/build.log)
  fi

  export CC=$(command -v "clang$CLANG_POSTFIX")
  export CXX=$(command -v "clang++$CLANG_POSTFIX")
  export AS=$(command -v "llvm-as$CLANG_POSTFIX")
  export AR=$(command -v "llvm-ar$CLANG_POSTFIX")
  export LD=$(command -v "ld.lld$CLANG_POSTFIX")
  export RANLIB=$(command -v "llvm-ranlib$CLANG_POSTFIX")
  export STRIP=$(command -v "llvm-strip$CLANG_POSTFIX")
  export NM=$(command -v "llvm-nm$CLANG_POSTFIX")
  export INSTALL_PKG_CONFIG_DIR="${BASEDIR}"/prebuilt/$(get_build_directory)/pkgconfig
  export ZLIB_PACKAGE_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}/zlib.pc"

  if [ ! -d "${INSTALL_PKG_CONFIG_DIR}" ]; then
    mkdir -p "${INSTALL_PKG_CONFIG_DIR}" 1>>"${BASEDIR}"/build.log 2>&1
  fi
}
