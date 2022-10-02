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

#include "FFmpegSession.h"
#include "FFmpegKitConfig.h"
#include "LogCallback.h"
#include "StatisticsCallback.h"

extern void addSessionToSessionHistory(const std::shared_ptr<ffmpegkit::Session> session);

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegSession::create(const std::list<std::string>& arguments) {
    std::shared_ptr<ffmpegkit::FFmpegSession> session = std::static_pointer_cast<ffmpegkit::FFmpegSession>(std::make_shared<ffmpegkit::FFmpegSession::PublicFFmpegSession>(arguments, nullptr, nullptr, nullptr, ffmpegkit::FFmpegKitConfig::getLogRedirectionStrategy()));
    addSessionToSessionHistory(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegSession::create(const std::list<std::string>& arguments, FFmpegSessionCompleteCallback completeCallback) {
    std::shared_ptr<ffmpegkit::FFmpegSession> session = std::static_pointer_cast<ffmpegkit::FFmpegSession>(std::make_shared<ffmpegkit::FFmpegSession::PublicFFmpegSession>(arguments, completeCallback, nullptr, nullptr, ffmpegkit::FFmpegKitConfig::getLogRedirectionStrategy()));
    addSessionToSessionHistory(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegSession::create(const std::list<std::string>& arguments, FFmpegSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, ffmpegkit::StatisticsCallback statisticsCallback) {
    std::shared_ptr<ffmpegkit::FFmpegSession> session = std::static_pointer_cast<ffmpegkit::FFmpegSession>(std::make_shared<ffmpegkit::FFmpegSession::PublicFFmpegSession>(arguments, completeCallback, logCallback, statisticsCallback, ffmpegkit::FFmpegKitConfig::getLogRedirectionStrategy()));
    addSessionToSessionHistory(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegSession::create(const std::list<std::string>& arguments, FFmpegSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, ffmpegkit::StatisticsCallback statisticsCallback, LogRedirectionStrategy logRedirectionStrategy) {
    std::shared_ptr<ffmpegkit::FFmpegSession> session = std::static_pointer_cast<ffmpegkit::FFmpegSession>(std::make_shared<ffmpegkit::FFmpegSession::PublicFFmpegSession>(arguments, completeCallback, logCallback, statisticsCallback, logRedirectionStrategy));
    addSessionToSessionHistory(session);
    return session;
}

struct ffmpegkit::FFmpegSession::PublicFFmpegSession : public ffmpegkit::FFmpegSession {
    PublicFFmpegSession(const std::list<std::string>& arguments, FFmpegSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, ffmpegkit::StatisticsCallback statisticsCallback, LogRedirectionStrategy logRedirectionStrategy) :
      FFmpegSession(arguments, completeCallback, logCallback, statisticsCallback, logRedirectionStrategy) {
    }
};

ffmpegkit::FFmpegSession::FFmpegSession(const std::list<std::string>& arguments, FFmpegSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, ffmpegkit::StatisticsCallback statisticsCallback, LogRedirectionStrategy logRedirectionStrategy) :
    ffmpegkit::AbstractSession(arguments, logCallback, logRedirectionStrategy), _completeCallback{completeCallback}, _statisticsCallback{statisticsCallback}, _statistics{std::make_shared<std::list<std::shared_ptr<ffmpegkit::Statistics>>>()} {
}

ffmpegkit::StatisticsCallback ffmpegkit::FFmpegSession::getStatisticsCallback() {
    return _statisticsCallback;
}

ffmpegkit::FFmpegSessionCompleteCallback ffmpegkit::FFmpegSession::getCompleteCallback() {
    return _completeCallback;
}

std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::Statistics>>> ffmpegkit::FFmpegSession::getAllStatisticsWithTimeout(const int waitTimeout) {
    this->waitForAsynchronousMessagesInTransmit(waitTimeout);

    if (this->thereAreAsynchronousMessagesInTransmit()) {
        std::cout << "getAllStatisticsWithTimeout was called to return all statistics but there are still statistics being transmitted for session id " << this->getSessionId() << "." << std::endl;
    }

    return this->getStatistics();
}

std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::Statistics>>> ffmpegkit::FFmpegSession::getAllStatistics() {
    return this->getAllStatisticsWithTimeout(ffmpegkit::AbstractSession::DefaultTimeoutForAsynchronousMessagesInTransmit);
}

std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::Statistics>>> ffmpegkit::FFmpegSession::getStatistics() {
    return _statistics;
}

std::shared_ptr<ffmpegkit::Statistics> ffmpegkit::FFmpegSession::getLastReceivedStatistics() {
    if (_statistics->size() > 0) {
        return _statistics->back();
    } else {
        return nullptr;
    }
}

void ffmpegkit::FFmpegSession::addStatistics(const std::shared_ptr<ffmpegkit::Statistics> statistics) {
    _statistics->push_back(statistics);
}

bool ffmpegkit::FFmpegSession::isFFmpeg() const {
    return true;
}

bool ffmpegkit::FFmpegSession::isFFprobe() const {
    return false;
}

bool ffmpegkit::FFmpegSession::isMediaInformation() const {
    return false;
}
