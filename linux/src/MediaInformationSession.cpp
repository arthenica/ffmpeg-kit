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

#include "MediaInformationSession.h"
#include "LogCallback.h"
#include "MediaInformation.h"

extern void addSessionToSessionHistory(const std::shared_ptr<ffmpegkit::Session> session);

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::MediaInformationSession::create(const std::list<std::string>& arguments) {
    auto session = std::static_pointer_cast<ffmpegkit::MediaInformationSession>(std::make_shared<ffmpegkit::MediaInformationSession::PublicMediaInformationSession>(arguments, nullptr, nullptr));
    addSessionToSessionHistory(session);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::MediaInformationSession::create(const std::list<std::string>& arguments, ffmpegkit::MediaInformationSessionCompleteCallback completeCallback) {
    auto session = std::static_pointer_cast<ffmpegkit::MediaInformationSession>(std::make_shared<ffmpegkit::MediaInformationSession::PublicMediaInformationSession>(arguments, completeCallback, nullptr));
    addSessionToSessionHistory(session);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::MediaInformationSession::create(const std::list<std::string>& arguments, ffmpegkit::MediaInformationSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback) {
    auto session = std::static_pointer_cast<ffmpegkit::MediaInformationSession>(std::make_shared<ffmpegkit::MediaInformationSession::PublicMediaInformationSession>(arguments, completeCallback, logCallback));
    addSessionToSessionHistory(session);
    return session;
}

struct ffmpegkit::MediaInformationSession::PublicMediaInformationSession : public ffmpegkit::MediaInformationSession {
    PublicMediaInformationSession(const std::list<std::string>& arguments, ffmpegkit::MediaInformationSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback) :
      MediaInformationSession(arguments, completeCallback, logCallback) {
    }
};

ffmpegkit::MediaInformationSession::MediaInformationSession(const std::list<std::string>& arguments, ffmpegkit::MediaInformationSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback) :
    ffmpegkit::AbstractSession(arguments, logCallback, ffmpegkit::LogRedirectionStrategyNeverPrintLogs), _completeCallback{completeCallback}, _mediaInformation{nullptr} {
}

std::shared_ptr<ffmpegkit::MediaInformation> ffmpegkit::MediaInformationSession::getMediaInformation() {
    return _mediaInformation;
}

void ffmpegkit::MediaInformationSession::setMediaInformation(const std::shared_ptr<ffmpegkit::MediaInformation> mediaInformation) {
    _mediaInformation = mediaInformation;
}

ffmpegkit::MediaInformationSessionCompleteCallback ffmpegkit::MediaInformationSession::getCompleteCallback() {
    return _completeCallback;
}

bool ffmpegkit::MediaInformationSession::isFFmpeg() const {
    return false;
}

bool ffmpegkit::MediaInformationSession::isFFprobe() const {
    return false;
}

bool ffmpegkit::MediaInformationSession::isMediaInformation() const {
    return true;
}
