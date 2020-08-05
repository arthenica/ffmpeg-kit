MY_LOCAL_PATH := $(call my-dir)
$(call import-add-path, $(MY_LOCAL_PATH))

MY_ARMV7 := false
MY_ARMV7_NEON := false
ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
    ifeq ("$(shell test -e $(MY_LOCAL_PATH)/../build/.armv7 && echo armv7)","armv7")
        MY_ARMV7 := true
    endif
    ifeq ("$(shell test -e $(MY_LOCAL_PATH)/../build/.armv7neon && echo armv7neon)","armv7neon")
        MY_ARMV7_NEON := true
    endif
endif
ifeq ($(MY_ARMV7_NEON), true)
    FFMPEG_INCLUDES := $(MY_LOCAL_PATH)/../../prebuilt/android-$(TARGET_ARCH)-neon/ffmpeg/include
else
    FFMPEG_INCLUDES := $(MY_LOCAL_PATH)/../../prebuilt/android-$(TARGET_ARCH)/ffmpeg/include
endif

MY_ARM_MODE := arm
MY_ARM_NEON := false
LOCAL_PATH := $(MY_LOCAL_PATH)/../app/src/main/cpp

# DEFINE ARCH FLAGS
ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
    MY_ARCH_FLAGS := ARM_V7A
    MY_ARM_NEON := false
endif
ifeq ($(TARGET_ARCH_ABI), arm64-v8a)
    MY_ARCH_FLAGS := ARM64_V8A
    MY_ARM_NEON := true
endif
ifeq ($(TARGET_ARCH_ABI), x86)
    MY_ARCH_FLAGS := X86
endif
ifeq ($(TARGET_ARCH_ABI), x86_64)
    MY_ARCH_FLAGS := X86_64
endif

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_MODULE := ffmpegkit_abidetect
LOCAL_SRC_FILES := ffmpegkit_abidetect.c
LOCAL_CFLAGS := -Wall -Wextra -Werror -Wno-unused-parameter -DFFMPEG_KIT_${MY_ARCH_FLAGS}
LOCAL_C_INCLUDES := $(FFMPEG_INCLUDES)
LOCAL_LDLIBS := -llog -lz -landroid
LOCAL_STATIC_LIBRARIES := cpu-features
LOCAL_ARM_NEON := ${MY_ARM_NEON}
include $(BUILD_SHARED_LIBRARY)

$(call import-module, cpu-features)

ifeq ($(TARGET_PLATFORM),android-16)
    MY_SRC_FILES := ffmpegkit.c ffprobekit.c android_lts_support.c ffmpegkit_exception.c fftools_cmdutils.c fftools_ffmpeg.c fftools_ffprobe.c fftools_ffmpeg_opt.c fftools_ffmpeg_hw.c fftools_ffmpeg_filter.c
else ifeq ($(TARGET_PLATFORM),android-17)
    MY_SRC_FILES := ffmpegkit.c ffprobekit.c android_lts_support.c ffmpegkit_exception.c fftools_cmdutils.c fftools_ffmpeg.c fftools_ffprobe.c fftools_ffmpeg_opt.c fftools_ffmpeg_hw.c fftools_ffmpeg_filter.c
else
    MY_SRC_FILES := ffmpegkit.c ffprobekit.c ffmpegkit_exception.c fftools_cmdutils.c fftools_ffmpeg.c fftools_ffprobe.c fftools_ffmpeg_opt.c fftools_ffmpeg_hw.c fftools_ffmpeg_filter.c
endif

MY_CFLAGS := -Wall -Werror -Wno-unused-parameter -Wno-switch -Wno-sign-compare
MY_LDLIBS := -llog -lz -landroid

MY_BUILD_GENERIC_FFMPEG_KIT := true

ifeq ($(MY_ARMV7_NEON), true)
    include $(CLEAR_VARS)
    LOCAL_PATH := $(MY_LOCAL_PATH)/../app/src/main/cpp
    LOCAL_ARM_MODE := $(MY_ARM_MODE)
    LOCAL_MODULE := ffmpegkit_armv7a_neon
    LOCAL_SRC_FILES := $(MY_SRC_FILES)
    LOCAL_CFLAGS := $(MY_CFLAGS)
    LOCAL_LDLIBS := $(MY_LDLIBS)
    LOCAL_SHARED_LIBRARIES := libavcodec_neon libavfilter_neon libswscale_neon libavformat_neon libavutil_neon libswresample_neon libavdevice_neon
    ifeq ($(APP_STL), c++_shared)
        LOCAL_SHARED_LIBRARIES += c++_shared # otherwise NDK will not add the library for packaging
    endif
    LOCAL_ARM_NEON := true
    include $(BUILD_SHARED_LIBRARY)

    $(call import-module, ffmpeg/neon)

    ifneq ($(MY_ARMV7), true)
        MY_BUILD_GENERIC_FFMPEG_KIT := false
    endif
endif

ifeq ($(MY_BUILD_GENERIC_FFMPEG_KIT), true)
    include $(CLEAR_VARS)
    LOCAL_PATH := $(MY_LOCAL_PATH)/../app/src/main/cpp
    LOCAL_ARM_MODE := $(MY_ARM_MODE)
    LOCAL_MODULE := ffmpegkit
    LOCAL_SRC_FILES := $(MY_SRC_FILES)
    LOCAL_CFLAGS := $(MY_CFLAGS)
    LOCAL_LDLIBS := $(MY_LDLIBS)
    LOCAL_SHARED_LIBRARIES := libavfilter libavformat libavcodec libavutil libswresample libavdevice libswscale
    ifeq ($(APP_STL), c++_shared)
        LOCAL_SHARED_LIBRARIES += c++_shared # otherwise NDK will not add the library for packaging
    endif
    LOCAL_ARM_NEON := ${MY_ARM_NEON}
    include $(BUILD_SHARED_LIBRARY)

    $(call import-module, ffmpeg)
endif
