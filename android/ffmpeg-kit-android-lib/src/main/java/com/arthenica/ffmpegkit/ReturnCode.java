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

    public static int NOT_SET = -999;

    public static int SUCCESS = 0;

    public static int CANCEL = 255;

    public static boolean isSuccess(final int returnCode) {
        return (returnCode == SUCCESS);
    }

    public static boolean isFailure(final int returnCode) {
        return (returnCode != NOT_SET) && (returnCode != SUCCESS) && (returnCode != CANCEL);
    }

    public static boolean isCancel(final int returnCode) {
        return (returnCode == CANCEL);
    }

}
