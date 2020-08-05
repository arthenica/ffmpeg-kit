/*
 * Copyright (c) 2018-2020 Taner Sener
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

/**
 * <p>Represents a callback function to receive an asynchronous execution result.
 */
@FunctionalInterface
public interface ExecuteCallback {

    /**
     * <p>Called when an asynchronous FFmpeg execution is completed.
     *
     * @param executionId id of the execution that completed
     * @param returnCode  return code of the execution completed, 0 on successful completion, 255
     *                    on user cancel, other non-zero codes on error
     */
    void apply(long executionId, int returnCode);

}
