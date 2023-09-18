#!/bin/bash

source "${BASEDIR}/scripts/function.sh"

prepare_inline_sed

enable_default_android_architectures() {
  ENABLED_ARCHITECTURES[ARCH_ARM_V7A]=1
  ENABLED_ARCHITECTURES[ARCH_ARM_V7A_NEON]=1
  ENABLED_ARCHITECTURES[ARCH_ARM64_V8A]=1
  ENABLED_ARCHITECTURES[ARCH_X86]=1
  ENABLED_ARCHITECTURES[ARCH_X86_64]=1
}

enable_default_android_libraries() {
  ENABLED_LIBRARIES[LIBRARY_CPU_FEATURES]=1
}

get_ffmpeg_kit_version() {
  local FFMPEG_KIT_VERSION=$(grep '#define FFMPEG_KIT_VERSION' "${BASEDIR}"/android/ffmpeg-kit-android-lib/src/main/cpp/ffmpegkit.h | grep -Eo '\".*\"' | sed -e 's/\"//g')

  echo "${FFMPEG_KIT_VERSION}"
}

display_help() {
  local COMMAND=$(echo "$0" | sed -e 's/\.\///g')

  echo -e "\n'$COMMAND' builds FFmpegKit for Android platform. By default five Android architectures (armeabi-v7a, \
armeabi-v7a-neon, arm64-v8a, x86 and x86_64) are built without any external libraries enabled. Options can be used to \
disable architectures and/or enable external libraries. Please note that GPL libraries (external libraries with GPL \
license) need --enable-gpl flag to be set explicitly. When compilation ends an Android Archive (AAR) file is created \
under the prebuilt folder.\n"
  echo -e "Usage: ./$COMMAND [OPTION]... [VAR=VALUE]...\n"
  echo -e "Specify environment variables as VARIABLE=VALUE to override default build options.\n"

  display_help_options "  -l, --lts\t\t\tbuild lts packages to support API 16+ devices" "      --api-level=api\t\toverride Android api level" "      --no-ffmpeg-kit-protocols\tdisable custom ffmpeg-kit protocols (saf)"
  display_help_licensing

  echo -e "Architectures:"
  echo -e "  --disable-arm-v7a\t\tdo not build arm-v7a architecture [yes]"
  echo -e "  --disable-arm-v7a-neon\tdo not build arm-v7a-neon architecture [yes]"
  echo -e "  --disable-arm64-v8a\t\tdo not build arm64-v8a architecture [yes]"
  echo -e "  --disable-x86\t\t\tdo not build x86 architecture [yes]"
  echo -e "  --disable-x86-64\t\tdo not build x86-64 architecture [yes]\n"

  echo -e "Libraries:"
  echo -e "  --full\t\t\tenables all external libraries"
  echo -e "  --enable-android-media-codec\tbuild with built-in Android MediaCodec support [no]"
  echo -e "  --enable-android-zlib\t\tbuild with built-in zlib support [no]"

  display_help_common_libraries
  display_help_gpl_libraries
  display_help_custom_libraries
  display_help_advanced_options "  --no-archive\t\t\tdo not build Android archive [no]"
}

enable_main_build() {
  export API=24
}

enable_lts_build() {
  export FFMPEG_KIT_LTS_BUILD="1"

  # LTS RELEASES USE API LEVEL 16 / Android 4.1 (JELLY BEAN)
  export API=16
}

build_application_mk() {
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    local LTS_BUILD_FLAG="-DFFMPEG_KIT_LTS "
  fi

  if [[ ${ENABLED_LIBRARIES[$LIBRARY_X265]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_TESSERACT]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_OPENH264]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_SNAPPY]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_RUBBERBAND]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_ZIMG]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_SRT]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_CHROMAPRINT]} -eq 1 ]] || [[ ${ENABLED_LIBRARIES[$LIBRARY_LIBILBC]} -eq 1 ]] || [[ -n ${CUSTOM_LIBRARY_USES_CPP} ]]; then
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

get_clang_host() {
  case ${ARCH} in
  arm-v7a | arm-v7a-neon)
    echo "armv7a-linux-androideabi${API}"
    ;;
  arm64-v8a)
    echo "aarch64-linux-android${API}"
    ;;
  x86)
    echo "i686-linux-android${API}"
    ;;
  x86-64)
    echo "x86_64-linux-android${API}"
    ;;
  esac
}

is_darwin_arm64() {
  HOST_OS=$(uname -s)
  HOST_ARCH=$(uname -m)

  if [ "${HOST_OS}" == "Darwin" ] && [ "${HOST_ARCH}" == "arm64" ]; then
    echo "1"
  else
    echo "0"
  fi
}

get_toolchain() {
  HOST_OS=$(uname -s)
  case ${HOST_OS} in
  Darwin) HOST_OS=darwin ;;
  Linux) HOST_OS=linux ;;
  FreeBsd) HOST_OS=freebsd ;;
  CYGWIN* | *_NT-*) HOST_OS=cygwin ;;
  esac

  HOST_ARCH=$(uname -m)
  case ${HOST_ARCH} in
  i?86) HOST_ARCH=x86 ;;
  x86_64 | amd64) HOST_ARCH=x86_64 ;;
  esac

  if [ "$(is_darwin_arm64)" == "1" ]; then
    # NDK DOESNT HAVE AN ARM64 TOOLCHAIN ON DARWIN
    # WE USE x86-64 WITH ROSETTA INSTEAD
    HOST_ARCH=x86_64
  fi

  echo "${HOST_OS}-${HOST_ARCH}"
}

get_cmake_system_processor() {
  case ${ARCH} in
  arm-v7a | arm-v7a-neon)
    echo "arm"
    ;;
  arm64-v8a)
    echo "aarch64"
    ;;
  x86)
    echo "x86"
    ;;
  x86-64)
    echo "x86_64"
    ;;
  esac
}

get_target_cpu() {
  case ${ARCH} in
  arm-v7a)
    echo "arm"
    ;;
  arm-v7a-neon)
    echo "arm-neon"
    ;;
  arm64-v8a)
    echo "arm64"
    ;;
  x86)
    echo "x86"
    ;;
  x86-64)
    echo "x86_64"
    ;;
  esac
}

get_toolchain_arch() {
  case ${ARCH} in
  arm-v7a | arm-v7a-neon)
    echo "arm"
    ;;
  arm64-v8a)
    echo "arm64"
    ;;
  x86)
    echo "x86"
    ;;
  x86-64)
    echo "x86_64"
    ;;
  esac
}

get_android_arch() {
  case $1 in
  0 | 1)
    echo "armeabi-v7a"
    ;;
  2)
    echo "arm64-v8a"
    ;;
  3)
    echo "x86"
    ;;
  4)
    echo "x86_64"
    ;;
  esac
}

get_common_includes() {
  echo ""
}

get_common_cflags() {
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    local LTS_BUILD_FLAG="-DFFMPEG_KIT_LTS "
  fi

  if [[ $(compare_versions "$DETECTED_NDK_VERSION" "23") -ge 0 ]]; then
    echo "-fstrict-aliasing -DANDROID_NDK -fPIC -DANDROID ${LTS_BUILD_FLAG}-D__ANDROID__ -D__ANDROID_MIN_SDK_VERSION__=${API}"
  else
    echo "-fno-integrated-as -fstrict-aliasing -DANDROID_NDK -fPIC -DANDROID ${LTS_BUILD_FLAG}-D__ANDROID__ -D__ANDROID_API__=${API}"
  fi
}

get_arch_specific_cflags() {
  case ${ARCH} in
  arm-v7a)
    echo "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -DFFMPEG_KIT_ARM_V7A"
    ;;
  arm-v7a-neon)
    echo "-march=armv7-a -mfpu=neon -mfloat-abi=softfp -DFFMPEG_KIT_ARM_V7A_NEON"
    ;;
  arm64-v8a)
    echo "-march=armv8-a -DFFMPEG_KIT_ARM64_V8A"
    ;;
  x86)
    if [[ $(compare_versions "$DETECTED_NDK_VERSION" "23") -ge 0 ]]; then
      echo "-march=i686 -mtune=generic -mssse3 -mfpmath=sse -m32 -DFFMPEG_KIT_X86"
    else
      echo "-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32 -DFFMPEG_KIT_X86"
    fi
    ;;
  x86-64)
    if [[ $(compare_versions "$DETECTED_NDK_VERSION" "23") -ge 0 ]]; then
      echo "-march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=generic -DFFMPEG_KIT_X86_64"
    else
      echo "-march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -DFFMPEG_KIT_X86_64"
    fi
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
  arm-v7a | arm-v7a-neon)
    case $1 in
    ffmpeg)
      ARCH_OPTIMIZATION="${LINK_TIME_OPTIMIZATION_FLAGS} -O2 -ffunction-sections -fdata-sections"
      ;;
    *)
      ARCH_OPTIMIZATION="-Os -ffunction-sections -fdata-sections"
      ;;
    esac
    ;;
  arm64-v8a)
    case $1 in
    ffmpeg)
      ARCH_OPTIMIZATION="${LINK_TIME_OPTIMIZATION_FLAGS} -fuse-ld=lld -O2 -ffunction-sections -fdata-sections"
      ;;
    *)
      ARCH_OPTIMIZATION="-Os -ffunction-sections -fdata-sections"
      ;;
    esac
    ;;
  x86 | x86-64)
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
  xvidcore)
    APP_FLAGS=""
    ;;
  ffmpeg)
    APP_FLAGS="-Wno-unused-function -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD"
    ;;
  gnutls)
    APP_FLAGS="-std=c99 -Wno-unused-function -D_GL_USE_STDLIB_ALLOC=1"
    ;;
  kvazaar)
    APP_FLAGS="-std=gnu99 -Wno-unused-function"
    ;;
  openh264)
    APP_FLAGS="-std=gnu99 -Wno-unused-function -fstack-protector-all"
    ;;
  rubberband)
    APP_FLAGS="-std=c99 -Wno-unused-function"
    ;;
  libvpx | openssl | shine | srt)
    APP_FLAGS="-Wno-unused-function"
    ;;
  soxr | snappy | libwebp)
    APP_FLAGS="-std=gnu99 -Wno-unused-function -DPIC"
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

  case $1 in
  gnutls)
    echo "-std=c++11 -fno-rtti ${OPTIMIZATION_FLAGS}"
    ;;
  ffmpeg)
    if [[ -z ${FFMPEG_KIT_DEBUG} ]]; then
      echo "-std=c++11 -fno-exceptions -fno-rtti ${LINK_TIME_OPTIMIZATION_FLAGS} -O2 -ffunction-sections -fdata-sections"
    else
      echo "-std=c++11 -fno-exceptions -fno-rtti ${FFMPEG_KIT_DEBUG}"
    fi
    ;;
  opencore-amr)
    echo "${OPTIMIZATION_FLAGS}"
    ;;
  x265)
    echo "-std=c++11 -fno-exceptions ${OPTIMIZATION_FLAGS}"
    ;;
  rubberband | srt | tesseract | zimg)
    echo "-std=c++11 ${OPTIMIZATION_FLAGS}"
    ;;
  *)
    echo "-std=c++11 -fno-exceptions -fno-rtti ${OPTIMIZATION_FLAGS}"
    ;;
  esac
}

get_common_linked_libraries() {
  local COMMON_LIBRARY_PATHS="-L${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/${HOST}/lib -L${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot/usr/lib/${HOST}/${API} -L${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/lib"

  case $1 in
  ffmpeg)

    # SUPPORTED ON API LEVEL 24 AND LATER
    if [[ ${API} -ge 24 ]]; then
      echo "-lc -lm -ldl -llog -landroid -lcamera2ndk -lmediandk ${COMMON_LIBRARY_PATHS}"
    else
      echo "-lc -lm -ldl -llog -landroid ${COMMON_LIBRARY_PATHS}"
      echo -e "INFO: Building ffmpeg without native camera API which is not supported on Android API Level ${API}\n" 1>>"${BASEDIR}"/build.log 2>&1
    fi
    ;;
  libvpx)
    echo "-lc -lm ${COMMON_LIBRARY_PATHS}"
    ;;
  srt | tesseract | x265)
    echo "-lc -lm -ldl -llog -lc++_shared ${COMMON_LIBRARY_PATHS}"
    ;;
  *)
    echo "-lc -lm -ldl -llog ${COMMON_LIBRARY_PATHS}"
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
  arm64-v8a)
    case $1 in
    ffmpeg)
      echo "-Wl,--gc-sections ${LINK_TIME_OPTIMIZATION_FLAGS} -fuse-ld=lld -O2 -ffunction-sections -fdata-sections -finline-functions"
      ;;
    *)
      echo "-Wl,--gc-sections -Os -ffunction-sections -fdata-sections"
      ;;
    esac
    ;;
  *)
    case $1 in
    ffmpeg)
      echo "-Wl,--gc-sections,--icf=safe ${LINK_TIME_OPTIMIZATION_FLAGS} -O2 -ffunction-sections -fdata-sections -finline-functions"
      ;;
    *)
      echo "-Wl,--gc-sections,--icf=safe -Os -ffunction-sections -fdata-sections"
      ;;
    esac
    ;;
  esac
}

get_arch_specific_ldflags() {
  case ${ARCH} in
  arm-v7a)
    echo "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wl,--fix-cortex-a8"
    ;;
  arm-v7a-neon)
    echo "-march=armv7-a -mfpu=neon -mfloat-abi=softfp -Wl,--fix-cortex-a8"
    ;;
  arm64-v8a)
    echo "-march=armv8-a"
    ;;
  x86)
    echo "-march=i686"
    ;;
  x86-64)
    echo "-march=x86-64"
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

  echo "${ARCH_FLAGS} ${OPTIMIZATION_FLAGS} ${COMMON_LINKED_LIBS} -Wl,--hash-style=both -Wl,--exclude-libs,libgcc.a -Wl,--exclude-libs,libunwind.a"
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
sys_root = '$ANDROID_SYSROOT'
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

create_chromaprint_package_config() {
  local CHROMAPRINT_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/libchromaprint.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/chromaprint
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: chromaprint
Description: Audio fingerprint library
URL: http://acoustid.org/chromaprint
Version: ${CHROMAPRINT_VERSION}
Libs: -L\${libdir} -lchromaprint
Cflags: -I\${includedir}
EOF
}

create_fontconfig_package_config() {
  local FONTCONFIG_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/fontconfig.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/fontconfig
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
prefix="${LIB_INSTALL_BASE}"/freetype
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: FreeType 2
URL: https://freetype.org
Description: A free, high-quality, and portable font engine.
Version: ${FREETYPE_VERSION}
Requires: libpng
Requires.private: zlib
Libs: -L\${libdir} -lfreetype
Libs.private:
Cflags: -I\${includedir}/freetype2
EOF
}

create_giflib_package_config() {
  local GIFLIB_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/giflib.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/giflib
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
prefix="${LIB_INSTALL_BASE}"/gmp
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
prefix="${LIB_INSTALL_BASE}"/gnutls
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: gnutls
Description: GNU TLS Implementation

Version: ${GNUTLS_VERSION}
Requires: nettle, hogweed, zlib
Cflags: -I\${includedir}
Libs: -L\${libdir} -lgnutls
Libs.private: -lgmp
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

create_libiconv_package_config() {
  local LIB_ICONV_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/libiconv.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/libiconv
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

create_libmp3lame_package_config() {
  local LAME_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/libmp3lame.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/lame
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

create_libvorbis_package_config() {
  local LIBVORBIS_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/vorbis.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/libvorbis
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
prefix="${LIB_INSTALL_BASE}"/libvorbis
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
prefix="${LIB_INSTALL_BASE}"/libvorbis
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
prefix="${LIB_INSTALL_BASE}"/libxml2
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
prefix="${LIB_INSTALL_BASE}"/snappy
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
prefix="${LIB_INSTALL_BASE}"/soxr
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
Libs.private: -lc -lm -ldl -llog -lc++_shared
Cflags: -I\${includedir} -I\${includedir}/srt
Requires.private: openssl libcrypto
EOF
}

create_tesseract_package_config() {
  local TESSERACT_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/tesseract.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/tesseract
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

Requires: lept, libjpeg, libpng, giflib, zlib, libwebp, libtiff-4
Libs: -L\${libdir} -ltesseract -lc++_shared
Cflags: -I\${includedir}
EOF
}

create_uuid_package_config() {
  local UUID_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/uuid.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/libuuid
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: uuid
Description: Universally unique id library
Version: ${UUID_VERSION}
Requires:
Cflags: -I\${includedir}
Libs: -L\${libdir} -luuid
EOF
}

create_x265_package_config() {
  local X265_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/x265.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/x265
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: x265
Description: H.265/HEVC video encoder
Version: ${X265_VERSION}

Libs: -L\${libdir} -lx265
Libs.private: -lm -ldl -llog -lm -lc++_shared
Cflags: -I\${includedir}
EOF
}

create_xvidcore_package_config() {
  local XVIDCORE_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/xvidcore.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/xvidcore
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

Libs: -L\${libdir} -lzimg -lc++_shared
Cflags: -I\${includedir}
EOF
}

create_zlib_system_package_config() {
  ZLIB_VERSION=$(grep '#define ZLIB_VERSION' "${ANDROID_NDK_ROOT}"/toolchains/llvm/prebuilt/"${TOOLCHAIN}"/sysroot/usr/include/zlib.h | grep -Eo '\".*\"' | sed -e 's/\"//g')

  cat >"${INSTALL_PKG_CONFIG_DIR}/zlib.pc" <<EOF
prefix="${ANDROID_SYSROOT}"/usr
exec_prefix=\${prefix}
libdir=${ANDROID_NDK_ROOT}/platforms/android-${API}/arch-${TOOLCHAIN_ARCH}/usr/lib
includedir=\${prefix}/include

Name: zlib
Description: zlib compression library
Version: ${ZLIB_VERSION}

Requires:
Libs: -L\${libdir} -lz
Cflags: -I\${includedir}
EOF
}

create_cpufeatures_package_config() {
  local CPU_FEATURES_VERSION="$1"

  cat >"${INSTALL_PKG_CONFIG_DIR}/cpu-features.pc" <<EOF
prefix="${LIB_INSTALL_BASE}"/cpu-features
exec_prefix=\${prefix}/bin
libdir=\${prefix}/lib
includedir=\${prefix}/include/ndk_compat

Name: cpufeatures
URL: https://github.com/google/cpu_features
Description: cpu_features Android compatibility library
Version: ${CPU_FEATURES_VERSION}

Requires:
Libs: -L\${libdir} -lndk_compat
Cflags: -I\${includedir}
EOF
}

# Maps current architecture to one of the ABIs supported in $ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake
# and returns it
get_android_cmake_ndk_abi() {
  case ${ARCH} in
  arm-v7a | arm-v7a-neon)
    echo "armeabi-v7a"
    ;;
  arm64-v8a)
    echo "arm64-v8a"
    ;;
  x86)
    echo "x86"
    ;;
  x86-64)
    echo "x86_64"
    ;;
  esac
}

get_build_directory() {
  local LTS_POSTFIX=""
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    LTS_POSTFIX="-lts"
  fi

  echo "android-$(get_target_cpu)${LTS_POSTFIX}"
}

get_aar_directory() {
  local LTS_POSTFIX=""
  if [[ -n ${FFMPEG_KIT_LTS_BUILD} ]]; then
    LTS_POSTFIX="-lts"
  fi

  echo "bundle-android-aar${LTS_POSTFIX}"
}

android_ndk_cmake() {
  local cmake=$(find "${ANDROID_SDK_ROOT}"/cmake -path \*/bin/cmake -type f -print -quit)
  if [[ -z ${cmake} ]]; then
    cmake=$(which cmake)
  fi
  if [[ -z ${cmake} ]]; then
    cmake="missing_cmake"
  fi

  # SET BUILD OPTIONS
  ASM_OPTIONS=""
  case ${ARCH} in
  arm-v7a-neon)
    ASM_OPTIONS="-DANDROID_ABI=$(get_android_cmake_ndk_abi) -DANDROID_ARM_NEON=TRUE"
    ;;
  *)
    ASM_OPTIONS="-DANDROID_ABI=$(get_android_cmake_ndk_abi)"
    ;;
  esac

  echo ${cmake} \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_ROOT}"/build/cmake/android.toolchain.cmake \
    -DCMAKE_SYSROOT="${ANDROID_SYSROOT}" \
    -DCMAKE_FIND_ROOT_PATH="${ANDROID_SYSROOT}" \
    -DCMAKE_INSTALL_PREFIX="${LIB_INSTALL_PREFIX}" \
    -H"${BASEDIR}"/src/"${LIB_NAME}" \
    -B"${BUILD_DIR}" \
    "${ASM_OPTIONS}" \
    -DANDROID_PLATFORM=android-"${API}"
}

set_toolchain_paths() {
  export PATH=$PATH:${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin

  HOST=$(get_host)

  export CC=$(get_clang_host)-clang
  export CXX=$(get_clang_host)-clang++

  case ${ARCH} in
  arm64-v8a)
    export ac_cv_c_bigendian=no
    ;;
  esac
  if [[ $(compare_versions "$DETECTED_NDK_VERSION" "23") -ge 0 ]]; then
    export AR=llvm-ar
    export LD=lld
    export RANLIB=llvm-ranlib
    export STRIP=llvm-strip
    export NM=llvm-nm
    export AS=$CC
  else
    export AR=${HOST}-ar
    export LD=${HOST}-ld
    export RANLIB=${HOST}-ranlib
    export STRIP=${HOST}-strip
    export NM=${HOST}-nm
    if [ "$1" == "x264" ]; then
      export AS=${CC}
    else
      export AS=${HOST}-as
    fi
  fi
  export INSTALL_PKG_CONFIG_DIR="${BASEDIR}"/prebuilt/$(get_build_directory)/pkgconfig
  export ZLIB_PACKAGE_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}/zlib.pc"

  if [ ! -d "${INSTALL_PKG_CONFIG_DIR}" ]; then
    mkdir -p "${INSTALL_PKG_CONFIG_DIR}" 1>>"${BASEDIR}"/build.log 2>&1
  fi

  if [ ! -f "${ZLIB_PACKAGE_CONFIG_PATH}" ]; then
    create_zlib_system_package_config 1>>"${BASEDIR}"/build.log 2>&1
  fi
}

build_android_lts_support() {

  # CLEAN OLD BUILD
  rm -f "${BASEDIR}"/android/ffmpeg-kit-android-lib/src/main/cpp/android_lts_support.o 1>>"${BASEDIR}"/build.log 2>&1
  rm -f "${BASEDIR}"/android/ffmpeg-kit-android-lib/src/main/cpp/android_lts_support.a 1>>"${BASEDIR}"/build.log 2>&1

  echo -e "INFO: Building android-lts-support objects for ${ARCH}\n" 1>>"${BASEDIR}"/build.log 2>&1

  # PREPARE PATHS
  LIB_NAME="android-lts-support"
  set_toolchain_paths ${LIB_NAME}

  # PREPARE FLAGS
  HOST=$(get_host)
  CFLAGS=$(get_cflags "${LIB_NAME}")
  LDFLAGS=$(get_ldflags ${LIB_NAME})

  # BUILD
  "${CC}" ${CFLAGS} -Wno-unused-command-line-argument -c "${BASEDIR}"/android/ffmpeg-kit-android-lib/src/main/cpp/android_lts_support.c -o "${BASEDIR}"/android/ffmpeg-kit-android-lib/src/main/cpp/android_lts_support.o ${LDFLAGS} 1>>"${BASEDIR}"/build.log 2>&1
  "${AR}" rcs "${BASEDIR}"/android/ffmpeg-kit-android-lib/src/main/cpp/libandroidltssupport.a "${BASEDIR}"/android/ffmpeg-kit-android-lib/src/main/cpp/android_lts_support.o 1>>"${BASEDIR}"/build.log 2>&1
}
