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

#import "ExecuteDelegate.h"
#import "FFmpegSession.h"
#import "FFmpegKitConfig.h"
#import "LogDelegate.h"
#import "StatisticsDelegate.h"

@implementation FFmpegSession {
    id<StatisticsDelegate> _statisticsDelegate;
    NSMutableArray* _statistics;
    NSRecursiveLock* _statisticsLock;
}

- (instancetype)init:(NSArray*)arguments {

    self = [super init:arguments withExecuteDelegate:nil withLogDelegate:nil withLogRedirectionStrategy:[FFmpegKitConfig getLogRedirectionStrategy]];

    if (self) {
        _statisticsDelegate = nil;
        _statistics = [[NSMutableArray alloc] init];
        _statisticsLock = [[NSRecursiveLock alloc] init];
    }

    return self;
}

- (instancetype)init:(NSArray*)arguments withExecuteDelegate:(id<ExecuteDelegate>)executeDelegate {

    self = [super init:arguments withExecuteDelegate:executeDelegate withLogDelegate:nil withLogRedirectionStrategy:[FFmpegKitConfig getLogRedirectionStrategy]];

    if (self) {
        _statisticsDelegate = nil;
        _statistics = [[NSMutableArray alloc] init];
        _statisticsLock = [[NSRecursiveLock alloc] init];
    }

    return self;
}

- (instancetype)init:(NSArray*)arguments withExecuteDelegate:(id<ExecuteDelegate>)executeDelegate withLogDelegate:(id<LogDelegate>)logDelegate withStatisticsDelegate:(id<StatisticsDelegate>)statisticsDelegate {

    self = [super init:arguments withExecuteDelegate:executeDelegate withLogDelegate:logDelegate withLogRedirectionStrategy:[FFmpegKitConfig getLogRedirectionStrategy]];

    if (self) {
        _statisticsDelegate = statisticsDelegate;
        _statistics = [[NSMutableArray alloc] init];
        _statisticsLock = [[NSRecursiveLock alloc] init];
    }

    return self;
}

- (instancetype)init:(NSArray*)arguments withExecuteDelegate:(id<ExecuteDelegate>)executeDelegate withLogDelegate:(id<LogDelegate>)logDelegate withStatisticsDelegate:(id<StatisticsDelegate>)statisticsDelegate withLogRedirectionStrategy:(LogRedirectionStrategy)logRedirectionStrategy {

    self = [super init:arguments withExecuteDelegate:executeDelegate withLogDelegate:logDelegate withLogRedirectionStrategy:logRedirectionStrategy];

    if (self) {
        _statisticsDelegate = statisticsDelegate;
        _statistics = [[NSMutableArray alloc] init];
        _statisticsLock = [[NSRecursiveLock alloc] init];
    }

    return self;
}

- (id<StatisticsDelegate>)getStatisticsDelegate {
    return _statisticsDelegate;
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
        lastStatistics = [_statistics objectAtIndex:0];
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

@end

