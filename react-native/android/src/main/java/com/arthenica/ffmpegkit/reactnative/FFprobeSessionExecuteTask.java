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

package com.arthenica.ffmpegkit.reactnative;

import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFprobeSession;
import com.facebook.react.bridge.Promise;

public class FFprobeSessionExecuteTask implements Runnable {
  private final FFprobeSession ffprobeSession;
  private final Promise promise;

  public FFprobeSessionExecuteTask(final FFprobeSession ffprobeSession, final Promise promise) {
    this.ffprobeSession = ffprobeSession;
    this.promise = promise;
  }

  @Override
  public void run() {
    FFmpegKitConfig.ffprobeExecute(ffprobeSession);
    promise.resolve(null);
  }
}
