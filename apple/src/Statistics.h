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

#include <Foundation/Foundation.h>

/**
 * Statistics for running executions.
 */
@interface Statistics : NSObject

- (instancetype)init;

- (instancetype)initWithId:(long)currentExecutionId videoFrameNumber:(int)newVideoFrameNumber fps:(float)newVideoFps quality:(float)newVideoQuality size:(int64_t)newSize time:(int)newTime bitrate:(double)newBitrate speed:(double)newSpeed;

- (void)update:(Statistics*)statistics;

- (long)getExecutionId;

- (int)getVideoFrameNumber;

- (float)getVideoFps;

- (float)getVideoQuality;

- (long)getSize;

- (int)getTime;

- (double)getBitrate;

- (double)getSpeed;

@end
