/*
 * Copyright (c) 2018-2020 Taner Sener
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

import android.content.Context;
import android.os.Build;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

/**
 * <p>This class is used to configure FFmpegKit library utilities/tools.
 *
 * <p>1. {@link LogCallback}: This class redirects FFmpeg/FFprobe output to Logcat by default. As
 * an alternative, it is possible not to print messages to Logcat and pass them to a
 * {@link LogCallback} function. This function can decide whether to print these logs, show them
 * inside another container or ignore them.
 *
 * <p>2. {@link #setLogLevel(Level)}/{@link #getLogLevel()}: Use this methods to set/get
 * FFmpeg/FFprobe log severity.
 *
 * <p>3. {@link StatisticsCallback}: It is possible to receive statistics about an ongoing
 * operation by defining a {@link StatisticsCallback} function or by calling
 * {@link #getLastReceivedStatistics()} method.
 *
 * <p>4. Font configuration: It is possible to register custom fonts with
 * {@link #setFontconfigConfigurationPath(String)} and
 * {@link #setFontDirectory(Context, String, Map)} methods.
 */
public class FFmpegKitConfig {

    public static final int RETURN_CODE_SUCCESS = 0;

    public static final int RETURN_CODE_CANCEL = 255;

    private static int lastReturnCode = 0;

    /**
     * Defines tag used for logging.
     */
    public static final String TAG = "ffmpeg-kit";

    public static final String FFMPEG_KIT_PIPE_PREFIX = "mf_pipe_";

    private static LogCallback logCallbackFunction;

    private static Level activeLogLevel;

    private static StatisticsCallback statisticsCallbackFunction;

    private static Statistics lastReceivedStatistics;

    private static int lastCreatedPipeIndex;

    private static final List<FFmpegExecution> executions;

    static {

        Log.i(FFmpegKitConfig.TAG, "Loading ffmpeg-kit.");

        boolean nativeFFmpegLoaded = false;
        boolean nativeFFmpegTriedAndFailed = false;
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {

            /* LOADING LIBRARIES MANUALLY ON API < 21 */
            final List<String> externalLibrariesEnabled = getExternalLibraries();
            if (externalLibrariesEnabled.contains("tesseract") || externalLibrariesEnabled.contains("x265") || externalLibrariesEnabled.contains("snappy") || externalLibrariesEnabled.contains("openh264") || externalLibrariesEnabled.contains("rubberband")) {
                System.loadLibrary("c++_shared");
            }

            if (AbiDetect.ARM_V7A.equals(AbiDetect.getNativeAbi())) {
                try {
                    System.loadLibrary("avutil_neon");
                    System.loadLibrary("swscale_neon");
                    System.loadLibrary("swresample_neon");
                    System.loadLibrary("avcodec_neon");
                    System.loadLibrary("avformat_neon");
                    System.loadLibrary("avfilter_neon");
                    System.loadLibrary("avdevice_neon");
                    nativeFFmpegLoaded = true;
                } catch (final UnsatisfiedLinkError e) {
                    Log.i(FFmpegKitConfig.TAG, "NEON supported armeabi-v7a ffmpeg library not found. Loading default armeabi-v7a library.", e);
                    nativeFFmpegTriedAndFailed = true;
                }
            }

            if (!nativeFFmpegLoaded) {
                System.loadLibrary("avutil");
                System.loadLibrary("swscale");
                System.loadLibrary("swresample");
                System.loadLibrary("avcodec");
                System.loadLibrary("avformat");
                System.loadLibrary("avfilter");
                System.loadLibrary("avdevice");
            }
        }

        /* ALL FFMPEG-KIT LIBRARIES LOADED AT STARTUP */
        Abi.class.getName();
        FFmpegKit.class.getName();
        FFprobeKit.class.getName();

        boolean nativeFFmpegKitLoaded = false;
        if (!nativeFFmpegTriedAndFailed && AbiDetect.ARM_V7A.equals(AbiDetect.getNativeAbi())) {
            try {

                /*
                 * THE TRY TO LOAD ARM-V7A-NEON FIRST. IF NOT LOAD DEFAULT ARM-V7A
                 */

                System.loadLibrary("ffmpegkit_armv7a_neon");
                nativeFFmpegKitLoaded = true;
                AbiDetect.setArmV7aNeonLoaded(true);
            } catch (final UnsatisfiedLinkError e) {
                Log.i(FFmpegKitConfig.TAG, "NEON supported armeabi-v7a ffmpegkit library not found. Loading default armeabi-v7a library.", e);
            }
        }

        if (!nativeFFmpegKitLoaded) {
            System.loadLibrary("ffmpegkit");
        }

        Log.i(FFmpegKitConfig.TAG, String.format("Loaded ffmpeg-kit-%s-%s-%s-%s.", getPackageName(), AbiDetect.getAbi(), getVersion(), getBuildDate()));

        /* NATIVE LOG LEVEL IS RECEIVED ONLY ON STARTUP */
        activeLogLevel = Level.from(getNativeLogLevel());

        lastReceivedStatistics = new Statistics();

        enableRedirection();

        lastCreatedPipeIndex = 0;

        executions = Collections.synchronizedList(new ArrayList<FFmpegExecution>());
    }

    /**
     * Default constructor hidden.
     */
    private FFmpegKitConfig() {
    }

    /**
     * <p>Enables log and statistics redirection.
     * <p>When redirection is not enabled FFmpeg/FFprobe logs are printed to stderr. By enabling
     * redirection, they are routed to Logcat and can be routed further to a callback function.
     * <p>Statistics redirection behaviour is similar. Statistics are not printed at all if
     * redirection is not enabled. If it is enabled then it is possible to define a statistics
     * callback function but if you don't, they are not printed anywhere and only saved as
     * <code>lastReceivedStatistics</code> data which can be polled with
     * {@link #getLastReceivedStatistics()}.
     * <p>Note that redirection is enabled by default. If you do not want to use its functionality
     * please use {@link #disableRedirection()} to disable it.
     */
    public static void enableRedirection() {
        enableNativeRedirection();
    }

    /**
     * <p>Disables log and statistics redirection.
     */
    public static void disableRedirection() {
        disableNativeRedirection();
    }

    /**
     * Returns log level.
     *
     * @return log level
     */
    public static Level getLogLevel() {
        return activeLogLevel;
    }

    /**
     * Sets log level.
     *
     * @param level log level
     */
    public static void setLogLevel(final Level level) {
        if (level != null) {
            activeLogLevel = level;
            setNativeLogLevel(level.getValue());
        }
    }

    /**
     * <p>Sets a callback function to redirect FFmpeg/FFprobe logs.
     *
     * @param newLogCallback new log callback function or NULL to disable a previously defined callback
     */
    public static void enableLogCallback(final LogCallback newLogCallback) {
        logCallbackFunction = newLogCallback;
    }

    /**
     * <p>Sets a callback function to redirect FFmpeg statistics.
     *
     * @param statisticsCallback new statistics callback function or NULL to disable a previously defined callback
     */
    public static void enableStatisticsCallback(final StatisticsCallback statisticsCallback) {
        statisticsCallbackFunction = statisticsCallback;
    }

    /**
     * <p>Log redirection method called by JNI/native part.
     *
     * @param executionId id of the execution that generated this log, 0 by default
     * @param levelValue  log level as defined in {@link Level}
     * @param logMessage  redirected log message
     */
    private static void log(final long executionId, final int levelValue, final byte[] logMessage) {
        final Level level = Level.from(levelValue);
        final String text = new String(logMessage);

        // AV_LOG_STDERR logs are always redirected
        if ((activeLogLevel == Level.AV_LOG_QUIET && levelValue != Level.AV_LOG_STDERR.getValue()) || levelValue > activeLogLevel.getValue()) {
            // LOG NEITHER PRINTED NOR FORWARDED
            return;
        }

        if (logCallbackFunction != null) {
            try {
                logCallbackFunction.apply(new LogMessage(executionId, level, text));
            } catch (final Exception e) {
                Log.e(FFmpegKitConfig.TAG, "Exception thrown inside LogCallback block", e);
            }
        } else {
            switch (level) {
                case AV_LOG_QUIET: {
                    // PRINT NO OUTPUT
                }
                break;
                case AV_LOG_TRACE:
                case AV_LOG_DEBUG: {
                    android.util.Log.d(TAG, text);
                }
                break;
                case AV_LOG_STDERR:
                case AV_LOG_VERBOSE: {
                    android.util.Log.v(TAG, text);
                }
                break;
                case AV_LOG_INFO: {
                    android.util.Log.i(TAG, text);
                }
                break;
                case AV_LOG_WARNING: {
                    android.util.Log.w(TAG, text);
                }
                break;
                case AV_LOG_ERROR:
                case AV_LOG_FATAL:
                case AV_LOG_PANIC: {
                    android.util.Log.e(TAG, text);
                }
                break;
                default: {
                    android.util.Log.v(TAG, text);
                }
                break;
            }
        }
    }

    /**
     * <p>Statistics redirection method called by JNI/native part.
     *
     * @param executionId      id of the execution that generated this statistics, 0 by default
     * @param videoFrameNumber last processed frame number for videos
     * @param videoFps         frames processed per second for videos
     * @param videoQuality     quality of the video stream
     * @param size             size in bytes
     * @param time             processed duration in milliseconds
     * @param bitrate          output bit rate in kbits/s
     * @param speed            processing speed = processed duration / operation duration
     */
    private static void statistics(final long executionId, final int videoFrameNumber,
                                   final float videoFps, final float videoQuality, final long size,
                                   final int time, final double bitrate, final double speed) {
        final Statistics newStatistics = new Statistics(executionId, videoFrameNumber, videoFps, videoQuality, size, time, bitrate, speed);
        lastReceivedStatistics.update(newStatistics);

        if (statisticsCallbackFunction != null) {
            try {
                statisticsCallbackFunction.apply(lastReceivedStatistics);
            } catch (final Exception e) {
                Log.e(FFmpegKitConfig.TAG, "Exception thrown inside StatisticsCallback block", e);
            }
        }
    }

    /**
     * <p>Returns the last received statistics data.
     *
     * @return last received statistics data
     */
    public static Statistics getLastReceivedStatistics() {
        return lastReceivedStatistics;
    }

    /**
     * <p>Resets last received statistics. It is recommended to call it before starting a new execution.
     */
    public static void resetStatistics() {
        lastReceivedStatistics = new Statistics();
    }

    /**
     * <p>Sets and overrides <code>fontconfig</code> configuration directory.
     *
     * @param path directory which contains fontconfig configuration (fonts.conf)
     * @return zero on success, non-zero on error
     */
    public static int setFontconfigConfigurationPath(final String path) {
        return setNativeEnvironmentVariable("FONTCONFIG_PATH", path);
    }

    /**
     * <p>Registers fonts inside the given path, so they are available to use in FFmpeg filters.
     *
     * <p>Note that you need to build <code>FFmpegKit</code> with <code>fontconfig</code>
     * enabled or use a prebuilt package with <code>fontconfig</code> inside to use this feature.
     *
     * @param context           application context to access application data
     * @param fontDirectoryPath directory which contains fonts (.ttf and .otf files)
     * @param fontNameMapping   custom font name mappings, useful to access your fonts with more friendly names
     */
    public static void setFontDirectory(final Context context, final String fontDirectoryPath, final Map<String, String> fontNameMapping) {
        final File cacheDir = context.getCacheDir();
        int validFontNameMappingCount = 0;

        final File tempConfigurationDirectory = new File(cacheDir, ".ffmpegkit");
        if (!tempConfigurationDirectory.exists()) {
            boolean tempFontConfDirectoryCreated = tempConfigurationDirectory.mkdirs();
            Log.d(TAG, String.format("Created temporary font conf directory: %s.", tempFontConfDirectoryCreated));
        }

        final File fontConfiguration = new File(tempConfigurationDirectory, "fonts.conf");
        if (fontConfiguration.exists()) {
            boolean fontConfigurationDeleted = fontConfiguration.delete();
            Log.d(TAG, String.format("Deleted old temporary font configuration: %s.", fontConfigurationDeleted));
        }

        /* PROCESS MAPPINGS FIRST */
        final StringBuilder fontNameMappingBlock = new StringBuilder("");
        if (fontNameMapping != null && (fontNameMapping.size() > 0)) {
            fontNameMapping.entrySet();
            for (Map.Entry<String, String> mapping : fontNameMapping.entrySet()) {
                String fontName = mapping.getKey();
                String mappedFontName = mapping.getValue();

                if ((fontName != null) && (mappedFontName != null) && (fontName.trim().length() > 0) && (mappedFontName.trim().length() > 0)) {
                    fontNameMappingBlock.append("        <match target=\"pattern\">\n");
                    fontNameMappingBlock.append("                <test qual=\"any\" name=\"family\">\n");
                    fontNameMappingBlock.append(String.format("                        <string>%s</string>\n", fontName));
                    fontNameMappingBlock.append("                </test>\n");
                    fontNameMappingBlock.append("                <edit name=\"family\" mode=\"assign\" binding=\"same\">\n");
                    fontNameMappingBlock.append(String.format("                        <string>%s</string>\n", mappedFontName));
                    fontNameMappingBlock.append("                </edit>\n");
                    fontNameMappingBlock.append("        </match>\n");

                    validFontNameMappingCount++;
                }
            }
        }

        final String fontConfig = "<?xml version=\"1.0\"?>\n" +
                "<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">\n" +
                "<fontconfig>\n" +
                "    <dir>.</dir>\n" +
                "    <dir>" + fontDirectoryPath + "</dir>\n" +
                fontNameMappingBlock +
                "</fontconfig>";

        final AtomicReference<FileOutputStream> reference = new AtomicReference<>();
        try {
            final FileOutputStream outputStream = new FileOutputStream(fontConfiguration);
            reference.set(outputStream);

            outputStream.write(fontConfig.getBytes());
            outputStream.flush();

            Log.d(TAG, String.format("Saved new temporary font configuration with %d font name mappings.", validFontNameMappingCount));

            setFontconfigConfigurationPath(tempConfigurationDirectory.getAbsolutePath());

            Log.d(TAG, String.format("Font directory %s registered successfully.", fontDirectoryPath));

        } catch (final IOException e) {
            Log.e(TAG, String.format("Failed to set font directory: %s.", fontDirectoryPath), e);
        } finally {
            if (reference.get() != null) {
                try {
                    reference.get().close();
                } catch (IOException e) {
                    // DO NOT PRINT THIS ERROR
                }
            }
        }
    }

    /**
     * <p>Returns package name.
     *
     * @return guessed package name according to supported external libraries
     * @since 3.0
     */
    public static String getPackageName() {
        return Packages.getPackageName();
    }

    /**
     * <p>Returns supported external libraries.
     *
     * @return list of supported external libraries
     * @since 3.0
     */
    public static List<String> getExternalLibraries() {
        return Packages.getExternalLibraries();
    }

    /**
     * <p>Creates a new named pipe to use in <code>FFmpeg</code> operations.
     *
     * <p>Please note that creator is responsible of closing created pipes.
     *
     * @param context application context
     * @return the full path of named pipe
     */
    public static String registerNewFFmpegPipe(final Context context) {

        // PIPES ARE CREATED UNDER THE CACHE DIRECTORY
        final File cacheDir = context.getCacheDir();

        final String newFFmpegPipePath = cacheDir + File.separator + FFMPEG_KIT_PIPE_PREFIX + (++lastCreatedPipeIndex);

        // FIRST CLOSE OLD PIPES WITH THE SAME NAME
        closeFFmpegPipe(newFFmpegPipePath);

        int rc = registerNewNativeFFmpegPipe(newFFmpegPipePath);
        if (rc == 0) {
            return newFFmpegPipePath;
        } else {
            Log.e(TAG, String.format("Failed to register new FFmpeg pipe %s. Operation failed with rc=%d.", newFFmpegPipePath, rc));
            return null;
        }
    }

    /**
     * <p>Closes a previously created <code>FFmpeg</code> pipe.
     *
     * @param ffmpegPipePath full path of ffmpeg pipe
     */
    public static void closeFFmpegPipe(final String ffmpegPipePath) {
        File file = new File(ffmpegPipePath);
        if (file.exists()) {
            file.delete();
        }
    }

    /**
     * Returns the list of camera ids supported.
     *
     * @param context application context
     * @return the list of camera ids supported or an empty list if no supported camera is found
     */
    public static List<String> getSupportedCameraIds(final Context context) {
        final List<String> detectedCameraIdList = new ArrayList<>();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            detectedCameraIdList.addAll(CameraSupport.extractSupportedCameraIds(context));
        }

        return detectedCameraIdList;
    }

    /**
     * <p>Returns FFmpeg version bundled within the library.
     *
     * @return FFmpeg version
     */
    public static String getFFmpegVersion() {
        return getNativeFFmpegVersion();
    }

    /**
     * <p>Returns FFmpegKit library version.
     *
     * @return FFmpegKit version
     */
    public static String getVersion() {
        if (isLTSBuild()) {
            return String.format("%s-lts", getNativeVersion());
        } else {
            return getNativeVersion();
        }
    }

    /**
     * <p>Returns whether FFmpegKit release is a long term release or not.
     *
     * @return YES or NO
     */
    public static boolean isLTSBuild() {
        return AbiDetect.isNativeLTSBuild();
    }

    /**
     * <p>Returns FFmpegKit library build date.
     *
     * @return FFmpegKit library build date
     */
    public static String getBuildDate() {
        return getNativeBuildDate();
    }

    /**
     * <p>Returns return code of last executed command.
     *
     * @return return code of last executed command
     * @since 3.0
     */
    public static int getLastReturnCode() {
        return lastReturnCode;
    }

    /**
     * <p>Returns log output of last executed single FFmpeg/FFprobe command.
     *
     * <p>This method does not support executing multiple concurrent commands. If you execute
     * multiple commands at the same time, this method will return output from all executions.
     *
     * <p>Please note that disabling redirection using {@link FFmpegKitConfig#disableRedirection()} method
     * also disables this functionality.
     *
     * @return output of the last executed command
     * @since 3.0
     */
    public static String getLastCommandOutput() {
        String nativeLastCommandOutput = getNativeLastCommandOutput();
        if (nativeLastCommandOutput != null) {

            // REPLACING CH(13) WITH CH(10)
            nativeLastCommandOutput = nativeLastCommandOutput.replace('\r', '\n');
        }
        return nativeLastCommandOutput;
    }

    /**
     * <p>Prints the output of the last executed FFmpeg/FFprobe command to the Logcat at the
     * specified priority.
     *
     * <p>This method does not support executing multiple concurrent commands. If you execute
     * multiple commands at the same time, this method will print output from all executions.
     *
     * @param logPriority one of {@link Log#VERBOSE}, {@link Log#DEBUG}, {@link Log#INFO},
     *                    {@link Log#WARN}, {@link Log#ERROR}, {@link Log#ASSERT}
     * @since 4.3
     */
    public static void printLastCommandOutput(int logPriority) {
        final int LOGGER_ENTRY_MAX_LEN = 4 * 1000;

        String buffer = getLastCommandOutput();
        do {
            if (buffer.length() <= LOGGER_ENTRY_MAX_LEN) {
                Log.println(logPriority, FFmpegKitConfig.TAG, buffer);
                buffer = "";
            } else {
                final int index = buffer.substring(0, LOGGER_ENTRY_MAX_LEN).lastIndexOf('\n');
                if (index < 0) {
                    Log.println(logPriority, FFmpegKitConfig.TAG, buffer.substring(0, LOGGER_ENTRY_MAX_LEN));
                    buffer = buffer.substring(LOGGER_ENTRY_MAX_LEN);
                } else {
                    Log.println(logPriority, FFmpegKitConfig.TAG, buffer.substring(0, index));
                    buffer = buffer.substring(index);
                }
            }
        } while (buffer.length() > 0);
    }

    /**
     * <p>Sets an environment variable.
     *
     * @param variableName  environment variable name
     * @param variableValue environment variable value
     * @return zero on success, non-zero on error
     */
    public static int setEnvironmentVariable(final String variableName, final String variableValue) {
        return setNativeEnvironmentVariable(variableName, variableValue);
    }

    /**
     * <p>Registers a new ignored signal. Ignored signals are not handled by the library.
     *
     * @param signal signal number to ignore
     */
    public static void ignoreSignal(final Signal signal) {
        ignoreNativeSignal(signal.getValue());
    }

    /**
     * <p>Synchronously executes FFmpeg with arguments provided.
     *
     * @param executionId id of the execution
     * @param arguments   FFmpeg command options/arguments as string array
     * @return zero on successful execution, 255 on user cancel and non-zero on error
     */
    static int ffmpegExecute(final long executionId, final String[] arguments) {
        final FFmpegExecution currentFFmpegExecution = new FFmpegExecution(executionId, arguments);
        executions.add(currentFFmpegExecution);

        try {
            final int lastReturnCode = nativeFFmpegExecute(executionId, arguments);

            FFmpegKitConfig.setLastReturnCode(lastReturnCode);

            return lastReturnCode;
        } finally {
            executions.remove(currentFFmpegExecution);
        }
    }

    /**
     * Updates return code value for the last executed command.
     *
     * @param newLastReturnCode new last return code value
     */
    static void setLastReturnCode(int newLastReturnCode) {
        lastReturnCode = newLastReturnCode;
    }

    /**
     * <p>Lists ongoing FFmpeg executions.
     *
     * @return list of ongoing FFmpeg executions
     */
    static List<FFmpegExecution> listFFmpegExecutions() {
        return new ArrayList<>(executions);
    }

    /**
     * <p>Enables native redirection. Necessary for log and statistics callback functions.
     */
    private static native void enableNativeRedirection();

    /**
     * <p>Disables native redirection
     */
    private static native void disableNativeRedirection();

    /**
     * Sets native log level
     *
     * @param level log level
     */
    private static native void setNativeLogLevel(int level);

    /**
     * Returns native log level.
     *
     * @return log level
     */
    private static native int getNativeLogLevel();

    /**
     * <p>Returns FFmpeg version bundled within the library natively.
     *
     * @return FFmpeg version
     */
    private native static String getNativeFFmpegVersion();

    /**
     * <p>Returns FFmpegKit library version natively.
     *
     * @return FFmpegKit version
     */
    private native static String getNativeVersion();

    /**
     * <p>Synchronously executes FFmpeg natively with arguments provided.
     *
     * @param executionId id of the execution
     * @param arguments   FFmpeg command options/arguments as string array
     * @return zero on successful execution, 255 on user cancel and non-zero on error
     */
    private native static int nativeFFmpegExecute(final long executionId, final String[] arguments);

    /**
     * <p>Cancels an ongoing FFmpeg operation natively. This function does not wait for termination
     * to complete and returns immediately.
     *
     * @param executionId id of the execution
     */
    native static void nativeFFmpegCancel(final long executionId);

    /**
     * <p>Synchronously executes FFprobe natively with arguments provided.
     *
     * @param arguments FFprobe command options/arguments as string array
     * @return zero on successful execution, 255 on user cancel and non-zero on error
     */
    native static int nativeFFprobeExecute(final String[] arguments);

    /**
     * <p>Creates natively a new named pipe to use in <code>FFmpeg</code> operations.
     *
     * <p>Please note that creator is responsible of closing created pipes.
     *
     * @param ffmpegPipePath full path of ffmpeg pipe
     * @return zero on successful creation, non-zero on error
     */
    private native static int registerNewNativeFFmpegPipe(final String ffmpegPipePath);

    /**
     * <p>Returns FFmpegKit library build date natively.
     *
     * @return FFmpegKit library build date
     */
    private native static String getNativeBuildDate();

    /**
     * <p>Sets an environment variable natively.
     *
     * @param variableName  environment variable name
     * @param variableValue environment variable value
     * @return zero on success, non-zero on error
     */
    private native static int setNativeEnvironmentVariable(final String variableName, final String variableValue);

    /**
     * <p>Returns log output of the last executed single command natively.
     *
     * @return output of the last executed single command
     */
    private native static String getNativeLastCommandOutput();

    /**
     * <p>Registers a new ignored signal natively. Ignored signals are not handled by the library.
     *
     * @param signum signal number
     */
    private native static void ignoreNativeSignal(final int signum);

}
