#!/bin/bash
#
# Generates javadocs for Android Java library
#

CURRENT_DIR="`pwd`"

gradle -b "${CURRENT_DIR}"/../../android/ffmpeg-kit-android-lib/build.gradle clean javaDocReleaseGeneration

rm -rf "${CURRENT_DIR}"/../../docs/android/javadoc

cp -r "${CURRENT_DIR}"/../../android/ffmpeg-kit-android-lib/build/intermediates/java_doc_dir/release "${CURRENT_DIR}"/../../docs/android/javadoc
