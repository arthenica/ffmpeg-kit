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
 * <p>A custom FFprobe execute session, which produces a <code>MediaInformation</code> object
 * using the output of the execution.
 */
public class MediaInformationSession extends FFprobeSession implements Session {
    private MediaInformation mediaInformation;

    public MediaInformationSession(final String[] arguments,
                                   final ExecuteCallback executeCallback,
                                   final LogCallback logCallback,
                                   final StatisticsCallback statisticsCallback) {
        super(arguments, executeCallback, logCallback, statisticsCallback, LogRedirectionStrategy.NEVER_PRINT_LOGS);
    }

    public MediaInformation getMediaInformation() {
        return mediaInformation;
    }

    public void setMediaInformation(MediaInformation mediaInformation) {
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
