ifeq ($(MY_LTS_POSTFIX),-lts)
    LOCAL_PATH := $(call my-dir)/../../../../prebuilt/android-$(TARGET_ARCH)-neon-lts/ffmpeg/lib
else
    LOCAL_PATH := $(call my-dir)/../../../../prebuilt/android-$(TARGET_ARCH)-neon/ffmpeg/lib
endif

MY_ARM_MODE := arm
MY_ARM_NEON := true

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_ARM_NEON := ${MY_ARM_NEON}
LOCAL_MODULE := libavcodec_neon
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)
LOCAL_SRC_FILES := libavcodec_neon.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_ARM_NEON := ${MY_ARM_NEON}
LOCAL_MODULE := libavfilter_neon
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)
LOCAL_SRC_FILES := libavfilter_neon.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_ARM_NEON := ${MY_ARM_NEON}
LOCAL_MODULE := libavdevice_neon
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)
LOCAL_SRC_FILES := libavdevice_neon.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_ARM_NEON := ${MY_ARM_NEON}
LOCAL_MODULE := libavformat_neon
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)
LOCAL_SRC_FILES := libavformat_neon.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_ARM_NEON := ${MY_ARM_NEON}
LOCAL_MODULE := libavutil_neon
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)
LOCAL_SRC_FILES := libavutil_neon.so
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_ARM_NEON := ${MY_ARM_NEON}
LOCAL_MODULE := libswresample_neon
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)
LOCAL_SRC_FILES := libswresample_neon.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_ARM_NEON := ${MY_ARM_NEON}
LOCAL_MODULE := libswscale_neon
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)
LOCAL_SRC_FILES := libswscale_neon.so
include $(PREBUILT_SHARED_LIBRARY)
