#!/bin/bash

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
    echo -e "\n(*) ANDROID_NDK_ROOT not defined\n"
    exit 1
fi

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

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/android-common.sh

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
    arm-v7a)
        ARCH_OPTIONS="--disable-neon --disable-neon-rtcd"
    ;;
    arm-v7a-neon | arm64-v8a)
        ARCH_OPTIONS="--enable-neon --enable-neon-rtcd"
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
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot \
    --enable-static \
    --disable-shared \
    --disable-dependency-tracking \
    --enable-libwebpmux \
    ${ARCH_OPTIONS} \
    --with-pngincludedir="${BASEDIR}/prebuilt/android-$(get_target_build)/libpng/include" \
    --with-pnglibdir="${BASEDIR}/prebuilt/android-$(get_target_build)/libpng/lib" \
    --with-jpegincludedir="${BASEDIR}/prebuilt/android-$(get_target_build)/jpeg/include" \
    --with-jpeglibdir="${BASEDIR}/prebuilt/android-$(get_target_build)/jpeg/lib" \
    --with-gifincludedir="${BASEDIR}/prebuilt/android-$(get_target_build)/giflib/include" \
    --with-giflibdir="${BASEDIR}/prebuilt/android-$(get_target_build)/giflib/lib" \
    --with-tiffincludedir="${BASEDIR}/prebuilt/android-$(get_target_build)/tiff/include" \
    --with-tifflibdir="${BASEDIR}/prebuilt/android-$(get_target_build)/tiff/lib" \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ${BASEDIR}/src/${LIB_NAME}/src/*.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1
cp ${BASEDIR}/src/${LIB_NAME}/src/demux/*.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1
cp ${BASEDIR}/src/${LIB_NAME}/src/mux/*.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
