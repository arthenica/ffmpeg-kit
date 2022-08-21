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

#ifndef FFMPEG_KIT_LOG_H
#define FFMPEG_KIT_LOG_H

#include "Level.h"
#include <string>

namespace ffmpegkit {

    /**
     * <p>Log entry for an <code>FFmpegKit</code> session.
     */
    class Log {
        public:
            Log(const long sessionId, const ffmpegkit::Level level, const char* message);
            long getSessionId() const;
            ffmpegkit::Level getLevel() const;
            std::string getMessage() const;

        private:
            long _sessionId;
            ffmpegkit::Level _level;
            std::string _message;
    };

}

#endif // FFMPEG_KIT_LOG_H
