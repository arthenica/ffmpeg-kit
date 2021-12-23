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

package com.arthenica.ffmpegkit;

import com.arthenica.smartexception.java.Exceptions;

/**
 * <p>Executes an FFmpeg session asynchronously.
 */
public class AsyncFFmpegExecuteTask implements Runnable {
    private final FFmpegSession ffmpegSession;
    private final FFmpegSessionCompleteCallback completeCallback;

    public AsyncFFmpegExecuteTask(final FFmpegSession ffmpegSession) {
        this.ffmpegSession = ffmpegSession;
        this.completeCallback = ffmpegSession.getCompleteCallback();
    }

    @Override
    public void run() {
        FFmpegKitConfig.ffmpegExecute(ffmpegSession);

        if (completeCallback != null) {
            try {
                // NOTIFY SESSION CALLBACK DEFINED
                completeCallback.apply(ffmpegSession);
            } catch (final Exception e) {
                android.util.Log.e(FFmpegKitConfig.TAG, String.format("Exception thrown inside session complete callback.%s", Exceptions.getStackTraceString(e)));
            }
        }

        final FFmpegSessionCompleteCallback globalFFmpegSessionCompleteCallback = FFmpegKitConfig.getFFmpegSessionCompleteCallback();
        if (globalFFmpegSessionCompleteCallback != null) {
            try {
                // NOTIFY GLOBAL CALLBACK DEFINED
                globalFFmpegSessionCompleteCallback.apply(ffmpegSession);
            } catch (final Exception e) {
                android.util.Log.e(FFmpegKitConfig.TAG, String.format("Exception thrown inside global complete callback.%s", Exceptions.getStackTraceString(e)));
            }
        }
    }
}
