#!/bin/bash

$(android_ndk_cmake) -DBUILD_PIC=ON || return 1

make -C "$(get_cmake_build_directory)" || return 1

make -C "$(get_cmake_build_directory)" install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_cpufeatures_package_config "0.4.1.1" || return 1
