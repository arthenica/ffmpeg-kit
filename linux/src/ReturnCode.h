/*
 * Copyright (c) 2022 Taner Sener
 *
 * This file is part of FFmpegKit.
 *
 * FFmpegKit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FFmpegKit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General License for more details.
 *
 *  You should have received a copy of the GNU Lesser General License
 *  along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef FFMPEG_KIT_RETURN_CODE_H
#define FFMPEG_KIT_RETURN_CODE_H

#include <memory>
#include <iostream>

namespace ffmpegkit {

    class ReturnCode {
        public:
            static constexpr int Success = 0;
            static constexpr int Cancel = 255;

            static bool isSuccess(const std::shared_ptr<ffmpegkit::ReturnCode> value);
            static bool isCancel(const std::shared_ptr<ffmpegkit::ReturnCode> value);

            ReturnCode(const int value);
            int getValue() const;
            bool isValueSuccess() const;
            bool isValueError() const;
            bool isValueCancel() const;
            friend std::ostream& operator<<(std::ostream& out, const std::shared_ptr<ffmpegkit::ReturnCode>& o);
        
        private:
            int _value;
    };

}

#endif // FFMPEG_KIT_RETURN_CODE_H
