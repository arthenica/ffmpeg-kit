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
    return getStringFormatProperty(KeyFilename);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getFormat() {
    return getStringFormatProperty(KeyFormat);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getLongFormat() {
    return getStringFormatProperty(KeyFormatLong);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getStartTime() {
    return getStringFormatProperty(KeyStartTime);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getDuration() {
    return getStringFormatProperty(KeyDuration);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getSize() {
    return getStringFormatProperty(KeySize);
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getBitrate() {
    return getStringFormatProperty(KeyBitRate);
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getTags() {
    auto formatProperties = getFormatProperties();
    if (formatProperties->HasMember(KeyTags)) {
        auto tags = std::make_shared<rapidjson::Value>();
        *tags = (*formatProperties)[KeyTags];
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
    auto allProperties = getAllProperties();
    if (allProperties->HasMember(key)) {
        return std::make_shared<std::string>((*allProperties)[key].GetString());
    } else {
        return nullptr;
    }
}

std::shared_ptr<int64_t> ffmpegkit::MediaInformation::getNumberProperty(const char* key) {
    auto allProperties = getAllProperties();
    if (allProperties->HasMember(key)) {
        return std::make_shared<int64_t>((*allProperties)[key].GetInt64());
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getProperty(const char* key) {
    auto allProperties = getAllProperties();
    if (allProperties->HasMember(key)) {
        auto value = std::make_shared<rapidjson::Value>();
        *value = (*allProperties)[key];
        return value;
    } else {
        return nullptr;
    }
}

std::shared_ptr<std::string> ffmpegkit::MediaInformation::getStringFormatProperty(const char* key) {
    auto formatProperties = getFormatProperties();
    if (formatProperties->HasMember(key)) {
        return std::make_shared<std::string>((*formatProperties)[key].GetString());
    } else {
        return nullptr;
    }
}

std::shared_ptr<int64_t> ffmpegkit::MediaInformation::getNumberFormatProperty(const char* key) {
    auto formatProperties = getFormatProperties();
    if (formatProperties->HasMember(key)) {
        return std::make_shared<int64_t>((*formatProperties)[key].GetInt64());
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getFormatProperty(const char* key) {
    auto formatProperties = getFormatProperties();
    if (formatProperties->HasMember(key)) {
        auto value = std::make_shared<rapidjson::Value>();
        *value = (*formatProperties)[key];
        return value;
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getFormatProperties() {
    if (_mediaInformationValue->HasMember(KeyFormatProperties)) {
        auto mediaProperties = std::make_shared<rapidjson::Value>();
        *mediaProperties = (*_mediaInformationValue)[KeyFormatProperties];
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
