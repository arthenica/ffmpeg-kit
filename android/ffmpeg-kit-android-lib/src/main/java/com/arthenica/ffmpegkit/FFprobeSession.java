/*
 * Copyright (c) 2020-2022 Taner Sener
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
     * Session specific complete callback.
     */
    private final FFprobeSessionCompleteCallback completeCallback;

    /**
     * Builds a new FFprobe session.
     *
     * @param arguments command arguments
     * @return created session
     */
    public static FFprobeSession create(final String[] arguments) {
        return new FFprobeSession(arguments, null, null, FFmpegKitConfig.getLogRedirectionStrategy());
    }

    /**
     * Builds a new FFprobe session.
     *
     * @param arguments        command arguments
     * @param completeCallback session specific complete callback
     * @return created session
     */
    public static FFprobeSession create(final String[] arguments, final FFprobeSessionCompleteCallback completeCallback) {
        return new FFprobeSession(arguments, completeCallback, null, FFmpegKitConfig.getLogRedirectionStrategy());
    }

    /**
     * Builds a new FFprobe session.
     *
     * @param arguments        command arguments
     * @param completeCallback session specific complete callback
     * @param logCallback      session specific log callback
     * @return created session
     */
    public static FFprobeSession create(final String[] arguments,
                                        final FFprobeSessionCompleteCallback completeCallback,
                                        final LogCallback logCallback) {
        return new FFprobeSession(arguments, completeCallback, logCallback, FFmpegKitConfig.getLogRedirectionStrategy());
    }

    /**
     * Builds a new FFprobe session.
     *
     * @param arguments              command arguments
     * @param completeCallback       session specific complete callback
     * @param logCallback            session specific log callback
     * @param logRedirectionStrategy session specific log redirection strategy
     * @return created session
     */
    public static FFprobeSession create(final String[] arguments,
                                        final FFprobeSessionCompleteCallback completeCallback,
                                        final LogCallback logCallback,
                                        final LogRedirectionStrategy logRedirectionStrategy) {
        return new FFprobeSession(arguments, completeCallback, logCallback, logRedirectionStrategy);
    }

    /**
     * Builds a new FFprobe session.
     *
     * @param arguments              command arguments
     * @param completeCallback       session specific complete callback
     * @param logCallback            session specific log callback
     * @param logRedirectionStrategy session specific log redirection strategy
     */
    private FFprobeSession(final String[] arguments,
                           final FFprobeSessionCompleteCallback completeCallback,
                           final LogCallback logCallback,
                           final LogRedirectionStrategy logRedirectionStrategy) {
        super(arguments, logCallback, logRedirectionStrategy);

        this.completeCallback = completeCallback;
    }

    /**
     * Returns the session specific complete callback.
     *
     * @return session specific complete callback
     */
    public FFprobeSessionCompleteCallback getCompleteCallback() {
        return completeCallback;
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
    public boolean isMediaInformation() {
        return false;
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
