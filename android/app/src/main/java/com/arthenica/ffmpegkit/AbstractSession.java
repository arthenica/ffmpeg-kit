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
import java.util.Optional;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicLong;
import java.util.function.BinaryOperator;
import java.util.function.Function;
import java.util.function.Supplier;
import java.util.stream.Stream;

public abstract class AbstractSession implements Session {

    /**
     * Generates ids for execute sessions.
     */
    private static final AtomicLong sessionIdGenerator = new AtomicLong(1);

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

    public AbstractSession(final String[] arguments,
                           final ExecuteCallback executeCallback,
                           final LogCallback logCallback,
                           final StatisticsCallback statisticsCallback) {
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
    }

    public ExecuteCallback getExecuteCallback() {
        return executeCallback;
    }

    public LogCallback getLogCallback() {
        return logCallback;
    }

    public StatisticsCallback getStatisticsCallback() {
        return statisticsCallback;
    }

    public long getSessionId() {
        return sessionId;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public Date getStartTime() {
        return startTime;
    }

    public Date getEndTime() {
        return endTime;
    }

    public long getDuration() {
        final Date startTime = this.startTime;
        final Date endTime = this.endTime;
        if (startTime != null && endTime != null) {
            return (endTime.getTime() - startTime.getTime());
        }

        return -1;
    }

    public String[] getArguments() {
        return arguments;
    }

    public String getCommand() {
        return FFmpegKit.argumentsToString(arguments);
    }

    public Queue<Log> getLogs() {
        return logs;
    }

    public Stream<Log> getLogsAsStream() {
        return logs.stream();
    }

    public String getLogsAsString() {
        final Optional<String> concatenatedStringOption = logs.stream().map(new Function<Log, String>() {
            @Override
            public String apply(final Log log) {
                return log.getMessage();
            }
        }).reduce(new BinaryOperator<String>() {
            @Override
            public String apply(final String s1, final String s2) {
                return s1 + s2;
            }
        });

        return concatenatedStringOption.orElseGet(new Supplier<String>() {

            @Override
            public String get() {
                return "";
            }
        });
    }

    public SessionState getState() {
        return state;
    }

    public int getReturnCode() {
        return returnCode;
    }

    public String getFailStackTrace() {
        return failStackTrace;
    }

    public void addLog(final Log log) {
        this.logs.add(log);
    }

    public Future<?> getFuture() {
        return future;
    }

    public void setFuture(final Future<?> future) {
        this.future = future;
    }

    public void startRunning() {
        this.state = SessionState.RUNNING;
        this.startTime = new Date();
    }

    public void complete(final int returnCode) {
        this.returnCode = returnCode;
        this.state = SessionState.COMPLETED;
        this.endTime = new Date();
    }

    public void fail(final Exception exception) {
        this.failStackTrace = Exceptions.getStackTraceString(exception);
        this.state = SessionState.FAILED;
        this.endTime = new Date();
    }

    public void cancel() {
        if (state == SessionState.RUNNING) {
            FFmpegKit.cancel(sessionId);
        }
    }

}
