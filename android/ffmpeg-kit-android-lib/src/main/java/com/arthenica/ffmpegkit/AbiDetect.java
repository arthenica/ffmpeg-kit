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
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit;

/**
 * <p>Detects the running ABI name natively using Google <code>cpu-features</code> library.
 */
public class AbiDetect {

    static {
        armV7aNeonLoaded = false;

        NativeLoader.loadFFmpegKitAbiDetect();

        /* ALL LIBRARIES LOADED AT STARTUP */
        FFmpegKit.class.getName();
        FFmpegKitConfig.class.getName();
        FFprobeKit.class.getName();
    }

    static final String ARM_V7A = "arm-v7a";

    static final String ARM_V7A_NEON = "arm-v7a-neon";

    private static boolean armV7aNeonLoaded;

    /**
     * Default constructor hidden.
     */
    private AbiDetect() {
    }

    static void setArmV7aNeonLoaded() {
        armV7aNeonLoaded = true;
    }

    /**
     * <p>Returns the ABI name loaded.
     *
     * @return ABI name loaded
     */
    public static String getAbi() {
        if (armV7aNeonLoaded) {
            return ARM_V7A_NEON;
        } else {
            return getNativeAbi();
        }
    }

    /**
     * <p>Returns the ABI name of the cpu running.
     *
     * @return ABI name of the cpu running
     */
    public static String getCpuAbi() {
        return getNativeCpuAbi();
    }

    /**
     * <p>Returns the ABI name loaded natively.
     *
     * @return ABI name loaded
     */
    native static String getNativeAbi();

    /**
     * <p>Returns the ABI name of the cpu running natively.
     *
     * @return ABI name of the cpu running
     */
    native static String getNativeCpuAbi();

    /**
     * <p>Returns whether FFmpegKit release is a long term release or not natively.
     *
     * @return yes or no
     */
    native static boolean isNativeLTSBuild();

    /**
     * <p>Returns the build configuration for <code>FFmpeg</code> natively.
     *
     * @return build configuration string
     */
    native static String getNativeBuildConf();

}
