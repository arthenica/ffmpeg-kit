#!/bin/bash
#
# Generates javadocs for Android Java library
#

CURRENT_DIR="`pwd`"

gradle -b "${CURRENT_DIR}"/../../android/ffmpeg-kit-android-lib/build.gradle clean javadoc
