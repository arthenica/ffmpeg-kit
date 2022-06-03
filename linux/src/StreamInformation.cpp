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

#include "StreamInformation.h"

ffmpegkit::StreamInformation::StreamInformation(std::shared_ptr<rapidjson::Value> streamInformationValue) : _streamInformationValue{streamInformationValue} {
}

int64_t ffmpegkit::StreamInformation::getIndex() {
    return (*_streamInformationValue)[KeyIndex].GetInt64();
}

std::string ffmpegkit::StreamInformation::getType() {
    return (*_streamInformationValue)[KeyType].GetString();
}

std::string ffmpegkit::StreamInformation::getCodec() {
    return (*_streamInformationValue)[KeyCodec].GetString();
}

std::string ffmpegkit::StreamInformation::getCodecLong() {
    return (*_streamInformationValue)[KeyCodecLong].GetString();
}

std::string ffmpegkit::StreamInformation::getFormat() {
    return (*_streamInformationValue)[KeyFormat].GetString();
}

int64_t ffmpegkit::StreamInformation::getWidth() {
    return (*_streamInformationValue)[KeyWidth].GetInt64();
}

int64_t ffmpegkit::StreamInformation::getHeight() {
    return (*_streamInformationValue)[KeyHeight].GetInt64();
}

std::string ffmpegkit::StreamInformation::getBitrate() {
    return (*_streamInformationValue)[KeyBitRate].GetString();
}

std::string ffmpegkit::StreamInformation::getSampleRate() {
    return (*_streamInformationValue)[KeySampleRate].GetString();
}

std::string ffmpegkit::StreamInformation::getSampleFormat() {
    return (*_streamInformationValue)[KeySampleFormat].GetString();
}

std::string ffmpegkit::StreamInformation::getChannelLayout() {
    return (*_streamInformationValue)[KeyChannelLayout].GetString();
}

std::string ffmpegkit::StreamInformation::getSampleAspectRatio() {
    return (*_streamInformationValue)[KeySampleAspectRatio].GetString();
}

std::string ffmpegkit::StreamInformation::getDisplayAspectRatio() {
    return (*_streamInformationValue)[KeyDisplayAspectRatio].GetString();
}

std::string ffmpegkit::StreamInformation::getAverageFrameRate() {
    return (*_streamInformationValue)[KeyAverageFrameRate].GetString();
}

std::string ffmpegkit::StreamInformation::getRealFrameRate() {
    return (*_streamInformationValue)[KeyRealFrameRate].GetString();
}

std::string ffmpegkit::StreamInformation::getTimeBase() {
    return (*_streamInformationValue)[KeyTimeBase].GetString();
}

std::string ffmpegkit::StreamInformation::getCodecTimeBase() {
    return (*_streamInformationValue)[KeyCodecTimeBase].GetString();
}

std::shared_ptr<rapidjson::Value> ffmpegkit::StreamInformation::getTags() {
    auto tags = std::make_shared<rapidjson::Value>();
    *tags =  (*_streamInformationValue)[KeyTags];
    return tags;
}

std::string ffmpegkit::StreamInformation::getStringProperty(const char* key) {
    return (*_streamInformationValue)[key].GetString();
}

int64_t ffmpegkit::StreamInformation::getNumberProperty(const char* key) {
    return (*_streamInformationValue)[key].GetInt64();
}

std::shared_ptr<rapidjson::Value> ffmpegkit::StreamInformation::getProperties(const char* key) {
    auto value = std::make_shared<rapidjson::Value>();
    *value =  (*_streamInformationValue)[key];
    return value;
}

std::shared_ptr<rapidjson::Value> ffmpegkit::StreamInformation::getAllProperties() {
    auto all = std::make_shared<rapidjson::Value>();
    *all =  (*_streamInformationValue);
    return all;
}
