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

#import "FFmpegSession.h"
#import "FFmpegKitConfig.h"
#import "LogCallback.h"
#import "StatisticsCallback.h"

@implementation FFmpegSession {
    StatisticsCallback _statisticsCallback;
    FFmpegSessionCompleteCallback _completeCallback;
    NSMutableArray* _statistics;
    NSRecursiveLock* _statisticsLock;
}

+ (void)initialize {
    // EMPTY INITIALIZE
}

+ (instancetype)create:(NSArray*)arguments {
    return [[self alloc] init:arguments withCompleteCallback:nil withLogCallback:nil withStatisticsCallback:nil withLogRedirectionStrategy:[FFmpegKitConfig getLogRedirectionStrategy]];
}

+ (instancetype)create:(NSArray*)arguments withCompleteCallback:(FFmpegSessionCompleteCallback)completeCallback {
    return [[self alloc] init:arguments withCompleteCallback:completeCallback withLogCallback:nil withStatisticsCallback:nil withLogRedirectionStrategy:[FFmpegKitConfig getLogRedirectionStrategy]];
}

+ (instancetype)create:(NSArray*)arguments withCompleteCallback:(FFmpegSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback withStatisticsCallback:(StatisticsCallback)statisticsCallback {
    return [[self alloc] init:arguments withCompleteCallback:completeCallback withLogCallback:logCallback withStatisticsCallback:statisticsCallback withLogRedirectionStrategy:[FFmpegKitConfig getLogRedirectionStrategy]];
}

+ (instancetype)create:(NSArray*)arguments withCompleteCallback:(FFmpegSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback withStatisticsCallback:(StatisticsCallback)statisticsCallback withLogRedirectionStrategy:(LogRedirectionStrategy)logRedirectionStrategy {
    return [[self alloc] init:arguments withCompleteCallback:completeCallback withLogCallback:logCallback withStatisticsCallback:statisticsCallback withLogRedirectionStrategy:logRedirectionStrategy];
}

- (instancetype)init:(NSArray*)arguments withCompleteCallback:(FFmpegSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback withStatisticsCallback:(StatisticsCallback)statisticsCallback withLogRedirectionStrategy:(LogRedirectionStrategy)logRedirectionStrategy {

    self = [super init:arguments withLogCallback:logCallback withLogRedirectionStrategy:logRedirectionStrategy];

    if (self) {
        _statisticsCallback = statisticsCallback;
        _completeCallback = completeCallback;
        _statistics = [[NSMutableArray alloc] init];
        _statisticsLock = [[NSRecursiveLock alloc] init];
    }

    return self;
}

- (StatisticsCallback)getStatisticsCallback {
    return _statisticsCallback;
}

- (FFmpegSessionCompleteCallback)getCompleteCallback {
    return _completeCallback;
}

- (NSArray*)getAllStatisticsWithTimeout:(int)waitTimeout {
    [self waitForAsynchronousMessagesInTransmit:waitTimeout];

    if ([self thereAreAsynchronousMessagesInTransmit]) {
        NSLog(@"getAllStatisticsWithTimeout was called to return all statistics but there are still statistics being transmitted for session id %ld.", [self getSessionId]);
    }

    return [self getStatistics];
}

- (NSArray*)getAllStatistics {
    return [self getAllStatisticsWithTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
}

- (NSArray*)getStatistics {
    [_statisticsLock lock];
    NSArray* statisticsCopy = [_statistics copy];
    [_statisticsLock unlock];
    
    return statisticsCopy;
}

- (Statistics*)getLastReceivedStatistics {
    Statistics* lastStatistics = nil;

    [_statisticsLock lock];
    if ([_statistics count] > 0) {
        lastStatistics = [_statistics objectAtIndex:[_statistics count] - 1];
    }
    [_statisticsLock unlock];

    return lastStatistics;
}

- (void)addStatistics:(Statistics*)statistics {
    [_statisticsLock lock];
    [_statistics addObject:statistics];
    [_statisticsLock unlock];
}

- (BOOL)isFFmpeg {
    return true;
}

- (BOOL)isFFprobe {
    return false;
}

- (BOOL)isMediaInformation {
    return false;
}

@end

