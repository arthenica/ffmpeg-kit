#!/bin/bash

export BASEDIR=$(pwd)

export ANDROID_MAIN_OPTIONS="--disable-arm-v7a --enable-android-media-codec --enable-android-zlib"
export ANDROID_LTS_OPTIONS="--lts --enable-android-media-codec --enable-android-zlib"

export IOS_MAIN_OPTIONS="--xcframework --disable-armv7 --disable-armv7s --disable-i386 --disable-arm64e --enable-ios-audiotoolbox --enable-ios-avfoundation --enable-ios-bzip2 --enable-ios-libiconv --enable-ios-videotoolbox --enable-ios-zlib"
export IOS_LTS_OPTIONS="--disable-armv7s --disable-arm64e --lts --enable-ios-audiotoolbox --enable-ios-bzip2 --enable-ios-libiconv --enable-ios-zlib"

export TVOS_MAIN_OPTIONS="--xcframework --enable-tvos-bzip2 --enable-tvos-audiotoolbox --enable-tvos-libiconv --enable-tvos-videotoolbox --enable-tvos-zlib"
export TVOS_LTS_OPTIONS="--disable-arm64-simulator --lts --enable-tvos-bzip2 --enable-tvos-audiotoolbox --enable-tvos-libiconv --enable-tvos-zlib"

export MACOS_MAIN_OPTIONS="--xcframework --enable-macos-audiotoolbox --enable-macos-avfoundation --enable-macos-bzip2 --enable-macos-coreimage --enable-macos-libiconv --enable-macos-opencl --enable-macos-opengl --enable-macos-videotoolbox --enable-macos-zlib"
export MACOS_LTS_OPTIONS="--disable-arm64 --lts --enable-macos-audiotoolbox --enable-macos-bzip2 --enable-macos-coreimage --enable-macos-libiconv --enable-macos-opencl --enable-macos-opengl --enable-macos-videotoolbox --enable-macos-zlib"

if [[ "${RELEASE_TYPE}" == "android" ]]; then
  export ANDROID_EXTRA_VIDEO_PACKAGES="--enable-libiconv "
  export ANDROID_EXTRA_DESCRIPTION="libiconv, "
else
  export ANDROID_EXTRA_VIDEO_PACKAGES=""
  export ANDROID_EXTRA_DESCRIPTION=""
fi

export GPL_PACKAGES="--enable-gpl --enable-libvidstab --enable-x264 --enable-x265 --enable-xvidcore"
export HTTPS_PACKAGES="--enable-gnutls --enable-gmp"
export AUDIO_PACKAGES="--enable-lame --enable-libilbc --enable-libvorbis --enable-opencore-amr --enable-opus --enable-shine --enable-soxr --enable-speex --enable-twolame --enable-vo-amrwbenc"
export VIDEO_PACKAGES="--enable-dav1d --enable-fontconfig --enable-freetype --enable-fribidi --enable-kvazaar --enable-libass ${ANDROID_EXTRA_VIDEO_PACKAGES} --enable-libtheora --enable-libvpx --enable-snappy --enable-libwebp --enable-zimg"
export FULL_PACKAGES="--enable-dav1d --enable-fontconfig --enable-freetype --enable-fribidi --enable-gmp --enable-gnutls --enable-kvazaar --enable-lame --enable-libass ${ANDROID_EXTRA_VIDEO_PACKAGES} --enable-libilbc --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libwebp --enable-zimg --enable-libxml2 --enable-opencore-amr --enable-opus --enable-shine --enable-snappy --enable-soxr --enable-speex --enable-twolame --enable-vo-amrwbenc"

export ANDROID_FFMPEG_KIT_VERSION=$(grep '#define FFMPEG_KIT_VERSION' "${BASEDIR}"/../../android/ffmpeg-kit-android-lib/src/main/cpp/ffmpegkit.h | grep -Eo '\".*\"' | sed -e 's/\"//g')
export APPLE_FFMPEG_KIT_VERSION=$(grep 'FFmpegKitVersion ' ${BASEDIR}/../../apple/src/FFmpegKitConfig.m | grep -Eo '\".*\"' | sed -e 's/\"//g')

export ANDROID_MAIN_MIN_SDK=24
export ANDROID_LTS_MIN_SDK=16
export ANDROID_TARGET_SDK=30

export LIBRARY_DESCRIPTION_MIN="Includes FFmpeg without any external libraries enabled."
export LIBRARY_DESCRIPTION_MIN_GPL="Includes FFmpeg with libvid.stab, x264, x265 and xvidcore libraries enabled."
export LIBRARY_DESCRIPTION_HTTPS="Includes FFmpeg with gmp and gnutls libraries enabled."
export LIBRARY_DESCRIPTION_HTTPS_GPL="Includes FFmpeg with gmp, gnutls, libvid.stab, x264, x265 and xvidcore libraries enabled."
export LIBRARY_DESCRIPTION_AUDIO="Includes FFmpeg with lame, libilbc, libvorbis, opencore-amr, opus, shine, soxr, speex, twolame and vo-amrwbenc libraries enabled."
export LIBRARY_DESCRIPTION_VIDEO="Includes FFmpeg with dav1d, fontconfig, freetype, fribidi, kvazaar, libass, ${ANDROID_EXTRA_DESCRIPTION}libtheora, libvpx, snappy, libwebp and zimg libraries enabled."
export LIBRARY_DESCRIPTION_FULL="Includes FFmpeg with dav1d, fontconfig, freetype, fribidi, gmp, gnutls, kvazaar, lame, libass, ${ANDROID_EXTRA_DESCRIPTION}libilbc, libtheora, libvorbis, libvpx, libwebp, zimg, libxml2, opencore-amr, opus, shine, snappy, soxr, speex, twolame and vo-amrwbenc libraries enabled."
export LIBRARY_DESCRIPTION_FULL_GPL="Includes FFmpeg with dav1d, fontconfig, freetype, fribidi, gmp, gnutls, kvazaar, lame, libass, ${ANDROID_EXTRA_DESCRIPTION}libilbc, libtheora, libvid.stab, libvorbis, libvpx, libwebp, zimg, libxml2, opencore-amr, opus, shine, snappy, soxr, speex, twolame, vo-amrwbenc, x264, x265 and xvidcore libraries enabled."
