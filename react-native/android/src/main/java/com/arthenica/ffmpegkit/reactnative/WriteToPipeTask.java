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
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit.reactnative;

import static com.arthenica.ffmpegkit.reactnative.FFmpegKitReactNativeModule.LIBRARY_NAME;

import android.util.Log;

import com.facebook.react.bridge.Promise;

import java.io.IOException;

public class WriteToPipeTask implements Runnable {
  private final String inputPath;
  private final String namedPipePath;
  private final Promise promise;

  public WriteToPipeTask(final String inputPath, final String namedPipePath, final Promise promise) {
    this.inputPath = inputPath;
    this.namedPipePath = namedPipePath;
    this.promise = promise;
  }

  @Override
  public void run() {
    int rc;

    try {
      final String asyncCommand = "cat " + inputPath + " > " + namedPipePath;
      Log.d(LIBRARY_NAME, String.format("Starting copy %s to pipe %s operation.", inputPath, namedPipePath));

      final long startTime = System.currentTimeMillis();

      final Process process = Runtime.getRuntime().exec(new String[]{"sh", "-c", asyncCommand});
      rc = process.waitFor();

      final long endTime = System.currentTimeMillis();

      Log.d(LIBRARY_NAME, String.format("Copying %s to pipe %s operation completed with rc %d in %d seconds.", inputPath, namedPipePath, rc, (endTime - startTime) / 1000));

      promise.resolve(rc);

    } catch (final IOException | InterruptedException e) {
      Log.e(LIBRARY_NAME, String.format("Copy %s to pipe %s failed with error.", inputPath, namedPipePath), e);
      promise.reject("Copy failed", String.format("Copy %s to pipe %s failed with error.", inputPath, namedPipePath), e);
    }
  }

}
