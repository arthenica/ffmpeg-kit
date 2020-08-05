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
LIB_NAME="kvazaar"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# ALWAYS RECONFIGURE
autoreconf_library ${LIB_NAME}

# LINKING WITH ANDROID LTS SUPPORT LIBRARY IS NECESSARY FOR API < 18
if [[ ! -z ${FFMPEG_KIT_LTS_BUILD} ]] && [[ ${API} < 18 ]]; then
    ARCH_SPECIFIC_LIBS=" -Wl,--no-whole-archive ${BASEDIR}/android/app/src/main/cpp/libandroidltssupport.a -Wl,--no-whole-archive"
else
    ARCH_SPECIFIC_LIBS=""
fi

# DISABLE LINKING TO -lrt
${SED_INLINE} 's/\-lrt//g' ${BASEDIR}/src/${LIB_NAME}/configure

LIBS="${ARCH_SPECIFIC_LIBS}" ./configure \
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --host=${BUILD_HOST} || exit 1

make || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./src/kvazaar.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
