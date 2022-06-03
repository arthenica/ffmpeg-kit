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
            static constexpr const char* KeyMediaProperties = "format";
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
            std::string getFilename();

            /**
             * Returns format.
             *
             * @return media format
             */
            std::string getFormat();

            /**
             * Returns long format.
             *
             * @return media long format
             */
            std::string getLongFormat();

            /**
             * Returns duration.
             *
             * @return media duration in milliseconds
             */
            std::string getDuration();

            /**
             * Returns start time.
             *
             * @return media start time in milliseconds
             */
            std::string getStartTime();

            /**
             * Returns size.
             *
             * @return media size in bytes
             */
            std::string getSize();

            /**
             * Returns bitrate.
             *
             * @return media bitrate in kb/s
             */
            std::string getBitrate();

            /**
             * Returns all tags.
             *
             * @return tags dictionary
             */
            std::shared_ptr<rapidjson::Value> getTags();

            /**
             * Returns all streams.
             *
             * @return streams array
             */
            std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> getStreams();

            /**
             * Returns all chapters.
             *
             * @return chapters array
             */
            std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> getChapters();

            /**
             * Returns the media property associated with the key.
             *
             * @return media property as string or nil if the key is not found
             */
            std::string getStringProperty(const char* key);

            /**
             * Returns the media property associated with the key.
             *
             * @return media property as number or nil if the key is not found
             */
            int64_t getNumberProperty(const char* key);

            /**
             * Returns the media properties associated with the key.
             *
             * @return media properties in a dictionary or nil if the key is not found
            */
            std::shared_ptr<rapidjson::Value> getProperties(const char* key);

            /**
             * Returns all media properties.
             *
             * @return all media properties in a dictionary or nil if no media properties are defined
            */
            std::shared_ptr<rapidjson::Value> getMediaProperties();

            /**
             * Returns all properties defined.
             *
             * @return all properties in a dictionary or nil if no properties are defined
            */
            std::shared_ptr<rapidjson::Value> getAllProperties();

        private:
            std::shared_ptr<rapidjson::Value> _mediaInformationValue;
            std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> _streams;
            std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> _chapters;
    };

}

#endif // FFMPEG_KIT_MEDIA_INFORMATION_H
