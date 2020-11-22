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
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "Statistics.h"

@implementation Statistics {
    long executionId;
    int videoFrameNumber;
    float videoFps;
    float videoQuality;
    long size;
    int time;
    double bitrate;
    double speed;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        executionId = 0;
        videoFrameNumber = 0;
        videoFps = 0;
        videoQuality = 0;
        size = 0;
        time = 0;
        bitrate = 0;
        speed = 0;
    }

    return self;
}

- (instancetype)initWithId:(long)currentExecutionId videoFrameNumber:(int)newVideoFrameNumber fps:(float)newVideoFps quality:(float)newVideoQuality size:(int64_t)newSize time:(int)newTime bitrate:(double)newBitrate speed:(double)newSpeed {
    self = [super init];
    if (self) {
        executionId = currentExecutionId;
        videoFrameNumber = newVideoFrameNumber;
        videoFps = newVideoFps;
        videoQuality = newVideoQuality;
        size = newSize;
        time = newTime;
        bitrate = newBitrate;
        speed = newSpeed;
    }

    return self;
}

- (void)update:(Statistics*)statistics {
    if (statistics != nil) {
        executionId = [statistics getExecutionId];
        if ([statistics getVideoFrameNumber] > 0) {
            videoFrameNumber = [statistics getVideoFrameNumber];
        }
        if ([statistics getVideoFps] > 0) {
            videoFps = [statistics getVideoFps];
        }
        if ([statistics getVideoQuality] > 0) {
            videoQuality = [statistics getVideoQuality];
        }
        if ([statistics getSize] > 0) {
            size = [statistics getSize];
        }
        if ([statistics getTime] > 0) {
            time = [statistics getTime];
        }
        if ([statistics getBitrate] > 0) {
            bitrate = [statistics getBitrate];
        }
        if ([statistics getSpeed] > 0) {
            speed = [statistics getSpeed];
        }
    }
}

- (long)getExecutionId {
    return executionId;
}

- (int)getVideoFrameNumber {
    return videoFrameNumber;
}

- (float)getVideoFps {
    return videoFps;
}

- (float)getVideoQuality {
    return videoQuality;
}

- (long)getSize {
    return size;
}

- (int)getTime {
    return time;
}

- (double)getBitrate {
    return bitrate;
}

- (double)getSpeed {
    return speed;
}

@end