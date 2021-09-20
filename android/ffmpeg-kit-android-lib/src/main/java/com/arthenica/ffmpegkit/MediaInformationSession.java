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

/**
 * <p>A custom FFprobe session, which produces a <code>MediaInformation</code> object using the
 * FFprobe output.
 */
public class MediaInformationSession extends FFprobeSession implements Session {

    /**
     * Media information extracted in the session.
     */
    private MediaInformation mediaInformation;

    /**
     * Creates a new media information session.
     *
     * @param arguments command arguments
     */
    public MediaInformationSession(final String[] arguments) {
        this(arguments, null);
    }

    /**
     * Creates a new media information session.
     *
     * @param arguments       command arguments
     * @param executeCallback session specific execute callback function
     */
    public MediaInformationSession(final String[] arguments, final ExecuteCallback executeCallback) {
        this(arguments, executeCallback, null);
    }

    /**
     * Creates a new media information session.
     *
     * @param arguments       command arguments
     * @param executeCallback session specific execute callback function
     * @param logCallback     session specific log callback function
     */
    public MediaInformationSession(final String[] arguments, final ExecuteCallback executeCallback, final LogCallback logCallback) {
        super(arguments, executeCallback, logCallback, LogRedirectionStrategy.NEVER_PRINT_LOGS);
    }

    /**
     * Returns the media information extracted in this session.
     *
     * @return media information extracted or null if the command failed or the output can not be
     * parsed
     */
    public MediaInformation getMediaInformation() {
        return mediaInformation;
    }

    /**
     * Sets the media information extracted in this session.
     *
     * @param mediaInformation media information extracted
     */
    public void setMediaInformation(final MediaInformation mediaInformation) {
        this.mediaInformation = mediaInformation;
    }

    @Override
    public String toString() {
        final StringBuilder stringBuilder = new StringBuilder();

        stringBuilder.append("MediaInformationSession{");
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
