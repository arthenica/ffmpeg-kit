/*
 * Copyright (c) 2018-2022 Taner Sener
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

#import "FFmpegKitFlutterPlugin.h"

#import <ffmpegkit/FFmpegKitConfig.h>

static NSString *const PLATFORM_NAME = @"macos";

static NSString *const METHOD_CHANNEL = @"flutter.arthenica.com/ffmpeg_kit";
static NSString *const EVENT_CHANNEL = @"flutter.arthenica.com/ffmpeg_kit_event";

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

// ARGUMENT NAMES
static NSString *const ARGUMENT_SESSION_ID = @"sessionId";
static NSString *const ARGUMENT_WAIT_TIMEOUT = @"waitTimeout";
static NSString *const ARGUMENT_ARGUMENTS = @"arguments";
static NSString *const ARGUMENT_FFPROBE_JSON_OUTPUT = @"ffprobeJsonOutput";

extern int const AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;

@implementation FFmpegKitFlutterPlugin {
  FlutterEventSink _eventSink;
  BOOL logsEnabled;
  BOOL statisticsEnabled;
  dispatch_queue_t asyncDispatchQueue;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    logsEnabled = false;
    statisticsEnabled = false;
    asyncDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    NSLog(@"FFmpegKitFlutterPlugin %p created.\n", self);
  }

  return self;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _eventSink = eventSink;
  NSLog(@"FFmpegKitFlutterPlugin %p started listening to events on %p.\n", self, eventSink);
  [self registerGlobalCallbacks];
  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  _eventSink = nil;
  return nil;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FFmpegKitFlutterPlugin* instance = [[FFmpegKitFlutterPlugin alloc] init];

  FlutterMethodChannel* methodChannel = [FlutterMethodChannel methodChannelWithName:METHOD_CHANNEL binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:methodChannel];

  FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:EVENT_CHANNEL binaryMessenger:[registrar messenger]];
  [eventChannel setStreamHandler:instance];
}

- (void)registerGlobalCallbacks {
  [FFmpegKitConfig enableFFmpegSessionCompleteCallback:^(FFmpegSession* session){
    NSDictionary *dictionary = [FFmpegKitFlutterPlugin toSessionDictionary:session];
    dispatch_async(dispatch_get_main_queue(), ^() {
      self->_eventSink([FFmpegKitFlutterPlugin toStringDictionary:EVENT_COMPLETE_CALLBACK_EVENT withDictionary:dictionary]);
    });
  }];

  [FFmpegKitConfig enableFFprobeSessionCompleteCallback:^(FFprobeSession* session){
    NSDictionary *dictionary = [FFmpegKitFlutterPlugin toSessionDictionary:session];
    dispatch_async(dispatch_get_main_queue(), ^() {
      self->_eventSink([FFmpegKitFlutterPlugin toStringDictionary:EVENT_COMPLETE_CALLBACK_EVENT withDictionary:dictionary]);
    });
  }];

  [FFmpegKitConfig enableMediaInformationSessionCompleteCallback:^(MediaInformationSession* session){
    NSDictionary *dictionary = [FFmpegKitFlutterPlugin toSessionDictionary:session];
    dispatch_async(dispatch_get_main_queue(), ^() {
      self->_eventSink([FFmpegKitFlutterPlugin toStringDictionary:EVENT_COMPLETE_CALLBACK_EVENT withDictionary:dictionary]);
    });
  }];

  [FFmpegKitConfig enableLogCallback: ^(Log* log){
    if (self->logsEnabled) {
      NSDictionary *dictionary = [FFmpegKitFlutterPlugin toLogDictionary:log];
      dispatch_async(dispatch_get_main_queue(), ^() {
        self->_eventSink([FFmpegKitFlutterPlugin toStringDictionary:EVENT_LOG_CALLBACK_EVENT withDictionary:dictionary]);
      });
    }
  }];

  [FFmpegKitConfig enableStatisticsCallback:^(Statistics* statistics){
    if (self->statisticsEnabled) {
      NSDictionary *dictionary = [FFmpegKitFlutterPlugin toStatisticsDictionary:statistics];
      dispatch_async(dispatch_get_main_queue(), ^() {
        self->_eventSink([FFmpegKitFlutterPlugin toStringDictionary:EVENT_STATISTICS_CALLBACK_EVENT withDictionary:dictionary]);
      });
    }
  }];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSNumber* sessionId = call.arguments[ARGUMENT_SESSION_ID];
  NSNumber* waitTimeout = call.arguments[ARGUMENT_WAIT_TIMEOUT];
  NSArray* arguments = call.arguments[ARGUMENT_ARGUMENTS];
  NSString* ffprobeJsonOutput = call.arguments[ARGUMENT_FFPROBE_JSON_OUTPUT];

  if ([@"abstractSessionGetEndTime" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self abstractSessionGetEndTime:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"abstractSessionGetDuration" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self abstractSessionGetDuration:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"abstractSessionGetAllLogs" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self abstractSessionGetAllLogs:sessionId timeout:(NSNumber*)waitTimeout result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"abstractSessionGetLogs" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self abstractSessionGetLogs:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"abstractSessionGetAllLogsAsString" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self abstractSessionGetAllLogsAsString:sessionId timeout:(NSNumber*)waitTimeout result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"abstractSessionGetState" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self abstractSessionGetState:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"abstractSessionGetReturnCode" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self abstractSessionGetReturnCode:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"abstractSessionGetFailStackTrace" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self abstractSessionGetFailStackTrace:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"thereAreAsynchronousMessagesInTransmit" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self thereAreAsynchronousMessagesInTransmit:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"getArch" isEqualToString:call.method]) {
    [self getArch:result];
  } else if ([@"ffmpegSession" isEqualToString:call.method]) {
    if (arguments != nil) {
      [self ffmpegSession:arguments result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_ARGUMENTS" message:@"Invalid arguments array." details:nil]);
    }
  } else if ([@"ffmpegSessionGetAllStatistics" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self ffmpegSessionGetAllStatistics:sessionId timeout:(NSNumber*)waitTimeout result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"ffmpegSessionGetStatistics" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self ffmpegSessionGetStatistics:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"ffprobeSession" isEqualToString:call.method]) {
    if (arguments != nil) {
      [self ffprobeSession:arguments result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_ARGUMENTS" message:@"Invalid arguments array." details:nil]);
    }
  } else if ([@"mediaInformationSession" isEqualToString:call.method]) {
    if (arguments != nil) {
      [self mediaInformationSession:arguments result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_ARGUMENTS" message:@"Invalid arguments array." details:nil]);
    }
  } else if ([@"getMediaInformation" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self getMediaInformation:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"mediaInformationJsonParserFrom" isEqualToString:call.method]) {
    if (ffprobeJsonOutput != nil) {
      [self mediaInformationJsonParserFrom:ffprobeJsonOutput result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_FFPROBE_JSON_OUTPUT" message:@"Invalid ffprobe json output." details:nil]);
    }
  } else if ([@"mediaInformationJsonParserFromWithError" isEqualToString:call.method]) {
    if (ffprobeJsonOutput != nil) {
      [self mediaInformationJsonParserFromWithError:ffprobeJsonOutput result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_FFPROBE_JSON_OUTPUT" message:@"Invalid ffprobe json output." details:nil]);
    }
  } else if ([@"enableRedirection" isEqualToString:call.method]) {
    [self enableRedirection:result];
  } else if ([@"disableRedirection" isEqualToString:call.method]) {
    [self disableRedirection:result];
  } else if ([@"enableLogs" isEqualToString:call.method]) {
    [self enableLogs:result];
  } else if ([@"disableLogs" isEqualToString:call.method]) {
    [self disableLogs:result];
  } else if ([@"enableStatistics" isEqualToString:call.method]) {
    [self enableStatistics:result];
  } else if ([@"disableStatistics" isEqualToString:call.method]) {
    [self disableStatistics:result];
  } else if ([@"setFontconfigConfigurationPath" isEqualToString:call.method]) {
    NSString* path = call.arguments[@"path"];
    if (path != nil) {
      [self setFontconfigConfigurationPath:path result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_PATH" message:@"Invalid path." details:nil]);
    }
  } else if ([@"setFontDirectory" isEqualToString:call.method]) {
    NSString* fontDirectory = call.arguments[@"fontDirectory"];
    NSDictionary* fontNameMap = call.arguments[@"fontNameMap"];
    if (fontDirectory != nil) {
      [self setFontDirectory:fontDirectory mapping:fontNameMap result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_FONT_DIRECTORY" message:@"Invalid font directory." details:nil]);
    }
  } else if ([@"setFontDirectoryList" isEqualToString:call.method]) {
    NSArray* fontDirectoryList = call.arguments[@"fontDirectoryList"];
    NSDictionary* fontNameMap = call.arguments[@"fontNameMap"];
    if (fontDirectoryList != nil) {
      [self setFontDirectoryList:fontDirectoryList mapping:fontNameMap result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_FONT_DIRECTORY_LIST" message:@"Invalid font directory list." details:nil]);
    }
  } else if ([@"registerNewFFmpegPipe" isEqualToString:call.method]) {
    [self registerNewFFmpegPipe:result];
  } else if ([@"closeFFmpegPipe" isEqualToString:call.method]) {
    NSString* ffmpegPipePath = call.arguments[@"ffmpegPipePath"];
    if (ffmpegPipePath != nil) {
      [self closeFFmpegPipe:ffmpegPipePath result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_PIPE_PATH" message:@"Invalid ffmpeg pipe path." details:nil]);
    }
  } else if ([@"getFFmpegVersion" isEqualToString:call.method]) {
    [self getFFmpegVersion:result];
  } else if ([@"isLTSBuild" isEqualToString:call.method]) {
    [self isLTSBuild:result];
  } else if ([@"getBuildDate" isEqualToString:call.method]) {
    [self getBuildDate:result];
  } else if ([@"setEnvironmentVariable" isEqualToString:call.method]) {
    NSString* variableName = call.arguments[@"variableName"];
    NSString* variableValue = call.arguments[@"variableValue"];
    if ((variableName != nil) && (variableValue != nil)) {
      [self setEnvironmentVariable:variableName value:variableValue result:result];
    } else if (variableValue != nil) {
      result([FlutterError errorWithCode:@"INVALID_NAME" message:@"Invalid environment variable name." details:nil]);
    } else {
      result([FlutterError errorWithCode:@"INVALID_VALUE" message:@"Invalid environment variable value." details:nil]);
    }
  } else if ([@"ignoreSignal" isEqualToString:call.method]) {
    NSNumber* signalIndex = call.arguments[@"signal"];
    if (signalIndex != nil) {
      [self ignoreSignal:[signalIndex intValue] result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SIGNAL" message:@"Invalid signal value." details:nil]);
    }
  } else if ([@"ffmpegSessionExecute" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self ffmpegSessionExecute:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"ffprobeSessionExecute" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self ffprobeSessionExecute:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"mediaInformationSessionExecute" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self mediaInformationSessionExecute:sessionId timeout:waitTimeout result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"asyncFFmpegSessionExecute" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self asyncFFmpegSessionExecute:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"asyncFFprobeSessionExecute" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self asyncFFprobeSessionExecute:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"asyncMediaInformationSessionExecute" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self asyncMediaInformationSessionExecute:sessionId timeout:waitTimeout result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"getLogLevel" isEqualToString:call.method]) {
    [self getLogLevel:result];
  } else if ([@"setLogLevel" isEqualToString:call.method]) {
    NSNumber* level = call.arguments[@"level"];
    if (level != nil) {
      [self setLogLevel:level result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_LEVEL" message:@"Invalid level value." details:nil]);
    }
  } else if ([@"getSessionHistorySize" isEqualToString:call.method]) {
    [self getSessionHistorySize:result];
  } else if ([@"setSessionHistorySize" isEqualToString:call.method]) {
    NSNumber* sessionHistorySize = call.arguments[@"sessionHistorySize"];
    if (sessionHistorySize != nil) {
      [self setSessionHistorySize:sessionHistorySize result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SIZE" message:@"Invalid session history size value." details:nil]);
    }
  } else if ([@"getSession" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self getSession:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"getLastSession" isEqualToString:call.method]) {
    [self getLastSession:result];
  } else if ([@"getLastCompletedSession" isEqualToString:call.method]) {
    [self getLastCompletedSession:result];
  } else if ([@"getSessions" isEqualToString:call.method]) {
    [self getSessions:result];
  } else if ([@"clearSessions" isEqualToString:call.method]) {
    [self clearSessions:result];
  } else if ([@"getSessionsByState" isEqualToString:call.method]) {
    NSNumber* stateIndex = call.arguments[@"state"];
    if (stateIndex != nil) {
      [self getSessionsByState:[stateIndex intValue] result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION_STATE" message:@"Invalid session state value." details:nil]);
    }
  } else if ([@"getLogRedirectionStrategy" isEqualToString:call.method]) {
    [self getLogRedirectionStrategy:result];
  } else if ([@"setLogRedirectionStrategy" isEqualToString:call.method]) {
    NSNumber* strategyIndex = call.arguments[@"strategy"];
    if (strategyIndex != nil) {
      [self setLogRedirectionStrategy:[strategyIndex intValue] result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_LOG_REDIRECTION_STRATEGY" message:@"Invalid log redirection strategy value." details:nil]);
    }
  } else if ([@"messagesInTransmit" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self messagesInTransmit:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"getPlatform" isEqualToString:call.method]) {
    [self getPlatform:result];
  } else if ([@"writeToPipe" isEqualToString:call.method]) {
    NSString* input = call.arguments[@"input"];
    NSString* pipe = call.arguments[@"pipe"];
    if ((input != nil) && (pipe != nil)) {
      [self writeToPipe:input pipe:pipe result:result];
    } else if (pipe != nil) {
      result([FlutterError errorWithCode:@"INVALID_INPUT" message:@"Invalid input value." details:nil]);
    } else {
      result([FlutterError errorWithCode:@"INVALID_PIPE" message:@"Invalid pipe value." details:nil]);
    }
  } else if ([@"selectDocument" isEqualToString:call.method]) {
    [self selectDocument:result];
  } else if ([@"getSafParameter" isEqualToString:call.method]) {
    [self getSafParameter:result];
  } else if ([@"cancel" isEqualToString:call.method]) {
    [self cancel:result];
  } else if ([@"cancelSession" isEqualToString:call.method]) {
    if (sessionId != nil) {
      [self cancelSession:sessionId result:result];
    } else {
      result([FlutterError errorWithCode:@"INVALID_SESSION" message:@"Invalid session id." details:nil]);
    }
  } else if ([@"getFFmpegSessions" isEqualToString:call.method]) {
    [self getFFmpegSessions:result];
  } else if ([@"getFFprobeSessions" isEqualToString:call.method]) {
    [self getFFprobeSessions:result];
  } else if ([@"getMediaInformationSessions" isEqualToString:call.method]) {
    [self getMediaInformationSessions:result];
  } else if ([@"getPackageName" isEqualToString:call.method]) {
    [self getPackageName:result];
  } else if ([@"getExternalLibraries" isEqualToString:call.method]) {
    [self getExternalLibraries:result];
  } else {

    result(FlutterMethodNotImplemented);

  }
}

- (void)abstractSessionGetEndTime:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    NSDate* endTime = [session getEndTime];
    if (endTime == nil) {
      result(nil);
    } else {
      result([NSNumber numberWithLong:[endTime timeIntervalSince1970]*1000]);
    }
  }
}

- (void)abstractSessionGetDuration:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    result([NSNumber numberWithLong:[session getDuration]]);
  }
}

- (void)abstractSessionGetAllLogs:(NSNumber*)sessionId timeout:(NSNumber*)waitTimeout result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    int timeout;
    if ([FFmpegKitFlutterPlugin isValidPositiveNumber:waitTimeout]) {
      timeout = [waitTimeout intValue];
    } else {
      timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
    }
    NSArray* allLogs = [session getAllLogsWithTimeout:timeout];
    result([FFmpegKitFlutterPlugin toLogArray:allLogs]);
  }
}

- (void)abstractSessionGetLogs:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    NSArray* logs = [session getLogs];
    result([FFmpegKitFlutterPlugin toLogArray:logs]);
  }
}

- (void)abstractSessionGetAllLogsAsString:(NSNumber*)sessionId timeout:(NSNumber*)waitTimeout result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    int timeout;
    if ([FFmpegKitFlutterPlugin isValidPositiveNumber:waitTimeout]) {
      timeout = [waitTimeout intValue];
    } else {
      timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
    }
    NSString* allLogsAsString = [session getAllLogsAsStringWithTimeout:timeout];
    result(allLogsAsString);
  }
}

- (void)abstractSessionGetState:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    result([FFmpegKitFlutterPlugin sessionStateToNumber:[session getState]]);
  }
}

- (void)abstractSessionGetReturnCode:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    ReturnCode* returnCode = [session getReturnCode];
    if (returnCode == nil) {
      result(nil);
    } else {
      result([NSNumber numberWithInt:[returnCode getValue]]);
    }
  }
}

- (void)abstractSessionGetFailStackTrace:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    result([session getFailStackTrace]);
  }
}

- (void)thereAreAsynchronousMessagesInTransmit:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    result([NSNumber numberWithBool:[session thereAreAsynchronousMessagesInTransmit]]);
  }
}

// ArchDetect

- (void)getArch:(FlutterResult)result {
  result([ArchDetect getArch]);
}

// FFmpegSession

- (void)ffmpegSession:(NSArray*)arguments result:(FlutterResult)result {
  FFmpegSession* session = [FFmpegSession create:arguments withCompleteCallback:nil withLogCallback:nil withStatisticsCallback:nil withLogRedirectionStrategy:LogRedirectionStrategyNeverPrintLogs];
  result([FFmpegKitFlutterPlugin toSessionDictionary:session]);
}

- (void)ffmpegSessionGetAllStatistics:(NSNumber*)sessionId timeout:(NSNumber*)waitTimeout result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    if ([session isFFmpeg]) {
      int timeout;
      if ([FFmpegKitFlutterPlugin isValidPositiveNumber:waitTimeout]) {
        timeout = [waitTimeout intValue];
      } else {
        timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
      }
      NSArray* allStatistics = [(FFmpegSession*)session getAllStatisticsWithTimeout:timeout];
      result([FFmpegKitFlutterPlugin toStatisticsArray:allStatistics]);
    } else {
      result([FlutterError errorWithCode:@"NOT_FFMPEG_SESSION" message:@"A session is found but it does not have the correct type." details:nil]);
    }
  }
}

- (void)ffmpegSessionGetStatistics:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    if ([session isFFmpeg]) {
      NSArray* statistics = [(FFmpegSession*)session getStatistics];
      result([FFmpegKitFlutterPlugin toStatisticsArray:statistics]);
    } else {
      result([FlutterError errorWithCode:@"NOT_FFMPEG_SESSION" message:@"A session is found but it does not have the correct type." details:nil]);
    }
  }
}

// FFprobeSession

- (void)ffprobeSession:(NSArray*)arguments result:(FlutterResult)result {
  FFprobeSession* session = [FFprobeSession create:arguments withCompleteCallback:nil withLogCallback:nil withLogRedirectionStrategy:LogRedirectionStrategyNeverPrintLogs];
  result([FFmpegKitFlutterPlugin toSessionDictionary:session]);
}

// MediaInformationSession

- (void)mediaInformationSession:(NSArray*)arguments result:(FlutterResult)result {
  MediaInformationSession* session = [MediaInformationSession create:arguments withCompleteCallback:nil withLogCallback:nil];
  result([FFmpegKitFlutterPlugin toSessionDictionary:session]);
}

- (void)getMediaInformation:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    if ([session isMediaInformation]) {
        MediaInformationSession *mediaInformationSession = (MediaInformationSession*)session;
        result([FFmpegKitFlutterPlugin toMediaInformationDictionary:[mediaInformationSession getMediaInformation]]);
    } else {
        result([FlutterError errorWithCode:@"NOT_MEDIA_INFORMATION_SESSION" message:@"A session is found but it does not have the correct type." details:nil]);
    }
  }
}

// MediaInformationJsonParser

- (void)mediaInformationJsonParserFrom:(NSString*)ffprobeJsonOutput result:(FlutterResult)result {
  @try {
    MediaInformation* mediaInformation = [MediaInformationJsonParser fromWithError:ffprobeJsonOutput];
    result([FFmpegKitFlutterPlugin toMediaInformationDictionary:mediaInformation]);
  } @catch (NSException *exception) {
    NSLog(@"Parsing MediaInformation failed: %@.\n", [NSString stringWithFormat:@"%@\n%@", [exception userInfo], [exception callStackSymbols]]);
    result(nil);
  }
}

- (void)mediaInformationJsonParserFromWithError:(NSString*)ffprobeJsonOutput result:(FlutterResult)result {
  @try {
    MediaInformation* mediaInformation = [MediaInformationJsonParser fromWithError:ffprobeJsonOutput];
    result([FFmpegKitFlutterPlugin toMediaInformationDictionary:mediaInformation]);
  } @catch (NSException *exception) {
    NSLog(@"Parsing MediaInformation failed: %@.\n", [NSString stringWithFormat:@"%@\n%@", [exception userInfo], [exception callStackSymbols]]);
    result([FlutterError errorWithCode:@"PARSE_FAILED" message:@"Parsing MediaInformation failed with JSON error." details:nil]);
  }
}

// FFmpegKitConfig

- (void)enableRedirection:(FlutterResult)result {
  [self enableLogs];
  [self enableStatistics];
  [FFmpegKitConfig enableRedirection];

  result(nil);
}

- (void)disableRedirection:(FlutterResult)result {
  [FFmpegKitConfig disableRedirection];

  result(nil);
}

- (void)enableLogs:(FlutterResult)result {
  [self enableLogs];

  result(nil);
}

- (void)disableLogs:(FlutterResult)result {
  [self disableLogs];

  result(nil);
}

- (void)enableStatistics:(FlutterResult)result {
  [self enableStatistics];

  result(nil);
}

- (void)disableStatistics:(FlutterResult)result {
  [self disableStatistics];

  result(nil);
}

- (void)setFontconfigConfigurationPath:(NSString*)path result:(FlutterResult)result {
  [FFmpegKitConfig setFontconfigConfigurationPath:path];

  result(nil);
}

- (void)setFontDirectory:(NSString*)fontDirectoryPath mapping:(NSDictionary*)fontNameMap result:(FlutterResult)result {
  [FFmpegKitConfig setFontDirectory:fontDirectoryPath with:fontNameMap];

  result(nil);
}

- (void)setFontDirectoryList:(NSArray*)fontDirectoryList mapping:(NSDictionary*)fontNameMap result:(FlutterResult)result {
  [FFmpegKitConfig setFontDirectoryList:fontDirectoryList with:fontNameMap];

  result(nil);
}

- (void)registerNewFFmpegPipe:(FlutterResult)result {
  result([FFmpegKitConfig registerNewFFmpegPipe]);
}

- (void)closeFFmpegPipe:(NSString*)ffmpegPipePath result:(FlutterResult)result {
  [FFmpegKitConfig closeFFmpegPipe:ffmpegPipePath];

  result(nil);
}

- (void)getFFmpegVersion:(FlutterResult)result {
  result([FFmpegKitConfig getFFmpegVersion]);
}

- (void)isLTSBuild:(FlutterResult)result {
  result([NSNumber numberWithBool:([FFmpegKitConfig isLTSBuild] == 1)]);
}

- (void)getBuildDate:(FlutterResult)result {
  result([FFmpegKitConfig getBuildDate]);
}

- (void)setEnvironmentVariable:(NSString*)variableName value:(NSString*)variableValue result:(FlutterResult)result {
  [FFmpegKitConfig setEnvironmentVariable:variableName value:variableValue];

  result(nil);
}

- (void)ignoreSignal:(int)signalIndex result:(FlutterResult)result {
  if ((signalIndex == 0) || (signalIndex == 1) || (signalIndex == 2) || (signalIndex == 3) || (signalIndex == 4)) {
    Signal signalValue;
    if (signalIndex == 0) {
      signalValue = SignalInt;
    } else if (signalIndex == 1) {
      signalValue = SignalQuit;
    } else if (signalIndex == 2) {
      signalValue = SignalPipe;
    } else if (signalIndex == 3) {
      signalValue = SignalTerm;
    } else {
      signalValue = SignalXcpu;
    }
    [FFmpegKitConfig ignoreSignal:signalValue];
    result(nil);
  } else {
    result([FlutterError errorWithCode:@"INVALID_SIGNAL" message:@"Signal value not supported." details:nil]);
  }
}

- (void)ffmpegSessionExecute:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    if ([session isFFmpeg]) {
      dispatch_async(asyncDispatchQueue, ^{
        [FFmpegKitConfig ffmpegExecute:(FFmpegSession*)session];
        result(nil);
      });
    } else {
      result([FlutterError errorWithCode:@"NOT_FFMPEG_SESSION" message:@"A session is found but it does not have the correct type." details:nil]);
    }
  }
}

- (void)ffprobeSessionExecute:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    if ([session isFFprobe]) {
      dispatch_async(asyncDispatchQueue, ^{
        [FFmpegKitConfig ffprobeExecute:(FFprobeSession*)session];
        result(nil);
      });
    } else {
      result([FlutterError errorWithCode:@"NOT_FFPROBE_SESSION" message:@"A session is found but it does not have the correct type." details:nil]);
    }
  }
}

- (void)mediaInformationSessionExecute:(NSNumber*)sessionId timeout:(NSNumber*)waitTimeout result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    if ([session isMediaInformation]) {
      int timeout;
      if ([FFmpegKitFlutterPlugin isValidPositiveNumber:waitTimeout]) {
        timeout = [waitTimeout intValue];
      } else {
        timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
      }
      dispatch_async(asyncDispatchQueue, ^{
        [FFmpegKitConfig getMediaInformationExecute:(MediaInformationSession*)session withTimeout:timeout];
        result(nil);
      });
    } else {
      result([FlutterError errorWithCode:@"NOT_MEDIA_INFORMATION_SESSION" message:@"A session is found but it does not have the correct type." details:nil]);
    }
  }
}

- (void)asyncFFmpegSessionExecute:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    if ([session isFFmpeg]) {
      [FFmpegKitConfig asyncFFmpegExecute:(FFmpegSession*)session];
      result(nil);
    } else {
      result([FlutterError errorWithCode:@"NOT_FFMPEG_SESSION" message:@"A session is found but it does not have the correct type." details:nil]);
    }
  }
}

- (void)asyncFFprobeSessionExecute:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    if ([session isFFprobe]) {
      [FFmpegKitConfig asyncFFprobeExecute:(FFprobeSession*)session];
      result(nil);
    } else {
      result([FlutterError errorWithCode:@"NOT_FFPROBE_SESSION" message:@"A session is found but it does not have the correct type." details:nil]);
    }
  }
}

- (void)asyncMediaInformationSessionExecute:(NSNumber*)sessionId timeout:(NSNumber*)waitTimeout result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    if ([session isMediaInformation]) {
      int timeout;
      if ([FFmpegKitFlutterPlugin isValidPositiveNumber:waitTimeout]) {
        timeout = [waitTimeout intValue];
      } else {
        timeout = AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit;
      }
      [FFmpegKitConfig asyncGetMediaInformationExecute:(MediaInformationSession*)session withTimeout:timeout];
      result(nil);
    } else {
      result([FlutterError errorWithCode:@"NOT_MEDIA_INFORMATION_SESSION" message:@"A session is found but it does not have the correct type." details:nil]);
    }
  }
}

- (void)getLogLevel:(FlutterResult)result {
  result([NSNumber numberWithInt:[FFmpegKitConfig getLogLevel]]);
}

- (void)setLogLevel:(NSNumber*)level result:(FlutterResult)result {
  [FFmpegKitConfig setLogLevel:[level intValue]];
  result(nil);
}

- (void)getSessionHistorySize:(FlutterResult)result {
  result([NSNumber numberWithInt:[FFmpegKitConfig getSessionHistorySize]]);
}

- (void)setSessionHistorySize:(NSNumber*)sessionHistorySize result:(FlutterResult)result {
  [FFmpegKitConfig setSessionHistorySize:[sessionHistorySize intValue]];
  result(nil);
}

- (void)getSession:(NSNumber*)sessionId result:(FlutterResult)result {
  AbstractSession* session = (AbstractSession*)[FFmpegKitConfig getSession:[sessionId longValue]];
  if (session == nil) {
    result([FlutterError errorWithCode:@"SESSION_NOT_FOUND" message:@"Session not found." details:nil]);
  } else {
    result([FFmpegKitFlutterPlugin toSessionDictionary:session]);
  }
}

- (void)getLastSession:(FlutterResult)result {
  result([FFmpegKitFlutterPlugin toSessionDictionary:[FFmpegKitConfig getLastSession]]);
}

- (void)getLastCompletedSession:(FlutterResult)result {
  result([FFmpegKitFlutterPlugin toSessionDictionary:[FFmpegKitConfig getLastSession]]);
}

- (void)getSessions:(FlutterResult)result {
  result([FFmpegKitFlutterPlugin toSessionArray:[FFmpegKitConfig getSessions]]);
}

- (void)clearSessions:(FlutterResult)result {
  [FFmpegKitConfig clearSessions];
  result(nil);
}

- (void)getSessionsByState:(int)stateIndex result:(FlutterResult)result {
  if ((stateIndex == 0) || (stateIndex == 1) || (stateIndex == 2) || (stateIndex == 3)) {
    NSUInteger sessionState;
    if (stateIndex == 0) {
      sessionState = SessionStateCreated;
    } else if (stateIndex == 1) {
      sessionState = SessionStateRunning;
    } else if (stateIndex == 2) {
      sessionState = SessionStateFailed;
    } else {
      sessionState = SessionStateCompleted;
    }
    result([FFmpegKitFlutterPlugin toSessionArray:[FFmpegKitConfig getSessionsByState:sessionState]]);
  } else {
    result([FlutterError errorWithCode:@"INVALID_SESSION_STATE" message:@"Session state value not supported." details:nil]);
  }
}

- (void)getLogRedirectionStrategy:(FlutterResult)result {
  result([FFmpegKitFlutterPlugin logRedirectionStrategyToNumber:[FFmpegKitConfig getLogRedirectionStrategy]]);
}

- (void)setLogRedirectionStrategy:(int)strategyIndex result:(FlutterResult)result {
  if ((strategyIndex == 0) || (strategyIndex == 1) || (strategyIndex == 2) || (strategyIndex == 3) || (strategyIndex == 4)) {
    NSUInteger logRedirectionStrategy;
    if (strategyIndex == 0) {
      logRedirectionStrategy = LogRedirectionStrategyAlwaysPrintLogs;
    } else if (strategyIndex == 1) {
      logRedirectionStrategy = LogRedirectionStrategyPrintLogsWhenNoCallbacksDefined;
    } else if (strategyIndex == 2) {
      logRedirectionStrategy = LogRedirectionStrategyPrintLogsWhenGlobalCallbackNotDefined;
    } else if (strategyIndex == 3) {
      logRedirectionStrategy = LogRedirectionStrategyPrintLogsWhenSessionCallbackNotDefined;
    } else {
      logRedirectionStrategy = LogRedirectionStrategyNeverPrintLogs;
    }
    [FFmpegKitConfig setLogRedirectionStrategy:logRedirectionStrategy];
    result(nil);
  } else {
    result([FlutterError errorWithCode:@"INVALID_LOG_REDIRECTION_STRATEGY" message:@"Log redirection strategy value not supported." details:nil]);
  }
}

- (void)messagesInTransmit:(NSNumber*)sessionId result:(FlutterResult)result {
  result([NSNumber numberWithInt:[FFmpegKitConfig messagesInTransmit:[sessionId longValue]]]);
}

- (void)getPlatform:(FlutterResult)result {
  result(PLATFORM_NAME);
}

- (void)writeToPipe:(NSString*)inputPath pipe:(NSString*)namedPipePath result:(FlutterResult)result {
  dispatch_async(asyncDispatchQueue, ^{

    NSLog(@"Starting copy %@ to pipe %@ operation.\n", inputPath, namedPipePath);

    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath: inputPath];
    if (fileHandle == nil) {
      NSLog(@"Failed to open file %@.\n", inputPath);
      result([FlutterError errorWithCode:@"COPY_FAILED" message:[NSString stringWithFormat:@"Failed to open file %@.", inputPath] details:nil]);
      return;
    }

    NSFileHandle *pipeHandle = [NSFileHandle fileHandleForWritingAtPath: namedPipePath];
    if (pipeHandle == nil) {
      NSLog(@"Failed to open pipe %@.\n", namedPipePath);
      result([FlutterError errorWithCode:@"COPY_FAILED" message:[NSString stringWithFormat:@"Failed to open pipe %@.", namedPipePath] details:nil]);
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

      result(0);

    } @catch (NSException *e) {
      NSLog(@"Copy failed %@.\n", [e reason]);
      result([FlutterError errorWithCode:@"COPY_FAILED" message:[NSString stringWithFormat:@"Copy %@ to %@ failed with error %@.", inputPath, namedPipePath, [e reason]] details:nil]);
    } @finally {
      [fileHandle closeFile];
      [pipeHandle closeFile];
    }
  });
}

- (void)selectDocument:(FlutterResult)result {
  result([FlutterError errorWithCode:@"NOT_SUPPORTED" message:@"Not supported on macOS platform." details:nil]);
}

- (void)getSafParameter:(FlutterResult)result {
  result([FlutterError errorWithCode:@"NOT_SUPPORTED" message:@"Not supported on macOS platform." details:nil]);
}

// FFmpegKit

- (void)cancel:(FlutterResult)result {
  [FFmpegKit cancel];

  result(nil);
}

- (void)cancelSession:(NSNumber*)sessionId result:(FlutterResult)result {
  [FFmpegKit cancel:[sessionId longValue]];

  result(nil);
}

- (void)getFFmpegSessions:(FlutterResult)result {
  result([FFmpegKitFlutterPlugin toSessionArray:[FFmpegKit listSessions]]);
}

// FFprobeKit

- (void)getFFprobeSessions:(FlutterResult)result {
  result([FFmpegKitFlutterPlugin toSessionArray:[FFprobeKit listFFprobeSessions]]);
}

- (void)getMediaInformationSessions:(FlutterResult)result {
  result([FFmpegKitFlutterPlugin toSessionArray:[FFprobeKit listMediaInformationSessions]]);
}

// Packages

- (void)getPackageName:(FlutterResult)result {
  result([Packages getPackageName]);
}

- (void)getExternalLibraries:(FlutterResult)result {
  result([Packages getExternalLibraries]);
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

+ (NSDictionary*)toSessionDictionary:(id<Session>) session {
  if (session != nil) {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    dictionary[KEY_SESSION_ID] = [NSNumber numberWithLong: [session getSessionId]];
    dictionary[KEY_SESSION_CREATE_TIME] = [NSNumber numberWithLong:[[session getCreateTime] timeIntervalSince1970]*1000];
    dictionary[KEY_SESSION_START_TIME] = [NSNumber numberWithLong:[[session getStartTime] timeIntervalSince1970]*1000];
    dictionary[KEY_SESSION_COMMAND] = [session getCommand];

    if ([session isFFmpeg]) {
      dictionary[KEY_SESSION_TYPE] = [NSNumber numberWithInt:SESSION_TYPE_FFMPEG];
    } else if ([session isFFprobe]) {
      dictionary[KEY_SESSION_TYPE] = [NSNumber numberWithInt:SESSION_TYPE_FFPROBE];
    } else if ([session isMediaInformation]) {
      MediaInformationSession *mediaInformationSession = (MediaInformationSession*)session;
      dictionary[KEY_SESSION_MEDIA_INFORMATION] = [FFmpegKitFlutterPlugin toMediaInformationDictionary:[mediaInformationSession getMediaInformation]];
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
    [array addObject: [FFmpegKitFlutterPlugin toLogDictionary:log]];
  }

  return array;
}

+ (NSArray*)toStatisticsArray:(NSArray*)statisticsArray {
  NSMutableArray *array = [[NSMutableArray alloc] init];

  for (int i = 0; i < [statisticsArray count]; i++) {
    Statistics* statistics = [statisticsArray objectAtIndex:i];
    [array addObject: [FFmpegKitFlutterPlugin toStatisticsDictionary:statistics]];
  }

  return array;
}

+ (NSArray*)toSessionArray:(NSArray*)sessions {
  NSMutableArray *array = [[NSMutableArray alloc] init];

  for (int i = 0; i < [sessions count]; i++) {
    AbstractSession* session = (AbstractSession*)[sessions objectAtIndex:i];
    [array addObject: [FFmpegKitFlutterPlugin toSessionDictionary:session]];
  }

  return array;
}

+ (NSDictionary *)toStringDictionary:(NSString*)key withDictionary:(NSDictionary*)value {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  dictionary[key] = value;

  return dictionary;
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

+ (BOOL)isValidPositiveNumber:(NSNumber*)value {
  if (![value isEqual:[NSNull null]] && (value != nil) && ([value intValue] >= 0)) {
    return true;
  } else {
    return false;
  }
}

@end
