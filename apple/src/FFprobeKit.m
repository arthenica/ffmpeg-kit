/*
 * Copyright (c) 2020-2021 Taner Sener
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

+ (FFprobeSession*)executeWithArguments:(NSArray*)arguments {
    FFprobeSession* session = [[FFprobeSession alloc] init:arguments];
    [FFmpegKitConfig ffprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeWithArgumentsAsync:(NSArray*)arguments withExecuteCallback:(ExecuteCallback)executeCallback {
    FFprobeSession* session = [[FFprobeSession alloc] init:arguments withExecuteCallback:executeCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeWithArgumentsAsync:(NSArray*)arguments withExecuteCallback:(ExecuteCallback)executeCallback withLogCallback:(LogCallback)logCallback {
    FFprobeSession* session = [[FFprobeSession alloc] init:arguments withExecuteCallback:executeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeWithArgumentsAsync:(NSArray*)arguments withExecuteCallback:(ExecuteCallback)executeCallback onDispatchQueue:(dispatch_queue_t)queue {
    FFprobeSession* session = [[FFprobeSession alloc] init:arguments withExecuteCallback:executeCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session onDispatchQueue:queue];
    return session;
}

+ (FFprobeSession*)executeWithArgumentsAsync:(NSArray*)arguments withExecuteCallback:(ExecuteCallback)executeCallback withLogCallback:(LogCallback)logCallback onDispatchQueue:(dispatch_queue_t)queue {
    FFprobeSession* session = [[FFprobeSession alloc] init:arguments withExecuteCallback:executeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session onDispatchQueue:queue];
    return session;
}

+ (FFprobeSession*)execute:(NSString*)command {
    FFprobeSession* session = [[FFprobeSession alloc] init:[FFmpegKitConfig parseArguments:command]];
    [FFmpegKitConfig ffprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeAsync:(NSString*)command withExecuteCallback:(ExecuteCallback)executeCallback {
    FFprobeSession* session = [[FFprobeSession alloc] init:[FFmpegKitConfig parseArguments:command] withExecuteCallback:executeCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeAsync:(NSString*)command withExecuteCallback:(ExecuteCallback)executeCallback withLogCallback:(LogCallback)logCallback {
    FFprobeSession* session = [[FFprobeSession alloc] init:[FFmpegKitConfig parseArguments:command] withExecuteCallback:executeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session];
    return session;
}

+ (FFprobeSession*)executeAsync:(NSString*)command withExecuteCallback:(ExecuteCallback)executeCallback onDispatchQueue:(dispatch_queue_t)queue {
    FFprobeSession* session = [[FFprobeSession alloc] init:[FFmpegKitConfig parseArguments:command] withExecuteCallback:executeCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session onDispatchQueue:queue];
    return session;
}

+ (FFprobeSession*)executeAsync:(NSString*)command withExecuteCallback:(ExecuteCallback)executeCallback withLogCallback:(LogCallback)logCallback onDispatchQueue:(dispatch_queue_t)queue {
    FFprobeSession* session = [[FFprobeSession alloc] init:[FFmpegKitConfig parseArguments:command] withExecuteCallback:executeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncFFprobeExecute:session onDispatchQueue:queue];
    return session;
}

+ (MediaInformationSession*)getMediaInformation:(NSString*)path {
    NSArray* arguments = [[NSArray alloc] initWithObjects:@"-v", @"error", @"-hide_banner", @"-print_format", @"json", @"-show_format", @"-show_streams", @"-i", path, nil];
    MediaInformationSession* session = [[MediaInformationSession alloc] init:arguments];
    [FFmpegKitConfig getMediaInformationExecute:session withTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
    return session;
}

+ (MediaInformationSession*)getMediaInformation:(NSString*)path withTimeout:(int)waitTimeout {
    NSArray* arguments = [[NSArray alloc] initWithObjects:@"-v", @"error", @"-hide_banner", @"-print_format", @"json", @"-show_format", @"-show_streams", @"-i", path, nil];
    MediaInformationSession* session = [[MediaInformationSession alloc] init:arguments];
    [FFmpegKitConfig getMediaInformationExecute:session withTimeout:waitTimeout];
    return session;
}

+ (MediaInformationSession*)getMediaInformationAsync:(NSString*)path withExecuteCallback:(ExecuteCallback)executeCallback {
    NSArray* arguments = [[NSArray alloc] initWithObjects:@"-v", @"error", @"-hide_banner", @"-print_format", @"json", @"-show_format", @"-show_streams", @"-i", path, nil];
    MediaInformationSession* session = [[MediaInformationSession alloc] init:arguments withExecuteCallback:executeCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session withTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
    return session;
}

+ (MediaInformationSession*)getMediaInformationAsync:(NSString*)path withExecuteCallback:(ExecuteCallback)executeCallback withLogCallback:(LogCallback)logCallback withTimeout:(int)waitTimeout {
    NSArray* arguments = [[NSArray alloc] initWithObjects:@"-v", @"error", @"-hide_banner", @"-print_format", @"json", @"-show_format", @"-show_streams", @"-i", path, nil];
    MediaInformationSession* session = [[MediaInformationSession alloc] init:arguments withExecuteCallback:executeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session withTimeout:waitTimeout];
    return session;
}

+ (MediaInformationSession*)getMediaInformationAsync:(NSString*)path withExecuteCallback:(ExecuteCallback)executeCallback onDispatchQueue:(dispatch_queue_t)queue {
    NSArray* arguments = [[NSArray alloc] initWithObjects:@"-v", @"error", @"-hide_banner", @"-print_format", @"json", @"-show_format", @"-show_streams", @"-i", path, nil];
    MediaInformationSession* session = [[MediaInformationSession alloc] init:arguments withExecuteCallback:executeCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session onDispatchQueue:queue withTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
    return session;
}

+ (MediaInformationSession*)getMediaInformationAsync:(NSString*)path withExecuteCallback:(ExecuteCallback)executeCallback withLogCallback:(LogCallback)logCallback onDispatchQueue:(dispatch_queue_t)queue withTimeout:(int)waitTimeout {
    NSArray* arguments = [[NSArray alloc] initWithObjects:@"-v", @"error", @"-hide_banner", @"-print_format", @"json", @"-show_format", @"-show_streams", @"-i", path, nil];
    MediaInformationSession* session = [[MediaInformationSession alloc] init:arguments withExecuteCallback:executeCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session onDispatchQueue:queue withTimeout:waitTimeout];
    return session;
}

+ (MediaInformationSession*)getMediaInformationFromCommand:(NSString*)command {
    MediaInformationSession* session = [[MediaInformationSession alloc] init:[FFmpegKitConfig parseArguments:command]];
    [FFmpegKitConfig getMediaInformationExecute:session withTimeout:AbstractSessionDefaultTimeoutForAsynchronousMessagesInTransmit];
    return session;
}

+ (MediaInformationSession*)getMediaInformationFromCommandAsync:(NSArray*)arguments withExecuteCallback:(ExecuteCallback)executeCallback withLogCallback:(LogCallback)logCallback onDispatchQueue:(dispatch_queue_t)queue withTimeout:(int)waitTimeout {
    MediaInformationSession* session = [[MediaInformationSession alloc] init:arguments withExecuteCallback:executeCallback withLogCallback:logCallback];
    [FFmpegKitConfig asyncGetMediaInformationExecute:session onDispatchQueue:queue withTimeout:waitTimeout];
    return session;
}

+ (NSArray*)listSessions {
    return [FFmpegKitConfig getFFprobeSessions];
}

@end
