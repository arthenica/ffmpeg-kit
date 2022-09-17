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

#ifndef FFMPEG_KIT_MEDIA_INFORMATION_SESSION_H
#define FFMPEG_KIT_MEDIA_INFORMATION_SESSION_H

#include "AbstractSession.h"
#include "MediaInformation.h"
#include "MediaInformationSessionCompleteCallback.h"

namespace ffmpegkit {

    /**
     * <p>A custom FFprobe session, which produces a <code>MediaInformation</code> object using the
     * FFprobe output.
     */
    class MediaInformationSession : public AbstractSession {
        public:

            /**
             * Creates a new media information session.
             *
             * @param arguments command arguments
             * @return created session
             */
            static std::shared_ptr<ffmpegkit::MediaInformationSession> create(const std::list<std::string>& arguments);

            /**
             * Creates a new media information session.
             *
             * @param arguments        command arguments
             * @param completeCallback session specific complete callback
             * @return created session
             */
            static std::shared_ptr<ffmpegkit::MediaInformationSession> create(const std::list<std::string>& arguments, ffmpegkit::MediaInformationSessionCompleteCallback completeCallback);

            /**
             * Creates a new media information session.
             *
             * @param arguments        command arguments
             * @param completeCallback session specific complete callback
             * @param logCallback      session specific log callback
             * @return created session
             */
            static std::shared_ptr<ffmpegkit::MediaInformationSession> create(const std::list<std::string>& arguments, ffmpegkit::MediaInformationSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback);

            /**
             * Returns the media information extracted in this session.
             *
             * @return media information extracted or nullptr if the command failed or the output can not be
             * parsed
             */
            std::shared_ptr<ffmpegkit::MediaInformation> getMediaInformation();

            /**
             * Sets the media information extracted in this session.
             *
             * @param mediaInformation media information extracted
             */
            void setMediaInformation(const std::shared_ptr<ffmpegkit::MediaInformation> mediaInformation);

            /**
             * Returns the session specific complete callback.
             *
             * @return session specific complete callback
             */
            ffmpegkit::MediaInformationSessionCompleteCallback getCompleteCallback();

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

            struct PublicMediaInformationSession;

            /**
             * Creates a new media information session.
             *
             * @param arguments        command arguments
             * @param completeCallback session specific complete callback
             * @param logCallback      session specific log callback
             */
            MediaInformationSession(const std::list<std::string>& arguments, ffmpegkit::MediaInformationSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback);

            ffmpegkit::MediaInformationSessionCompleteCallback _completeCallback;
            std::shared_ptr<ffmpegkit::MediaInformation> _mediaInformation;
    };

}

#endif // FFMPEG_KIT_MEDIA_INFORMATION_SESSION_H
