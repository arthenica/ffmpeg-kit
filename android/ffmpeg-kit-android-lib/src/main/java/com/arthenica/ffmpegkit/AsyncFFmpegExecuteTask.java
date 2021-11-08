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
    private final ExecuteCallback executeCallback;

    public AsyncFFmpegExecuteTask(final FFmpegSession ffmpegSession) {
        this.ffmpegSession = ffmpegSession;
        this.executeCallback = ffmpegSession.getExecuteCallback();
    }

    @Override
    public void run() {
        FFmpegKitConfig.ffmpegExecute(ffmpegSession);

        if (executeCallback != null) {
            try {
                // NOTIFY SESSION CALLBACK DEFINED
                executeCallback.apply(ffmpegSession);
            } catch (final Exception e) {
                android.util.Log.e(FFmpegKitConfig.TAG, String.format("Exception thrown inside session ExecuteCallback block.%s", Exceptions.getStackTraceString(e)));
            }
        }

        final ExecuteCallback globalExecuteCallbackFunction = FFmpegKitConfig.getExecuteCallback();
        if (globalExecuteCallbackFunction != null) {
            try {
                // NOTIFY GLOBAL CALLBACK DEFINED
                globalExecuteCallbackFunction.apply(ffmpegSession);
            } catch (final Exception e) {
                android.util.Log.e(FFmpegKitConfig.TAG, String.format("Exception thrown inside global ExecuteCallback block.%s", Exceptions.getStackTraceString(e)));
            }
        }
    }
}
