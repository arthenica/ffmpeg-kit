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

std::shared_ptr<int64_t> ffmpegkit::Chapter::getId() {
    return getNumberProperty(KeyId);
}

std::shared_ptr<std::string> ffmpegkit::Chapter::getTimeBase() {
    return getStringProperty(KeyTimeBase);
}

std::shared_ptr<int64_t> ffmpegkit::Chapter::getStart() {
    return getNumberProperty(KeyStart);
}

std::shared_ptr<std::string> ffmpegkit::Chapter::getStartTime() {
    return getStringProperty(KeyStartTime);
}

std::shared_ptr<int64_t> ffmpegkit::Chapter::getEnd() {
    return getNumberProperty(KeyEnd);
}

std::shared_ptr<std::string> ffmpegkit::Chapter::getEndTime() {
    return getStringProperty(KeyEndTime);
}

std::shared_ptr<rapidjson::Value> ffmpegkit::Chapter::getTags() {
    return getProperty(KeyTags);
}

std::shared_ptr<std::string> ffmpegkit::Chapter::getStringProperty(const char* key) {
    if (_chapterValue->HasMember(key)) {
        return std::make_shared<std::string>((*_chapterValue)[key].GetString());
    } else {
        return nullptr;
    }
}

std::shared_ptr<int64_t> ffmpegkit::Chapter::getNumberProperty(const char* key) {
    if (_chapterValue->HasMember(key)) {
        return std::make_shared<int64_t>((*_chapterValue)[key].GetInt64());
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::Chapter::getProperty(const char* key) {
    if (_chapterValue->HasMember(key)) {
        auto value = std::make_shared<rapidjson::Value>();
        *value = (*_chapterValue)[key];
        return value;
    } else {
        return nullptr;
    }
}

std::shared_ptr<rapidjson::Value> ffmpegkit::Chapter::getAllProperties() {
    if (_chapterValue != nullptr) {
        auto all = std::make_shared<rapidjson::Value>();
        *all =  (*_chapterValue);
        return all;
    } else {
        return nullptr;
    }
}
