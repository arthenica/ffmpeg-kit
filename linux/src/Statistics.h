/*
 * Copyright (c) 2022 Taner Sener
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

#ifndef FFMPEG_KIT_STATISTICS_H
#define FFMPEG_KIT_STATISTICS_H

#include <stdlib.h>

namespace ffmpegkit {

    /**
     * Statistics entry for an FFmpeg execute session.
     */
    class Statistics {
        public:

            Statistics(const long sessionId, const int videoFrameNumber, const float videoFps, const float videoQuality, const int64_t size, const double time, const double bitrate, const double speed);
            long getSessionId();
            int getVideoFrameNumber();
            float getVideoFps();
            float getVideoQuality();
            int64_t getSize();
            double getTime();
            double getBitrate();
            double getSpeed();

        private:
            long _sessionId;
            int _videoFrameNumber;
            float _videoFps;
            float _videoQuality;
            int64_t _size;
            double _time;
            double _bitrate;
            double _speed;
    };

}

#endif // FFMPEG_KIT_STATISTICS_H
