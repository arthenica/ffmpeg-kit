#!/bin/bash

# ENABLE COMMON FUNCTIONS
. "${BASEDIR}"/scripts/function-android.sh

LIB_NAME="cpu-features"
set_toolchain_paths ${LIB_NAME}

cd "${BASEDIR}"/src/${LIB_NAME} || exit 1

$(android_ndk_cmake) -DBUILD_PIC=ON || exit 1
make -C "$(get_android_build_dir)" install || exit 1

create_cpufeatures_package_config