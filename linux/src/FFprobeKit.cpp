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

#include "FFmpegKit.h"
#include "FFmpegKitConfig.h"
#include "FFprobeKit.h"

extern void* ffmpegKitInitialize();

const void* _ffprobeKitInitializer{ffmpegKitInitialize()};

static std::list<std::string> defaultGetMediaInformationCommandArguments(const std::string& path) {
    return std::list<std::string>{"-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-show_chapters", "-i", path};
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeWithArguments(const std::list<std::string>& arguments) {
    auto session = ffmpegkit::FFprobeSession::create(arguments);
    ffmpegkit::FFmpegKitConfig::ffprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeWithArgumentsAsync(const std::list<std::string>& arguments, FFprobeSessionCompleteCallback completeCallback) {
    auto session = ffmpegkit::FFprobeSession::create(arguments, completeCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeWithArgumentsAsync(const std::list<std::string>& arguments, FFprobeSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback) {
    auto session = ffmpegkit::FFprobeSession::create(arguments, completeCallback, logCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::execute(const std::string command) {
    auto session = ffmpegkit::FFprobeSession::create(FFmpegKitConfig::parseArguments(command.c_str()));
    ffmpegkit::FFmpegKitConfig::ffprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeAsync(const std::string command, FFprobeSessionCompleteCallback completeCallback) {
    auto session = ffmpegkit::FFprobeSession::create(FFmpegKitConfig::parseArguments(command.c_str()), completeCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeAsync(const std::string command, FFprobeSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback){
    auto session = ffmpegkit::FFprobeSession::create(FFmpegKitConfig::parseArguments(command.c_str()), completeCallback, logCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformation(const std::string path) {
    auto arguments = defaultGetMediaInformationCommandArguments(path);
    auto session = ffmpegkit::MediaInformationSession::create(arguments);
    ffmpegkit::FFmpegKitConfig::getMediaInformationExecute(session, ffmpegkit::AbstractSession::DefaultTimeoutForAsynchronousMessagesInTransmit);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformation(const std::string path, const int waitTimeout) {
    auto arguments = defaultGetMediaInformationCommandArguments(path);
    auto session = ffmpegkit::MediaInformationSession::create(arguments);
    ffmpegkit::FFmpegKitConfig::getMediaInformationExecute(session, waitTimeout);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformationAsync(const std::string path, MediaInformationSessionCompleteCallback completeCallback) {
    auto arguments = defaultGetMediaInformationCommandArguments(path);
    auto session = ffmpegkit::MediaInformationSession::create(arguments, completeCallback);
    ffmpegkit::FFmpegKitConfig::asyncGetMediaInformationExecute(session, ffmpegkit::AbstractSession::DefaultTimeoutForAsynchronousMessagesInTransmit);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformationAsync(const std::string path, MediaInformationSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, const int waitTimeout) {
    auto arguments = defaultGetMediaInformationCommandArguments(path);
    auto session = ffmpegkit::MediaInformationSession::create(arguments, completeCallback, logCallback);
    ffmpegkit::FFmpegKitConfig::asyncGetMediaInformationExecute(session, waitTimeout);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformationFromCommand(const std::string command) {
    auto session = ffmpegkit::MediaInformationSession::create(FFmpegKitConfig::parseArguments(command.c_str()));
    ffmpegkit::FFmpegKitConfig::getMediaInformationExecute(session, ffmpegkit::AbstractSession::DefaultTimeoutForAsynchronousMessagesInTransmit);
    return session;
}

std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::FFprobeSession>>> ffmpegkit::FFprobeKit::listFFprobeSessions() {
    return ffmpegkit::FFmpegKitConfig::getFFprobeSessions();
}

std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::MediaInformationSession>>> ffmpegkit::FFprobeKit::listMediaInformationSessions() {
    return ffmpegkit::FFmpegKitConfig::getMediaInformationSessions();
}
