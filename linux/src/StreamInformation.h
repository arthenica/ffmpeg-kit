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

#ifndef FFMPEG_KIT_STREAM_INFORMATION_H
#define FFMPEG_KIT_STREAM_INFORMATION_H

// OVERRIDING THE MACRO TO PREVENT APPLICATION TERMINATION
#define RAPIDJSON_ASSERT(x)
#include "rapidjson/document.h"
#include <string>
#include <memory>

namespace ffmpegkit {

    /**
     * Stream information class.
     */
    class StreamInformation {
        public:
            static constexpr const char* KeyIndex = "index";
            static constexpr const char* KeyType = "codec_type";
            static constexpr const char* KeyCodec = "codec_name";
            static constexpr const char* KeyCodecLong = "codec_long_name";
            static constexpr const char* KeyFormat = "pix_fmt";
            static constexpr const char* KeyWidth = "width";
            static constexpr const char* KeyHeight = "height";
            static constexpr const char* KeyBitRate = "bit_rate";
            static constexpr const char* KeySampleRate = "sample_rate";
            static constexpr const char* KeySampleFormat = "sample_fmt";
            static constexpr const char* KeyChannelLayout = "channel_layout";
            static constexpr const char* KeySampleAspectRatio = "sample_aspect_ratio";
            static constexpr const char* KeyDisplayAspectRatio = "display_aspect_ratio";
            static constexpr const char* KeyAverageFrameRate = "avg_frame_rate";
            static constexpr const char* KeyRealFrameRate = "r_frame_rate";
            static constexpr const char* KeyTimeBase = "time_base";
            static constexpr const char* KeyCodecTimeBase = "codec_time_base";
            static constexpr const char* KeyTags = "tags";

            StreamInformation(std::shared_ptr<rapidjson::Value> streamInformationValue);

            /**
             * Returns stream index.
             *
             * @return stream index, starting from zero
             */
            std::shared_ptr<int64_t> getIndex();

            /**
             * Returns stream type.
             *
             * @return stream type; audio or video
             */
            std::shared_ptr<std::string> getType();

            /**
             * Returns stream codec.
             *
             * @return stream codec
             */
            std::shared_ptr<std::string> getCodec();

            /**
             * Returns stream codec in long format.
             *
             * @return stream codec with additional profile and mode information
             */
            std::shared_ptr<std::string> getCodecLong();

            /**
             * Returns stream format.
             *
             * @return stream format
             */
            std::shared_ptr<std::string> getFormat();

            /**
             * Returns width.
             *
             * @return width in pixels
             */
            std::shared_ptr<int64_t> getWidth();

            /**
             * Returns height.
             *
             * @return height in pixels
             */
            std::shared_ptr<int64_t> getHeight();

            /**
             * Returns bitrate.
             *
             * @return bitrate in kb/s
             */
            std::shared_ptr<std::string> getBitrate();

            /**
             * Returns sample rate.
             *
             * @return sample rate in hz
             */
            std::shared_ptr<std::string> getSampleRate();

            /**
             * Returns sample format.
             *
             * @return sample format
             */
            std::shared_ptr<std::string> getSampleFormat();

            /**
             * Returns channel layout.
             *
             * @return channel layout
             */
            std::shared_ptr<std::string> getChannelLayout();

            /**
             * Returns sample aspect ratio.
             *
             * @return sample aspect ratio
             */
            std::shared_ptr<std::string> getSampleAspectRatio();

            /**
             * Returns display aspect ratio.
             *
             * @return display aspect ratio
             */
            std::shared_ptr<std::string> getDisplayAspectRatio();

            /**
             * Returns average frame rate.
             *
             * @return average frame rate in fps
             */
            std::shared_ptr<std::string> getAverageFrameRate();

            /**
             * Returns real frame rate.
             *
             * @return real frame rate in tbr
             */
            std::shared_ptr<std::string> getRealFrameRate();

            /**
             * Returns time base.
             *
             * @return time base in tbn
             */
            std::shared_ptr<std::string> getTimeBase();

            /**
             * Returns codec time base.
             *
             * @return codec time base in tbc
             */
            std::shared_ptr<std::string> getCodecTimeBase();

            /**
             * Returns all tags.
             *
             * @return tags Value
             */
            std::shared_ptr<rapidjson::Value> getTags();

            /**
             * Returns the stream property associated with the key.
             *
             * @return stream property as string or nullptr if the key is not found
             */
            std::shared_ptr<std::string> getStringProperty(const char* key);

            /**
             * Returns the stream property associated with the key.
             *
             * @return stream property as number or nullptr if the key is not found
             */
            std::shared_ptr<int64_t> getNumberProperty(const char* key);

            /**
             * Returns the stream property associated with the key.
             *
             * @return stream property in a Value or nullptr if the key is not found
            */
            std::shared_ptr<rapidjson::Value> getProperty(const char* key);

            /**
             * Returns all stream properties defined.
             *
             * @return all stream properties in a Value or nullptr if no properties are defined
            */
            std::shared_ptr<rapidjson::Value> getAllProperties();

        private:
            std::shared_ptr<rapidjson::Value> _streamInformationValue;
    };

}

#endif // FFMPEG_KIT_STREAM_INFORMATION_H
