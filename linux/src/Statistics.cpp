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

#include "Statistics.h"

ffmpegkit::Statistics::Statistics(const long sessionId, const int videoFrameNumber, const float videoFps, const float videoQuality, const int64_t size, const double time, const double bitrate, const double speed) :
    _sessionId{sessionId}, _videoFrameNumber{videoFrameNumber}, _videoFps{videoFps}, _videoQuality{videoQuality}, _size{size}, _time{time}, _bitrate{bitrate}, _speed{speed} {
}

long ffmpegkit::Statistics::getSessionId() {
    return _sessionId;
}

int ffmpegkit::Statistics::getVideoFrameNumber() {
    return _videoFrameNumber;
}

float ffmpegkit::Statistics::getVideoFps() {
    return _videoFps;
}

float ffmpegkit::Statistics::getVideoQuality() {
    return _videoQuality;
}

int64_t ffmpegkit::Statistics::getSize() {
    return _size;
}

double ffmpegkit::Statistics::getTime() {
    return _time;
}

double ffmpegkit::Statistics::getBitrate() {
    return _bitrate;
}

double ffmpegkit::Statistics::getSpeed() {
    return _speed;
}
