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

#include "ReturnCode.h"

bool ffmpegkit::ReturnCode::isSuccess(const std::shared_ptr<ffmpegkit::ReturnCode> value) {
    return (value != nullptr) && (value->getValue() == Success);
}

bool ffmpegkit::ReturnCode::isCancel(const std::shared_ptr<ffmpegkit::ReturnCode> value) {
    return (value != nullptr) && (value->getValue() == Cancel);
}

ffmpegkit::ReturnCode::ReturnCode(const int value) : _value {value} {
}

int ffmpegkit::ReturnCode::getValue() const {
    return _value;
}

bool ffmpegkit::ReturnCode::isValueSuccess() const {
    return (_value == Success);
}

bool ffmpegkit::ReturnCode::isValueError() const {
    return ((_value != Success) && (_value != Cancel));
}

bool ffmpegkit::ReturnCode::isValueCancel() const {
    return (_value == Cancel);
}

namespace ffmpegkit {

    std::ostream& operator<<(std::ostream& out, const std::shared_ptr<ffmpegkit::ReturnCode>& o) {
        if (o == nullptr) {
            return out;
        } else {
            return out << o->_value;
        }
    }

}
