/*
 * Copyright (c) 2021-2022 Taner Sener
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

#import "AbstractSession.h"
#import "AtomicLong.h"
#import "FFmpegKit.h"
#import "FFmpegKitConfig.h"
#import "LogCallback.h"
#import "ReturnCode.h"

int const AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit = 5000;

static AtomicLong *sessionIdGenerator = nil;

extern void addSessionToSessionHistory(id<Session> session);

@implementation AbstractSession {
    long _sessionId;
    LogCallback _logCallback;
    NSDate* _createTime;
    NSDate* _startTime;
    NSDate* _endTime;
    NSArray* _arguments;
    NSMutableArray* _logs;
    NSRecursiveLock* _logsLock;
    SessionState _state;
    ReturnCode* _returnCode;
    NSString* _failStackTrace;
    LogRedirectionStrategy _logRedirectionStrategy;
}

+ (void)initialize {
    sessionIdGenerator = [[AtomicLong alloc] initWithValue:1];
}

- (instancetype)init:(NSArray*)arguments withLogCallback:(LogCallback)logCallback withLogRedirectionStrategy:(LogRedirectionStrategy)logRedirectionStrategy {
    self = [super init];
    if (self) {
        _sessionId = [sessionIdGenerator getAndIncrement];
        _logCallback = logCallback;
        _createTime = [NSDate date];
        _startTime = nil;
        _endTime = nil;
        _arguments = arguments;
        _logs = [[NSMutableArray alloc] init];
        _logsLock = [[NSRecursiveLock alloc] init];
        _state = SessionStateCreated;
        _returnCode = nil;
        _failStackTrace = nil;
        _logRedirectionStrategy = logRedirectionStrategy;

        addSessionToSessionHistory(self);
    }

    return self;
}

- (LogCallback)getLogCallback {
    return _logCallback;
}

- (long)getSessionId {
    return _sessionId;
}

- (NSDate*)getCreateTime {
    return _createTime;
}

- (NSDate*)getStartTime {
    return _startTime;
}

- (NSDate*)getEndTime {
    return _endTime;
}

- (long)getDuration {
    NSDate* startTime = _startTime;
    NSDate* endTime = _endTime;
    if (startTime != nil && endTime != nil) {
        return [[NSNumber numberWithDouble:([endTime timeIntervalSinceDate:startTime]*1000)] longValue];
    }
    
    return 0;
}

- (NSArray*)getArguments {
    return _arguments;
}

- (NSString*)getCommand {
    return [FFmpegKitConfig argumentsToString:_arguments];
}

- (void)waitForAsynchronousMessagesInTransmit:(int)timeout {
    NSDate* expireDate = [[NSDate date] dateByAddingTimeInterval:((double)timeout)/1000];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    while ([self thereAreAsynchronousMessagesInTransmit] && ([[NSDate date] timeIntervalSinceDate:expireDate] < 0)) {
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC));
    }
}

- (NSArray*)getAllLogsWithTimeout:(int)waitTimeout {
    [self waitForAsynchronousMessagesInTransmit:waitTimeout];

    if ([self thereAreAsynchronousMessagesInTransmit]) {
        NSLog(@"getAllLogsWithTimeout was called to return all logs but there are still logs being transmitted for session id %ld.", _sessionId);
    }

    return [self getLogs];
}

- (NSArray*)getAllLogs {
    return [self getAllLogsWithTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
}

- (NSArray*)getLogs {
    [_logsLock lock];
    NSArray* logsCopy = [_logs copy];
    [_logsLock unlock];
    
    return logsCopy;
}

- (NSString*)getAllLogsAsStringWithTimeout:(int)waitTimeout {
    [self waitForAsynchronousMessagesInTransmit:waitTimeout];

    if ([self thereAreAsynchronousMessagesInTransmit]) {
        NSLog(@"getAllLogsAsStringWithTimeout was called to return all logs but there are still logs being transmitted for session id %ld.", _sessionId);
    }

    return [self getLogsAsString];
}

- (NSString*)getAllLogsAsString {
    return [self getAllLogsAsStringWithTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
}

- (NSString*)getLogsAsString {
    NSMutableString* concatenatedString = [[NSMutableString alloc] init];

    [_logsLock lock];
    for (int i=0; i < [_logs count]; i++) {
        [concatenatedString appendString:[[_logs objectAtIndex:i] getMessage]];
    }
    [_logsLock unlock];

    return concatenatedString;
}

- (NSString*)getOutput {
    return [self getAllLogsAsString];
}

- (SessionState)getState {
    return _state;
}

- (ReturnCode*)getReturnCode {
    return _returnCode;
}

- (NSString*)getFailStackTrace {
    return _failStackTrace;
}

- (LogRedirectionStrategy)getLogRedirectionStrategy {
    return _logRedirectionStrategy;
}

- (BOOL)thereAreAsynchronousMessagesInTransmit {
    return ([FFmpegKitConfig messagesInTransmit:_sessionId] != 0);
}

- (void)addLog:(Log*)log {
    [_logsLock lock];
    [_logs addObject:log];
    [_logsLock unlock];
}

- (void)startRunning {
    _state = SessionStateRunning;
    _startTime = [NSDate date];
}

- (void)complete:(ReturnCode*)returnCode {
    _returnCode = returnCode;
    _state = SessionStateCompleted;
    _endTime = [NSDate date];
}

- (void)fail:(NSException*)exception {
    _failStackTrace = [NSString stringWithFormat:@"%@\n%@", [exception userInfo], [exception callStackSymbols]];
    _state = SessionStateFailed;
    _endTime = [NSDate date];
}

- (BOOL)isFFmpeg {
    // IMPLEMENTED IN SUBCLASSES
    return false;
}

- (BOOL)isFFprobe {
    // IMPLEMENTED IN SUBCLASSES
    return false;
}

- (BOOL)isMediaInformation {
    // IMPLEMENTED IN SUBCLASSES
    return false;
}

- (void)cancel {
    if (_state == SessionStateRunning) {
        [FFmpegKit cancel:_sessionId];
    }
}

@end
