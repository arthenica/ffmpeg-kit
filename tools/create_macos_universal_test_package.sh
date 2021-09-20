#!/bin/bash

cd ../prebuilt/bundle-apple-universal-macos || exit 1
find . -name "*.a" -not -path "./ffmpeg-kit/*" -exec cp {} ./ffmpeg-kit/lib \; || exit 1
cp -r ffmpeg/include/* ffmpeg-kit/include || exit 1

# COPY LICENSE FILE OF EACH LIBRARY
LICENSE_FILES=$(find . -name LICENSE | grep -vi ffmpeg)
for LICENSE_FILE in ${LICENSE_FILES[@]}
do
    LIBRARY_NAME=$(echo ${LICENSE_FILE} | sed 's/\.\///g;s/\/LICENSE//g')
    cp ${LICENSE_FILE} ffmpeg-kit/LICENSE.${LIBRARY_NAME} || exit 1
done

zip -r "../ffmpeg-kit-macos-universal.zip" ffmpeg-kit || exit 1