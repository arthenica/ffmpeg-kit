#!/bin/bash

source "${BASEDIR}/scripts/common-arch.sh"

get_clang_target_host() {
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

get_toolchain() {
    HOST_OS=$(uname -s)
    case ${HOST_OS} in
        Darwin) HOST_OS=darwin;;
        Linux) HOST_OS=linux;;
        FreeBsd) HOST_OS=freebsd;;
        CYGWIN*|*_NT-*) HOST_OS=cygwin;;
    esac

    HOST_ARCH=$(uname -m)
    case ${HOST_ARCH} in
        i?86) HOST_ARCH=x86;;
        x86_64|amd64) HOST_ARCH=x86_64;;
    esac

    echo "${HOST_OS}-${HOST_ARCH}"
}

get_cmake_target_processor() {
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

get_target_build() {
    case ${ARCH} in
        arm-v7a)
            echo "arm"
        ;;
        arm-v7a-neon)
            if [[ ! -z ${MOBILE_FFMPEG_LTS_BUILD} ]]; then
                echo "arm/neon"
            else
                echo "arm"
            fi
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
    if [[ ! -z ${MOBILE_FFMPEG_LTS_BUILD} ]]; then
        local LTS_BUILD__FLAG="-DMOBILE_FFMPEG_LTS "
    fi

    echo "-fno-integrated-as -fstrict-aliasing -fPIC -DANDROID ${LTS_BUILD__FLAG}-D__ANDROID__ -D__ANDROID_API__=${API}"
}

get_arch_specific_cflags() {
    case ${ARCH} in
        arm-v7a)
            echo "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -DMOBILE_FFMPEG_ARM_V7A"
        ;;
        arm-v7a-neon)
            echo "-march=armv7-a -mfpu=neon -mfloat-abi=softfp -DMOBILE_FFMPEG_ARM_V7A_NEON"
        ;;
        arm64-v8a)
            echo "-march=armv8-a -DMOBILE_FFMPEG_ARM64_V8A"
        ;;
        x86)
            echo "-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32 -DMOBILE_FFMPEG_X86"
        ;;
        x86-64)
            echo "-march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -DMOBILE_FFMPEG_X86_64"
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
                    ARCH_OPTIMIZATION="${LINK_TIME_OPTIMIZATION_FLAGS} -fuse-ld=gold -O2 -ffunction-sections -fdata-sections"
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
        kvazaar)
            APP_FLAGS="-std=gnu99 -Wno-unused-function"
        ;;
        rubberband)
            APP_FLAGS="-std=c99 -Wno-unused-function"
        ;;
        shine)
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
    local APP_FLAGS=$(get_app_specific_cflags $1)
    local COMMON_FLAGS=$(get_common_cflags)
    if [[ -z ${MOBILE_FFMPEG_DEBUG} ]]; then
        local OPTIMIZATION_FLAGS=$(get_size_optimization_cflags $1)
    else
        local OPTIMIZATION_FLAGS="${MOBILE_FFMPEG_DEBUG}"
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

    if [[ -z ${MOBILE_FFMPEG_DEBUG} ]]; then
        local OPTIMIZATION_FLAGS="-Os -ffunction-sections -fdata-sections"
    else
        local OPTIMIZATION_FLAGS="${MOBILE_FFMPEG_DEBUG}"
    fi

    case $1 in
        gnutls)
            echo "-std=c++11 -fno-rtti ${OPTIMIZATION_FLAGS}"
        ;;
        ffmpeg)
            if [[ -z ${MOBILE_FFMPEG_DEBUG} ]]; then
                echo "-std=c++11 -fno-exceptions -fno-rtti ${LINK_TIME_OPTIMIZATION_FLAGS} -O2 -ffunction-sections -fdata-sections"
            else
                echo "-std=c++11 -fno-exceptions -fno-rtti ${MOBILE_FFMPEG_DEBUG}"
            fi
        ;;
        opencore-amr)
            echo "${OPTIMIZATION_FLAGS}"
        ;;
        x265)
            echo "-std=c++11 -fno-exceptions ${OPTIMIZATION_FLAGS}"
        ;;
        rubberband)
            echo "-std=c++11 ${OPTIMIZATION_FLAGS}"
        ;;
        *)
            echo "-std=c++11 -fno-exceptions -fno-rtti ${OPTIMIZATION_FLAGS}"
        ;;
    esac
}

get_common_linked_libraries() {
    local COMMON_LIBRARY_PATHS="-L${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/${BUILD_HOST}/lib -L${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot/usr/lib/${BUILD_HOST}/${API} -L${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/lib"

    case $1 in
        ffmpeg)
            if [[ -z ${MOBILE_FFMPEG_LTS_BUILD} ]]; then
                echo "-lc -lm -ldl -llog -lcamera2ndk -lmediandk ${COMMON_LIBRARY_PATHS}"
            else
                echo "-lc -lm -ldl -llog ${COMMON_LIBRARY_PATHS}"
            fi
        ;;
        libvpx)
            echo "-lc -lm ${COMMON_LIBRARY_PATHS}"
        ;;
        tesseract | x265)
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
                    echo "-Wl,--gc-sections ${LINK_TIME_OPTIMIZATION_FLAGS} -fuse-ld=gold -O2 -ffunction-sections -fdata-sections -finline-functions"
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
    if [[ -z ${MOBILE_FFMPEG_DEBUG} ]]; then
        local OPTIMIZATION_FLAGS="$(get_size_optimization_ldflags $1)"
    else
        local OPTIMIZATION_FLAGS="${MOBILE_FFMPEG_DEBUG}"
    fi
    local COMMON_LINKED_LIBS=$(get_common_linked_libraries $1)

    echo "${ARCH_FLAGS} ${OPTIMIZATION_FLAGS} ${COMMON_LINKED_LIBS} -Wl,--hash-style=both -Wl,--exclude-libs,libgcc.a -Wl,--exclude-libs,libunwind.a"
}

create_chromaprint_package_config() {
    local CHROMAPRINT_VERSION="$1"

    cat > "${INSTALL_PKG_CONFIG_DIR}/libchromaprint.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/chromaprint
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/fontconfig.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/fontconfig
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/freetype2.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/freetype
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/giflib.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/giflib
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/gmp.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/gmp
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/gnutls.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/gnutls
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/aom.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/libaom
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/libiconv.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/libiconv
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/libmp3lame.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/lame
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/vorbis.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/libvorbis
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

cat > "${INSTALL_PKG_CONFIG_DIR}/vorbisenc.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/libvorbis
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

cat > "${INSTALL_PKG_CONFIG_DIR}/vorbisfile.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/libvorbis
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/libxml-2.0.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/libxml2
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/snappy.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/snappy
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/soxr.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/soxr
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/tesseract.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/tesseract
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/uuid.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/libuuid
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

    cat > "${INSTALL_PKG_CONFIG_DIR}/x265.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/x265
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: x265
Description: H.265/HEVC video encoder
Version: ${X265_VERSION}

Requires:
Libs: -L\${libdir} -lx265
Libs.private: -lm -lgcc -lgcc -ldl -lgcc -lgcc -ldl -lc++_shared
Cflags: -I\${includedir}
EOF
}

create_xvidcore_package_config() {
    local XVIDCORE_VERSION="$1"

    cat > "${INSTALL_PKG_CONFIG_DIR}/xvidcore.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/xvidcore
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
    ZLIB_VERSION=$(grep '#define ZLIB_VERSION' ${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot/usr/include/zlib.h | grep -Eo '\".*\"' | sed -e 's/\"//g')

    cat > "${INSTALL_PKG_CONFIG_DIR}/zlib.pc" << EOF
prefix=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot/usr
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
    cat > "${INSTALL_PKG_CONFIG_DIR}/cpu-features.pc" << EOF
prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/cpu-features
exec_prefix=\${prefix}/bin
libdir=\${prefix}/lib
includedir=\${prefix}/include/ndk_compat

Name: cpufeatures
URL: https://github.com/google/cpu_features
Description: cpu_features Android compatibility library
Version: 1.${API}

Requires:
Libs: -L\${libdir} -lndk_compat
Cflags: -I\${includedir}
EOF
}

android_ndk_abi() { # to be used with CMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake
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

android_build_dir() {
  echo ${BASEDIR}/android/build/${LIB_NAME}/$(get_target_build)
}

android_ndk_cmake() {
    local cmake=$(find ${ANDROID_HOME}/cmake -path \*/bin/cmake -type f -print -quit)
    if [[ -z ${cmake} ]]; then
        cmake=$(which cmake)
    fi
    if [[ -z ${cmake} ]]; then
        cmake="missing_cmake"
    fi

    echo ${cmake} \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
  -H${BASEDIR}/src/${LIB_NAME} \
  -B$(android_build_dir) \
  -DANDROID_ABI=$(android_ndk_abi) \
  -DANDROID_PLATFORM=android-${API} \
  -DCMAKE_INSTALL_PREFIX=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME}
}

set_toolchain_clang_paths() {
    export PATH=$PATH:${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/bin

    BUILD_HOST=$(get_build_host)
    
    export AR=${BUILD_HOST}-ar
    export CC=$(get_clang_target_host)-clang
    export CXX=$(get_clang_target_host)-clang++

    if [ "$1" == "x264" ]; then
        export AS=${CC}
    else
        export AS=${BUILD_HOST}-as
    fi

    case ${ARCH} in
        arm64-v8a)
            export ac_cv_c_bigendian=no
        ;;
    esac

    export LD=${BUILD_HOST}-ld
    export RANLIB=${BUILD_HOST}-ranlib
    export STRIP=${BUILD_HOST}-strip

    export INSTALL_PKG_CONFIG_DIR="${BASEDIR}/prebuilt/android-$(get_target_build)/pkgconfig"
    export ZLIB_PACKAGE_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}/zlib.pc"

    if [ ! -d ${INSTALL_PKG_CONFIG_DIR} ]; then
        mkdir -p ${INSTALL_PKG_CONFIG_DIR}
    fi

    if [ ! -f ${ZLIB_PACKAGE_CONFIG_PATH} ]; then
        create_zlib_system_package_config
    fi

    prepare_inline_sed
}

build_android_lts_support() {

    # CLEAN OLD BUILD
    rm -f ${BASEDIR}/android/app/src/main/cpp/android_lts_support.o 1>>${BASEDIR}/build.log 2>&1
    rm -f ${BASEDIR}/android/app/src/main/cpp/android_lts_support.a 1>>${BASEDIR}/build.log 2>&1

    echo -e "INFO: Building android-lts-support objects for ${ARCH}\n" 1>>${BASEDIR}/build.log 2>&1

    # PREPARING PATHS
    LIB_NAME="android-lts-support"
    set_toolchain_clang_paths ${LIB_NAME}

    # PREPARING FLAGS
    BUILD_HOST=$(get_build_host)
    CFLAGS=$(get_cflags ${LIB_NAME})
    LDFLAGS=$(get_ldflags ${LIB_NAME})

    # THEN BUILD FOR THIS ABI
    $(get_clang_target_host)-clang ${CFLAGS} -Wno-unused-command-line-argument -c ${BASEDIR}/android/app/src/main/cpp/android_lts_support.c -o ${BASEDIR}/android/app/src/main/cpp/android_lts_support.o ${LDFLAGS} 1>>${BASEDIR}/build.log 2>&1
    ${BUILD_HOST}-ar rcs ${BASEDIR}/android/app/src/main/cpp/libandroidltssupport.a ${BASEDIR}/android/app/src/main/cpp/android_lts_support.o 1>>${BASEDIR}/build.log 2>&1
}
