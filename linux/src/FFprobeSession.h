/*
 * Copyright (c) 2022 Taner Sener
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

#ifndef FFMPEG_KIT_FFPROBE_SESSION_H
#define FFMPEG_KIT_FFPROBE_SESSION_H

#include "AbstractSession.h"
#include "FFprobeSessionCompleteCallback.h"

namespace ffmpegkit {

    /**
     * <p>An FFprobe session.
     */
    class FFprobeSession : public AbstractSession {
        public:

            /**
             * Builds a new FFprobe session.
             *
             * @param arguments command arguments
             * @return created session
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> create(const std::list<std::string>& arguments);

            /**
             * Builds a new FFprobe session.
             *
             * @param arguments        command arguments
             * @param completeCallback session specific complete callback
             * @return created session
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> create(const std::list<std::string>& arguments, const FFprobeSessionCompleteCallback completeCallback);

            /**
             * Builds a new FFprobe session.
             *
             * @param arguments        command arguments
             * @param completeCallback session specific complete callback
             * @param logCallback      session specific log callback
             * @return created session
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> create(const std::list<std::string>& arguments, const FFprobeSessionCompleteCallback completeCallback, const ffmpegkit::LogCallback logCallback);

            /**
             * Builds a new FFprobe session.
             *
             * @param arguments               command arguments
             * @param completeCallback        session specific complete callback
             * @param logCallback             session specific log callback
             * @param logRedirectionStrategy  session specific log redirection strategy
             * @return created session
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> create(const std::list<std::string>& arguments, const FFprobeSessionCompleteCallback completeCallback, const ffmpegkit::LogCallback logCallback, const LogRedirectionStrategy logRedirectionStrategy);

            /**
             * Returns the session specific complete callback.
             *
             * @return session specific complete callback
             */
            ffmpegkit::FFprobeSessionCompleteCallback getCompleteCallback();

            /**
             * Returns whether it is an <code>FFmpeg</code> session or not.
             *
             * @return true if it is an <code>FFmpeg</code> session, false otherwise
             */
            bool isFFmpeg() const override;

            /**
             * Returns whether it is an <code>FFprobe</code> session or not.
             *
             * @return true if it is an <code>FFprobe</code> session, false otherwise
             */
            bool isFFprobe() const override;

            /**
             * Returns whether it is a <code>MediaInformation</code> session or not.
             *
             * @return true if it is a <code>MediaInformation</code> session, false otherwise
             */
            bool isMediaInformation() const override;

        private:

            struct PublicFFprobeSession;

            /**
             * Builds a new FFprobe session.
             *
             * @param arguments               command arguments
             * @param completeCallback        session specific complete callback
             * @param logCallback             session specific log callback
             * @param logRedirectionStrategy  session specific log redirection strategy
             */
            FFprobeSession(const std::list<std::string>& arguments, const FFprobeSessionCompleteCallback completeCallback, const ffmpegkit::LogCallback logCallback, const LogRedirectionStrategy logRedirectionStrategy);

            FFprobeSessionCompleteCallback _completeCallback;
    };

}

#endif // FFMPEG_KIT_FFPROBE_SESSION_H
