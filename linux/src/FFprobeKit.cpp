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

#include "fftools_ffmpeg.h"
#include "FFmpegKit.h"
#include "FFmpegKitConfig.h"
#include "FFprobeKit.h"

extern void* ffmpegKitInitialize();

static const void* _ffprobeKitInitializer = ffmpegKitInitialize();

static std::shared_ptr<std::list<std::string>> defaultGetMediaInformationCommandArguments(const std::string& path) {
    std::shared_ptr<std::list<std::string>> arguments = std::make_shared<std::list<std::string>>();
    arguments->push_back(std::string("-v"));
    arguments->push_back(std::string("error"));
    arguments->push_back(std::string("-hide_banner"));
    arguments->push_back(std::string("-print_format"));
    arguments->push_back(std::string("json"));
    arguments->push_back(std::string("-show_format"));
    arguments->push_back(std::string("-show_streams"));
    arguments->push_back(std::string("-show_chapters"));
    arguments->push_back(std::string("-i"));
    arguments->push_back(path);
    return arguments;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeWithArguments(const std::shared_ptr<std::list<std::string>> arguments) {
    auto session = std::make_shared<FFprobeSession>(arguments);
    ffmpegkit::FFmpegKitConfig::ffprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeWithArgumentsAsync(const std::shared_ptr<std::list<std::string>> arguments, FFprobeSessionCompleteCallback completeCallback) {
    auto session = std::make_shared<FFprobeSession>(arguments, completeCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeWithArgumentsAsync(const std::shared_ptr<std::list<std::string>> arguments, FFprobeSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback) {
    auto session = std::make_shared<FFprobeSession>(arguments, completeCallback, logCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::execute(const std::string command) {
    auto session = std::make_shared<FFprobeSession>(FFmpegKitConfig::parseArguments(command.c_str()));
    ffmpegkit::FFmpegKitConfig::ffprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeAsync(const std::string command, FFprobeSessionCompleteCallback completeCallback) {
    auto session = std::make_shared<FFprobeSession>(FFmpegKitConfig::parseArguments(command.c_str()), completeCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::FFprobeSession> ffmpegkit::FFprobeKit::executeAsync(const std::string command, FFprobeSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback){
    auto session = std::make_shared<FFprobeSession>(FFmpegKitConfig::parseArguments(command.c_str()), completeCallback, logCallback);
    ffmpegkit::FFmpegKitConfig::asyncFFprobeExecute(session);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformation(const std::string path) {
    auto arguments = defaultGetMediaInformationCommandArguments(path);
    auto session = std::make_shared<MediaInformationSession>(arguments);
    ffmpegkit::FFmpegKitConfig::getMediaInformationExecute(session, ffmpegkit::AbstractSession::DefaultTimeoutForAsynchronousMessagesInTransmit);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformation(const std::string path, const int waitTimeout) {
    auto arguments = defaultGetMediaInformationCommandArguments(path);
    auto session = std::make_shared<MediaInformationSession>(arguments);
    ffmpegkit::FFmpegKitConfig::getMediaInformationExecute(session, waitTimeout);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformationAsync(const std::string path, MediaInformationSessionCompleteCallback completeCallback) {
    auto arguments = defaultGetMediaInformationCommandArguments(path);
    auto session = std::make_shared<MediaInformationSession>(arguments, completeCallback);
    ffmpegkit::FFmpegKitConfig::asyncGetMediaInformationExecute(session, ffmpegkit::AbstractSession::DefaultTimeoutForAsynchronousMessagesInTransmit);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformationAsync(const std::string path, MediaInformationSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, const int waitTimeout) {
    auto arguments = defaultGetMediaInformationCommandArguments(path);
    auto session = std::make_shared<MediaInformationSession>(arguments, completeCallback, logCallback);
    ffmpegkit::FFmpegKitConfig::asyncGetMediaInformationExecute(session, waitTimeout);
    return session;
}

std::shared_ptr<ffmpegkit::MediaInformationSession> ffmpegkit::FFprobeKit::getMediaInformationFromCommand(const std::string command) {
    auto session = std::make_shared<MediaInformationSession>(FFmpegKitConfig::parseArguments(command.c_str()));
    ffmpegkit::FFmpegKitConfig::getMediaInformationExecute(session, ffmpegkit::AbstractSession::DefaultTimeoutForAsynchronousMessagesInTransmit);
    return session;
}

std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::FFprobeSession>>> ffmpegkit::FFprobeKit::listFFprobeSessions() {
    return ffmpegkit::FFmpegKitConfig::getFFprobeSessions();
}

std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::MediaInformationSession>>> ffmpegkit::FFprobeKit::listMediaInformationSessions() {
    return ffmpegkit::FFmpegKitConfig::getMediaInformationSessions();
}
