/*
 * Copyright (c) 2020-2022 Taner Sener
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

#import "fftools_ffmpeg.h"
#import "FFmpegKit.h"
#import "FFmpegKitConfig.h"
#import "FFprobeKit.h"

@implementation FFprobeKit

+ (void)initialize {
    [FFmpegKitConfig class];
}

+ (NSArray*)defaultGetMediaInformationCommandArguments:(NSString*)path {
    return [[NSArray alloc] initWithObjects:@"-v", @"error", @"-hide_banner", @"-print_format", @"json", @"-show_format", @"-show_streams", @"-show_chapters", @"-i", path, nil];
}

+ (FFprobeSession*)executeWithArguments:(NSArray*)arguments {
    FFprobeSession* session = [FFprobeSession create:arguments];
    [FFmpegKitConfig ffprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeWithArgumentsAsync:(NSArray*)arguments withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback {
    FFprobeSession* session = [FFprobeSession create:arguments withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeWithArgumentsAsync:(NSArray*)arguments withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback {
    FFprobeSession* session = [FFprobeSession create:arguments withCompleteCallback:completeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeWithArgumentsAsync:(NSArray*)arguments withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback onDispatchQueue:(dispatch_queue_t)queue {
    FFprobeSession* session = [FFprobeSession create:arguments withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session onDispatchQueue:queue];
    return session;
}

+ (FFprobeSession*)executeWithArgumentsAsync:(NSArray*)arguments withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback onDispatchQueue:(dispatch_queue_t)queue {
    FFprobeSession* session = [FFprobeSession create:arguments withCompleteCallback:completeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session onDispatchQueue:queue];
    return session;
}

+ (FFprobeSession*)execute:(NSString*)command {
    FFprobeSession* session = [FFprobeSession create:[FFmpegKitConfig parseArguments:command]];
    [FFmpegKitConfig ffprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeAsync:(NSString*)command withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback {
    FFprobeSession* session = [FFprobeSession create:[FFmpegKitConfig parseArguments:command] withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeAsync:(NSString*)command withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback {
    FFprobeSession* session = [FFprobeSession create:[FFmpegKitConfig parseArguments:command] withCompleteCallback:completeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeAsync:(NSString*)command withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback onDispatchQueue:(dispatch_queue_t)queue {
    FFprobeSession* session = [FFprobeSession create:[FFmpegKitConfig parseArguments:command] withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session onDispatchQueue:queue];
    return session;
}

+ (FFprobeSession*)executeAsync:(NSString*)command withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback onDispatchQueue:(dispatch_queue_t)queue {
    FFprobeSession* session = [FFprobeSession create:[FFmpegKitConfig parseArguments:command] withCompleteCallback:completeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session onDispatchQueue:queue];
    return session;
}

+ (MediaInformationSession*)getMediaInformation:(NSString*)path {
    NSArray* arguments = [FFprobeKit defaultGetMediaInformationCommandArguments:path];
    MediaInformationSession* session = [MediaInformationSession create:arguments];
    [FFmpegKitConfig getMediaInformationExecute:session withTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
    return session;
}

+ (MediaInformationSession*)getMediaInformation:(NSString*)path withTimeout:(int)waitTimeout {
    NSArray* arguments = [FFprobeKit defaultGetMediaInformationCommandArguments:path];
    MediaInformationSession* session = [MediaInformationSession create:arguments];
    [FFmpegKitConfig getMediaInformationExecute:session withTimeout:waitTimeout];
    return session;
}

+ (MediaInformationSession*)getMediaInformationAsync:(NSString*)path withCompleteCallback:(MediaInformationSessionCompleteCallback)completeCallback {
    NSArray* arguments = [FFprobeKit defaultGetMediaInformationCommandArguments:path];
    MediaInformationSession* session = [MediaInformationSession create:arguments withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session withTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
    return session;
}

+ (MediaInformationSession*)getMediaInformationAsync:(NSString*)path withCompleteCallback:(MediaInformationSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback withTimeout:(int)waitTimeout {
    NSArray* arguments = [FFprobeKit defaultGetMediaInformationCommandArguments:path];
    MediaInformationSession* session = [MediaInformationSession create:arguments withCompleteCallback:completeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session withTimeout:waitTimeout];
    return session;
}

+ (MediaInformationSession*)getMediaInformationAsync:(NSString*)path withCompleteCallback:(MediaInformationSessionCompleteCallback)completeCallback onDispatchQueue:(dispatch_queue_t)queue {
    NSArray* arguments = [FFprobeKit defaultGetMediaInformationCommandArguments:path];
    MediaInformationSession* session = [MediaInformationSession create:arguments withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session onDispatchQueue:queue withTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
    return session;
}

+ (MediaInformationSession*)getMediaInformationAsync:(NSString*)path withCompleteCallback:(MediaInformationSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback onDispatchQueue:(dispatch_queue_t)queue withTimeout:(int)waitTimeout {
    NSArray* arguments = [FFprobeKit defaultGetMediaInformationCommandArguments:path];
    MediaInformationSession* session = [MediaInformationSession create:arguments withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session onDispatchQueue:queue withTimeout:waitTimeout];
    return session;
}

+ (MediaInformationSession*)getMediaInformationFromCommand:(NSString*)command {
    MediaInformationSession* session = [MediaInformationSession create:[FFmpegKitConfig parseArguments:command]];
    [FFmpegKitConfig getMediaInformationExecute:session withTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
    return session;
}

+ (MediaInformationSession*)getMediaInformationFromCommandAsync:(NSString*)command withCompleteCallback:(MediaInformationSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback onDispatchQueue:(dispatch_queue_t)queue withTimeout:(int)waitTimeout {
    MediaInformationSession* session = [MediaInformationSession create:[FFmpegKitConfig parseArguments:command] withCompleteCallback:completeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session onDispatchQueue:queue withTimeout:waitTimeout];
    return session;
}

+ (MediaInformationSession*)getMediaInformationFromCommandArgumentsAsync:(NSArray*)arguments withCompleteCallback:(MediaInformationSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback onDispatchQueue:(dispatch_queue_t)queue withTimeout:(int)waitTimeout {
    MediaInformationSession* session = [MediaInformationSession create:arguments withCompleteCallback:completeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session onDispatchQueue:queue withTimeout:waitTimeout];
    return session;
}

+ (NSArray*)listFFprobeSessions {
    return [FFmpegKitConfig getFFprobeSessions];
}

+ (NSArray*)listMediaInformationSessions {
    return [FFmpegKitConfig getMediaInformationSessions];
}

@end
