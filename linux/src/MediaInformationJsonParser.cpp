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

#include "MediaInformationJsonParser.h"
// OVERRIDING THE MACRO TO PREVENT APPLICATION TERMINATION
#define RAPIDJSON_ASSERT(x)
#include "rapidjson/reader.h"
#include "rapidjson/document.h"
#include "rapidjson/error/en.h"
#include <memory>

static const char* MediaInformationJsonParserKeyStreams =  "streams";
static const char* MediaInformationJsonParserKeyChapters = "chapters";

std::shared_ptr<ffmpegkit::MediaInformation> ffmpegkit::MediaInformationJsonParser::from(const std::string& ffprobeJsonOutput) {
    try {
        return fromWithError(ffprobeJsonOutput);
    } catch(const std::exception& exception) {
        std::cout << "MediaInformation parsing failed: " << exception.what() << std::endl;
        return nullptr;
    }
}

std::shared_ptr<ffmpegkit::MediaInformation> ffmpegkit::MediaInformationJsonParser::fromWithError(const std::string& ffprobeJsonOutput) {
    std::shared_ptr<rapidjson::Document> document = std::make_shared<rapidjson::Document>();

    document->Parse(ffprobeJsonOutput.c_str());

    if (document->HasParseError()) {
        throw std::runtime_error(GetParseError_En(document->GetParseError()));
    } else {
        std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> streams = std::make_shared<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>>();
        std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> chapters = std::make_shared<std::vector<std::shared_ptr<ffmpegkit::Chapter>>>();

        if (document->HasMember(MediaInformationJsonParserKeyStreams)) {
            rapidjson::Value& streamArray = (*document.get())[MediaInformationJsonParserKeyStreams];
            if (streamArray.IsArray()) {
                for (rapidjson::SizeType i = 0; i < streamArray.Size(); i++) {
                    auto stream = std::make_shared<rapidjson::Value>();
                    *stream = streamArray[i];
                    streams->push_back(std::make_shared<ffmpegkit::StreamInformation>(stream));
                }
            }
        }

        if (document->HasMember(MediaInformationJsonParserKeyChapters)) {
            rapidjson::Value& chapterArray = (*document.get())[MediaInformationJsonParserKeyChapters];
            if (chapterArray.IsArray()) {
                for (rapidjson::SizeType i = 0; i < chapterArray.Size(); i++) {
                    auto chapter = std::make_shared<rapidjson::Value>();
                    *chapter = chapterArray[i];
                    chapters->push_back(std::make_shared<ffmpegkit::Chapter>(chapter));
                }
            }
        }

        return std::make_shared<ffmpegkit::MediaInformation>(std::static_pointer_cast<rapidjson::Value>(document), streams, chapters);
    }
}
