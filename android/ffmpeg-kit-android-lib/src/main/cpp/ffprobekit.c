/*
 * Copyright (c) 2020-2021 Taner Sener
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

#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "config.h"
#include "libavcodec/jni.h"
#include "libavutil/bprint.h"
#include "libavutil/mem.h"
#include "ffmpegkit.h"

/** Forward declaration for function defined in fftools_ffprobe.c */
int ffprobe_execute(int argc, char **argv);

extern int configuredLogLevel;
extern __thread long globalSessionId;
extern void addSession(long sessionId);
extern void removeSession(long sessionId);
extern void resetMessagesInTransmit(long sessionId);

/**
 * Synchronously executes FFprobe natively with arguments provided.
 *
 * @param env pointer to native method interface
 * @param object reference to the class on which this method is invoked
 * @param id session id
 * @param stringArray reference to the object holding FFprobe command arguments
 * @return zero on successful execution, non-zero on error
 */
JNIEXPORT jint JNICALL Java_com_arthenica_ffmpegkit_FFmpegKitConfig_nativeFFprobeExecute(JNIEnv *env, jclass object, jlong id, jobjectArray stringArray) {
    jstring *tempArray = NULL;
    int argumentCount = 1;
    char **argv = NULL;

    // SETS DEFAULT LOG LEVEL BEFORE STARTING A NEW RUN
    av_log_set_level(configuredLogLevel);

    if (stringArray) {
        int programArgumentCount = (*env)->GetArrayLength(env, stringArray);
        argumentCount = programArgumentCount + 1;

        tempArray = (jstring *) av_malloc(sizeof(jstring) * programArgumentCount);
    }

    /* PRESERVE USAGE FORMAT
     *
     * ffprobe <arguments>
     */
    argv = (char **)av_malloc(sizeof(char*) * (argumentCount));
    argv[0] = (char *)av_malloc(sizeof(char) * (strlen(LIB_NAME) + 1));
    strcpy(argv[0], LIB_NAME);

    // PREPARE ARRAY ELEMENTS
    if (stringArray) {
        for (int i = 0; i < (argumentCount - 1); i++) {
            tempArray[i] = (jstring) (*env)->GetObjectArrayElement(env, stringArray, i);
            if (tempArray[i] != NULL) {
                argv[i + 1] = (char *) (*env)->GetStringUTFChars(env, tempArray[i], 0);
            }
        }
    }

    // REGISTER THE ID BEFORE STARTING THE SESSION
    globalSessionId = (long) id;
    addSession((long) id);

    resetMessagesInTransmit(globalSessionId);

    // RUN
    int returnCode = ffprobe_execute(argumentCount, argv);

    // ALWAYS REMOVE THE ID FROM THE MAP
    removeSession((long) id);

    // CLEANUP
    if (tempArray) {
        for (int i = 0; i < (argumentCount - 1); i++) {
            (*env)->ReleaseStringUTFChars(env, tempArray[i], argv[i + 1]);
        }

        av_free(tempArray);
    }
    av_free(argv[0]);
    av_free(argv);

    return returnCode;
}
