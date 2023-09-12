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

package com.arthenica.ffmpegkit;

import android.os.Build;

import com.arthenica.smartexception.java.Exceptions;

import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * <p>Responsible of loading native libraries.
 */
public class NativeLoader {

    static final String[] FFMPEG_LIBRARIES = {"avutil", "swscale", "swresample", "avcodec", "avformat", "avfilter", "avdevice"};

    static final String[] LIBRARIES_LINKED_WITH_CXX = {"chromaprint", "openh264", "rubberband", "snappy", "srt", "tesseract", "x265", "zimg", "libilbc"};

    static boolean isTestModeDisabled() {
        return (System.getProperty("enable.ffmpeg.kit.test.mode") == null);
    }

    private static void loadLibrary(final String libraryName) {
        if (isTestModeDisabled()) {
            try {
                System.loadLibrary(libraryName);
            } catch (final UnsatisfiedLinkError e) {
                throw new Error(String.format("FFmpegKit failed to start on %s.", getDeviceDebugInformation()), e);
            }
        }
    }

    private static List<String> loadExternalLibraries() {
        if (isTestModeDisabled()) {
            return Packages.getExternalLibraries();
        } else {
            return Collections.emptyList();
        }
    }

    private static String loadNativeAbi() {
        if (isTestModeDisabled()) {
            return AbiDetect.getNativeAbi();
        } else {
            return Abi.ABI_X86_64.getName();
        }
    }

    static String loadAbi() {
        if (isTestModeDisabled()) {
            return AbiDetect.getAbi();
        } else {
            return Abi.ABI_X86_64.getName();
        }
    }

    static String loadPackageName() {
        if (isTestModeDisabled()) {
            return Packages.getPackageName();
        } else {
            return "test";
        }
    }

    static String loadVersion() {
        final String version = "6.0";

        if (isTestModeDisabled()) {
            return FFmpegKitConfig.getVersion();
        } else if (loadIsLTSBuild()) {
            return String.format("%s-lts", version);
        } else {
            return version;
        }
    }

    static boolean loadIsLTSBuild() {
        if (isTestModeDisabled()) {
            return AbiDetect.isNativeLTSBuild();
        } else {
            return true;
        }
    }

    static int loadLogLevel() {
        if (isTestModeDisabled()) {
            return FFmpegKitConfig.getNativeLogLevel();
        } else {
            return Level.AV_LOG_DEBUG.getValue();
        }
    }

    static String loadBuildDate() {
        if (isTestModeDisabled()) {
            return FFmpegKitConfig.getBuildDate();
        } else {
            return new SimpleDateFormat("yyyyMMdd", Locale.getDefault()).format(new Date());
        }
    }

    static void enableRedirection() {
        if (isTestModeDisabled()) {
            FFmpegKitConfig.enableRedirection();
        }
    }

    static void loadFFmpegKitAbiDetect() {
        loadLibrary("ffmpegkit_abidetect");
    }

    static boolean loadFFmpeg() {
        boolean nativeFFmpegLoaded = false;
        boolean nativeFFmpegTriedAndFailed = false;

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {

            /* LOADING LINKED LIBRARIES MANUALLY ON API < 21 */
            final List<String> externalLibrariesEnabled = loadExternalLibraries();
            for (String dependantLibrary : LIBRARIES_LINKED_WITH_CXX) {
                if (externalLibrariesEnabled.contains(dependantLibrary)) {
                    loadLibrary("c++_shared");
                    break;
                }
            }

            if (AbiDetect.ARM_V7A.equals(loadNativeAbi())) {
                try {
                    for (String ffmpegLibrary : FFMPEG_LIBRARIES) {
                        loadLibrary(ffmpegLibrary + "_neon");
                    }
                    nativeFFmpegLoaded = true;
                } catch (final Error e) {
                    android.util.Log.i(FFmpegKitConfig.TAG, String.format("NEON supported armeabi-v7a ffmpeg library not found. Loading default armeabi-v7a library.%s", Exceptions.getStackTraceString(e)));
                    nativeFFmpegTriedAndFailed = true;
                }
            }

            if (!nativeFFmpegLoaded) {
                for (String ffmpegLibrary : FFMPEG_LIBRARIES) {
                    loadLibrary(ffmpegLibrary);
                }
            }
        }

        return nativeFFmpegTriedAndFailed;
    }

    static void loadFFmpegKit(final boolean nativeFFmpegTriedAndFailed) {
        boolean nativeFFmpegKitLoaded = false;

        if (!nativeFFmpegTriedAndFailed && AbiDetect.ARM_V7A.equals(loadNativeAbi())) {
            try {

                /*
                 * THE TRY TO LOAD ARM-V7A-NEON FIRST. IF NOT LOAD DEFAULT ARM-V7A
                 */

                loadLibrary("ffmpegkit_armv7a_neon");
                nativeFFmpegKitLoaded = true;
                AbiDetect.setArmV7aNeonLoaded();
            } catch (final Error e) {
                android.util.Log.i(FFmpegKitConfig.TAG, String.format("NEON supported armeabi-v7a ffmpegkit library not found. Loading default armeabi-v7a library.%s", Exceptions.getStackTraceString(e)));
            }
        }

        if (!nativeFFmpegKitLoaded) {
            loadLibrary("ffmpegkit");
        }
    }

    @SuppressWarnings("deprecation")
    static String getDeviceDebugInformation() {
        final StringBuilder stringBuilder = new StringBuilder();

        stringBuilder.append("brand: ");
        stringBuilder.append(Build.BRAND);
        stringBuilder.append(", model: ");
        stringBuilder.append(Build.MODEL);
        stringBuilder.append(", device: ");
        stringBuilder.append(Build.DEVICE);
        stringBuilder.append(", api level: ");
        stringBuilder.append(Build.VERSION.SDK_INT);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            stringBuilder.append(", abis: ");
            stringBuilder.append(FFmpegKitConfig.argumentsToString(Build.SUPPORTED_ABIS));
            stringBuilder.append(", 32bit abis: ");
            stringBuilder.append(FFmpegKitConfig.argumentsToString(Build.SUPPORTED_32_BIT_ABIS));
            stringBuilder.append(", 64bit abis: ");
            stringBuilder.append(FFmpegKitConfig.argumentsToString(Build.SUPPORTED_64_BIT_ABIS));
        } else {
            stringBuilder.append(", cpu abis: ");
            stringBuilder.append(Build.CPU_ABI);
            stringBuilder.append(", cpu abi2s: ");
            stringBuilder.append(Build.CPU_ABI2);
        }

        return stringBuilder.toString();
    }

}
