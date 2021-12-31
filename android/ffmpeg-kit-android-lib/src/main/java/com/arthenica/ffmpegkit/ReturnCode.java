/*
 * Copyright (c) 2021 Taner Sener
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
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit;

public class ReturnCode {

    public static int SUCCESS = 0;

    public static int CANCEL = 255;

    private final int value;

    public ReturnCode(final int value) {
        this.value = value;
    }

    public static boolean isSuccess(final ReturnCode returnCode) {
        return (returnCode != null && returnCode.getValue() == SUCCESS);
    }

    public static boolean isCancel(final ReturnCode returnCode) {
        return (returnCode != null && returnCode.getValue() == CANCEL);
    }

    public int getValue() {
        return value;
    }

    public boolean isValueSuccess() {
        return (value == SUCCESS);
    }

    public boolean isValueError() {
        return ((value != SUCCESS) && (value != CANCEL));
    }

    public boolean isValueCancel() {
        return (value == CANCEL);
    }

    @Override
    public String toString() {
        return String.valueOf(value);
    }

}
