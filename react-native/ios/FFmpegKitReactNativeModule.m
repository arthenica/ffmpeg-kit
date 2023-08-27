/*
 * Copyright (c) 2021-2022 Taner Sener
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

#import "FFmpegKitReactNativeModule.h"
#import <React/RCTLog.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>

#import <ffmpegkit/FFmpegKit.h>
#import <ffmpegkit/FFprobeKit.h>
#import <ffmpegkit/ArchDetect.h>
#import <ffmpegkit/MediaInformation.h>
#import <ffmpegkit/Packages.h>

static NSString *const PLATFORM_NAME = @"ios";

// LOG CLASS
static NSString *const KEY_LOG_SESSION_ID = @"sessionId";
static NSString *const KEY_LOG_LEVEL = @"level";
static NSString *const KEY_LOG_MESSAGE = @"message";

// STATISTICS CLASS
static NSString *const KEY_STATISTICS_SESSION_ID = @"sessionId";
static NSString *const KEY_STATISTICS_VIDEO_FRAME_NUMBER = @"videoFrameNumber";
static NSString *const KEY_STATISTICS_VIDEO_FPS = @"videoFps";
static NSString *const KEY_STATISTICS_VIDEO_QUALITY = @"videoQuality";
static NSString *const KEY_STATISTICS_SIZE = @"size";
static NSString *const KEY_STATISTICS_TIME = @"time";
static NSString *const KEY_STATISTICS_BITRATE = @"bitrate";
static NSString *const KEY_STATISTICS_SPEED = @"speed";

// SESSION CLASS
static NSString *const KEY_SESSION_ID = @"sessionId";
static NSString *const KEY_SESSION_CREATE_TIME = @"createTime";
static NSString *const KEY_SESSION_START_TIME = @"startTime";
static NSString *const KEY_SESSION_COMMAND = @"command";
static NSString *const KEY_SESSION_TYPE = @"type";
static NSString *const KEY_SESSION_MEDIA_INFORMATION = @"mediaInformation";

// SESSION TYPE
static int const SESSION_TYPE_FFMPEG = 1;
static int const SESSION_TYPE_FFPROBE = 2;
static int const SESSION_TYPE_MEDIA_INFORMATION = 3;

// EVENTS
static NSString *const EVENT_LOG_CALLBACK_EVENT = @"FFmpegKitLogCallbackEvent";
static NSString *const EVENT_STATISTICS_CALLBACK_EVENT = @"FFmpegKitStatisticsCallbackEvent";
static NSString *const EVENT_COMPLETE_CALLBACK_EVENT = @"FFmpegKitCompleteCallbackEvent";

extern int const AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;

@implementation FFmpegKitReactNativeModule {
  BOOL logsEnabled;
  BOOL statisticsEnabled;
  dispatch_queue_t asyncDispatchQueue;
}

RCT_EXPORT_MODULE(FFmpegKitReactNativeModule);

- (instancetype)init {
    self = [super init];
    if (self) {
        logsEnabled = false;
        statisticsEnabled = false;
        asyncDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        [self registerGlobalCallbacks];
    }

    return self;
}

- (NSArray<NSString*>*)supportedEvents {
    NSMutableArray *array = [NSMutableArray array];

    [array addObject:EVENT_LOG_CALLBACK_EVENT];
    [array addObject:EVENT_STATISTICS_CALLBACK_EVENT];
    [array addObject:EVENT_COMPLETE_CALLBACK_EVENT];

    return array;
}

- (void)registerGlobalCallbacks {
  [FFmpegKitConfig enableFFmpegSessionCompleteCallback:^(FFmpegSession* session){
    NSDictionary *dictionary = [FFmpegKitReactNativeModule toSessionDictionary:session];
    [self sendEventWithName:EVENT_COMPLETE_CALLBACK_EVENT body:dictionary];
  }];

  [FFmpegKitConfig enableFFprobeSessionCompleteCallback:^(FFprobeSession* session){
    NSDictionary *dictionary = [FFmpegKitReactNativeModule toSessionDictionary:session];
    [self sendEventWithName:EVENT_COMPLETE_CALLBACK_EVENT body:dictionary];
  }];

  [FFmpegKitConfig enableMediaInformationSessionCompleteCallback:^(MediaInformationSession* session){
    NSDictionary *dictionary = [FFmpegKitReactNativeModule toSessionDictionary:session];
    [self sendEventWithName:EVENT_COMPLETE_CALLBACK_EVENT body:dictionary];
  }];

  [FFmpegKitConfig enableLogCallback: ^(Log* log){
    if (self->logsEnabled) {
      NSDictionary *dictionary = [FFmpegKitReactNativeModule toLogDictionary:log];
      [self sendEventWithName:EVENT_LOG_CALLBACK_EVENT body:dictionary];
    }
  }];

  [FFmpegKitConfig enableStatisticsCallback:^(Statistics* statistics){
    if (self->statisticsEnabled) {
      NSDictionary *dictionary = [FFmpegKitReactNativeModule toStatisticsDictionary:statistics];
      [self sendEventWithName:EVENT_STATISTICS_CALLBACK_EVENT body:dictionary];
    }
  }];
}

// AbstractSession

RCT_EXPORT_METHOD(abstractSessionGetEndTime:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
      NSDate* endTime = [session getEndTime];
      if (endTime == nil) {
        resolve(nil);
      } else {
        resolve([NSNumber numberWithDouble:[endTime timeIntervalSince1970]*1000]);
      }
    }
}

RCT_EXPORT_METHOD(abstractSessionGetDuration:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
      resolve([NSNumber numberWithLong:[session getDuration]]);
    }
}

RCT_EXPORT_METHOD(abstractSessionGetAllLogs:(int)sessionId withTimeout:(int)waitTimeout resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
      int timeout;
      if ([FFmpegKitReactNativeModule isValidPositiveNumber:waitTimeout]) {
        timeout = waitTimeout;
      } else {
        timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
      }
      NSArray* allLogs = [session getAllLogsWithTimeout:timeout];
      resolve([FFmpegKitReactNativeModule toLogArray:allLogs]);
    }
}

RCT_EXPORT_METHOD(abstractSessionGetLogs:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
      NSArray* logs = [session getLogs];
      resolve([FFmpegKitReactNativeModule toLogArray:logs]);
    }
}

RCT_EXPORT_METHOD(abstractSessionGetAllLogsAsString:(int)sessionId withTimeout:(int)waitTimeout resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
      int timeout;
      if ([FFmpegKitReactNativeModule isValidPositiveNumber:waitTimeout]) {
        timeout = waitTimeout;
      } else {
        timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
      }
      NSString* allLogsAsString = [session getAllLogsAsStringWithTimeout:timeout];
      resolve(allLogsAsString);
    }
}

RCT_EXPORT_METHOD(abstractSessionGetState:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
      resolve([FFmpegKitReactNativeModule sessionStateToNumber:[session getState]]);
    }
}

RCT_EXPORT_METHOD(abstractSessionGetReturnCode:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
      ReturnCode* returnCode = [session getReturnCode];
      if (returnCode == nil) {
        resolve(nil);
      } else {
        resolve([NSNumber numberWithInt:[returnCode getValue]]);
      }
    }
}

RCT_EXPORT_METHOD(abstractSessionGetFailStackTrace:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
      resolve([session getFailStackTrace]);
    }
}

RCT_EXPORT_METHOD(thereAreAsynchronousMessagesInTransmit:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
      resolve([NSNumber numberWithBool:[session thereAreAsynchronousMessagesInTransmit]]);
    }
}

// ArchDetect

RCT_EXPORT_METHOD(getArch:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([ArchDetect getArch]);
}

// FFmpegSession

RCT_EXPORT_METHOD(ffmpegSession:(NSArray*)arguments resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    FFmpegSession* session = [FFmpegSession create:arguments withCompleteCallback:nil withLogCallback:nil withStatisticsCallback:nil withLogRedirectionStrategy:LogRedirectionStrategyNeverPrintLogs];
    resolve([FFmpegKitReactNativeModule toSessionDictionary:session]);
}

RCT_EXPORT_METHOD(ffmpegSessionGetAllStatistics:(int)sessionId withTimeout:(int)waitTimeout resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        if ([session isFFmpeg]) {
            int timeout;
            if ([FFmpegKitReactNativeModule isValidPositiveNumber:waitTimeout]) {
              timeout = waitTimeout;
            } else {
              timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
            }
            NSArray* allStatistics = [(FFmpegSession*)session getAllStatisticsWithTimeout:timeout];
            resolve([FFmpegKitReactNativeModule toStatisticsArray:allStatistics]);
        } else {
            reject(@"NOT_FFMPEG_SESSION", @"A session is found but it does not have the correct type.", nil);
        }
    }
}

RCT_EXPORT_METHOD(ffmpegSessionGetStatistics:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        if ([session isFFmpeg]) {
            NSArray* statistics = [(FFmpegSession*)session getStatistics];
            resolve([FFmpegKitReactNativeModule toStatisticsArray:statistics]);
        } else {
            reject(@"NOT_FFMPEG_SESSION", @"A session is found but it does not have the correct type.", nil);
        }
    }
}

// FFprobeSession

RCT_EXPORT_METHOD(ffprobeSession:(NSArray*)arguments resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    FFprobeSession* session = [FFprobeSession create:arguments withCompleteCallback:nil withLogCallback:nil withLogRedirectionStrategy:LogRedirectionStrategyNeverPrintLogs];
    resolve([FFmpegKitReactNativeModule toSessionDictionary:session]);
}

// MediaInformationSession

RCT_EXPORT_METHOD(mediaInformationSession:(NSArray*)arguments resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    MediaInformationSession* session = [MediaInformationSession create:arguments withCompleteCallback:nil withLogCallback:nil];
    resolve([FFmpegKitReactNativeModule toSessionDictionary:session]);
}

// MediaInformationJsonParser

RCT_EXPORT_METHOD(mediaInformationJsonParserFrom:(NSString*)ffprobeJsonOutput resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        MediaInformation* mediaInformation = [MediaInformationJsonParser fromWithError:ffprobeJsonOutput];
        resolve([FFmpegKitReactNativeModule toMediaInformationDictionary:mediaInformation]);
    } @catch (NSException *exception) {
        NSLog(@"Parsing MediaInformation failed: %@.\n", [NSString stringWithFormat:@"%@\n%@", [exception userInfo], [exception callStackSymbols]]);
        resolve(nil);
    }
}

RCT_EXPORT_METHOD(mediaInformationJsonParserFromWithError:(NSString*)ffprobeJsonOutput resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        MediaInformation* mediaInformation = [MediaInformationJsonParser fromWithError:ffprobeJsonOutput];
        resolve([FFmpegKitReactNativeModule toMediaInformationDictionary:mediaInformation]);
    } @catch (NSException *exception) {
        NSLog(@"Parsing MediaInformation failed: %@.\n", [NSString stringWithFormat:@"%@\n%@", [exception userInfo], [exception callStackSymbols]]);
        reject(@"PARSE_FAILED", @"Parsing MediaInformation failed with JSON error.", nil);
    }
}

// FFmpegKitConfig

RCT_EXPORT_METHOD(enableRedirection:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [self enableLogs];
    [self enableStatistics];
    [FFmpegKitConfig enableRedirection];

    resolve(nil);
}

RCT_EXPORT_METHOD(disableRedirection:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig disableRedirection];

    resolve(nil);
}

RCT_EXPORT_METHOD(enableLogs:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [self enableLogs];

    resolve(nil);
}

RCT_EXPORT_METHOD(disableLogs:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [self disableLogs];

    resolve(nil);
}

RCT_EXPORT_METHOD(enableStatistics:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [self enableStatistics];

    resolve(nil);
}

RCT_EXPORT_METHOD(disableStatistics:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [self disableStatistics];

    resolve(nil);
}

RCT_EXPORT_METHOD(setFontconfigConfigurationPath:(NSString*)path resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig setFontconfigConfigurationPath:path];

    resolve(nil);
}

RCT_EXPORT_METHOD(setFontDirectory:(NSString*)fontDirectoryPath with:(NSDictionary*)fontNameMap resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig setFontDirectory:fontDirectoryPath with:fontNameMap];

    resolve(nil);
}

RCT_EXPORT_METHOD(setFontDirectoryList:(NSArray*)fontDirectoryList with:(NSDictionary*)fontNameMap resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig setFontDirectoryList:fontDirectoryList with:fontNameMap];

    resolve(nil);
}

RCT_EXPORT_METHOD(registerNewFFmpegPipe:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitConfig registerNewFFmpegPipe]);
}

RCT_EXPORT_METHOD(closeFFmpegPipe:(NSString*)ffmpegPipePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig closeFFmpegPipe:ffmpegPipePath];

    resolve(nil);
}

RCT_EXPORT_METHOD(getFFmpegVersion:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitConfig getFFmpegVersion]);
}

RCT_EXPORT_METHOD(isLTSBuild:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([NSNumber numberWithInt:[FFmpegKitConfig isLTSBuild]]);
}

RCT_EXPORT_METHOD(getBuildDate:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitConfig getBuildDate]);
}

RCT_EXPORT_METHOD(setEnvironmentVariable:(NSString*)variableName with:(NSString*)variableValue resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig setEnvironmentVariable:variableName value:variableValue];

    resolve(nil);
}

RCT_EXPORT_METHOD(ignoreSignal:(int)signalValue resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if ((signalValue == SignalInt) || (signalValue == SignalQuit) || (signalValue == SignalPipe) || (signalValue == SignalTerm) || (signalValue == SignalXcpu)) {
        resolve(nil);
    } else {
        reject(@"INVALID_SIGNAL", @"Signal value not supported.", nil);
    }
}

RCT_EXPORT_METHOD(ffmpegSessionExecute:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        if ([session isFFmpeg]) {
            dispatch_async(asyncDispatchQueue, ^{
                [FFmpegKitConfig ffmpegExecute:(FFmpegSession*)session];
                resolve(nil);
            });
        } else {
            reject(@"NOT_FFMPEG_SESSION", @"A session is found but it does not have the correct type.", nil);
        }
    }
}

RCT_EXPORT_METHOD(ffprobeSessionExecute:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        if ([session isFFprobe]) {
            dispatch_async(asyncDispatchQueue, ^{
                [FFmpegKitConfig ffprobeExecute:(FFprobeSession*)session];
                resolve(nil);
            });
        } else {
            reject(@"NOT_FFPROBE_SESSION", @"A session is found but it does not have the correct type.", nil);
        }
    }
}

RCT_EXPORT_METHOD(mediaInformationSessionExecute:(int)sessionId withTimeout:(int)waitTimeout resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        if ([session isMediaInformation]) {
            int timeout;
            if ([FFmpegKitReactNativeModule isValidPositiveNumber:waitTimeout]) {
              timeout = waitTimeout;
            } else {
              timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
            }
            dispatch_async(asyncDispatchQueue, ^{
                [FFmpegKitConfig getMediaInformationExecute:(MediaInformationSession*)session withTimeout:timeout];
                resolve(nil);
            });
        } else {
            reject(@"NOT_MEDIA_INFORMATION_SESSION", @"A session is found but it does not have the correct type.", nil);
        }
    }
}
RCT_EXPORT_METHOD(asyncFFmpegSessionExecute:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        if ([session isFFmpeg]) {
            [FFmpegKitConfig asyncFFmpegExecute:(FFmpegSession*)session];
            resolve(nil);
        } else {
            reject(@"NOT_FFMPEG_SESSION", @"A session is found but it does not have the correct type.", nil);
        }
    }
}

RCT_EXPORT_METHOD(asyncFFprobeSessionExecute:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        if ([session isFFprobe]) {
            [FFmpegKitConfig asyncFFprobeExecute:(FFprobeSession*)session];
            resolve(nil);
        } else {
            reject(@"NOT_FFPROBE_SESSION", @"A session is found but it does not have the correct type.", nil);
        }
    }
}

RCT_EXPORT_METHOD(asyncMediaInformationSessionExecute:(int)sessionId withTimeout:(int)waitTimeout resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
      reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        if ([session isMediaInformation]) {
            int timeout;
            if ([FFmpegKitReactNativeModule isValidPositiveNumber:waitTimeout]) {
              timeout = waitTimeout;
            } else {
              timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
            }
            [FFmpegKitConfig asyncGetMediaInformationExecute:(MediaInformationSession*)session withTimeout:timeout];
            resolve(nil);
        } else {
            reject(@"NOT_MEDIA_INFORMATION_SESSION", @"A session is found but it does not have the correct type.", nil);
        }
    }
}

RCT_EXPORT_METHOD(getLogLevel:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([NSNumber numberWithInt:[FFmpegKitConfig getLogLevel]]);
}

RCT_EXPORT_METHOD(setLogLevel:(int)level resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig setLogLevel:level];
    resolve(nil);
}

RCT_EXPORT_METHOD(getSessionHistorySize:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([NSNumber numberWithInt:[FFmpegKitConfig getSessionHistorySize]]);
}

RCT_EXPORT_METHOD(setSessionHistorySize:(int)sessionHistorySize resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig setSessionHistorySize:sessionHistorySize];
    resolve(nil);
}

RCT_EXPORT_METHOD(getSession:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
        reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        resolve([FFmpegKitReactNativeModule toSessionDictionary:session]);
    }
}

RCT_EXPORT_METHOD(getLastSession:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitReactNativeModule toSessionDictionary:[FFmpegKitConfig getLastSession]]);
}

RCT_EXPORT_METHOD(getLastCompletedSession:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitReactNativeModule toSessionDictionary:[FFmpegKitConfig getLastCompletedSession]]);
}

RCT_EXPORT_METHOD(getSessions:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitReactNativeModule toSessionArray:[FFmpegKitConfig getSessions]]);
}

RCT_EXPORT_METHOD(clearSessions:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig clearSessions];
    resolve(nil);
}

RCT_EXPORT_METHOD(getSessionsByState:(int)sessionState resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitReactNativeModule toSessionArray:[FFmpegKitConfig getSessionsByState:sessionState]]);
}

RCT_EXPORT_METHOD(getLogRedirectionStrategy:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitReactNativeModule logRedirectionStrategyToNumber:[FFmpegKitConfig getLogRedirectionStrategy]]);
}

RCT_EXPORT_METHOD(setLogRedirectionStrategy:(int)logRedirectionStrategy resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKitConfig setLogRedirectionStrategy:logRedirectionStrategy];
    resolve(nil);
}

RCT_EXPORT_METHOD(messagesInTransmit:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([NSNumber numberWithInt:[FFmpegKitConfig messagesInTransmit:sessionId]]);
}

RCT_EXPORT_METHOD(getPlatform:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(PLATFORM_NAME);
}

RCT_EXPORT_METHOD(writeToPipe:(NSString*)inputPath onPipe:(NSString*)namedPipePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    dispatch_async(asyncDispatchQueue, ^{

        NSLog(@"Starting copy %@ to pipe %@ operation.\n", inputPath, namedPipePath);

        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath: inputPath];
        if (fileHandle == nil) {
            NSLog(@"Failed to open file %@.\n", inputPath);
            reject(@"Copy failed", [NSString stringWithFormat:@"Failed to open file %@.", inputPath], nil);
            return;
        }

        NSFileHandle *pipeHandle = [NSFileHandle fileHandleForWritingAtPath: namedPipePath];
        if (pipeHandle == nil) {
            NSLog(@"Failed to open pipe %@.\n", namedPipePath);
            reject(@"Copy failed", [NSString stringWithFormat:@"Failed to open pipe %@.", namedPipePath], nil);
            [fileHandle closeFile];
            return;
        }

        int BUFFER_SIZE = 4096;
        unsigned long readBytes = 0;
        unsigned long totalBytes = 0;
        double startTime = CACurrentMediaTime();

        @try {
            [fileHandle seekToFileOffset: 0];

            do {
                NSData *data = [fileHandle readDataOfLength:BUFFER_SIZE];
                readBytes = [data length];
                if (readBytes > 0) {
                    totalBytes += readBytes;
                    [pipeHandle writeData:data];
                }
            } while (readBytes > 0);

            double endTime = CACurrentMediaTime();

            NSLog(@"Copying %@ to pipe %@ operation completed successfully. %lu bytes copied in %f seconds.\n", inputPath, namedPipePath, totalBytes, (endTime - startTime)/1000);

            resolve(0);

        } @catch (NSException *e) {
            NSLog(@"Copy failed %@.\n", [e reason]);
            reject(@"Copy failed", [NSString stringWithFormat:@"Copy %@ to %@ failed with error %@.", inputPath, namedPipePath, [e reason]], nil);
        } @finally {
            [fileHandle closeFile];
            [pipeHandle closeFile];
        }
    });
}

RCT_EXPORT_METHOD(selectDocument:(BOOL)writable title:(NSString*)title type:(NSString*)type array:(NSArray*)extraTypes resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  reject(@"Not Supported", @"Not supported on iOS platform.", nil);
}

RCT_EXPORT_METHOD(getSafParameter:(NSString*)uriString mode:(NSString*)openMode resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  reject(@"Not Supported", @"Not supported on iOS platform.", nil);
}

// FFmpegKit

RCT_EXPORT_METHOD(cancel:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKit cancel];

    resolve(nil);
}

RCT_EXPORT_METHOD(cancelSession:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [FFmpegKit cancel:sessionId];

    resolve(nil);
}

RCT_EXPORT_METHOD(getFFmpegSessions:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitReactNativeModule toSessionArray:[FFmpegKit listSessions]]);
}

// FFprobeKit

RCT_EXPORT_METHOD(getFFprobeSessions:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitReactNativeModule toSessionArray:[FFprobeKit listFFprobeSessions]]);
}

RCT_EXPORT_METHOD(getMediaInformationSessions:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([FFmpegKitReactNativeModule toSessionArray:[FFprobeKit listMediaInformationSessions]]);
}

// MediaInformationSession

RCT_EXPORT_METHOD(getMediaInformation:(int)sessionId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:sessionId];
    if (session == nil) {
        reject(@"SESSION_NOT_FOUND", @"Session not found.", nil);
    } else {
        if ([session isMediaInformation]) {
            MediaInformationSession *mediaInformationSession = (MediaInformationSession*)session;
            resolve([FFmpegKitReactNativeModule toMediaInformationDictionary:[mediaInformationSession getMediaInformation]]);
        } else {
            reject(@"NOT_MEDIA_INFORMATION_SESSION", @"A session is found but it does not have the correct type.", nil);
        }
    }
}

// Packages

RCT_EXPORT_METHOD(getPackageName:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([Packages getPackageName]);
}

RCT_EXPORT_METHOD(getExternalLibraries:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([Packages getExternalLibraries]);
}

RCT_EXPORT_METHOD(uninit:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(nil);
}

- (void)enableLogs {
    logsEnabled = true;
}

- (void)disableLogs {
    logsEnabled = false;
}

- (void)enableStatistics {
    statisticsEnabled = true;
}

- (void)disableStatistics {
    statisticsEnabled = false;
}

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

+ (NSDictionary*)toSessionDictionary:(id<Session>) session {
    if (session != nil) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

        dictionary[KEY_SESSION_ID] = [NSNumber numberWithLong: [session getSessionId]];
        dictionary[KEY_SESSION_CREATE_TIME] = [NSNumber numberWithDouble:[[session getCreateTime] timeIntervalSince1970]*1000];
        dictionary[KEY_SESSION_START_TIME] = [NSNumber numberWithDouble:[[session getStartTime] timeIntervalSince1970]*1000];
        dictionary[KEY_SESSION_COMMAND] = [session getCommand];

        if ([session isFFmpeg]) {
          dictionary[KEY_SESSION_TYPE] = [NSNumber numberWithInt:SESSION_TYPE_FFMPEG];
        } else if ([session isFFprobe]) {
          dictionary[KEY_SESSION_TYPE] = [NSNumber numberWithInt:SESSION_TYPE_FFPROBE];
        } else if ([session isMediaInformation]) {
          MediaInformationSession *mediaInformationSession = (MediaInformationSession*)session;
          dictionary[KEY_SESSION_MEDIA_INFORMATION] = [FFmpegKitReactNativeModule toMediaInformationDictionary:[mediaInformationSession getMediaInformation]];
          dictionary[KEY_SESSION_TYPE] = [NSNumber numberWithInt:SESSION_TYPE_MEDIA_INFORMATION];
        }

        return dictionary;
    } else {
        return nil;
    }
}

+ (NSDictionary*)toLogDictionary:(Log*)log {
    if (log != nil) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

        dictionary[KEY_LOG_SESSION_ID] = [NSNumber numberWithLong: [log getSessionId]];
        dictionary[KEY_LOG_LEVEL] = [NSNumber numberWithInt: [log getLevel]];
        dictionary[KEY_LOG_MESSAGE] = [log getMessage];

        return dictionary;
    } else {
        return nil;
    }
}

+ (NSDictionary*)toStatisticsDictionary:(Statistics*)statistics {
    if (statistics != nil) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

        dictionary[KEY_STATISTICS_SESSION_ID] = [NSNumber numberWithLong: [statistics getSessionId]];
        dictionary[KEY_STATISTICS_VIDEO_FRAME_NUMBER] = [NSNumber numberWithInt: [statistics getVideoFrameNumber]];
        dictionary[KEY_STATISTICS_VIDEO_FPS] = [NSNumber numberWithFloat: [statistics getVideoFps]];
        dictionary[KEY_STATISTICS_VIDEO_QUALITY] = [NSNumber numberWithFloat: [statistics getVideoQuality]];
        dictionary[KEY_STATISTICS_SIZE] = [NSNumber numberWithLong: [statistics getSize]];
        dictionary[KEY_STATISTICS_TIME] = [NSNumber numberWithDouble: [statistics getTime]];
        dictionary[KEY_STATISTICS_BITRATE] = [NSNumber numberWithDouble: [statistics getBitrate]];
        dictionary[KEY_STATISTICS_SPEED] = [NSNumber numberWithDouble: [statistics getSpeed]];

        return dictionary;
    } else {
        return nil;
    }
}

+ (NSDictionary*)toMediaInformationDictionary:(MediaInformation*)mediaInformation {
    if (mediaInformation != nil) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

        NSDictionary* allProperties = [mediaInformation getAllProperties];
        if (allProperties != nil) {
            for(NSString *key in [allProperties allKeys]) {
                dictionary[key] = [allProperties objectForKey:key];
            }
        }

        return dictionary;
    } else {
        return nil;
    }
}

+ (NSArray*)toLogArray:(NSArray*)logs {
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (int i = 0; i < [logs count]; i++) {
        Log* log = [logs objectAtIndex:i];
        [array addObject: [FFmpegKitReactNativeModule toLogDictionary:log]];
    }

    return array;
}

+ (NSArray*)toStatisticsArray:(NSArray*)statisticsArray {
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (int i = 0; i < [statisticsArray count]; i++) {
        Statistics* statistics = [statisticsArray objectAtIndex:i];
        [array addObject: [FFmpegKitReactNativeModule toStatisticsDictionary:statistics]];
    }

    return array;
}

+ (NSArray*)toSessionArray:(NSArray*)sessions {
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (int i = 0; i < [sessions count]; i++) {
        AbstractSession* session = (AbstractSession*)[sessions objectAtIndex:i];
        [array addObject: [FFmpegKitReactNativeModule toSessionDictionary:session]];
    }

    return array;
}

+ (NSNumber*)sessionStateToNumber:(SessionState)sessionState {
  switch (sessionState) {
    case SessionStateCreated:
      return [NSNumber numberWithInt:0];
    case SessionStateRunning:
      return [NSNumber numberWithInt:1];
    case SessionStateFailed:
      return [NSNumber numberWithInt:2];
    case SessionStateCompleted:
    default:
      return [NSNumber numberWithInt:3];
  }
}

+ (NSNumber*)logRedirectionStrategyToNumber:(LogRedirectionStrategy)logRedirectionStrategy {
  switch (logRedirectionStrategy) {
    case LogRedirectionStrategyAlwaysPrintLogs:
      return [NSNumber numberWithInt:0];
    case LogRedirectionStrategyPrintLogsWhenNoCallbacksDefined:
      return [NSNumber numberWithInt:1];
    case LogRedirectionStrategyPrintLogsWhenGlobalCallbackNotDefined:
      return [NSNumber numberWithInt:2];
    case LogRedirectionStrategyPrintLogsWhenSessionCallbackNotDefined:
      return [NSNumber numberWithInt:3];
    case LogRedirectionStrategyNeverPrintLogs:
    default:
      return [NSNumber numberWithInt:4];
  }
}

+ (BOOL)isValidPositiveNumber:(int)value {
    if (value >= 0) {
        return true;
    } else {
        return false;
    }
}

@end
