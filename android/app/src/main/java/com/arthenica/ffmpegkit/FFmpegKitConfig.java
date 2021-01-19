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

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.ParcelFileDescriptor;
import android.provider.DocumentsContract;
import android.util.SparseArray;

import com.arthenica.smartexception.java.Exceptions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;

/**
 * <p>This class is used to configure FFmpegKit library and tools coming with it.
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

    /**
     * The tag used for logging.
     */
    public static final String TAG = "ffmpeg-kit";

    /**
     * Prefix of named pipes created by ffmpeg kit.
     */
    public static final String FFMPEG_KIT_NAMED_PIPE_PREFIX = "fk_pipe_";

    /**
     * Generates ids for named ffmpeg kit pipes.
     */
    private static final AtomicLong pipeIndexGenerator;

    /* SESSION HISTORY VARIABLES */
    private static int sessionHistorySize;
    private static final Map<Long, Session> sessionHistoryMap;
    private static final Queue<Session> sessionHistoryQueue;
    private static final Object sessionHistoryLock;

    /**
     * Executor service for async executions.
     */
    private static ExecutorService asyncExecutorService;
    private static LogCallback globalLogCallbackFunction;
    private static StatisticsCallback globalStatisticsCallbackFunction;
    private static ExecuteCallback globalExecuteCallbackFunction;
    private static Level activeLogLevel;
    private static int asyncConcurrencyLimit;
    private static final SparseArray<ParcelFileDescriptor> pfdMap;
    private static LogRedirectionStrategy logRedirectionStrategy;

    static {

        Exceptions.registerRootPackage("com.arthenica");

        android.util.Log.i(FFmpegKitConfig.TAG, "Loading ffmpeg-kit.");

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
                    android.util.Log.i(FFmpegKitConfig.TAG, String.format("NEON supported armeabi-v7a ffmpeg library not found. Loading default armeabi-v7a library.%s", Exceptions.getStackTraceString(e)));
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
                AbiDetect.setArmV7aNeonLoaded();
            } catch (final UnsatisfiedLinkError e) {
                android.util.Log.i(FFmpegKitConfig.TAG, String.format("NEON supported armeabi-v7a ffmpegkit library not found. Loading default armeabi-v7a library.%s", Exceptions.getStackTraceString(e)));
            }
        }

        if (!nativeFFmpegKitLoaded) {
            System.loadLibrary("ffmpegkit");
        }

        android.util.Log.i(FFmpegKitConfig.TAG, String.format("Loaded ffmpeg-kit-%s-%s-%s-%s.", getPackageName(), AbiDetect.getAbi(), getVersion(), getBuildDate()));

        pipeIndexGenerator = new AtomicLong(1);
        asyncConcurrencyLimit = 10;
        asyncExecutorService = Executors.newFixedThreadPool(asyncConcurrencyLimit);

        /* NATIVE LOG LEVEL IS RECEIVED ONLY ON STARTUP */
        activeLogLevel = Level.from(getNativeLogLevel());

        sessionHistorySize = 10;
        sessionHistoryMap = Collections.synchronizedMap(new LinkedHashMap<Long, Session>() {

            @Override
            protected boolean removeEldestEntry(Map.Entry<Long, Session> eldest) {
                return (this.size() > sessionHistorySize);
            }
        });
        sessionHistoryQueue = new LinkedList<>();
        sessionHistoryLock = new Object();

        pfdMap = new SparseArray<>();
        logRedirectionStrategy = LogRedirectionStrategy.PRINT_LOGS_WHEN_NO_CALLBACKS_DEFINED;

        enableRedirection();
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
     * <p>Log redirection method called by JNI/native part.
     *
     * @param sessionId  id of the session that generated this log, 0 by default
     * @param levelValue log level as defined in {@link Level}
     * @param logMessage redirected log message
     */
    private static void log(final long sessionId, final int levelValue, final byte[] logMessage) {
        final Level level = Level.from(levelValue);
        final String text = new String(logMessage);
        final Log log = new Log(sessionId, level, text);
        boolean globalCallbackDefined = false;
        boolean sessionCallbackDefined = false;
        LogRedirectionStrategy activeLogRedirectionStrategy = FFmpegKitConfig.logRedirectionStrategy;

        // AV_LOG_STDERR logs are always redirected
        if ((activeLogLevel == Level.AV_LOG_QUIET && levelValue != Level.AV_LOG_STDERR.getValue()) || levelValue > activeLogLevel.getValue()) {
            // LOG NEITHER PRINTED NOR FORWARDED
            return;
        }

        final Session session = getSession(sessionId);
        if (session != null) {
            activeLogRedirectionStrategy = session.getLogRedirectionStrategy();
            session.addLog(log);

            if (session.getLogCallback() != null) {
                sessionCallbackDefined = true;

                try {
                    // NOTIFY SESSION CALLBACK IF DEFINED
                    session.getLogCallback().apply(log);
                } catch (final Exception e) {
                    android.util.Log.e(FFmpegKitConfig.TAG, String.format("Exception thrown inside session LogCallback block.%s", Exceptions.getStackTraceString(e)));
                }
            }
        }

        final LogCallback globalLogCallbackFunction = FFmpegKitConfig.globalLogCallbackFunction;
        if (globalLogCallbackFunction != null) {
            globalCallbackDefined = true;

            try {
                // NOTIFY GLOBAL CALLBACK IF DEFINED
                globalLogCallbackFunction.apply(log);
            } catch (final Exception e) {
                android.util.Log.e(FFmpegKitConfig.TAG, String.format("Exception thrown inside global LogCallback block.%s", Exceptions.getStackTraceString(e)));
            }
        }

        // EXECUTE THE LOG STRATEGY
        switch (activeLogRedirectionStrategy) {
            case NEVER_PRINT_LOGS: {
                return;
            }
            case PRINT_LOGS_WHEN_GLOBAL_CALLBACK_NOT_DEFINED: {
                if (globalCallbackDefined) {
                    return;
                }
            }
            break;
            case PRINT_LOGS_WHEN_SESSION_CALLBACK_NOT_DEFINED: {
                if (sessionCallbackDefined) {
                    return;
                }
            }
            case PRINT_LOGS_WHEN_NO_CALLBACKS_DEFINED: {
                if (globalCallbackDefined || sessionCallbackDefined) {
                    return;
                }
            }
        }

        // PRINT LOGS
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
            case AV_LOG_STDERR:
            case AV_LOG_VERBOSE:
            default: {
                android.util.Log.v(TAG, text);
            }
            break;
        }
    }

    /**
     * <p>Statistics redirection method called by JNI/native part.
     *
     * @param sessionId        id of the session that generated this statistics, 0 by default
     * @param videoFrameNumber last processed frame number for videos
     * @param videoFps         frames processed per second for videos
     * @param videoQuality     quality of the video stream
     * @param size             size in bytes
     * @param time             processed duration in milliseconds
     * @param bitrate          output bit rate in kbits/s
     * @param speed            processing speed = processed duration / operation duration
     */
    private static void statistics(final long sessionId, final int videoFrameNumber,
                                   final float videoFps, final float videoQuality, final long size,
                                   final int time, final double bitrate, final double speed) {
        final Statistics statistics = new Statistics(sessionId, videoFrameNumber, videoFps, videoQuality, size, time, bitrate, speed);

        final Session session = getSession(sessionId);
        if (session != null) {
            session.addStatistics(statistics);

            if (session.getStatisticsCallback() != null) {
                try {
                    // NOTIFY SESSION CALLBACK IF DEFINED
                    session.getStatisticsCallback().apply(statistics);
                } catch (final Exception e) {
                    android.util.Log.e(FFmpegKitConfig.TAG, String.format("Exception thrown inside session StatisticsCallback block.%s", Exceptions.getStackTraceString(e)));
                }
            }
        }

        final StatisticsCallback globalStatisticsCallbackFunction = FFmpegKitConfig.globalStatisticsCallbackFunction;
        if (globalStatisticsCallbackFunction != null) {
            try {
                // NOTIFY GLOBAL CALLBACK IF DEFINED
                globalStatisticsCallbackFunction.apply(statistics);
            } catch (final Exception e) {
                android.util.Log.e(FFmpegKitConfig.TAG, String.format("Exception thrown inside global StatisticsCallback block.%s", Exceptions.getStackTraceString(e)));
            }
        }
    }

    /**
     * <p>Returns the last received statistics data.
     *
     * @return last received statistics data or null if no statistics data is available
     */
    public static Statistics getLastReceivedStatistics() {
        final Session lastSession = getLastSession();
        if (lastSession != null) {
            return lastSession.getStatistics().peek();
        } else {
            return null;
        }
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
     * <p>Registers fonts inside the given path, so they become available to use in FFmpeg filters.
     *
     * <p>Note that you need to build <code>FFmpegKit</code> with <code>fontconfig</code>
     * enabled or use a prebuilt package with <code>fontconfig</code> inside to use this feature.
     *
     * @param context           application context to access application data
     * @param fontDirectoryPath directory which contains fonts (.ttf and .otf files)
     * @param fontNameMapping   custom font name mappings, useful to access your fonts with more
     *                          friendly names
     */
    public static void setFontDirectory(final Context context, final String fontDirectoryPath, final Map<String, String> fontNameMapping) {
        final File cacheDir = context.getCacheDir();
        int validFontNameMappingCount = 0;

        final File tempConfigurationDirectory = new File(cacheDir, ".ffmpegkit");
        if (!tempConfigurationDirectory.exists()) {
            boolean tempFontConfDirectoryCreated = tempConfigurationDirectory.mkdirs();
            android.util.Log.d(TAG, String.format("Created temporary font conf directory: %s.", tempFontConfDirectoryCreated));
        }

        final File fontConfiguration = new File(tempConfigurationDirectory, "fonts.conf");
        if (fontConfiguration.exists()) {
            boolean fontConfigurationDeleted = fontConfiguration.delete();
            android.util.Log.d(TAG, String.format("Deleted old temporary font configuration: %s.", fontConfigurationDeleted));
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

            android.util.Log.d(TAG, String.format("Saved new temporary font configuration with %d font name mappings.", validFontNameMappingCount));

            setFontconfigConfigurationPath(tempConfigurationDirectory.getAbsolutePath());

            android.util.Log.d(TAG, String.format("Font directory %s registered successfully.", fontDirectoryPath));

        } catch (final IOException e) {
            android.util.Log.e(TAG, String.format("Failed to set font directory: %s.%s", fontDirectoryPath, Exceptions.getStackTraceString(e)));
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
     * <p>Returns <code>FFmpegKit</code> package name.
     *
     * @return FFmpegKit package name
     */
    public static String getPackageName() {
        return Packages.getPackageName();
    }

    /**
     * <p>Returns the list of supported external libraries.
     *
     * @return list of supported external libraries
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
     * @return the full path of the named pipe
     */
    public static String registerNewFFmpegPipe(final Context context) {

        // PIPES ARE CREATED UNDER THE CACHE DIRECTORY
        final File cacheDir = context.getCacheDir();

        final String newFFmpegPipePath = MessageFormat.format("{0}{1}{2}{3}", cacheDir, File.separator, FFMPEG_KIT_NAMED_PIPE_PREFIX, pipeIndexGenerator.getAndIncrement());

        // FIRST CLOSE OLD PIPES WITH THE SAME NAME
        closeFFmpegPipe(newFFmpegPipePath);

        int rc = registerNewNativeFFmpegPipe(newFFmpegPipePath);
        if (rc == 0) {
            return newFFmpegPipePath;
        } else {
            android.util.Log.e(TAG, String.format("Failed to register new FFmpeg pipe %s. Operation failed with rc=%d.", newFFmpegPipePath, rc));
            return null;
        }
    }

    /**
     * <p>Closes a previously created <code>FFmpeg</code> pipe.
     *
     * @param ffmpegPipePath full path of ffmpeg pipe
     */
    public static void closeFFmpegPipe(final String ffmpegPipePath) {
        final File file = new File(ffmpegPipePath);
        if (file.exists()) {
            file.delete();
        }
    }

    /**
     * Returns the list of camera ids supported.
     *
     * <p>Note that this method requires API Level >= 24. On older API levels it returns an empty
     * list.
     *
     * @param context application context
     * @return the list of camera ids supported or an empty list if no supported cameras are found
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
     * <p>Returns whether FFmpegKit release is a Long Term Release or not.
     *
     * @return true/yes or false/no
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
     * <p>Returns the return code of the last completed execution.
     *
     * @return return code of the last completed execution
     */
    public static int getLastReturnCode() {
        final Session lastSession = getLastSession();
        if (lastSession != null) {
            return lastSession.getReturnCode();
        } else {
            return 0;
        }
    }

    /**
     * <p>Returns the log output of the last executed FFmpeg/FFprobe command.
     *
     * <p>Please note that disabling redirection using {@link FFmpegKitConfig#disableRedirection()}
     * method also disables this functionality.
     *
     * @return output of the last executed command
     */
    public static String getLastCommandOutput() {
        final Session lastSession = getLastSession();
        if (lastSession != null) {

            // REPLACING CH(13) WITH CH(10)
            return lastSession.getAllLogsAsString().replace('\r', '\n');
        } else {
            return "";
        }
    }

    /**
     * <p>Prints the output of the last executed FFmpeg/FFprobe command to the Logcat at the
     * specified priority.
     *
     * @param logPriority one of {@link android.util.Log#VERBOSE},
     *                    {@link android.util.Log#DEBUG},
     *                    {@link android.util.Log#INFO},
     *                    {@link android.util.Log#WARN},
     *                    {@link android.util.Log#ERROR},
     *                    {@link android.util.Log#ASSERT}
     */
    public static void printLastCommandOutput(final int logPriority) {
        final int LOGGER_ENTRY_MAX_LEN = 4 * 1000;

        String buffer = getLastCommandOutput();
        do {
            if (buffer.length() <= LOGGER_ENTRY_MAX_LEN) {
                android.util.Log.println(logPriority, FFmpegKitConfig.TAG, buffer);
                buffer = "";
            } else {
                final int index = buffer.substring(0, LOGGER_ENTRY_MAX_LEN).lastIndexOf('\n');
                if (index < 0) {
                    android.util.Log.println(logPriority, FFmpegKitConfig.TAG, buffer.substring(0, LOGGER_ENTRY_MAX_LEN));
                    buffer = buffer.substring(LOGGER_ENTRY_MAX_LEN);
                } else {
                    android.util.Log.println(logPriority, FFmpegKitConfig.TAG, buffer.substring(0, index));
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
     * <p>Synchronously executes the ffmpeg session provided.
     *
     * @param ffmpegSession FFmpeg session which includes command options/arguments
     */
    static void ffmpegExecute(final FFmpegSession ffmpegSession) {
        addSession(ffmpegSession);
        ffmpegSession.startRunning();

        try {
            final int returnCode = nativeFFmpegExecute(ffmpegSession.getSessionId(), ffmpegSession.getArguments());
            ffmpegSession.complete(returnCode);
        } catch (final Exception e) {
            ffmpegSession.fail(e);
            android.util.Log.w(FFmpegKitConfig.TAG, String.format("FFmpeg execute failed: %s.%s", FFmpegKit.argumentsToString(ffmpegSession.getArguments()), Exceptions.getStackTraceString(e)));
        }
    }

    /**
     * <p>Synchronously executes the ffprobe session provided.
     *
     * @param ffprobeSession FFprobe session which includes command options/arguments
     */
    static void ffprobeExecute(final FFprobeSession ffprobeSession) {
        addSession(ffprobeSession);
        ffprobeSession.startRunning();

        try {
            final int returnCode = nativeFFprobeExecute(ffprobeSession.getSessionId(), ffprobeSession.getArguments());
            ffprobeSession.complete(returnCode);
        } catch (final Exception e) {
            ffprobeSession.fail(e);
            android.util.Log.w(FFmpegKitConfig.TAG, String.format("FFprobe execute failed: %s.%s", FFmpegKit.argumentsToString(ffprobeSession.getArguments()), Exceptions.getStackTraceString(e)));
        }
    }

    /**
     * <p>Synchronously executes the media information session provided.
     *
     * @param mediaInformationSession media information session which includes command options/arguments
     * @param waitTimeout             max time to wait until media information is transmitted
     */
    static void getMediaInformationExecute(final MediaInformationSession mediaInformationSession, final int waitTimeout) {
        addSession(mediaInformationSession);
        mediaInformationSession.startRunning();

        try {
            final int returnCode = nativeFFprobeExecute(mediaInformationSession.getSessionId(), mediaInformationSession.getArguments());
            mediaInformationSession.complete(returnCode);
            if (returnCode == ReturnCode.SUCCESS) {
                MediaInformation mediaInformation = MediaInformationParser.fromWithError(mediaInformationSession.getAllLogsAsString(waitTimeout));
                mediaInformationSession.setMediaInformation(mediaInformation);
            }
        } catch (final Exception e) {
            mediaInformationSession.fail(e);
            android.util.Log.w(FFmpegKitConfig.TAG, String.format("Get media information execute failed: %s.%s", FFmpegKit.argumentsToString(mediaInformationSession.getArguments()), Exceptions.getStackTraceString(e)));
        }
    }

    /**
     * <p>Asynchronously executes the ffmpeg session provided.
     *
     * @param ffmpegSession FFmpeg session which includes command options/arguments
     */
    static void asyncFFmpegExecute(final FFmpegSession ffmpegSession) {
        AsyncFFmpegExecuteTask asyncFFmpegExecuteTask = new AsyncFFmpegExecuteTask(ffmpegSession);
        Future<?> future = asyncExecutorService.submit(asyncFFmpegExecuteTask);
        ffmpegSession.setFuture(future);
    }

    /**
     * <p>Asynchronously executes the ffprobe session provided.
     *
     * @param ffprobeSession FFprobe session which includes command options/arguments
     */
    static void asyncFFprobeExecute(final FFprobeSession ffprobeSession) {
        AsyncFFprobeExecuteTask asyncFFmpegExecuteTask = new AsyncFFprobeExecuteTask(ffprobeSession);
        Future<?> future = asyncExecutorService.submit(asyncFFmpegExecuteTask);
        ffprobeSession.setFuture(future);
    }

    /**
     * <p>Asynchronously executes the media information session provided.
     *
     * @param mediaInformationSession media information session which includes command options/arguments
     * @param waitTimeout             max time to wait until media information is transmitted
     */
    static void asyncGetMediaInformationExecute(final MediaInformationSession mediaInformationSession, final Integer waitTimeout) {
        AsyncGetMediaInformationTask asyncGetMediaInformationTask = new AsyncGetMediaInformationTask(mediaInformationSession, waitTimeout);
        Future<?> future = asyncExecutorService.submit(asyncGetMediaInformationTask);
        mediaInformationSession.setFuture(future);
    }

    /**
     * Returns the maximum number of async operations that will be executed in parallel.
     *
     * @return maximum number of async operations that will be executed in parallel
     */
    public static int getAsyncConcurrencyLimit() {
        return asyncConcurrencyLimit;
    }

    /**
     * Sets the maximum number of async operations that will be executed in parallel. If more
     * operations are submitted those will be queued.
     *
     * @param asyncConcurrencyLimit new async concurrency limit
     */
    public static void setAsyncConcurrencyLimit(final int asyncConcurrencyLimit) {

        if (asyncConcurrencyLimit > 0) {

            /* SET THE NEW LIMIT */
            FFmpegKitConfig.asyncConcurrencyLimit = asyncConcurrencyLimit;
            ExecutorService oldAsyncExecutorService = FFmpegKitConfig.asyncExecutorService;

            /* CREATE THE NEW ASYNC THREAD POOL */
            FFmpegKitConfig.asyncExecutorService = Executors.newFixedThreadPool(asyncConcurrencyLimit);

            /* STOP THE OLD ASYNC THREAD POOL */
            oldAsyncExecutorService.shutdown();
        }
    }

    /**
     * <p>Sets a global callback function to redirect FFmpeg/FFprobe logs.
     *
     * @param newLogCallback new log callback function or null to disable a previously defined
     *                       callback
     */
    public static void enableLogCallback(final LogCallback newLogCallback) {
        globalLogCallbackFunction = newLogCallback;
    }

    /**
     * <p>Sets a global callback function to redirect FFmpeg statistics.
     *
     * @param statisticsCallback new statistics callback function or null to disable a previously
     *                           defined callback
     */
    public static void enableStatisticsCallback(final StatisticsCallback statisticsCallback) {
        globalStatisticsCallbackFunction = statisticsCallback;
    }

    /**
     * <p>Sets a global callback function to receive execution results.
     *
     * @param executeCallback new execute callback function or null to disable a previously
     *                        defined callback
     */
    public static void enableExecuteCallback(final ExecuteCallback executeCallback) {
        globalExecuteCallbackFunction = executeCallback;
    }

    /**
     * <p>Returns global execute callback function.
     *
     * @return global execute callback function
     */
    static ExecuteCallback getGlobalExecuteCallbackFunction() {
        return globalExecuteCallbackFunction;
    }

    /**
     * Returns the current log level.
     *
     * @return current log level
     */
    public static Level getLogLevel() {
        return activeLogLevel;
    }

    /**
     * Sets the log level.
     *
     * @param level new log level
     */
    public static void setLogLevel(final Level level) {
        if (level != null) {
            activeLogLevel = level;
            setNativeLogLevel(level.getValue());
        }
    }

    /**
     * <p>Converts the given Structured Access Framework Uri (<code>"content:…"</code>) into an
     * input/output url that can be used in FFmpegKit and FFprobeKit.
     *
     * <p>Requires API Level >= 19. On older API levels it returns an empty url.
     *
     * @return input/output url that can be passed to FFmpegKit or FFprobeKit
     */
    private static String getSafParameter(final Context context, final Uri uri, final String openMode) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            android.util.Log.i(TAG, String.format("getSafParameter is not supported on API Level %d", Build.VERSION.SDK_INT));
            return "";
        }

        String displayName = "unknown";
        try (Cursor cursor = context.getContentResolver().query(uri, null, null, null, null)) {
            if (cursor != null && cursor.moveToFirst()) {
                displayName = cursor.getString(cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DISPLAY_NAME));
            }
        } catch (final Throwable t) {
            android.util.Log.e(TAG, String.format("Failed to get %s column for %s.%s", DocumentsContract.Document.COLUMN_DISPLAY_NAME, uri.toString(), Exceptions.getStackTraceString(t)));
        }

        int fd = -1;
        try {
            ParcelFileDescriptor parcelFileDescriptor = context.getContentResolver().openFileDescriptor(uri, openMode);
            fd = parcelFileDescriptor.getFd();
            pfdMap.put(fd, parcelFileDescriptor);
        } catch (final Throwable t) {
            android.util.Log.e(TAG, String.format("Failed to obtain %s parcelFileDescriptor for %s.%s", openMode, uri.toString(), Exceptions.getStackTraceString(t)));
        }

        // workaround for https://issuetracker.google.com/issues/162440528: ANDROID_CREATE_DOCUMENT generating file names like "transcode.mp3 (2)"
        if (displayName.lastIndexOf('.') > 0 && displayName.lastIndexOf(' ') > displayName.lastIndexOf('.')) {
            String extension = displayName.substring(displayName.lastIndexOf('.'), displayName.lastIndexOf(' '));
            displayName += extension;
        }
        // spaces can break argument list parsing, see https://github.com/alexcohn/mobile-ffmpeg/pull/1#issuecomment-688643836
        final char NBSP = (char) 0xa0;
        return "saf:" + fd + "/" + displayName.replace(' ', NBSP);
    }

    /**
     * <p>Converts the given Structured Access Framework Uri (<code>"content:…"</code>) into an
     * input url that can be used in FFmpegKit and FFprobeKit.
     *
     * <p>Requires API Level >= 19. On older API levels it returns an empty url.
     *
     * @return input url that can be passed to FFmpegKit or FFprobeKit
     */
    public static String getSafParameterForRead(final Context context, final Uri uri) {
        return getSafParameter(context, uri, "r");
    }

    /**
     * <p>Converts the given Structured Access Framework Uri (<code>"content:…"</code>) into an
     * output url that can be used in FFmpegKit and FFprobeKit.
     *
     * <p>Requires API Level >= 19. On older API levels it returns an empty url.
     *
     * @return output url that can be passed to FFmpegKit or FFprobeKit
     */
    public static String getSafParameterForWrite(final Context context, final Uri uri) {
        return getSafParameter(context, uri, "w");
    }

    /**
     * Called by saf_wrapper from JNI/native part to close a parcel file descriptor.
     *
     * @param fd parcel file descriptor created for a saf uri
     */
    private static void closeParcelFileDescriptor(final int fd) {
        try {
            ParcelFileDescriptor pfd = pfdMap.get(fd);
            if (pfd != null) {
                pfd.close();
                pfdMap.delete(fd);
            }
        } catch (final Throwable t) {
            android.util.Log.e(TAG, String.format("Failed to close file descriptor %d.%s", fd, Exceptions.getStackTraceString(t)));
        }
    }

    /**
     * Returns the session history size.
     *
     * @return session history size
     */
    public static int getSessionHistorySize() {
        return sessionHistorySize;
    }

    /**
     * Sets the session history size.
     *
     * @param sessionHistorySize new session history size, should be smaller than 1000
     */
    public static void setSessionHistorySize(final int sessionHistorySize) {
        if (sessionHistorySize >= 1000) {

            /*
             * THERE IS A HARD LIMIT ON THE NATIVE SIDE. HISTORY SIZE MUST BE SMALLER THAN 1000
             */
            throw new IllegalArgumentException("Session history size must not exceed the hard limit!");
        }
        FFmpegKitConfig.sessionHistorySize = sessionHistorySize;
    }

    /**
     * Adds a session to the session history.
     *
     * @param session new session
     */
    static void addSession(final Session session) {
        synchronized (sessionHistoryLock) {
            sessionHistoryMap.put(session.getSessionId(), session);
            sessionHistoryQueue.offer(session);

            if (sessionHistoryQueue.size() > sessionHistorySize) {
                final Session oldestElement = sessionHistoryQueue.poll();
                if (oldestElement != null) {
                    sessionHistoryMap.remove(oldestElement.getSessionId());
                }
            }
        }
    }

    /**
     * Returns the session specified with sessionId from the session history.
     *
     * @param sessionId session identifier
     * @return session specified with sessionId or null if it is not found in the history
     */
    public static Session getSession(final long sessionId) {
        synchronized (sessionHistoryLock) {
            return sessionHistoryMap.get(sessionId);
        }
    }

    /**
     * Returns the last session from the session history.
     *
     * @return the last session from the session history
     */
    public static Session getLastSession() {
        synchronized (sessionHistoryLock) {
            return sessionHistoryQueue.peek();
        }
    }

    /**
     * <p>Returns all sessions in the session history.
     *
     * @return all sessions in the session history
     */
    public static List<Session> getSessions() {
        synchronized (sessionHistoryLock) {
            return new LinkedList<>(sessionHistoryQueue);
        }
    }

    /**
     * <p>Returns all FFmpeg sessions in the session history.
     *
     * @return all FFmpeg sessions in the session history
     */
    static List<FFmpegSession> getFFmpegSessions() {
        final LinkedList<FFmpegSession> list = new LinkedList<>();

        synchronized (sessionHistoryLock) {
            for (Session session : sessionHistoryQueue) {
                if (session.isFFmpeg()) {
                    list.add((FFmpegSession) session);
                }
            }
        }

        return list;
    }

    /**
     * <p>Returns all FFprobe sessions in the session history.
     *
     * @return all FFprobe sessions in the session history
     */
    static List<FFprobeSession> getFFprobeSessions() {
        final LinkedList<FFprobeSession> list = new LinkedList<>();

        synchronized (sessionHistoryLock) {
            for (Session session : sessionHistoryQueue) {
                if (session.isFFprobe()) {
                    list.add((FFprobeSession) session);
                }
            }
        }

        return list;
    }

    /**
     * <p>Returns sessions that have the given state.
     *
     * @return sessions that have the given state from the session history
     */
    public static List<Session> getSessionsByState(final SessionState state) {
        final LinkedList<Session> list = new LinkedList<>();

        synchronized (sessionHistoryLock) {
            for (Session session : sessionHistoryQueue) {
                if (session.getState() == state) {
                    list.add(session);
                }
            }
        }

        return list;
    }

    /**
     * Returns the active log redirection strategy.
     *
     * @return log redirection strategy
     */
    public static LogRedirectionStrategy getLogRedirectionStrategy() {
        return logRedirectionStrategy;
    }

    /**
     * <p>Sets the log redirection strategy
     *
     * @param logRedirectionStrategy new log redirection strategy
     */
    public static void setLogRedirectionStrategy(final LogRedirectionStrategy logRedirectionStrategy) {
        FFmpegKitConfig.logRedirectionStrategy = logRedirectionStrategy;
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
     * Returns native log level.
     *
     * @return log level
     */
    private static native int getNativeLogLevel();

    /**
     * Sets native log level
     *
     * @param level log level
     */
    private static native void setNativeLogLevel(int level);

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
     * <p>Synchronously executes FFmpeg natively.
     *
     * @param sessionId id of the session
     * @param arguments FFmpeg command options/arguments as string array
     * @return {@link ReturnCode#SUCCESS} on successful execution and {@link ReturnCode#CANCEL} on
     * user cancel. Other non-zero values are returned on error. Use {@link ReturnCode} class to
     * handle the value
     */
    private native static int nativeFFmpegExecute(final long sessionId, final String[] arguments);

    /**
     * <p>Cancels an ongoing FFmpeg operation natively. This function does not wait for termination
     * to complete and returns immediately.
     *
     * @param sessionId id of the session
     */
    native static void nativeFFmpegCancel(final long sessionId);

    /**
     * <p>Synchronously executes FFprobe natively.
     *
     * @param sessionId id of the session
     * @param arguments FFprobe command options/arguments as string array
     * @return {@link ReturnCode#SUCCESS} on successful execution and {@link ReturnCode#CANCEL} on
     * user cancel. Other non-zero values are returned on error. Use {@link ReturnCode} class to
     * handle the value
     */
    native static int nativeFFprobeExecute(final long sessionId, final String[] arguments);

    /**
     * <p>Returns the number of native messages which are not transmitted to the Java callbacks for
     * this session natively.
     *
     * @param sessionId id of the session
     * @return number of native messages which are not transmitted to the Java callbacks for
     * this session natively
     */
    native static int messagesInTransmit(final long sessionId);

    /**
     * <p>Creates a new named pipe to use in <code>FFmpeg</code> operations natively.
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
     * <p>Registers a new ignored signal natively. Ignored signals are not handled by the library.
     *
     * @param signum signal number
     */
    private native static void ignoreNativeSignal(final int signum);

}
