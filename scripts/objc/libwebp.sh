#!/bin/bash

if [[ -z ${ARCH} ]]; then
    echo -e "\n(*) ARCH not defined\n"
    exit 1
fi

if [[ -z ${TARGET_SDK} ]]; then
    echo -e "\n(*) TARGET_SDK not defined\n"
    exit 1
fi

if [[ -z ${SDK_PATH} ]]; then
    echo -e "\n(*) SDK_PATH not defined\n"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo -e "\n(*) BASEDIR not defined\n"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
if [[ ${FFMPEG_KIT_BUILD_TYPE} == "tvos" ]]; then
    . ${BASEDIR}/build/tvos-common.sh
else
    . ${BASEDIR}/build/ios-common.sh
fi

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="libwebp"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

ARCH_OPTIONS=""
case ${ARCH} in
    armv7 | armv7s | arm64 | arm64e)
        ARCH_OPTIONS="--enable-neon --enable-neon-rtcd"
    ;;
    x86-64-mac-catalyst)
        ARCH_OPTIONS="--disable-sse2 --disable-sse4.1"
    ;;
    *)
        ARCH_OPTIONS="--enable-sse2 --enable-sse4.1"
    ;;
esac

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# ALWAYS RECONFIGURE
autoreconf_library ${LIB_NAME}

./configure \
    --prefix="${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME}" \
    --with-pic \
    --with-sysroot=${SDK_PATH} \
    --enable-static \
    --disable-shared \
    --disable-dependency-tracking \
    --enable-libwebpmux \
    ${ARCH_OPTIONS} \
    --with-pngincludedir="${BASEDIR}/prebuilt/$(get_target_build_directory)/libpng/include" \
    --with-pnglibdir="${BASEDIR}/prebuilt/$(get_target_build_directory)/libpng/lib" \
    --with-jpegincludedir="${BASEDIR}/prebuilt/$(get_target_build_directory)/jpeg/include" \
    --with-jpeglibdir="${BASEDIR}/prebuilt/$(get_target_build_directory)/jpeg/lib" \
    --with-gifincludedir="${BASEDIR}/prebuilt/$(get_target_build_directory)/giflib/include" \
    --with-giflibdir="${BASEDIR}/prebuilt/$(get_target_build_directory)/giflib/lib" \
    --with-tiffincludedir="${BASEDIR}/prebuilt/$(get_target_build_directory)/tiff/include" \
    --with-tifflibdir="${BASEDIR}/prebuilt/$(get_target_build_directory)/tiff/lib" \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ${BASEDIR}/src/${LIB_NAME}/src/*.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1
cp ${BASEDIR}/src/${LIB_NAME}/src/demux/*.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1
cp ${BASEDIR}/src/${LIB_NAME}/src/mux/*.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
