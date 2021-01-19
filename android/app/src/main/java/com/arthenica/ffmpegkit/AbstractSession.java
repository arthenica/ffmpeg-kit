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
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicLong;

public abstract class AbstractSession implements Session {

    /**
     * Generates ids for execute sessions.
     */
    protected static final AtomicLong sessionIdGenerator = new AtomicLong(1);

    /**
     * Defines how long default `getAll` methods wait.
     */
    protected static final int DEFAULT_TIMEOUT_FOR_CALLBACK_MESSAGES_IN_TRANSMIT = 5000;

    protected final ExecuteCallback executeCallback;
    protected final LogCallback logCallback;
    protected final StatisticsCallback statisticsCallback;
    protected final long sessionId;
    protected final Date createTime;
    protected Date startTime;
    protected Date endTime;
    protected final String[] arguments;
    protected final Queue<Log> logs;
    protected Future<?> future;
    protected SessionState state;
    protected int returnCode;
    protected String failStackTrace;
    protected final LogRedirectionStrategy logRedirectionStrategy;

    public AbstractSession(final String[] arguments,
                           final ExecuteCallback executeCallback,
                           final LogCallback logCallback,
                           final StatisticsCallback statisticsCallback,
                           final LogRedirectionStrategy logRedirectionStrategy) {
        this.sessionId = sessionIdGenerator.getAndIncrement();
        this.createTime = new Date();
        this.startTime = null;
        this.arguments = arguments;
        this.executeCallback = executeCallback;
        this.logCallback = logCallback;
        this.statisticsCallback = statisticsCallback;
        this.logs = new ConcurrentLinkedQueue<>();
        this.future = null;
        this.state = SessionState.CREATED;
        this.returnCode = ReturnCode.NOT_SET;
        this.failStackTrace = null;
        this.logRedirectionStrategy = logRedirectionStrategy;
    }

    @Override
    public ExecuteCallback getExecuteCallback() {
        return executeCallback;
    }

    @Override
    public LogCallback getLogCallback() {
        return logCallback;
    }

    @Override
    public StatisticsCallback getStatisticsCallback() {
        return statisticsCallback;
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

        return -1;
    }

    @Override
    public String[] getArguments() {
        return arguments;
    }

    @Override
    public String getCommand() {
        return FFmpegKit.argumentsToString(arguments);
    }

    protected void waitForCallbackMessagesInTransmit(final int timeout) {
        final long start = System.currentTimeMillis();

        /*
         * WE GIVE MAX 5 SECONDS TO TRANSMIT ALL NATIVE MESSAGES
         */
        while (thereAreCallbackMessagesInTransmit() && (System.currentTimeMillis() < (start + timeout))) {
            synchronized (this) {
                try {
                    wait(100);
                } catch (InterruptedException ignored) {
                }
            }
        }
    }

    @Override
    public Queue<Log> getAllLogs(final int waitTimeout) {
        waitForCallbackMessagesInTransmit(waitTimeout);

        if (thereAreCallbackMessagesInTransmit()) {
            android.util.Log.i(FFmpegKitConfig.TAG, String.format("getAllLogs was asked to return all logs but there are still logs being transmitted for session id %d.", sessionId));
        }

        return logs;
    }

    @Override
    public Queue<Log> getAllLogs() {
        return getAllLogs(DEFAULT_TIMEOUT_FOR_CALLBACK_MESSAGES_IN_TRANSMIT);
    }

    @Override
    public Queue<Log> getLogs() {
        return logs;
    }

    @Override
    public String getAllLogsAsString(final int waitTimeout) {
        waitForCallbackMessagesInTransmit(waitTimeout);

        if (thereAreCallbackMessagesInTransmit()) {
            android.util.Log.i(FFmpegKitConfig.TAG, String.format("getAllLogsAsString was asked to return all logs but there are still logs being transmitted for session id %d.", sessionId));
        }

        return getLogsAsString();
    }

    @Override
    public String getAllLogsAsString() {
        return getAllLogsAsString(DEFAULT_TIMEOUT_FOR_CALLBACK_MESSAGES_IN_TRANSMIT);
    }

    @Override
    public String getLogsAsString() {
        final StringBuilder concatenatedString = new StringBuilder();

        for (Log log : logs) {
            concatenatedString.append(log.getMessage());
        }

        return concatenatedString.toString();
    }

    @Override
    public SessionState getState() {
        return state;
    }

    @Override
    public int getReturnCode() {
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
    public boolean thereAreCallbackMessagesInTransmit() {
        return (FFmpegKitConfig.messagesInTransmit(sessionId) != 0);
    }

    @Override
    public void addLog(final Log log) {
        this.logs.add(log);
    }

    @Override
    public Future<?> getFuture() {
        return future;
    }

    @Override
    public void setFuture(final Future<?> future) {
        this.future = future;
    }

    @Override
    public void startRunning() {
        this.state = SessionState.RUNNING;
        this.startTime = new Date();
    }

    @Override
    public void complete(final int returnCode) {
        this.returnCode = returnCode;
        this.state = SessionState.COMPLETED;
        this.endTime = new Date();
    }

    @Override
    public void fail(final Exception exception) {
        this.failStackTrace = Exceptions.getStackTraceString(exception);
        this.state = SessionState.FAILED;
        this.endTime = new Date();
    }

    @Override
    public void cancel() {
        if (state == SessionState.RUNNING) {
            FFmpegKit.cancel(sessionId);
        }
    }

}
