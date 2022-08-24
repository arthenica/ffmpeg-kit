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

import com.arthenica.smartexception.java.Exceptions;

import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Abstract session implementation which includes common features shared by <code>FFmpeg</code>,
 * <code>FFprobe</code> and <code>MediaInformation</code> sessions.
 */
public abstract class AbstractSession implements Session {

    /**
     * Generates unique ids for sessions.
     */
    protected static final AtomicLong sessionIdGenerator = new AtomicLong(1);

    /**
     * Defines how long default "getAll" methods wait, in milliseconds.
     */
    public static final int DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT = 5000;

    /**
     * Session identifier.
     */
    protected final long sessionId;

    /**
     * Session specific log callback.
     */
    protected final LogCallback logCallback;

    /**
     * Date and time the session was created.
     */
    protected final Date createTime;

    /**
     * Date and time the session was started.
     */
    protected Date startTime;

    /**
     * Date and time the session has ended.
     */
    protected Date endTime;

    /**
     * Command arguments as an array.
     */
    protected final String[] arguments;

    /**
     * Log entries received for this session.
     */
    protected final List<Log> logs;

    /**
     * Log entry lock.
     */
    protected final Object logsLock;

    /**
     * Future created for sessions executed asynchronously.
     */
    protected Future<?> future;

    /**
     * State of the session.
     */
    protected SessionState state;

    /**
     * Return code for the completed sessions.
     */
    protected ReturnCode returnCode;

    /**
     * Stack trace of the error received while trying to execute this session.
     */
    protected String failStackTrace;

    /**
     * Session specific log redirection strategy.
     */
    protected final LogRedirectionStrategy logRedirectionStrategy;

    /**
     * Creates a new abstract session.
     *
     * @param arguments              command arguments
     * @param logCallback            session specific log callback
     * @param logRedirectionStrategy session specific log redirection strategy
     */
    protected AbstractSession(final String[] arguments,
                           final LogCallback logCallback,
                           final LogRedirectionStrategy logRedirectionStrategy) {
        this.sessionId = sessionIdGenerator.getAndIncrement();
        this.logCallback = logCallback;
        this.createTime = new Date();
        this.startTime = null;
        this.endTime = null;
        this.arguments = arguments;
        this.logs = new LinkedList<>();
        this.logsLock = new Object();
        this.future = null;
        this.state = SessionState.CREATED;
        this.returnCode = null;
        this.failStackTrace = null;
        this.logRedirectionStrategy = logRedirectionStrategy;

        FFmpegKitConfig.addSession(this);
    }

    @Override
    public LogCallback getLogCallback() {
        return logCallback;
    }

    @Override
    public long getSessionId() {
        return sessionId;
    }

    @Override
    public Date getCreateTime() {
        return createTime;
    }

    @Override
    public Date getStartTime() {
        return startTime;
    }

    @Override
    public Date getEndTime() {
        return endTime;
    }

    @Override
    public long getDuration() {
        final Date startTime = this.startTime;
        final Date endTime = this.endTime;
        if (startTime != null && endTime != null) {
            return (endTime.getTime() - startTime.getTime());
        }

        return 0;
    }

    @Override
    public String[] getArguments() {
        return arguments;
    }

    @Override
    public String getCommand() {
        return FFmpegKitConfig.argumentsToString(arguments);
    }

    @Override
    public List<Log> getAllLogs(final int waitTimeout) {
        waitForAsynchronousMessagesInTransmit(waitTimeout);

        if (thereAreAsynchronousMessagesInTransmit()) {
            android.util.Log.i(FFmpegKitConfig.TAG, String.format("getAllLogs was called to return all logs but there are still logs being transmitted for session id %d.", sessionId));
        }

        return getLogs();
    }

    /**
     * Returns all log entries generated for this session. If there are asynchronous
     * messages that are not delivered yet, this method waits for them until
     * {@link #DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT} expires.
     *
     * @return list of log entries generated for this session
     */
    @Override
    public List<Log> getAllLogs() {
        return getAllLogs(DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT);
    }

    @Override
    public List<Log> getLogs() {
        synchronized (logsLock) {
            return new LinkedList<>(logs);
        }
    }

    @Override
    public String getAllLogsAsString(final int waitTimeout) {
        waitForAsynchronousMessagesInTransmit(waitTimeout);

        if (thereAreAsynchronousMessagesInTransmit()) {
            android.util.Log.i(FFmpegKitConfig.TAG, String.format("getAllLogsAsString was called to return all logs but there are still logs being transmitted for session id %d.", sessionId));
        }

        return getLogsAsString();
    }

    /**
     * Returns all log entries generated for this session as a concatenated string. If there are
     * asynchronous messages that are not delivered yet, this method waits for them until
     * {@link #DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT} expires.
     *
     * @return all log entries generated for this session as a concatenated string
     */
    @Override
    public String getAllLogsAsString() {
        return getAllLogsAsString(DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT);
    }

    @Override
    public String getLogsAsString() {
        final StringBuilder concatenatedString = new StringBuilder();

        synchronized (logsLock) {
            for (Log log : logs) {
                concatenatedString.append(log.getMessage());
            }
        }

        return concatenatedString.toString();
    }

    @Override
    public String getOutput() {
        return getAllLogsAsString();
    }

    @Override
    public SessionState getState() {
        return state;
    }

    @Override
    public ReturnCode getReturnCode() {
        return returnCode;
    }

    @Override
    public String getFailStackTrace() {
        return failStackTrace;
    }

    @Override
    public LogRedirectionStrategy getLogRedirectionStrategy() {
        return logRedirectionStrategy;
    }

    @Override
    public boolean thereAreAsynchronousMessagesInTransmit() {
        return (FFmpegKitConfig.messagesInTransmit(sessionId) != 0);
    }

    @Override
    public void addLog(final Log log) {
        synchronized (logsLock) {
            this.logs.add(log);
        }
    }

    @Override
    public Future<?> getFuture() {
        return future;
    }

    @Override
    public void cancel() {
        if (state == SessionState.RUNNING) {
            FFmpegKit.cancel(sessionId);
        }
    }

    /**
     * Waits for all asynchronous messages to be transmitted until the given timeout.
     *
     * @param timeout wait timeout in milliseconds
     */
    protected void waitForAsynchronousMessagesInTransmit(final int timeout) {
        final long start = System.currentTimeMillis();

        while (thereAreAsynchronousMessagesInTransmit() && (System.currentTimeMillis() < (start + timeout))) {
            synchronized (this) {
                try {
                    wait(100);
                } catch (InterruptedException ignored) {
                }
            }
        }
    }

    /**
     * Sets the future created for this session.
     *
     * @param future future that runs this session asynchronously
     */
    void setFuture(final Future<?> future) {
        this.future = future;
    }

    /**
     * Starts running the session.
     */
    void startRunning() {
        this.state = SessionState.RUNNING;
        this.startTime = new Date();
    }

    /**
     * Completes running the session with the provided return code.
     *
     * @param returnCode return code of the execution
     */
    void complete(final ReturnCode returnCode) {
        this.returnCode = returnCode;
        this.state = SessionState.COMPLETED;
        this.endTime = new Date();
    }

    /**
     * Ends running the session with a failure.
     *
     * @param exception execution received
     */
    void fail(final Exception exception) {
        this.failStackTrace = Exceptions.getStackTraceString(exception);
        this.state = SessionState.FAILED;
        this.endTime = new Date();
    }

}
