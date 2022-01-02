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

import static com.arthenica.ffmpegkit.flutter.FFmpegKitFlutterPlugin.LIBRARY_NAME;

import android.util.Log;

import androidx.annotation.NonNull;

import java.io.IOException;

import io.flutter.plugin.common.MethodChannel;

public class WriteToPipeTask implements Runnable {
    private final String inputPath;
    private final String namedPipePath;
    private final FFmpegKitFlutterMethodResultHandler resultHandler;
    private final MethodChannel.Result result;

    public WriteToPipeTask(@NonNull final String inputPath, @NonNull final String namedPipePath, @NonNull final FFmpegKitFlutterMethodResultHandler resultHandler, @NonNull final MethodChannel.Result result) {
        this.inputPath = inputPath;
        this.namedPipePath = namedPipePath;
        this.resultHandler = resultHandler;
        this.result = result;
    }

    @Override
    public void run() {
        final int rc;

        try {
            final String asyncCommand = "cat " + inputPath + " > " + namedPipePath;
            Log.d(LIBRARY_NAME, String.format("Starting copy %s to pipe %s operation.", inputPath, namedPipePath));

            final long startTime = System.currentTimeMillis();

            final Process process = Runtime.getRuntime().exec(new String[]{"sh", "-c", asyncCommand});
            rc = process.waitFor();

            final long endTime = System.currentTimeMillis();

            Log.d(LIBRARY_NAME, String.format("Copying %s to pipe %s operation completed with rc %d in %d seconds.", inputPath, namedPipePath, rc, (endTime - startTime) / 1000));

            resultHandler.successAsync(result, rc);

        } catch (final IOException | InterruptedException e) {
            Log.e(LIBRARY_NAME, String.format("Copy %s to pipe %s failed with error.", inputPath, namedPipePath), e);
            resultHandler.errorAsync(result, "WRITE_TO_PIPE_FAILED", e.getMessage());
        }
    }

}
