#!/bin/bash

# DIRECTORY DEFINITIONS
export FFMPEG_KIT_TMPDIR="${BASEDIR}/.tmp"

# ARRAY OF ENABLED ARCHITECTURES
ENABLED_ARCHITECTURES=(0 0 0 0 0 0 0 0 0 0 0 0 0)

# ARRAY OF ENABLED ARCHITECTURE VARIANTS
ENABLED_ARCHITECTURE_VARIANTS=(0 0 0 0 0 0 0 0 0 0)

# ARRAY OF ENABLED LIBRARIES
ENABLED_LIBRARIES=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)

# ARRAY OF LIBRARIES THAT WILL BE RE-CONFIGURED
RECONF_LIBRARIES=()

# ARRAY OF LIBRARIES THAT WILL BE RE-BUILD
REBUILD_LIBRARIES=()

# ARRAY OF LIBRARIES THAT WILL BE RE-DOWNLOADED
REDOWNLOAD_LIBRARIES=()

# ARRAY OF CUSTOM LIBRARIES
CUSTOM_LIBRARIES=()

# ARCH INDEXES
ARCH_ARM_V7A=0              # android
ARCH_ARM_V7A_NEON=1         # android
ARCH_ARMV7=2                # ios
ARCH_ARMV7S=3               # ios
ARCH_ARM64_V8A=4            # android
ARCH_ARM64=5                # ios, tvos, xros, macos
ARCH_ARM64E=6               # ios
ARCH_I386=7                 # ios
ARCH_X86=8                  # android
ARCH_X86_64=9               # android, ios, linux, macos, tvos
ARCH_X86_64_MAC_CATALYST=10 # ios
ARCH_ARM64_MAC_CATALYST=11  # ios
ARCH_ARM64_SIMULATOR=12     # ios, xros

# ARCH VARIANT INDEXES
ARCH_VAR_IOS=1              # ios
ARCH_VAR_IPHONEOS=2         # ios
ARCH_VAR_IPHONESIMULATOR=3  # ios
ARCH_VAR_MAC_CATALYST=4     # ios
ARCH_VAR_TVOS=5             # tvos
ARCH_VAR_APPLETVOS=6        # tvos
ARCH_VAR_APPLETVSIMULATOR=7 # tvos
ARCH_VAR_MACOS=8            # macos
ARCH_VAR_XROS=9             # xros
ARCH_VAR_XRSIMULATOR=10     # xros

# LIBRARY INDEXES
LIBRARY_FONTCONFIG=0
LIBRARY_FREETYPE=1
LIBRARY_FRIBIDI=2
LIBRARY_GMP=3
LIBRARY_GNUTLS=4
LIBRARY_LAME=5
LIBRARY_LIBASS=6
LIBRARY_LIBICONV=7
LIBRARY_LIBTHEORA=8
LIBRARY_LIBVORBIS=9
LIBRARY_LIBVPX=10
LIBRARY_LIBWEBP=11
LIBRARY_LIBXML2=12
LIBRARY_OPENCOREAMR=13
LIBRARY_SHINE=14
LIBRARY_SPEEX=15
LIBRARY_DAV1D=16
LIBRARY_KVAZAAR=17
LIBRARY_X264=18
LIBRARY_XVIDCORE=19
LIBRARY_X265=20
LIBRARY_LIBVIDSTAB=21
LIBRARY_RUBBERBAND=22
LIBRARY_LIBILBC=23
LIBRARY_OPUS=24
LIBRARY_SNAPPY=25
LIBRARY_SOXR=26
LIBRARY_LIBAOM=27
LIBRARY_CHROMAPRINT=28
LIBRARY_TWOLAME=29
LIBRARY_SDL=30
LIBRARY_TESSERACT=31
LIBRARY_OPENH264=32
LIBRARY_VO_AMRWBENC=33
LIBRARY_ZIMG=34
LIBRARY_OPENSSL=35
LIBRARY_SRT=36
LIBRARY_GIFLIB=37
LIBRARY_JPEG=38
LIBRARY_LIBOGG=39
LIBRARY_LIBPNG=40
LIBRARY_LIBUUID=41
LIBRARY_NETTLE=42
LIBRARY_TIFF=43
LIBRARY_EXPAT=44
LIBRARY_SNDFILE=45
LIBRARY_LEPTONICA=46
LIBRARY_LIBSAMPLERATE=47
LIBRARY_HARFBUZZ=48
LIBRARY_CPU_FEATURES=49
LIBRARY_SYSTEM_ZLIB=50
LIBRARY_LINUX_ALSA=51
LIBRARY_ANDROID_MEDIA_CODEC=52
LIBRARY_APPLE_AUDIOTOOLBOX=53
LIBRARY_APPLE_BZIP2=54
LIBRARY_APPLE_VIDEOTOOLBOX=55
LIBRARY_APPLE_AVFOUNDATION=56
LIBRARY_APPLE_LIBICONV=57
LIBRARY_APPLE_LIBUUID=58
LIBRARY_APPLE_COREIMAGE=59
LIBRARY_APPLE_OPENCL=60
LIBRARY_APPLE_OPENGL=61
LIBRARY_LINUX_FONTCONFIG=62
LIBRARY_LINUX_FREETYPE=63
LIBRARY_LINUX_FRIBIDI=64
LIBRARY_LINUX_GMP=65
LIBRARY_LINUX_GNUTLS=66
LIBRARY_LINUX_LAME=67
LIBRARY_LINUX_LIBASS=68
LIBRARY_LINUX_LIBICONV=69
LIBRARY_LINUX_LIBTHEORA=70
LIBRARY_LINUX_LIBVORBIS=71
LIBRARY_LINUX_LIBVPX=72
LIBRARY_LINUX_LIBWEBP=73
LIBRARY_LINUX_LIBXML2=74
LIBRARY_LINUX_OPENCOREAMR=75
LIBRARY_LINUX_SHINE=76
LIBRARY_LINUX_SPEEX=77
LIBRARY_LINUX_OPENCL=78
LIBRARY_LINUX_XVIDCORE=79
LIBRARY_LINUX_X265=80
LIBRARY_LINUX_LIBVIDSTAB=81
LIBRARY_LINUX_RUBBERBAND=82
LIBRARY_LINUX_V4L2=83
LIBRARY_LINUX_OPUS=84
LIBRARY_LINUX_SNAPPY=85
LIBRARY_LINUX_SOXR=86
LIBRARY_LINUX_TWOLAME=87
LIBRARY_LINUX_SDL=88
LIBRARY_LINUX_TESSERACT=89
LIBRARY_LINUX_VAAPI=90
LIBRARY_LINUX_VO_AMRWBENC=91
