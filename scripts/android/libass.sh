#!/bin/bash

# ENABLE COMMON FUNCTIONS
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="libass"
set_toolchain_paths ${LIB_NAME}

# SET BUILD FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_libass} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

# SET ARCH OPTIONS
ASM_FLAGS=""
case ${ARCH} in
    x86)

        # please note that asm is disabled
        # because enabling asm for x86 causes text relocations in libavfilter.so
        ASM_FLAGS="	--disable-asm"
    ;;
    *)
        ASM_FLAGS="	--enable-asm"
    ;;
esac

./configure \
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot \
    --disable-libtool-lock \
    --enable-static \
    --disable-shared \
    --disable-harfbuzz \
    --disable-fast-install \
    --disable-test \
    --disable-profile \
    --disable-coretext \
    ${ASM_FLAGS} \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
