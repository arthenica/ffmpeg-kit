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

package com.arthenica.ffmpegkit;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;

/**
 * <p>Main class for FFmpeg operations. Supports synchronous {@link #execute(String...)} and
 * asynchronous {@link #executeAsync(String, ExecuteCallback)} methods to execute FFmpeg commands.
 * <pre>
 *      int rc = FFmpeg.execute("-i file1.mp4 -c:v libxvid file1.avi");
 *      Log.i(Config.TAG, String.format("Command execution %s.", (rc == 0?"completed successfully":"failed with rc=" + rc));
 * </pre>
 * <pre>
 *      long executionId = FFmpeg.executeAsync("-i file1.mp4 -c:v libxvid file1.avi", executeCallback);
 *      Log.i(Config.TAG, String.format("Asynchronous execution %d started.", executionId));
 * </pre>
 */
public class FFmpegKit {

    static {
        AbiDetect.class.getName();
        FFmpegKitConfig.class.getName();
    }

    /**
     * Default constructor hidden.
     */
    private FFmpegKit() {
    }

    /**
     * <p>Synchronously executes FFmpeg with arguments provided.
     *
     * @param arguments FFmpeg command options/arguments as string array
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession execute(final String[] arguments) {
        final FFmpegSession session = new FFmpegSession(arguments, null, null, null);

        FFmpegKitConfig.ffmpegExecute(session);

        return session;
    }

    /**
     * <p>Asynchronously executes FFmpeg with arguments provided.
     *
     * @param arguments       FFmpeg command options/arguments as string array
     * @param executeCallback callback that will be notified when the execution is completed
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession executeAsync(final String[] arguments,
                                             final ExecuteCallback executeCallback) {
        final FFmpegSession session = new FFmpegSession(arguments, executeCallback, null, null);

        FFmpegKitConfig.asyncFFmpegExecute(session);

        return session;
    }

    /**
     * <p>Asynchronously executes FFmpeg with arguments provided.
     *
     * @param arguments          FFmpeg command options/arguments as string array
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession executeAsync(final String[] arguments,
                                             final ExecuteCallback executeCallback,
                                             final LogCallback logCallback,
                                             final StatisticsCallback statisticsCallback) {
        final FFmpegSession session = new FFmpegSession(arguments, executeCallback, logCallback, statisticsCallback);

        FFmpegKitConfig.asyncFFmpegExecute(session);

        return session;
    }

    /**
     * <p>Asynchronously executes FFmpeg with arguments provided.
     *
     * @param arguments       FFmpeg command options/arguments as string array
     * @param executeCallback callback that will be notified when execution is completed
     * @param executor        executor that will be used to run this asynchronous operation
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession executeAsync(final String[] arguments,
                                             final ExecuteCallback executeCallback,
                                             final Executor executor) {
        final FFmpegSession session = new FFmpegSession(arguments, executeCallback, null, null);

        AsyncFFmpegExecuteTask asyncFFmpegExecuteTask = new AsyncFFmpegExecuteTask(session);
        executor.execute(asyncFFmpegExecuteTask);

        return session;
    }

    /**
     * <p>Asynchronously executes FFmpeg with arguments provided.
     *
     * @param arguments          FFmpeg command options/arguments as string array
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @param executor           executor that will be used to run this asynchronous operation
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession executeAsync(final String[] arguments,
                                             final ExecuteCallback executeCallback,
                                             final LogCallback logCallback,
                                             final StatisticsCallback statisticsCallback,
                                             final Executor executor) {
        final FFmpegSession session = new FFmpegSession(arguments, executeCallback, logCallback, statisticsCallback);

        AsyncFFmpegExecuteTask asyncFFmpegExecuteTask = new AsyncFFmpegExecuteTask(session);
        executor.execute(asyncFFmpegExecuteTask);

        return session;
    }

    /**
     * <p>Synchronously executes FFmpeg command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command FFmpeg command
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession execute(final String command) {
        return execute(parseArguments(command));
    }

    /**
     * <p>Asynchronously executes FFmpeg command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command         FFmpeg command
     * @param executeCallback callback that will be notified when execution is completed
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession executeAsync(final String command,
                                             final ExecuteCallback executeCallback) {
        return executeAsync(parseArguments(command), executeCallback);
    }

    /**
     * <p>Asynchronously executes FFmpeg command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command            FFmpeg command
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession executeAsync(final String command,
                                             final ExecuteCallback executeCallback,
                                             final LogCallback logCallback,
                                             final StatisticsCallback statisticsCallback) {
        return executeAsync(parseArguments(command), executeCallback, logCallback, statisticsCallback);
    }

    /**
     * <p>Asynchronously executes FFmpeg command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command         FFmpeg command
     * @param executeCallback callback that will be notified when execution is completed
     * @param executor        executor that will be used to run this asynchronous operation
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession executeAsync(final String command,
                                             final ExecuteCallback executeCallback,
                                             final Executor executor) {
        final FFmpegSession session = new FFmpegSession(parseArguments(command), executeCallback, null, null);

        AsyncFFmpegExecuteTask asyncFFmpegExecuteTask = new AsyncFFmpegExecuteTask(session);
        executor.execute(asyncFFmpegExecuteTask);

        return session;
    }

    /**
     * <p>Asynchronously executes FFmpeg command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command            FFmpeg command
     * @param executeCallback    callback that will be notified when execution is completed
     * @param logCallback        callback that will receive log entries
     * @param statisticsCallback callback that will receive statistics
     * @param executor           executor that will be used to run this asynchronous operation
     * @return ffmpeg session created for this execution
     */
    public static FFmpegSession executeAsync(final String command,
                                             final ExecuteCallback executeCallback,
                                             final LogCallback logCallback,
                                             final StatisticsCallback statisticsCallback,
                                             final Executor executor) {
        final FFmpegSession session = new FFmpegSession(parseArguments(command), executeCallback, logCallback, statisticsCallback);

        AsyncFFmpegExecuteTask asyncFFmpegExecuteTask = new AsyncFFmpegExecuteTask(session);
        executor.execute(asyncFFmpegExecuteTask);

        return session;
    }

    /**
     * <p>Cancels the last execution started.
     *
     * <p>This function does not wait for termination to complete and returns immediately.
     */
    public static void cancel() {
        Session lastSession = FFmpegKitConfig.getLastSession();
        if (lastSession != null) {
            FFmpegKitConfig.nativeFFmpegCancel(lastSession.getSessionId());
        } else {
            android.util.Log.w(FFmpegKitConfig.TAG, "FFmpegKit cancel skipped. The last execution does not exist.");
        }
    }

    /**
     * <p>Cancels the given execution.
     *
     * <p>This function does not wait for termination to complete and returns immediately.
     *
     * @param sessionId id of the session that will be stopped
     */
    public static void cancel(final long sessionId) {
        FFmpegKitConfig.nativeFFmpegCancel(sessionId);
    }

    /**
     * <p>Lists all FFmpeg sessions in the session history
     *
     * @return all FFmpeg sessions in the session history
     */
    public static List<FFmpegSession> listSessions() {
        return FFmpegKitConfig.getFFmpegSessions();
    }

    /**
     * <p>Parses the given command into arguments.
     *
     * @param command string command
     * @return array of arguments
     */
    static String[] parseArguments(final String command) {
        final List<String> argumentList = new ArrayList<>();
        StringBuilder currentArgument = new StringBuilder();

        boolean singleQuoteStarted = false;
        boolean doubleQuoteStarted = false;

        for (int i = 0; i < command.length(); i++) {
            final Character previousChar;
            if (i > 0) {
                previousChar = command.charAt(i - 1);
            } else {
                previousChar = null;
            }
            final char currentChar = command.charAt(i);

            if (currentChar == ' ') {
                if (singleQuoteStarted || doubleQuoteStarted) {
                    currentArgument.append(currentChar);
                } else if (currentArgument.length() > 0) {
                    argumentList.add(currentArgument.toString());
                    currentArgument = new StringBuilder();
                }
            } else if (currentChar == '\'' && (previousChar == null || previousChar != '\\')) {
                if (singleQuoteStarted) {
                    singleQuoteStarted = false;
                } else if (doubleQuoteStarted) {
                    currentArgument.append(currentChar);
                } else {
                    singleQuoteStarted = true;
                }
            } else if (currentChar == '\"' && (previousChar == null || previousChar != '\\')) {
                if (doubleQuoteStarted) {
                    doubleQuoteStarted = false;
                } else if (singleQuoteStarted) {
                    currentArgument.append(currentChar);
                } else {
                    doubleQuoteStarted = true;
                }
            } else {
                currentArgument.append(currentChar);
            }
        }

        if (currentArgument.length() > 0) {
            argumentList.add(currentArgument.toString());
        }

        return argumentList.toArray(new String[0]);
    }

    /**
     * <p>Combines arguments into a string.
     *
     * @param arguments arguments
     * @return string containing all arguments
     */
    static String argumentsToString(final String[] arguments) {
        if (arguments == null) {
            return "null";
        }

        StringBuilder stringBuilder = new StringBuilder();
        for (int i = 0; i < arguments.length; i++) {
            if (i > 0) {
                stringBuilder.append(" ");
            }
            stringBuilder.append(arguments[i]);
        }

        return stringBuilder.toString();
    }

}
