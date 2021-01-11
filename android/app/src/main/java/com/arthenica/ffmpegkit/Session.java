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
import java.util.Queue;
import java.util.concurrent.Future;
import java.util.stream.Stream;

/**
 * <p>Interface for ffmpeg and ffprobe execute sessions.
 */
public interface Session {

    ExecuteCallback getExecuteCallback();

    LogCallback getLogCallback();

    StatisticsCallback getStatisticsCallback();

    long getSessionId();

    Date getCreateTime();

    Date getStartTime();

    Date getEndTime();

    long getDuration();

    String[] getArguments();

    String getCommand();

    Queue<Log> getLogs();

    Stream<Log> getLogsAsStream();

    String getLogsAsString();

    Queue<Statistics> getStatistics();

    Stream<Statistics> getStatisticsAsStream();

    SessionState getState();

    int getReturnCode();

    String getFailStackTrace();

    void addLog(final Log log);

    void addStatistics(final Statistics statistics);

    Future<?> getFuture();

    void setFuture(final Future<?> future);

    void startRunning();

    void complete(final int returnCode);

    void fail(final Exception exception);

    boolean isFFmpeg();

    boolean isFFprobe();

    void cancel();

}
