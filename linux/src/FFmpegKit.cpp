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

#include "ArchDetect.h"
#include "FFmpegKit.h"
#include "FFmpegKitConfig.h"
#include "Packages.h"

extern "C" {
    void cancel_operation(long id);
}

extern void* ffmpegKitInitialize();

const void* _ffmpegKitInitializeri{ffmpegKitInitialize()};

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegKit::executeWithArguments(const std::list<std::string>& arguments) {
    auto session = ffmpegkit::FFmpegSession::create(arguments);
    ffmpegkit::FFmpegKitConfig::ffmpegExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegKit::executeWithArgumentsAsync(const std::list<std::string>& arguments, FFmpegSessionCompleteCallback completeCallback) {
    auto session = ffmpegkit::FFmpegSession::create(arguments, completeCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFmpegExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegKit::executeWithArgumentsAsync(const std::list<std::string>& arguments, FFmpegSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, ffmpegkit::StatisticsCallback statisticsCallback) {
    auto session = ffmpegkit::FFmpegSession::create(arguments, completeCallback, logCallback, statisticsCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFmpegExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegKit::execute(const std::string command) {
    auto session = ffmpegkit::FFmpegSession::create(FFmpegKitConfig::parseArguments(command.c_str()));
    ffmpegkit::FFmpegKitConfig::ffmpegExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegKit::executeAsync(const std::string command, FFmpegSessionCompleteCallback completeCallback) {
    auto session = ffmpegkit::FFmpegSession::create(FFmpegKitConfig::parseArguments(command.c_str()), completeCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFmpegExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegkit::FFmpegKit::executeAsync(const std::string command, FFmpegSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, ffmpegkit::StatisticsCallback statisticsCallback) {
    auto session = ffmpegkit::FFmpegSession::create(FFmpegKitConfig::parseArguments(command.c_str()), completeCallback, logCallback, statisticsCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFmpegExecute(session);
    return session;
}

void ffmpegkit::FFmpegKit::cancel() {

    /*
     * ZERO (0) IS A SPECIAL SESSION ID
     * WHEN IT IS PASSED TO THIS METHOD, A SIGINT IS GENERATED WHICH CANCELS ALL ONGOING SESSIONS
     */
    cancel_operation(0);
}

void ffmpegkit::FFmpegKit::cancel(const long sessionId) {
    cancel_operation(sessionId);
}

std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::FFmpegSession>>> ffmpegkit::FFmpegKit::listSessions() {
    return ffmpegkit::FFmpegKitConfig::getFFmpegSessions();
}
