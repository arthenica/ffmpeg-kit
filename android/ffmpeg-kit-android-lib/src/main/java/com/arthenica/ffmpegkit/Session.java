/*
 * Copyright (c) 2021 Taner Sener
 *
 * This file is part of FFmpegKit.
 *
 * FFmpegKit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FFmpegKit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General License for more details.
 *
 *  You should have received a copy of the GNU Lesser General License
 *  along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit;

import java.util.Date;
import java.util.List;
import java.util.concurrent.Future;

/**
 * <p>Common interface for all <code>FFmpegKit</code> sessions.
 */
public interface Session {

    /**
     * Returns the session specific log callback.
     *
     * @return session specific log callback
     */
    LogCallback getLogCallback();

    /**
     * Returns the session identifier.
     *
     * @return session identifier
     */
    long getSessionId();

    /**
     * Returns session create time.
     *
     * @return session create time
     */
    Date getCreateTime();

    /**
     * Returns session start time.
     *
     * @return session start time
     */
    Date getStartTime();

    /**
     * Returns session end time.
     *
     * @return session end time
     */
    Date getEndTime();

    /**
     * Returns the time taken to execute this session.
     *
     * @return time taken to execute this session in milliseconds or zero (0) if the session is
     * not over yet
     */
    long getDuration();

    /**
     * Returns command arguments as an array.
     *
     * @return command arguments as an array
     */
    String[] getArguments();

    /**
     * Returns command arguments as a concatenated string.
     *
     * @return command arguments as a concatenated string
     */
    String getCommand();

    /**
     * Returns all log entries generated for this session. If there are asynchronous
     * messages that are not delivered yet, this method waits for them until the given timeout.
     *
     * @param waitTimeout wait timeout for asynchronous messages in milliseconds
     * @return list of log entries generated for this session
     */
    List<Log> getAllLogs(final int waitTimeout);

    /**
     * Returns all log entries generated for this session. If there are asynchronous
     * messages that are not delivered yet, this method waits for them.
     *
     * @return list of log entries generated for this session
     */
    List<Log> getAllLogs();

    /**
     * Returns all log entries delivered for this session. Note that if there are asynchronous log
     * messages that are not delivered yet, this method will not wait for them and will return
     * immediately.
     *
     * @return list of log entries received for this session
     */
    List<Log> getLogs();

    /**
     * Returns all log entries generated for this session as a concatenated string. If there are
     * asynchronous messages that are not delivered yet, this method waits for them until
     * the given timeout.
     *
     * @param waitTimeout wait timeout for asynchronous messages in milliseconds
     * @return all log entries generated for this session as a concatenated string
     */
    String getAllLogsAsString(final int waitTimeout);

    /**
     * Returns all log entries generated for this session as a concatenated string. If there are
     * asynchronous messages that are not delivered yet, this method waits for them.
     *
     * @return all log entries generated for this session as a concatenated string
     */
    String getAllLogsAsString();

    /**
     * Returns all log entries delivered for this session as a concatenated string. Note that if
     * there are asynchronous log messages that are not delivered yet, this method will not wait
     * for them and will return immediately.
     *
     * @return list of log entries received for this session
     */
    String getLogsAsString();

    /**
     * Returns the log output generated while running the session.
     *
     * @return log output generated
     */
    String getOutput();

    /**
     * Returns the state of the session.
     *
     * @return state of the session
     */
    SessionState getState();

    /**
     * Returns the return code for this session. Note that return code is only set for sessions
     * that end with COMPLETED state. If a session is not started, still running or failed then
     * this method returns null.
     *
     * @return the return code for this session if the session is COMPLETED, null if session is
     * not started, still running or failed
     */
    ReturnCode getReturnCode();

    /**
     * Returns the stack trace of the exception received while executing this session.
     * <p>
     * The stack trace is only set for sessions that end with FAILED state. For sessions that has
     * COMPLETED state this method returns null.
     *
     * @return stack trace of the exception received while executing this session, null if session
     * is not started, still running or completed
     */
    String getFailStackTrace();

    /**
     * Returns session specific log redirection strategy.
     *
     * @return session specific log redirection strategy
     */
    LogRedirectionStrategy getLogRedirectionStrategy();

    /**
     * Returns whether there are still asynchronous messages being transmitted for this
     * session or not.
     *
     * @return true if there are still asynchronous messages being transmitted, false
     * otherwise
     */
    boolean thereAreAsynchronousMessagesInTransmit();

    /**
     * Adds a new log entry for this session.
     * <p>
     * It is invoked internally by <code>FFmpegKit</code> library methods. Must not be used by user
     * applications.
     *
     * @param log log entry
     */
    void addLog(final Log log);

    /**
     * Returns the future created for this session, if it is executed asynchronously.
     *
     * @return future that runs this session asynchronously
     */
    Future<?> getFuture();

    /**
     * Returns whether it is an <code>FFmpeg</code> session or not.
     *
     * @return true if it is an <code>FFmpeg</code> session, false otherwise
     */
    boolean isFFmpeg();

    /**
     * Returns whether it is an <code>FFprobe</code> session or not.
     *
     * @return true if it is an <code>FFprobe</code> session, false otherwise
     */
    boolean isFFprobe();

    /**
     * Returns whether it is a <code>MediaInformation</code> session or not.
     *
     * @return true if it is a <code>MediaInformation</code> session, false otherwise
     */
    boolean isMediaInformation();

    /**
     * Cancels running the session.
     */
    void cancel();

}
