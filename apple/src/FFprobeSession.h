/*
 * Copyright (c) 2021 Taner Sener
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

#ifndef FFMPEG_KIT_FFPROBE_SESSION_H
#define FFMPEG_KIT_FFPROBE_SESSION_H

#import <Foundation/Foundation.h>
#import "AbstractSession.h"

/**
 * <p>An FFprobe session.
 */
@interface FFprobeSession : AbstractSession

/**
 * Builds a new FFprobe session.
 *
 * @param arguments command arguments
 */
- (instancetype)init:(NSArray*)arguments;

/**
 * Builds a new FFprobe session.
 *
 * @param arguments       command arguments
 * @param executeDelegate session specific execute delegate
 */
- (instancetype)init:(NSArray*)arguments withExecuteDelegate:(id<ExecuteDelegate>)executeDelegate;

/**
 * Builds a new FFprobe session.
 *
 * @param arguments       command arguments
 * @param executeDelegate session specific execute delegate
 * @param logDelegate     session specific log delegate
 */
- (instancetype)init:(NSArray*)arguments withExecuteDelegate:(id<ExecuteDelegate>)executeDelegate withLogDelegate:(id<LogDelegate>)logDelegate;

/**
 * Builds a new FFprobe session.
 *
 * @param arguments              command arguments
 * @param executeDelegate        session specific execute delegate
 * @param logDelegate            session specific log delegate
 * @param logRedirectionStrategy session specific log redirection strategy
 */
- (instancetype)init:(NSArray*)arguments withExecuteDelegate:(id<ExecuteDelegate>)executeDelegate withLogDelegate:(id<LogDelegate>)logDelegate withLogRedirectionStrategy:(LogRedirectionStrategy)logRedirectionStrategy;

@end

#endif // FFMPEG_KIT_FFPROBE_SESSION_H
