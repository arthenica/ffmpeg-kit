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

package com.arthenica.ffmpegkit.flutter;

import static com.arthenica.ffmpegkit.flutter.FFmpegKitFlutterPlugin.LIBRARY_NAME;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class FFmpegKitFlutterMethodResultHandler {
    private final Handler handler;

    FFmpegKitFlutterMethodResultHandler() {
        handler = new Handler(Looper.getMainLooper());
    }

    void successAsync(final MethodChannel.Result result, final Object object) {
        handler.post(() -> {
            if (result != null) {
                result.success(object);
            } else {
                Log.w(LIBRARY_NAME, String.format("ResultHandler can not send successful response %s on a null method call result.", object));
            }
        });
    }

    void successAsync(final EventChannel.EventSink eventSink, final Object object) {
        handler.post(() -> {
            if (eventSink != null) {
                eventSink.success(object);
            } else {
                Log.w(LIBRARY_NAME, String.format("ResultHandler can not send event %s on a null event sink.", object));
            }
        });
    }

    void errorAsync(final MethodChannel.Result result, final String errorCode, final String errorMessage) {
        errorAsync(result, errorCode, errorMessage, null);
    }

    void errorAsync(final MethodChannel.Result result, final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(() -> {
            if (result != null) {
                result.error(errorCode, errorMessage, errorDetails);
            } else {
                Log.w(LIBRARY_NAME, String.format("ResultHandler can not send failure response %s:%s on a null method call result.", errorCode, errorMessage));
            }
        });
    }

    void notImplementedAsync(final MethodChannel.Result result) {
        handler.post(() -> {
            if (result != null) {
                result.notImplemented();
            } else {
                Log.w(LIBRARY_NAME, "ResultHandler can not send not implemented response on a null method call result.");
            }
        });
    }

}
