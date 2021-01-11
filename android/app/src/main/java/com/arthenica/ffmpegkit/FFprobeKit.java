/*
 * Copyright (c) 2020-2021 Taner Sener
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

import java.util.concurrent.Executor;

/**
 * <p>Main class for FFprobe operations.
 * <p>Supports running FFprobe commands using {@link #execute(String...)} method.
 * <pre>
 *      FFprobeSession session = FFprobe.execute("-hide_banner -v error -show_entries format=size -of default=noprint_wrappers=1 file1.mp4");
 *      Log.i(FFmpegKitConfig.TAG, String.format("Command execution %s.", (session.getReturnCode() == 0?"completed successfully":"failed with rc=" + session.getReturnCode()));
 * </pre>
 * <p>It can also extract media information for a file or a url, using {@link #getMediaInformation(String)} method.
 * <pre>
 *      MediaInformationSession session = FFprobe.getMediaInformation("file1.mp4");
 *      Log.i(FFmpegKitConfig.TAG, String.format("Media information %s.", (session.getReturnCode() == 0?"extracted successfully":"was not extracted due to rc=" + session.getReturnCode()));
 * </pre>
 */
public class FFprobeKit {

    static {
        AbiDetect.class.getName();
        FFmpegKitConfig.class.getName();
    }

    /**
     * Default constructor hidden.
     */
    private FFprobeKit() {
    }

    /**
     * <p>Synchronously executes FFprobe with arguments provided.
     *
     * @param arguments FFprobe command options/arguments as string array
     * @return ffprobe session created for this execution
     */
    public static FFprobeSession execute(final String[] arguments) {
        final FFprobeSession session = new FFprobeSession(arguments, null, null, null);

        FFmpegKitConfig.ffprobeExecute(session);

        return session;
    }

    /**
     * <p>Synchronously executes FFprobe command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command FFprobe command
     * @return ffprobe session created for this execution
     */
    public static FFprobeSession execute(final String command) {
        return execute(FFmpegKit.parseArguments(command));
    }

    /**
     * <p>Asynchronously executes FFprobe command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command         FFprobe command
     * @param executeCallback callback that will be notified when the execution is completed
     * @return ffprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String command,
                                              final ExecuteCallback executeCallback) {
        return executeAsync(FFmpegKit.parseArguments(command), executeCallback);
    }

    /**
     * <p>Asynchronously executes FFprobe with arguments provided.
     *
     * @param arguments       FFprobe command options/arguments as string array
     * @param executeCallback callback that will be notified when the execution is completed
     * @return ffprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String[] arguments,
                                              final ExecuteCallback executeCallback) {
        final FFprobeSession session = new FFprobeSession(arguments, executeCallback, null, null);

        FFmpegKitConfig.asyncFFprobeExecute(session);

        return session;
    }

    /**
     * <p>Asynchronously executes FFprobe command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command            FFprobe command
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @return ffprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String command,
                                              final ExecuteCallback executeCallback,
                                              final LogCallback logCallback,
                                              final StatisticsCallback statisticsCallback) {
        return executeAsync(FFmpegKit.parseArguments(command), executeCallback, logCallback, statisticsCallback);
    }

    /**
     * <p>Asynchronously executes FFprobe with arguments provided.
     *
     * @param arguments          FFprobe command options/arguments as string array
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @return ffprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String[] arguments,
                                              final ExecuteCallback executeCallback,
                                              final LogCallback logCallback,
                                              final StatisticsCallback statisticsCallback) {
        final FFprobeSession session = new FFprobeSession(arguments, executeCallback, logCallback, statisticsCallback);

        FFmpegKitConfig.asyncFFprobeExecute(session);

        return session;
    }

    /**
     * <p>Asynchronously executes FFprobe with arguments provided.
     *
     * @param arguments       FFprobe command options/arguments as string array
     * @param executeCallback callback that will be notified when the execution is completed
     * @param executor        executor that will be used to run this asynchronous operation
     * @return ffprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String[] arguments,
                                              final ExecuteCallback executeCallback,
                                              final Executor executor) {
        final FFprobeSession session = new FFprobeSession(arguments, executeCallback, null, null);

        AsyncFFprobeExecuteTask asyncFFprobeExecuteTask = new AsyncFFprobeExecuteTask(session);
        executor.execute(asyncFFprobeExecuteTask);

        return session;
    }

    /**
     * <p>Asynchronously executes FFprobe with arguments provided.
     *
     * @param arguments          FFprobe command options/arguments as string array
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @param executor           executor that will be used to run this asynchronous operation
     * @return ffprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String[] arguments,
                                              final ExecuteCallback executeCallback,
                                              final LogCallback logCallback,
                                              final StatisticsCallback statisticsCallback,
                                              final Executor executor) {
        final FFprobeSession session = new FFprobeSession(arguments, executeCallback, logCallback, statisticsCallback);

        AsyncFFprobeExecuteTask asyncFFprobeExecuteTask = new AsyncFFprobeExecuteTask(session);
        executor.execute(asyncFFprobeExecuteTask);

        return session;
    }

    /**
     * <p>Returns media information for the given path.
     *
     * @param path path or uri of a media file
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformation(final String path) {
        return getMediaInformationFromCommandArguments(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path}, null, null, null);
    }

    /**
     * <p>Returns media information for the given path asynchronously.
     *
     * @param path            path or uri of a media file
     * @param executeCallback callback that will be notified when the execution is completed
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationAsync(final String path,
                                                                   final ExecuteCallback executeCallback) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path}, executeCallback, null, null);

        FFmpegKitConfig.asyncGetMediaInformationExecute(session);

        return session;
    }

    /**
     * <p>Returns media information for the given path asynchronously.
     *
     * @param path               path or uri of a media file
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationAsync(final String path,
                                                                   final ExecuteCallback executeCallback,
                                                                   final LogCallback logCallback,
                                                                   final StatisticsCallback statisticsCallback) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path}, executeCallback, logCallback, statisticsCallback);

        FFmpegKitConfig.asyncGetMediaInformationExecute(session);

        return session;
    }

    /**
     * <p>Returns media information for the given path asynchronously.
     *
     * @param path            path or uri of a media file
     * @param executeCallback callback that will be notified when the execution is completed
     * @param executor        executor that will be used to run this asynchronous operation
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationAsync(final String path,
                                                                   final ExecuteCallback executeCallback,
                                                                   final Executor executor) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path}, executeCallback, null, null);

        AsyncGetMediaInformationTask asyncGetMediaInformationTask = new AsyncGetMediaInformationTask(session);
        executor.execute(asyncGetMediaInformationTask);

        return session;
    }

    /**
     * <p>Returns media information for the given path asynchronously.
     *
     * @param path               path or uri of a media file
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @param executor           executor that will be used to run this asynchronous operation
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationAsync(final String path,
                                                                   final ExecuteCallback executeCallback,
                                                                   final LogCallback logCallback,
                                                                   final StatisticsCallback statisticsCallback,
                                                                   final Executor executor) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path}, executeCallback, logCallback, statisticsCallback);

        AsyncGetMediaInformationTask asyncGetMediaInformationTask = new AsyncGetMediaInformationTask(session);
        executor.execute(asyncGetMediaInformationTask);

        return session;
    }

    /**
     * <p>Returns media information for the given command.
     *
     * @param command command to execute
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationFromCommand(final String command) {
        return getMediaInformationFromCommandArguments(FFmpegKit.parseArguments(command), null, null, null);
    }


    /**
     * <p>Returns media information for the given command.
     *
     * @param command            command to execute
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationFromCommand(final String command,
                                                                         final ExecuteCallback executeCallback,
                                                                         final LogCallback logCallback,
                                                                         final StatisticsCallback statisticsCallback) {
        return getMediaInformationFromCommandArguments(FFmpegKit.parseArguments(command), executeCallback, logCallback, statisticsCallback);
    }

    private static MediaInformationSession getMediaInformationFromCommandArguments(final String[] arguments,
                                                                                   final ExecuteCallback executeCallback,
                                                                                   final LogCallback logCallback,
                                                                                   final StatisticsCallback statisticsCallback) {
        final MediaInformationSession session = new MediaInformationSession(arguments, executeCallback, logCallback, statisticsCallback);

        FFmpegKitConfig.getMediaInformationExecute(session);

        return session;
    }

}
