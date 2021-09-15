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

/**
 * <p>An FFprobe session.
 */
public class FFprobeSession extends AbstractSession implements Session {

    /**
     * Builds a new FFprobe session.
     *
     * @param arguments command arguments
     */
    public FFprobeSession(final String[] arguments) {
        this(arguments, null);
    }

    /**
     * Builds a new FFprobe session.
     *
     * @param arguments       command arguments
     * @param executeCallback session specific execute callback function
     */
    public FFprobeSession(final String[] arguments, final ExecuteCallback executeCallback) {
        this(arguments, executeCallback, null);
    }

    /**
     * Builds a new FFprobe session.
     *
     * @param arguments       command arguments
     * @param executeCallback session specific execute callback function
     * @param logCallback     session specific log callback function
     */
    public FFprobeSession(final String[] arguments,
                          final ExecuteCallback executeCallback,
                          final LogCallback logCallback) {
        this(arguments, executeCallback, logCallback, FFmpegKitConfig.getLogRedirectionStrategy());
    }

    /**
     * Builds a new FFprobe session.
     *
     * @param arguments              command arguments
     * @param executeCallback        session specific execute callback function
     * @param logCallback            session specific log callback function
     * @param logRedirectionStrategy session specific log redirection strategy
     */
    public FFprobeSession(final String[] arguments,
                          final ExecuteCallback executeCallback,
                          final LogCallback logCallback,
                          final LogRedirectionStrategy logRedirectionStrategy) {
        super(arguments, executeCallback, logCallback, logRedirectionStrategy);
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
