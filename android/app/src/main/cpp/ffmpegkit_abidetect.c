/*
 * Copyright (c) 2018-2021 Taner Sener
 *
 * This file is part of FFmpegKit.
 *
 * FFmpegKit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FFmpegKit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "cpu-features.h"
#include "fftools_ffmpeg.h"
#include "ffmpegkit_abidetect.h"

/** Full name of the Java class that owns native functions in this file. */
const char *abiDetectClassName = "com/arthenica/ffmpegkit/AbiDetect";

/** Prototypes of native functions defined by this file. */
JNINativeMethod abiDetectMethods[] = {
  {"getNativeAbi", "()Ljava/lang/String;", (void*) Java_com_arthenica_ffmpegkit_AbiDetect_getNativeAbi},
  {"getNativeCpuAbi", "()Ljava/lang/String;", (void*) Java_com_arthenica_ffmpegkit_AbiDetect_getNativeCpuAbi},
  {"isNativeLTSBuild", "()Z", (void*) Java_com_arthenica_ffmpegkit_AbiDetect_isNativeLTSBuild},
  {"getNativeBuildConf", "()Ljava/lang/String;", (void*) Java_com_arthenica_ffmpegkit_AbiDetect_getNativeBuildConf}
};

/**
 * Called when 'abidetect' native library is loaded.
 *
 * @param vm pointer to the running virtual machine
 * @param reserved reserved
 * @return JNI version needed by 'abidetect' library
 */
jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env;
    if ((*vm)->GetEnv(vm, (void**) &env, JNI_VERSION_1_6) != JNI_OK) {
        LOGE("OnLoad failed to GetEnv for class %s.\n", abiDetectClassName);
        return JNI_FALSE;
    }

    jclass abiDetectClass = (*env)->FindClass(env, abiDetectClassName);
    if (abiDetectClass == NULL) {
        LOGE("OnLoad failed to FindClass %s.\n", abiDetectClassName);
        return JNI_FALSE;
    }

    if ((*env)->RegisterNatives(env, abiDetectClass, abiDetectMethods, 4) < 0) {
        LOGE("OnLoad failed to RegisterNatives for class %s.\n", abiDetectClassName);
        return JNI_FALSE;
    }

    return JNI_VERSION_1_6;
}

/**
 * Returns loaded ABI name.
 *
 * @param env pointer to native method interface
 * @param object reference to the class on which this method is invoked
 * @return loaded ABI name as UTF string
 */
JNIEXPORT jstring JNICALL Java_com_arthenica_ffmpegkit_AbiDetect_getNativeAbi(JNIEnv *env, jclass object) {

#ifdef FFMPEG_KIT_ARM_V7A
    return (*env)->NewStringUTF(env, "arm-v7a");
#elif FFMPEG_KIT_ARM64_V8A
    return (*env)->NewStringUTF(env, "arm64-v8a");
#elif FFMPEG_KIT_X86
    return (*env)->NewStringUTF(env, "x86");
#elif FFMPEG_KIT_X86_64
    return (*env)->NewStringUTF(env, "x86_64");
#else
    return (*env)->NewStringUTF(env, "unknown");
#endif

}

/**
 * Returns ABI name of the running cpu.
 *
 * @param env pointer to native method interface
 * @param object reference to the class on which this method is invoked
 * @return ABI name of the running cpu as UTF string
 */
JNIEXPORT jstring JNICALL Java_com_arthenica_ffmpegkit_AbiDetect_getNativeCpuAbi(JNIEnv *env, jclass object) {
    AndroidCpuFamily family = android_getCpuFamily();

    if (family == ANDROID_CPU_FAMILY_ARM) {
        uint64_t features = android_getCpuFeatures();

        if (features & ANDROID_CPU_ARM_FEATURE_ARMv7) {
            if (features & ANDROID_CPU_ARM_FEATURE_NEON) {
                return (*env)->NewStringUTF(env, ABI_ARMV7A_NEON);
            } else {
                return (*env)->NewStringUTF(env, ABI_ARMV7A);
            }
        } else {
            return (*env)->NewStringUTF(env, ABI_ARM);
        }

    } else if (family == ANDROID_CPU_FAMILY_ARM64) {
        return (*env)->NewStringUTF(env, ABI_ARM64_V8A);
    } else if (family == ANDROID_CPU_FAMILY_X86) {
        return (*env)->NewStringUTF(env, ABI_X86);
    } else if (family == ANDROID_CPU_FAMILY_X86_64) {
        return (*env)->NewStringUTF(env, ABI_X86_64);
    } else {
        return (*env)->NewStringUTF(env, ABI_UNKNOWN);
    }
}

/**
 * Returns whether FFmpegKit release is a long term release or not.
 *
 * @param env pointer to native method interface
 * @param object reference to the class on which this method is invoked
 * @return yes or no
 */
JNIEXPORT jboolean JNICALL Java_com_arthenica_ffmpegkit_AbiDetect_isNativeLTSBuild(JNIEnv *env, jclass object) {
    #if defined(FFMPEG_KIT_LTS)
        return JNI_TRUE;
    #else
        return JNI_FALSE;
    #endif
}

/**
 * Returns build configuration for FFmpeg.
 *
 * @param env pointer to native method interface
 * @param object reference to the class on which this method is invoked
 * @return build configuration string
 */
JNIEXPORT jstring JNICALL Java_com_arthenica_ffmpegkit_AbiDetect_getNativeBuildConf(JNIEnv *env, jclass object) {
    return (*env)->NewStringUTF(env, FFMPEG_CONFIGURATION);
}
