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

#ifndef FFMPEG_KIT_H
#define FFMPEG_KIT_H

#include <jni.h>
#include <android/log.h>

#include "libavutil/log.h"
#include "libavutil/ffversion.h"

/** Library version string */
#define FFMPEG_KIT_VERSION "6.0"

/** Defines tag used for Android logging. */
#define LIB_NAME "ffmpeg-kit"

/** Verbose Android logging macro. */
#define LOGV(...) __android_log_print(ANDROID_LOG_VERBOSE, LIB_NAME, __VA_ARGS__)

/** Debug Android logging macro. */
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LIB_NAME, __VA_ARGS__)

/** Info Android logging macro. */
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LIB_NAME, __VA_ARGS__)

/** Warn Android logging macro. */
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN, LIB_NAME, __VA_ARGS__)

/** Error Android logging macro. */
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LIB_NAME, __VA_ARGS__)

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    enableNativeRedirection
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_enableNativeRedirection(JNIEnv *, jclass);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    disableNativeRedirection
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_disableNativeRedirection(JNIEnv *, jclass);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    setNativeLogLevel
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_setNativeLogLevel(JNIEnv *, jclass, jint);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    getNativeLogLevel
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_getNativeLogLevel(JNIEnv *, jclass);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    getNativeFFmpegVersion
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_getNativeFFmpegVersion(JNIEnv *, jclass);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    getNativeVersion
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_getNativeVersion(JNIEnv *, jclass);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    nativeFFmpegExecute
 * Signature: (J[Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_nativeFFmpegExecute(JNIEnv *, jclass, jlong, jobjectArray);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    nativeFFmpegCancel
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_nativeFFmpegCancel(JNIEnv *, jclass, jlong);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    registerNewNativeFFmpegPipe
 * Signature: (Ljava/lang/String;)I
 */
JNIEXPORT int JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_registerNewNativeFFmpegPipe(JNIEnv *env, jclass object, jstring ffmpegPipePath);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    getNativeBuildDate
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_getNativeBuildDate(JNIEnv *env, jclass object);

/**
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    setNativeEnvironmentVariable
 * Signature: (Ljava/lang/String;Ljava/lang/String;)I
 */
JNIEXPORT int JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_setNativeEnvironmentVariable(JNIEnv *env, jclass object, jstring variableName, jstring variableValue);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    ignoreNativeSignal
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_ignoreNativeSignal(JNIEnv *env, jclass object, jint signum);

/*
 * Class:     com_arthenica_ffmpegkit_FFmpegKitConfig
 * Method:    messagesInTransmit
 * Signature: (J)I
 */
JNIEXPORT int JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_messagesInTransmit(JNIEnv *env, jclass object, jlong id);

#endif /* FFMPEG_KIT_H */