/*
 * Copyright (c) 2018-2021 Taner Sener
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
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit;

/**
 * <p>Executes a MediaInformation session asynchronously.
 */
public class AsyncGetMediaInformationTask implements Runnable {
    private final MediaInformationSession mediaInformationSession;
    private final ExecuteCallback executeCallback;
    private final Integer waitTimeout;

    public AsyncGetMediaInformationTask(final MediaInformationSession mediaInformationSession) {
        this(mediaInformationSession, AbstractSession.DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT);
    }

    public AsyncGetMediaInformationTask(final MediaInformationSession mediaInformationSession, final Integer waitTimeout) {
        this.mediaInformationSession = mediaInformationSession;
        this.executeCallback = mediaInformationSession.getExecuteCallback();
        this.waitTimeout = waitTimeout;
    }

    @Override
    public void run() {
        FFmpegKitConfig.getMediaInformationExecute(mediaInformationSession, waitTimeout);

        final ExecuteCallback globalExecuteCallbackFunction = FFmpegKitConfig.getExecuteCallback();
        if (globalExecuteCallbackFunction != null) {
            globalExecuteCallbackFunction.apply(mediaInformationSession);
        }

        if (executeCallback != null) {
            executeCallback.apply(mediaInformationSession);
        }
    }

}
