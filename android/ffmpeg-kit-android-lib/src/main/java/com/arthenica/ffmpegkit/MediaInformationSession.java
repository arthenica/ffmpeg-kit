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
public class MediaInformationSession extends AbstractSession implements Session {

    /**
     * Media information extracted in the session.
     */
    private MediaInformation mediaInformation;

    /**
     * Session specific complete callback.
     */
    private final MediaInformationSessionCompleteCallback completeCallback;

    /**
     * Creates a new media information session.
     *
     * @param arguments command arguments
     * @return created session
     */
    public static MediaInformationSession create(final String[] arguments) {
        return new MediaInformationSession(arguments, null, null);
    }

    /**
     * Creates a new media information session.
     *
     * @param arguments        command arguments
     * @param completeCallback session specific complete callback
     * @return created session
     */
    public static MediaInformationSession create(final String[] arguments, final MediaInformationSessionCompleteCallback completeCallback) {
        return new MediaInformationSession(arguments, completeCallback, null);
    }

    /**
     * Creates a new media information session.
     *
     * @param arguments        command arguments
     * @param completeCallback session specific complete callback
     * @param logCallback      session specific log callback
     * @return created session
     */
    public static MediaInformationSession create(final String[] arguments, final MediaInformationSessionCompleteCallback completeCallback, final LogCallback logCallback) {
        return new MediaInformationSession(arguments, completeCallback, logCallback);
    }

    /**
     * Creates a new media information session.
     *
     * @param arguments        command arguments
     * @param completeCallback session specific complete callback
     * @param logCallback      session specific log callback
     */
    private MediaInformationSession(final String[] arguments, final MediaInformationSessionCompleteCallback completeCallback, final LogCallback logCallback) {
        super(arguments, logCallback, LogRedirectionStrategy.NEVER_PRINT_LOGS);

        this.completeCallback = completeCallback;
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

    /**
     * Returns the session specific complete callback.
     *
     * @return session specific complete callback
     */
    public MediaInformationSessionCompleteCallback getCompleteCallback() {
        return completeCallback;
    }

    @Override
    public boolean isFFmpeg() {
        return false;
    }

    @Override
    public boolean isFFprobe() {
        return false;
    }

    @Override
    public boolean isMediaInformation() {
        return true;
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
