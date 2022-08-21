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

#include "Log.h"

ffmpegkit::Log::Log(const long sessionId, const ffmpegkit::Level level, const char* message) : _sessionId{sessionId}, _level{level}, _message{message} {
}

long ffmpegkit::Log::getSessionId() const {
    return _sessionId;
}

ffmpegkit::Level ffmpegkit::Log::getLevel() const {
    return _level;
}

std::string ffmpegkit::Log::getMessage() const {
    return _message;
}
