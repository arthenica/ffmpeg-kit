ifeq ($(MY_ARMV7_NEON), true)
    LOCAL_PATH := $(call my-dir)/../../../prebuilt/android-$(TARGET_ARCH)-neon/cpu-features/lib
else
    LOCAL_PATH := $(call my-dir)/../../../prebuilt/android-$(TARGET_ARCH)/cpu-features/lib
endif

include $(CLEAR_VARS)
LOCAL_ARM_MODE := $(MY_ARM_MODE)
LOCAL_MODULE := cpu-features
LOCAL_SRC_FILES := libndk_compat.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include/ndk_compat
include $(PREBUILT_STATIC_LIBRARY)
