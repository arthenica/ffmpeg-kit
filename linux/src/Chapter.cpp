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

#include "Chapter.h"

ffmpegkit::Chapter::Chapter(std::shared_ptr<rapidjson::Value> chapterValue) : _chapterValue{chapterValue} {
}

int64_t ffmpegkit::Chapter::getId() {
    return (*_chapterValue)[KeyId].GetInt64();
}

std::string ffmpegkit::Chapter::getTimeBase() {
    return  (*_chapterValue)[KeyTimeBase].GetString();
}

int64_t ffmpegkit::Chapter::getStart() {
    return  (*_chapterValue)[KeyStart].GetInt64();
}

std::string ffmpegkit::Chapter::getStartTime() {
    return  (*_chapterValue)[KeyStartTime].GetString();
}

int64_t ffmpegkit::Chapter::getEnd() {
    return  (*_chapterValue)[KeyEnd].GetInt64();
}

std::string ffmpegkit::Chapter::getEndTime() {
    return  (*_chapterValue)[KeyEndTime].GetString();
}

std::shared_ptr<rapidjson::Value> ffmpegkit::Chapter::getTags() {
    auto tags = std::make_shared<rapidjson::Value>();
    *tags =  (*_chapterValue)[KeyTags];
    return tags;
}

std::string ffmpegkit::Chapter::getStringProperty(const char* key) {
    return  (*_chapterValue)[key].GetString();
}

int64_t ffmpegkit::Chapter::getNumberProperty(const char* key) {
    return  (*_chapterValue)[key].GetInt64();
}

std::shared_ptr<rapidjson::Value> ffmpegkit::Chapter::getProperties(const char* key) {
    auto value = std::make_shared<rapidjson::Value>();
    *value =  (*_chapterValue)[key];
    return value;
}

std::shared_ptr<rapidjson::Value> ffmpegkit::Chapter::getAllProperties() {
    auto all = std::make_shared<rapidjson::Value>();
    *all =  (*_chapterValue);
    return all;
}
