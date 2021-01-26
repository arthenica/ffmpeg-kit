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

import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

/**
 * <p>An FFmpeg execute session.
 */
public class FFmpegSession extends AbstractSession implements Session {
    private final Queue<Statistics> statistics;

    public FFmpegSession(final String[] arguments,
                         final ExecuteCallback executeCallback,
                         final LogCallback logCallback,
                         final StatisticsCallback statisticsCallback) {
        super(arguments, executeCallback, logCallback, statisticsCallback, FFmpegKitConfig.getLogRedirectionStrategy());

        this.statistics = new ConcurrentLinkedQueue<>();
    }

    @Override
    public Queue<Statistics> getAllStatistics(final int waitTimeout) {
        waitForCallbackMessagesInTransmit(waitTimeout);

        if (thereAreCallbackMessagesInTransmit()) {
            android.util.Log.i(FFmpegKitConfig.TAG, String.format("getAllStatistics was asked to return all statistics but there are still statistics being transmitted for session id %d.", sessionId));
        }

        return getStatistics();
    }

    @Override
    public Queue<Statistics> getAllStatistics() {
        return getAllStatistics(DEFAULT_TIMEOUT_FOR_CALLBACK_MESSAGES_IN_TRANSMIT);
    }

    @Override
    public Queue<Statistics> getStatistics() {
        return statistics;
    }

    @Override
    public void addStatistics(final Statistics statistics) {
        this.statistics.add(statistics);
    }

    @Override
    public boolean isFFmpeg() {
        return true;
    }

    @Override
    public boolean isFFprobe() {
        return false;
    }

    @Override
    public String toString() {
        final StringBuilder stringBuilder = new StringBuilder();

        stringBuilder.append("FFmpegSession{");
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
