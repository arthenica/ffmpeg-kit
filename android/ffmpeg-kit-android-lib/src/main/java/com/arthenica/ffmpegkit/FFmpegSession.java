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

import java.util.LinkedList;
import java.util.List;

/**
 * <p>An FFmpeg session.
 */
public class FFmpegSession extends AbstractSession implements Session {

    /**
     * Session specific statistics callback.
     */
    private final StatisticsCallback statisticsCallback;

    /**
     * Session specific complete callback.
     */
    private final FFmpegSessionCompleteCallback completeCallback;

    /**
     * Statistics entries received for this session.
     */
    private final List<Statistics> statistics;

    /**
     * Statistics entry lock.
     */
    private final Object statisticsLock;

    /**
     * Builds a new FFmpeg session.
     *
     * @param arguments command arguments
     * @return created session
     */
    public static FFmpegSession create(final String[] arguments) {
        return new FFmpegSession(arguments, null, null, null, FFmpegKitConfig.getLogRedirectionStrategy());
    }

    /**
     * Builds a new FFmpeg session.
     *
     * @param arguments        command arguments
     * @param completeCallback session specific complete callback
     * @return created session
     */
    public static FFmpegSession create(final String[] arguments, final FFmpegSessionCompleteCallback completeCallback) {
        return new FFmpegSession(arguments, completeCallback, null, null, FFmpegKitConfig.getLogRedirectionStrategy());
    }

    /**
     * Builds a new FFmpeg session.
     *
     * @param arguments          command arguments
     * @param completeCallback   session specific complete callback
     * @param logCallback        session specific log callback
     * @param statisticsCallback session specific statistics callback
     * @return created session
     */
    public static FFmpegSession create(final String[] arguments,
                                       final FFmpegSessionCompleteCallback completeCallback,
                                       final LogCallback logCallback,
                                       final StatisticsCallback statisticsCallback) {
        return new FFmpegSession(arguments, completeCallback, logCallback, statisticsCallback, FFmpegKitConfig.getLogRedirectionStrategy());
    }

    /**
     * Builds a new FFmpeg session.
     *
     * @param arguments              command arguments
     * @param completeCallback       session specific complete callback
     * @param logCallback            session specific log callback
     * @param statisticsCallback     session specific statistics callback
     * @param logRedirectionStrategy session specific log redirection strategy
     * @return created session
     */
    public static FFmpegSession create(final String[] arguments,
                                       final FFmpegSessionCompleteCallback completeCallback,
                                       final LogCallback logCallback,
                                       final StatisticsCallback statisticsCallback,
                                       final LogRedirectionStrategy logRedirectionStrategy) {
        return new FFmpegSession(arguments, completeCallback, logCallback, statisticsCallback, logRedirectionStrategy);
    }

    /**
     * Builds a new FFmpeg session.
     *
     * @param arguments              command arguments
     * @param completeCallback       session specific complete callback
     * @param logCallback            session specific log callback
     * @param statisticsCallback     session specific statistics callback
     * @param logRedirectionStrategy session specific log redirection strategy
     */
    private FFmpegSession(final String[] arguments,
                          final FFmpegSessionCompleteCallback completeCallback,
                          final LogCallback logCallback,
                          final StatisticsCallback statisticsCallback,
                          final LogRedirectionStrategy logRedirectionStrategy) {
        super(arguments, logCallback, logRedirectionStrategy);

        this.completeCallback = completeCallback;
        this.statisticsCallback = statisticsCallback;

        this.statistics = new LinkedList<>();
        this.statisticsLock = new Object();
    }

    /**
     * Returns the session specific statistics callback.
     *
     * @return session specific statistics callback
     */
    public StatisticsCallback getStatisticsCallback() {
        return statisticsCallback;
    }

    /**
     * Returns the session specific complete callback.
     *
     * @return session specific complete callback
     */
    public FFmpegSessionCompleteCallback getCompleteCallback() {
        return completeCallback;
    }

    /**
     * Returns all statistics entries generated for this session. If there are asynchronous
     * messages that are not delivered yet, this method waits for them until the given timeout.
     *
     * @param waitTimeout wait timeout for asynchronous messages in milliseconds
     * @return list of statistics entries generated for this session
     */
    public List<Statistics> getAllStatistics(final int waitTimeout) {
        waitForAsynchronousMessagesInTransmit(waitTimeout);

        if (thereAreAsynchronousMessagesInTransmit()) {
            android.util.Log.i(FFmpegKitConfig.TAG, String.format("getAllStatistics was called to return all statistics but there are still statistics being transmitted for session id %d.", sessionId));
        }

        return getStatistics();
    }

    /**
     * Returns all statistics entries generated for this session. If there are asynchronous
     * messages that are not delivered yet, this method waits for them until
     * {@link #DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT} expires.
     *
     * @return list of statistics entries generated for this session
     */
    public List<Statistics> getAllStatistics() {
        return getAllStatistics(DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT);
    }

    /**
     * Returns all statistics entries delivered for this session. Note that if there are
     * asynchronous messages that are not delivered yet, this method will not wait for
     * them and will return immediately.
     *
     * @return list of statistics entries received for this session
     */
    public List<Statistics> getStatistics() {
        synchronized (statisticsLock) {
            return statistics;
        }
    }

    /**
     * Returns the last received statistics entry.
     *
     * @return the last received statistics entry or null if there are not any statistics entries
     * received
     */
    public Statistics getLastReceivedStatistics() {
        synchronized (statisticsLock) {
            if (statistics.size() > 0) {
                return statistics.get(statistics.size() - 1);
            } else {
                return null;
            }
        }
    }

    /**
     * Adds a new statistics entry for this session. It is invoked internally by
     * <code>FFmpegKit</code> library methods. Must not be used by user applications.
     *
     * @param statistics statistics entry
     */
    public void addStatistics(final Statistics statistics) {
        synchronized (statisticsLock) {
            this.statistics.add(statistics);
        }
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
    public boolean isMediaInformation() {
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
        stringBuilder.append(FFmpegKitConfig.argumentsToString(arguments));
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
