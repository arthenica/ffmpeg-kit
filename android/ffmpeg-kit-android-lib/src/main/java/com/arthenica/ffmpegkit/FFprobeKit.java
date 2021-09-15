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

import java.util.List;
import java.util.concurrent.ExecutorService;

/**
 * <p>Main class to run <code>FFprobe</code> commands. Supports executing commands both
 * synchronously and asynchronously.
 * <pre>
 * FFprobeSession session = FFprobeKit.execute("-hide_banner -v error -show_entries format=size -of default=noprint_wrappers=1 file1.mp4");
 *
 * FFprobeSession asyncSession = FFprobeKit.executeAsync("-hide_banner -v error -show_entries format=size -of default=noprint_wrappers=1 file1.mp4", executeCallback);
 * </pre>
 * <p>Provides overloaded <code>execute</code> methods to define session specific callbacks.
 * <pre>
 * FFprobeSession session = FFprobeKit.executeAsync("-hide_banner -v error -show_entries format=size -of default=noprint_wrappers=1 file1.mp4", executeCallback, logCallback);
 * </pre>
 * <p>It can extract media information for a file or a url, using {@link #getMediaInformation(String)} method.
 * <pre>
 * MediaInformationSession session = FFprobeKit.getMediaInformation("file1.mp4");
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
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession execute(final String[] arguments) {
        final FFprobeSession session = new FFprobeSession(arguments);

        FFmpegKitConfig.ffprobeExecute(session);

        return session;
    }

    /**
     * <p>Asynchronously executes FFprobe with arguments provided.
     *
     * @param arguments       FFprobe command options/arguments as string array
     * @param executeCallback callback that will be called when the execution is completed
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String[] arguments,
                                              final ExecuteCallback executeCallback) {
        final FFprobeSession session = new FFprobeSession(arguments, executeCallback);

        FFmpegKitConfig.asyncFFprobeExecute(session);

        return session;
    }

    /**
     * <p>Asynchronously executes FFprobe with arguments provided.
     *
     * @param arguments       FFprobe command options/arguments as string array
     * @param executeCallback callback that will be notified when execution is completed
     * @param logCallback     callback that will receive logs
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String[] arguments,
                                              final ExecuteCallback executeCallback,
                                              final LogCallback logCallback) {
        final FFprobeSession session = new FFprobeSession(arguments, executeCallback, logCallback);

        FFmpegKitConfig.asyncFFprobeExecute(session);

        return session;
    }

    /**
     * <p>Asynchronously executes FFprobe with arguments provided.
     *
     * @param arguments       FFprobe command options/arguments as string array
     * @param executeCallback callback that will be called when the execution is completed
     * @param executorService executor service that will be used to run this asynchronous operation
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String[] arguments,
                                              final ExecuteCallback executeCallback,
                                              final ExecutorService executorService) {
        final FFprobeSession session = new FFprobeSession(arguments, executeCallback);

        FFmpegKitConfig.asyncFFprobeExecute(session, executorService);

        return session;
    }

    /**
     * <p>Asynchronously executes FFprobe with arguments provided.
     *
     * @param arguments       FFprobe command options/arguments as string array
     * @param executeCallback callback that will be notified when execution is completed
     * @param logCallback     callback that will receive logs
     * @param executorService executor service that will be used to run this asynchronous operation
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String[] arguments,
                                              final ExecuteCallback executeCallback,
                                              final LogCallback logCallback,
                                              final ExecutorService executorService) {
        final FFprobeSession session = new FFprobeSession(arguments, executeCallback, logCallback);

        FFmpegKitConfig.asyncFFprobeExecute(session, executorService);

        return session;
    }

    /**
     * <p>Synchronously executes FFprobe command provided. Space character is used to split command
     * into arguments. You can use single or double quote characters to specify arguments inside
     * your command.
     *
     * @param command FFprobe command
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession execute(final String command) {
        return execute(FFmpegKitConfig.parseArguments(command));
    }

    /**
     * <p>Asynchronously executes FFprobe command provided. Space character is used to split command
     * into arguments. You can use single or double quote characters to specify arguments inside
     * your command.
     *
     * @param command         FFprobe command
     * @param executeCallback callback that will be called when the execution is completed
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String command,
                                              final ExecuteCallback executeCallback) {
        return executeAsync(FFmpegKitConfig.parseArguments(command), executeCallback);
    }

    /**
     * <p>Asynchronously executes FFprobe command provided. Space character is used to split command
     * into arguments. You can use single or double quote characters to specify arguments inside
     * your command.
     *
     * @param command         FFprobe command
     * @param executeCallback callback that will be notified when execution is completed
     * @param logCallback     callback that will receive logs
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String command,
                                              final ExecuteCallback executeCallback,
                                              final LogCallback logCallback) {
        return executeAsync(FFmpegKitConfig.parseArguments(command), executeCallback, logCallback);
    }

    /**
     * <p>Asynchronously executes FFprobe command provided. Space character is used to split command
     * into arguments. You can use single or double quote characters to specify arguments inside
     * your command.
     *
     * @param command         FFprobe command
     * @param executeCallback callback that will be called when the execution is completed
     * @param executorService executor service that will be used to run this asynchronous operation
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String command,
                                              final ExecuteCallback executeCallback,
                                              final ExecutorService executorService) {
        final FFprobeSession session = new FFprobeSession(FFmpegKitConfig.parseArguments(command), executeCallback);

        FFmpegKitConfig.asyncFFprobeExecute(session, executorService);

        return session;
    }

    /**
     * <p>Asynchronously executes FFprobe command provided. Space character is used to split command
     * into arguments. You can use single or double quote characters to specify arguments inside
     * your command.
     *
     * @param command         FFprobe command
     * @param executeCallback callback that will be called when the execution is completed
     * @param logCallback     callback that will receive logs
     * @param executorService executor service that will be used to run this asynchronous operation
     * @return FFprobe session created for this execution
     */
    public static FFprobeSession executeAsync(final String command,
                                              final ExecuteCallback executeCallback,
                                              final LogCallback logCallback,
                                              final ExecutorService executorService) {
        final FFprobeSession session = new FFprobeSession(FFmpegKitConfig.parseArguments(command), executeCallback, logCallback);

        FFmpegKitConfig.asyncFFprobeExecute(session, executorService);

        return session;
    }

    /**
     * <p>Extracts media information for the file specified with path.
     *
     * @param path path or uri of a media file
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformation(final String path) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path});

        FFmpegKitConfig.getMediaInformationExecute(session, AbstractSession.DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT);

        return session;
    }

    /**
     * <p>Extracts media information for the file specified with path.
     *
     * @param path        path or uri of a media file
     * @param waitTimeout max time to wait until media information is transmitted
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformation(final String path,
                                                              final int waitTimeout) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path});

        FFmpegKitConfig.getMediaInformationExecute(session, waitTimeout);

        return session;
    }

    /**
     * <p>Extracts media information for the file specified with path asynchronously.
     *
     * @param path            path or uri of a media file
     * @param executeCallback callback that will be called when the execution is completed
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationAsync(final String path,
                                                                   final ExecuteCallback executeCallback) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path}, executeCallback);

        FFmpegKitConfig.asyncGetMediaInformationExecute(session, AbstractSession.DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT);

        return session;
    }

    /**
     * <p>Extracts media information for the file specified with path asynchronously.
     *
     * @param path            path or uri of a media file
     * @param executeCallback callback that will be notified when execution is completed
     * @param logCallback     callback that will receive logs
     * @param waitTimeout     max time to wait until media information is transmitted
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationAsync(final String path,
                                                                   final ExecuteCallback executeCallback,
                                                                   final LogCallback logCallback,
                                                                   final int waitTimeout) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path}, executeCallback, logCallback);

        FFmpegKitConfig.asyncGetMediaInformationExecute(session, waitTimeout);

        return session;
    }

    /**
     * <p>Extracts media information for the file specified with path asynchronously.
     *
     * @param path            path or uri of a media file
     * @param executeCallback callback that will be called when the execution is completed
     * @param executorService executor service that will be used to run this asynchronous operation
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationAsync(final String path,
                                                                   final ExecuteCallback executeCallback,
                                                                   final ExecutorService executorService) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path}, executeCallback);

        FFmpegKitConfig.asyncGetMediaInformationExecute(session, executorService, AbstractSession.DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT);

        return session;
    }

    /**
     * <p>Extracts media information for the file specified with path asynchronously.
     *
     * @param path            path or uri of a media file
     * @param executeCallback callback that will be notified when execution is completed
     * @param logCallback     callback that will receive logs
     * @param executorService executor service that will be used to run this asynchronous operation
     * @param waitTimeout     max time to wait until media information is transmitted
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationAsync(final String path,
                                                                   final ExecuteCallback executeCallback,
                                                                   final LogCallback logCallback,
                                                                   final ExecutorService executorService,
                                                                   final int waitTimeout) {
        final MediaInformationSession session = new MediaInformationSession(new String[]{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-i", path}, executeCallback, logCallback);

        FFmpegKitConfig.asyncGetMediaInformationExecute(session, executorService, waitTimeout);

        return session;
    }

    /**
     * <p>Extracts media information using the command provided asynchronously.
     *
     * @param command FFprobe command that prints media information for a file in JSON format
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationFromCommand(final String command) {
        final MediaInformationSession session = new MediaInformationSession(FFmpegKitConfig.parseArguments(command));

        FFmpegKitConfig.asyncGetMediaInformationExecute(session, AbstractSession.DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT);

        return session;
    }

    /**
     * <p>Extracts media information using the command provided asynchronously.
     *
     * @param command         FFprobe command that prints media information for a file in JSON format
     * @param executeCallback callback that will be notified when execution is completed
     * @param logCallback     callback that will receive logs
     * @param waitTimeout     max time to wait until media information is transmitted
     * @return media information session created for this execution
     */
    public static MediaInformationSession getMediaInformationFromCommandAsync(final String command,
                                                                              final ExecuteCallback executeCallback,
                                                                              final LogCallback logCallback,
                                                                              final int waitTimeout) {
        return getMediaInformationFromCommandArgumentsAsync(FFmpegKitConfig.parseArguments(command), executeCallback, logCallback, waitTimeout);
    }

    /**
     * Extracts media information using the command arguments provided asynchronously.
     *
     * @param arguments       FFprobe command arguments that print media information for a file in JSON format
     * @param executeCallback callback that will be notified when execution is completed
     * @param logCallback     callback that will receive logs
     * @param waitTimeout     max time to wait until media information is transmitted
     * @return media information session created for this execution
     */
    private static MediaInformationSession getMediaInformationFromCommandArgumentsAsync(final String[] arguments,
                                                                                        final ExecuteCallback executeCallback,
                                                                                        final LogCallback logCallback,
                                                                                        final int waitTimeout) {
        final MediaInformationSession session = new MediaInformationSession(arguments, executeCallback, logCallback);

        FFmpegKitConfig.getMediaInformationExecute(session, waitTimeout);

        return session;
    }

    /**
     * <p>Lists all FFprobe sessions in the session history.
     *
     * @return all FFprobe sessions in the session history
     */
    public static List<FFprobeSession> listSessions() {
        return FFmpegKitConfig.getFFprobeSessions();
    }

}
