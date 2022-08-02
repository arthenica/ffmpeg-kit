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

#include "MediaInformation.h"

ffmpegkit::MediaInformation::MediaInformation(std::shared_ptr<rapidjson::Value> mediaInformationValue, std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> streams, std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> chapters) :
    _mediaInformationValue{mediaInformationValue}, _streams{streams}, _chapters{chapters} {
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getFilename() {
    return getStringProperty(KeyFilename);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getFormat() {
    return getStringProperty(KeyFormat);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getLongFormat() {
    return getStringProperty(KeyFormatLong);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getStartTime() {
    return getStringProperty(KeyStartTime);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getDuration() {
    return getStringProperty(KeyDuration);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getSize() {
    return getStringProperty(KeySize);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getBitrate() {
    return getStringProperty(KeyBitRate);
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getTags() {
    auto mediaProperties = getMediaProperties();
    if (mediaProperties->HasMember(KeyTags)) {
        auto tags = std::make_shared<rapidjson::Value>();
        *tags = (*mediaProperties)[KeyTags];
        return tags;
    } else {
        return nullptr;
    }
}

std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> ffmpegkit::MediaInformation::getStreams() {
    return _streams;
}

std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> ffmpegkit::MediaInformation::getChapters() {
    return _chapters;
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getStringProperty(const char* key) {
    auto mediaProperties = getMediaProperties();
    if (mediaProperties->HasMember(key)) {
        return std::make_shared<std::string>((*mediaProperties)[key].GetString());
    } else {
        return nullptr;
    }
}

std::shared_ptr<int64_t> ffmpegkit::MediaInformation::getNumberProperty(const char* key) {
    auto mediaProperties = getMediaProperties();
    if (mediaProperties->HasMember(key)) {
        return std::make_shared<int64_t>((*mediaProperties)[key].GetInt64());
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getProperties(const char* key) {
    if (_mediaInformationValue->HasMember(key)) {
        auto value = std::make_shared<rapidjson::Value>();
        *value = (*_mediaInformationValue)[key];
        return value;
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getMediaProperties() {
    if (_mediaInformationValue->HasMember(KeyMediaProperties)) {
        auto mediaProperties = std::make_shared<rapidjson::Value>();
        *mediaProperties = (*_mediaInformationValue)[KeyMediaProperties];
        return mediaProperties;
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getAllProperties() {
    if (_mediaInformationValue != nullptr) {
        auto all = std::make_shared<rapidjson::Value>();
        *all = (*_mediaInformationValue);
        return all;
    } else {
        return nullptr;
    }
}
