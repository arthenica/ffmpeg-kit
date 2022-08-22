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

std::shared_ptr<int64_t> ffmpegkit::StreamInformation::getIndex() {
    return getNumberProperty(KeyIndex);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getType() {
    return getStringProperty(KeyType);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getCodec() {
    return getStringProperty(KeyCodec);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getCodecLong() {
    return getStringProperty(KeyCodecLong);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getFormat() {
    return getStringProperty(KeyFormat);
}

std::shared_ptr<int64_t> ffmpegkit::StreamInformation::getWidth() {
    return getNumberProperty(KeyWidth);
}

std::shared_ptr<int64_t> ffmpegkit::StreamInformation::getHeight() {
    return getNumberProperty(KeyHeight);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getBitrate() {
    return getStringProperty(KeyBitRate);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getSampleRate() {
    return getStringProperty(KeySampleRate);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getSampleFormat() {
    return getStringProperty(KeySampleFormat);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getChannelLayout() {
    return getStringProperty(KeyChannelLayout);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getSampleAspectRatio() {
    return getStringProperty(KeySampleAspectRatio);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getDisplayAspectRatio() {
    return getStringProperty(KeyDisplayAspectRatio);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getAverageFrameRate() {
    return getStringProperty(KeyAverageFrameRate);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getRealFrameRate() {
    return getStringProperty(KeyRealFrameRate);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getTimeBase() {
    return getStringProperty(KeyTimeBase);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getCodecTimeBase() {
    return getStringProperty(KeyCodecTimeBase);
}

std::shared_ptr<rapidjson::Value> ffmpegkit::StreamInformation::getTags() {
    return getProperty(KeyTags);
}

std::shared_ptr<std::string> ffmpegkit::StreamInformation::getStringProperty(const char* key) {
    if (_streamInformationValue->HasMember(key)) {
        return std::make_shared<std::string>((*_streamInformationValue)[key].GetString());
    } else {
        return nullptr;
    }
}

std::shared_ptr<int64_t> ffmpegkit::StreamInformation::getNumberProperty(const char* key) {
    if (_streamInformationValue->HasMember(key)) {
        return std::make_shared<int64_t>((*_streamInformationValue)[key].GetInt64());
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::StreamInformation::getProperty(const char* key) {
    if (_streamInformationValue->HasMember(key)) {
        auto value = std::make_shared<rapidjson::Value>();
        *value = (*_streamInformationValue)[key];
        return value;
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::StreamInformation::getAllProperties() {
    if (_streamInformationValue != nullptr) {
        auto all = std::make_shared<rapidjson::Value>();
        *all =  (*_streamInformationValue);
        return all;
    } else {
        return nullptr;
    }
}
