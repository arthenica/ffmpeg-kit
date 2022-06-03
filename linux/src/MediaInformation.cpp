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

std::string ffmpegkit::MediaInformation::getFilename() {
    return (*_mediaInformationValue)[KeyFilename].GetString();
}

std::string ffmpegkit::MediaInformation::getFormat() {
    return (*_mediaInformationValue)[KeyFormat].GetString();
}

std::string ffmpegkit::MediaInformation::getLongFormat() {
    return (*_mediaInformationValue)[KeyFormatLong].GetString();
}

std::string ffmpegkit::MediaInformation::getStartTime() {
    return (*_mediaInformationValue)[KeyStartTime].GetString();
}

std::string ffmpegkit::MediaInformation::getDuration() {
    return (*_mediaInformationValue)[KeyDuration].GetString();
}

std::string ffmpegkit::MediaInformation::getSize() {
    return (*_mediaInformationValue)[KeySize].GetString();
}

std::string ffmpegkit::MediaInformation::getBitrate() {
    return (*_mediaInformationValue)[KeyBitRate].GetString();
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getTags() {
    auto tags = std::make_shared<rapidjson::Value>();
    *tags =  (*_mediaInformationValue)[KeyTags];
    return tags;
}

std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> ffmpegkit::MediaInformation::getStreams() {
    return _streams;
}

std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> ffmpegkit::MediaInformation::getChapters() {
    return _chapters;
}

std::string ffmpegkit::MediaInformation::getStringProperty(const char* key) {
    return (*_mediaInformationValue)[key].GetString();
}

int64_t ffmpegkit::MediaInformation::getNumberProperty(const char* key) {
    return (*_mediaInformationValue)[key].GetInt64();
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getProperties(const char* key) {
    auto value = std::make_shared<rapidjson::Value>();
    *value =  (*_mediaInformationValue)[key];
    return value;
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getMediaProperties() {
    auto mediaProperties = std::make_shared<rapidjson::Value>();
    *mediaProperties =  (*_mediaInformationValue)[KeyMediaProperties];
    return mediaProperties;
}

std::shared_ptr<rapidjson::Value> ffmpegkit::MediaInformation::getAllProperties() {
    auto all = std::make_shared<rapidjson::Value>();
    *all =  (*_mediaInformationValue);
    return all;
}
