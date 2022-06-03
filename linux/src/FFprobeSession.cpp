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

#include "FFprobeSession.h"
#include "FFmpegKitConfig.h"
#include "LogCallback.h"

ffmpegkit::FFprobeSession::FFprobeSession(const std::shared_ptr<std::list<std::string>> arguments) :
    ffmpegkit::FFprobeSession(arguments, nullptr, nullptr) {
}

ffmpegkit::FFprobeSession::FFprobeSession(const std::shared_ptr<std::list<std::string>> arguments, const FFprobeSessionCompleteCallback completeCallback) :
    ffmpegkit::FFprobeSession(arguments, completeCallback, nullptr) {
}

ffmpegkit::FFprobeSession::FFprobeSession(const std::shared_ptr<std::list<std::string>> arguments, const FFprobeSessionCompleteCallback completeCallback, const ffmpegkit::LogCallback logCallback) :
    ffmpegkit::AbstractSession(arguments, logCallback, ffmpegkit::FFmpegKitConfig::getLogRedirectionStrategy()), _completeCallback{completeCallback} {
}

ffmpegkit::FFprobeSession::FFprobeSession(const std::shared_ptr<std::list<std::string>> arguments, const FFprobeSessionCompleteCallback completeCallback, const ffmpegkit::LogCallback logCallback, const LogRedirectionStrategy logRedirectionStrategy) :
    ffmpegkit::AbstractSession(arguments, logCallback, logRedirectionStrategy), _completeCallback{completeCallback} {
}

ffmpegkit::FFprobeSessionCompleteCallback ffmpegkit::FFprobeSession::getCompleteCallback() {
    return _completeCallback;
}

bool ffmpegkit::FFprobeSession::isFFmpeg() const {
    return false;
}

bool ffmpegkit::FFprobeSession::isFFprobe() const {
    return true;
}

bool ffmpegkit::FFprobeSession::isMediaInformation() const {
    return false;
}
