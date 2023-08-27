/*
 * Copyright (c) 2018-2021 Taner Sener
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

#import "Statistics.h"

@implementation Statistics {
    long _sessionId;
    int _videoFrameNumber;
    float _videoFps;
    float _videoQuality;
    long _size;
    double _time;
    double _bitrate;
    double _speed;
}

- (instancetype)init:(long)sessionId videoFrameNumber:(int)videoFrameNumber videoFps:(float)videoFps videoQuality:(float)videoQuality size:(int64_t)size time:(double)time bitrate:(double)bitrate speed:(double)speed {
    self = [super init];
    if (self) {
        _sessionId = sessionId;
        _videoFrameNumber = videoFrameNumber;
        _videoFps = videoFps;
        _videoQuality = videoQuality;
        _size = size;
        _time = time;
        _bitrate = bitrate;
        _speed = speed;
    }

    return self;
}

- (long)getSessionId {
    return _sessionId;
}

- (int)getVideoFrameNumber {
    return _videoFrameNumber;
}

- (float)getVideoFps {
    return _videoFps;
}

- (float)getVideoQuality {
    return _videoQuality;
}

- (long)getSize {
    return _size;
}

- (double)getTime {
    return _time;
}

- (double)getBitrate {
    return _bitrate;
}

- (double)getSpeed {
    return _speed;
}

@end
