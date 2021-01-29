#!/bin/bash

# SET BUILD FLAGS
CROSS_FILE="${BASEDIR}"/src/"${LIB_NAME}"/package/crossfiles/$ARCH-$FFMPEG_KIT_BUILD_TYPE.meson

create_mason_cross_file "$CROSS_FILE" || return 1

# ALWAYS CLEAN THE PREVIOUS BUILD
rm -rf "${BUILD_DIR}" || return 1

meson "${BUILD_DIR}" \
  --cross-file="$CROSS_FILE" \
  -Db_lto=false \
  -Db_ndebug=false \
  -Denable_asm=false \
  -Denable_tools=false \
  -Denable_examples=false \
  -Denable_tests=false || return 1

cd "${BUILD_DIR}" || return 1

ninja -j$(get_cpu_count) || return 1

ninja install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp "${BUILD_DIR}"/meson-private/dav1d.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
