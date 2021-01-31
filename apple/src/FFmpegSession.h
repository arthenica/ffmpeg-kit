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

#ifndef FFMPEG_KIT_FFMPEG_SESSION_H
#define FFMPEG_KIT_FFMPEG_SESSION_H

#import <Foundation/Foundation.h>
#import "AbstractSession.h"
#import "StatisticsDelegate.h"

/**
 * <p>An FFmpeg session.
 */
@interface FFmpegSession : AbstractSession

/**
 * Builds a new FFmpeg session.
 *
 * @param arguments command arguments
 */
- (instancetype)init:(NSArray*)arguments;

/**
 * Builds a new FFmpeg session.
 *
 * @param arguments       command arguments
 * @param executeDelegate session specific execute delegate
 */
- (instancetype)init:(NSArray*)arguments withExecuteDelegate:(id<ExecuteDelegate>)executeDelegate;

/**
 * Builds a new FFmpeg session.
 *
 * @param arguments          command arguments
 * @param executeDelegate    session specific execute delegate
 * @param logDelegate        session specific log delegate
 * @param statisticsDelegate session specific statistics delegate
 */
- (instancetype)init:(NSArray*)arguments withExecuteDelegate:(id<ExecuteDelegate>)executeDelegate withLogDelegate:(id<LogDelegate>)logDelegate withStatisticsDelegate:(id<StatisticsDelegate>)statisticsDelegate;

/**
 * Builds a new FFmpeg session.
 *
 * @param arguments              command arguments
 * @param executeDelegate        session specific execute delegate
 * @param logDelegate            session specific log delegate
 * @param statisticsDelegate     session specific statistics delegate
 * @param logRedirectionStrategy session specific log redirection strategy
 */
- (instancetype)init:(NSArray*)arguments withExecuteDelegate:(id<ExecuteDelegate>)executeDelegate withLogDelegate:(id<LogDelegate>)logDelegate withStatisticsDelegate:(id<StatisticsDelegate>)statisticsDelegate withLogRedirectionStrategy:(LogRedirectionStrategy)logRedirectionStrategy;

/**
 * Returns the session specific statistics delegate.
 *
 * @return session specific statistics delegate
 */
- (id<StatisticsDelegate>)getStatisticsDelegate;

/**
 * Returns all statistics entries generated for this session. If there are asynchronous
 * messages that are not delivered yet, this method waits for them until the given timeout.
 *
 * @param waitTimeout wait timeout for asynchronous messages in milliseconds
 * @return list of statistics entries generated for this session
 */
- (NSArray*)getAllStatisticsWithTimeout:(int)waitTimeout;

/**
 * Returns all statistics entries generated for this session. If there are asynchronous
 * messages that are not delivered yet, this method waits for them until
 * AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit expires.
 *
 * @return list of statistics entries generated for this session
 */
- (NSArray*)getAllStatistics;

/**
 * Returns all statistics entries delivered for this session. Note that if there are
 * asynchronous messages that are not delivered yet, this method will not wait for
 * them and will return immediately.
 *
 * @return list of statistics entries received for this session
 */
- (NSArray*)getStatistics;

/**
 * Returns the last received statistics entry.
 *
 * @return the last received statistics entry or nil if there are not any statistics entries
 * received
 */
- (Statistics*)getLastReceivedStatistics;

/**
 * Adds a new statistics entry for this session.
 *
 * @param statistics statistics entry
 */
- (void)addStatistics:(Statistics*)statistics;

@end

#endif // FFMPEG_KIT_FFMPEG_SESSION_H
