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
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit;

import android.os.AsyncTask;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicLong;

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

    static final long DEFAULT_EXECUTION_ID = 0;

    private static final AtomicLong executionIdCounter = new AtomicLong(3000);

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
     * @return 0 on successful execution, 255 on user cancel, other non-zero codes on error
     */
    public static int execute(final String[] arguments) {
        return FFmpegKitConfig.ffmpegExecute(DEFAULT_EXECUTION_ID, arguments);
    }

    /**
     * <p>Asynchronously executes FFmpeg with arguments provided.
     *
     * @param arguments       FFmpeg command options/arguments as string array
     * @param executeCallback callback that will be notified when execution is completed
     * @return returns a unique id that represents this execution
     */
    public static long executeAsync(final String[] arguments, final ExecuteCallback executeCallback) {
        final long newExecutionId = executionIdCounter.incrementAndGet();

        AsyncFFmpegExecuteTask asyncFFmpegExecuteTask = new AsyncFFmpegExecuteTask(newExecutionId, arguments, executeCallback);
        asyncFFmpegExecuteTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

        return newExecutionId;
    }

    /**
     * <p>Asynchronously executes FFmpeg with arguments provided.
     *
     * @param arguments       FFmpeg command options/arguments as string array
     * @param executeCallback callback that will be notified when execution is completed
     * @param executor        executor that will be used to run this asynchronous operation
     * @return returns a unique id that represents this execution
     */
    public static long executeAsync(final String[] arguments, final ExecuteCallback executeCallback, final Executor executor) {
        final long newExecutionId = executionIdCounter.incrementAndGet();

        AsyncFFmpegExecuteTask asyncFFmpegExecuteTask = new AsyncFFmpegExecuteTask(newExecutionId, arguments, executeCallback);
        asyncFFmpegExecuteTask.executeOnExecutor(executor);

        return newExecutionId;
    }

    /**
     * <p>Synchronously executes FFmpeg command provided. Command is split into arguments using
     * provided delimiter character.
     *
     * @param command   FFmpeg command
     * @param delimiter delimiter used to split arguments
     * @return 0 on successful execution, 255 on user cancel, other non-zero codes on error
     * @since 3.0
     * @deprecated argument splitting mechanism used in this method is pretty simple and prone to
     * errors. Consider using a more advanced method like {@link #execute(String)} or
     * {@link #execute(String[])}
     */
    public static int execute(final String command, final String delimiter) {
        return execute((command == null) ? new String[]{""} : command.split((delimiter == null) ? " " : delimiter));
    }

    /**
     * <p>Synchronously executes FFmpeg command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command FFmpeg command
     * @return 0 on successful execution, 255 on user cancel, other non-zero codes on error
     */
    public static int execute(final String command) {
        return execute(parseArguments(command));
    }

    /**
     * <p>Asynchronously executes FFmpeg command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command         FFmpeg command
     * @param executeCallback callback that will be notified when execution is completed
     * @return returns a unique id that represents this execution
     */
    public static long executeAsync(final String command, final ExecuteCallback executeCallback) {
        final long newExecutionId = executionIdCounter.incrementAndGet();

        AsyncFFmpegExecuteTask asyncFFmpegExecuteTask = new AsyncFFmpegExecuteTask(newExecutionId, command, executeCallback);
        asyncFFmpegExecuteTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

        return newExecutionId;
    }

    /**
     * <p>Asynchronously executes FFmpeg command provided. Space character is used to split command
     * into arguments. You can use single and double quote characters to specify arguments inside
     * your command.
     *
     * @param command         FFmpeg command
     * @param executeCallback callback that will be notified when execution is completed
     * @param executor        executor that will be used to run this asynchronous operation
     * @return returns a unique id that represents this execution
     */
    public static long executeAsync(final String command, final ExecuteCallback executeCallback, final Executor executor) {
        final long newExecutionId = executionIdCounter.incrementAndGet();

        AsyncFFmpegExecuteTask asyncFFmpegExecuteTask = new AsyncFFmpegExecuteTask(newExecutionId, command, executeCallback);
        asyncFFmpegExecuteTask.executeOnExecutor(executor);

        return newExecutionId;
    }

    /**
     * <p>Cancels an ongoing operation.
     *
     * <p>This function does not wait for termination to complete and returns immediately.
     */
    public static void cancel() {
        FFmpegKitConfig.nativeFFmpegCancel(DEFAULT_EXECUTION_ID);
    }

    /**
     * <p>Cancels an ongoing operation.
     *
     * <p>This function does not wait for termination to complete and returns immediately.
     *
     * @param executionId id of the execution
     */
    public static void cancel(final long executionId) {
        FFmpegKitConfig.nativeFFmpegCancel(executionId);
    }

    /**
     * <p>Lists ongoing executions.
     *
     * @return list of ongoing executions
     */
    public static List<FFmpegExecution> listExecutions() {
        return FFmpegKitConfig.listFFmpegExecutions();
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
