/*
 * Copyright (c) 2021 Taner Sener
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

package com.arthenica.ffmpegkit.flutter;

import androidx.annotation.NonNull;

import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFmpegSession;

import io.flutter.plugin.common.MethodChannel;

public class FFmpegSessionExecuteTask implements Runnable {
    private final FFmpegSession ffmpegSession;
    private final FFmpegKitFlutterMethodResultHandler resultHandler;
    private final MethodChannel.Result result;

    public FFmpegSessionExecuteTask(@NonNull final FFmpegSession ffmpegSession, @NonNull final FFmpegKitFlutterMethodResultHandler resultHandler, @NonNull final MethodChannel.Result result) {
        this.ffmpegSession = ffmpegSession;
        this.resultHandler = resultHandler;
        this.result = result;
    }

    @Override
    public void run() {
        FFmpegKitConfig.ffmpegExecute(ffmpegSession);
        resultHandler.successAsync(result, null);
    }
}
