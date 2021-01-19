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
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit;

import java.text.MessageFormat;
import java.util.LinkedList;
import java.util.Queue;

/**
 * <p>An FFprobe execute session.
 */
public class FFprobeSession extends AbstractSession implements Session {

    public FFprobeSession(final String[] arguments,
                          final ExecuteCallback executeCallback,
                          final LogCallback logCallback,
                          final StatisticsCallback statisticsCallback) {
        this(arguments, executeCallback, logCallback, statisticsCallback, FFmpegKitConfig.getLogRedirectionStrategy());
    }

    FFprobeSession(final String[] arguments,
                   final ExecuteCallback executeCallback,
                   final LogCallback logCallback,
                   final StatisticsCallback statisticsCallback,
                   final LogRedirectionStrategy logRedirectionStrategy) {
        super(arguments, executeCallback, logCallback, statisticsCallback, logRedirectionStrategy);
    }

    @Override
    public Queue<Statistics> getAllStatistics(final int waitTimeout) {
        return new LinkedList<>();
    }

    @Override
    public Queue<Statistics> getAllStatistics() {
        return new LinkedList<>();
    }

    @Override
    public Queue<Statistics> getStatistics() {
        return new LinkedList<>();
    }

    @Override
    public void addStatistics(final Statistics statistics) {
        /*
         * ffprobe does not support statistics.
         * So, this method should never have been called.
         */
        android.util.Log.w(FFmpegKitConfig.TAG, MessageFormat.format("FFprobe execute session {0} received statistics.", sessionId));
    }

    @Override
    public boolean isFFmpeg() {
        return false;
    }

    @Override
    public boolean isFFprobe() {
        return true;
    }

    @Override
    public String toString() {
        final StringBuilder stringBuilder = new StringBuilder();

        stringBuilder.append("FFprobeSession{");
        stringBuilder.append("sessionId=");
        stringBuilder.append(sessionId);
        stringBuilder.append(", createTime=");
        stringBuilder.append(createTime);
        stringBuilder.append(", startTime=");
        stringBuilder.append(startTime);
        stringBuilder.append(", endTime=");
        stringBuilder.append(endTime);
        stringBuilder.append(", arguments=");
        stringBuilder.append(FFmpegKit.argumentsToString(arguments));
        stringBuilder.append(", logs=");
        stringBuilder.append(getLogsAsString());
        stringBuilder.append(", state=");
        stringBuilder.append(state);
        stringBuilder.append(", returnCode=");
        stringBuilder.append(returnCode);
        stringBuilder.append(", failStackTrace=");
        stringBuilder.append('\'');
        stringBuilder.append(failStackTrace);
        stringBuilder.append('\'');
        stringBuilder.append('}');

        return stringBuilder.toString();
    }

}
