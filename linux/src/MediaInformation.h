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

#ifndef FFMPEG_KIT_MEDIA_INFORMATION_H
#define FFMPEG_KIT_MEDIA_INFORMATION_H

#include "Chapter.h"
#include "StreamInformation.h"
#include <memory>
#include <vector>

namespace ffmpegkit {

    /**
     * Media information class.
     */
    class MediaInformation {
        public:
            static constexpr const char* KeyFormatProperties = "format";
            static constexpr const char* KeyFilename = "filename";
            static constexpr const char* KeyFormat = "format_name";
            static constexpr const char* KeyFormatLong = "format_long_name";
            static constexpr const char* KeyStartTime = "start_time";
            static constexpr const char* KeyDuration = "duration";
            static constexpr const char* KeySize = "size";
            static constexpr const char* KeyBitRate = "bit_rate";
            static constexpr const char* KeyTags = "tags";

            MediaInformation(std::shared_ptr<rapidjson::Value> mediaInformationValue, std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> streams, std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> chapters);

            /**
             * Returns file name.
             *
             * @return media file name
             */
            std::shared_ptr<std::string> getFilename();

            /**
             * Returns format.
             *
             * @return media format
             */
            std::shared_ptr<std::string> getFormat();

            /**
             * Returns long format.
             *
             * @return media long format
             */
            std::shared_ptr<std::string> getLongFormat();

            /**
             * Returns duration.
             *
             * @return media duration in milliseconds
             */
            std::shared_ptr<std::string> getDuration();

            /**
             * Returns start time.
             *
             * @return media start time in milliseconds
             */
            std::shared_ptr<std::string> getStartTime();

            /**
             * Returns size.
             *
             * @return media size in bytes
             */
            std::shared_ptr<std::string> getSize();

            /**
             * Returns bitrate.
             *
             * @return media bitrate in kb/s
             */
            std::shared_ptr<std::string> getBitrate();

            /**
             * Returns all tags.
             *
             * @return tags Value
             */
            std::shared_ptr<rapidjson::Value> getTags();

            /**
             * Returns all streams.
             *
             * @return streams vector
             */
            std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> getStreams();

            /**
             * Returns all chapters.
             *
             * @return chapters vector
             */
            std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> getChapters();

            /**
             * Returns the property associated with the key.
             *
             * @return property as string or nullptr if the key is not found
             */
            std::shared_ptr<std::string> getStringProperty(const char* key);

            /**
             * Returns the property associated with the key.
             *
             * @return property as number or nullptr if the key is not found
             */
            std::shared_ptr<int64_t> getNumberProperty(const char* key);

            /**
             * Returns the property associated with the key.
             *
             * @return property in a Value or nullptr if the key is not found
            */
            std::shared_ptr<rapidjson::Value> getProperty(const char* key);

            /**
             * Returns the format property associated with the key.
             *
             * @return format property as string or nullptr if the key is not found
             */
            std::shared_ptr<std::string> getStringFormatProperty(const char* key);

            /**
             * Returns the format property associated with the key.
             *
             * @return format property as number or nullptr if the key is not found
             */
            std::shared_ptr<int64_t> getNumberFormatProperty(const char* key);

            /**
             * Returns the format property associated with the key.
             *
             * @return format property in a Value or nullptr if the key is not found
            */
            std::shared_ptr<rapidjson::Value> getFormatProperty(const char* key);

            /**
             * Returns all format properties defined.
             *
             * @return all format properties in a Value or nullptr if no format properties are defined
            */
            std::shared_ptr<rapidjson::Value> getFormatProperties();

            /**
             * Returns all properties defined.
             *
             * @return all properties in a Value or nullptr if no properties are defined
            */
            std::shared_ptr<rapidjson::Value> getAllProperties();

        private:
            std::shared_ptr<rapidjson::Value> _mediaInformationValue;
            std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> _streams;
            std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> _chapters;
    };

}

#endif // FFMPEG_KIT_MEDIA_INFORMATION_H
