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

extern void addSessionToSessionHistory(const std::shared_ptr<ffmpegkit::Session> session);

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeSession::create(const std::list<std::string>& arguments) {
    auto session = std::static_pointer_cast<ffmpegkit::FFprobeSession>(std::make_shared<ffmpegkit::FFprobeSession::PublicFFprobeSession>(arguments, nullptr, nullptr, ffmpegkit::FFmpegKitConfig::getLogRedirectionStrategy()));
    addSessionToSessionHistory(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeSession::create(const std::list<std::string>& arguments, const FFprobeSessionCompleteCallback completeCallback) {
    auto session = std::static_pointer_cast<ffmpegkit::FFprobeSession>(std::make_shared<ffmpegkit::FFprobeSession::PublicFFprobeSession>(arguments, completeCallback, nullptr, ffmpegkit::FFmpegKitConfig::getLogRedirectionStrategy()));
    addSessionToSessionHistory(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeSession::create(const std::list<std::string>& arguments, const FFprobeSessionCompleteCallback completeCallback, const ffmpegkit::LogCallback logCallback) {
    auto session = std::static_pointer_cast<ffmpegkit::FFprobeSession>(std::make_shared<ffmpegkit::FFprobeSession::PublicFFprobeSession>(arguments, completeCallback, logCallback, ffmpegkit::FFmpegKitConfig::getLogRedirectionStrategy()));
    addSessionToSessionHistory(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeSession::create(const std::list<std::string>& arguments, const FFprobeSessionCompleteCallback completeCallback, const ffmpegkit::LogCallback logCallback, const LogRedirectionStrategy logRedirectionStrategy) {
    auto session = std::static_pointer_cast<ffmpegkit::FFprobeSession>(std::make_shared<ffmpegkit::FFprobeSession::PublicFFprobeSession>(arguments, completeCallback, logCallback, logRedirectionStrategy));
    addSessionToSessionHistory(session);
    return session;
}

struct ffmpegkit::FFprobeSession::PublicFFprobeSession : public ffmpegkit::FFprobeSession {
    PublicFFprobeSession(const std::list<std::string>& arguments, const FFprobeSessionCompleteCallback completeCallback, const ffmpegkit::LogCallback logCallback, const LogRedirectionStrategy logRedirectionStrategy) :
      FFprobeSession(arguments, completeCallback, logCallback, logRedirectionStrategy) {
    }
};

ffmpegkit::FFprobeSession::FFprobeSession(const std::list<std::string>& arguments, const FFprobeSessionCompleteCallback completeCallback, const ffmpegkit::LogCallback logCallback, const LogRedirectionStrategy logRedirectionStrategy) :
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
