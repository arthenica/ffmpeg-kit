#!/bin/bash

$(android_ndk_cmake) || return 1

make -C "$(get_cmake_build_directory)" || return 1

make -C "$(get_cmake_build_directory)" install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_cpufeatures_package_config "0.8.0" || return 1
