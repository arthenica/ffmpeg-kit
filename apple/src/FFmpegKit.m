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

#import "fftools_ffmpeg.h"
#import "ArchDetect.h"
#import "AtomicLong.h"
#import "FFmpegKit.h"
#import "FFmpegKitConfig.h"
#import "Packages.h"

@implementation FFmpegKit

+ (void)initialize {
    NSLog(@"Loading ffmpeg-kit.\n");

    [FFmpegKitConfig class];

    #if TARGET_OS_MACCATALYST
        NSString* osType = @"maccatalyst";
    #elif TARGET_OS_TV
        NSString* osType = @"tvos";
    #elif TARGET_OS_IOS
        NSString* osType = @"ios";
    #elif TARGET_OS_MAC
        NSString* osType = @"macos";
    #endif

    NSLog(@"Loaded ffmpeg-kit-%@-%@-%@-%@%@-%@.\n", [Packages getPackageName],
          [ArchDetect getArch], [FFmpegKitConfig getVersion], osType,
          [ArchDetect getMinSdk], [FFmpegKitConfig getBuildDate]);
}

+ (FFmpegSession *)executeWithArguments:(NSArray *)arguments {
    FFmpegSession *session = [FFmpegSession create:arguments];
    [FFmpegKitConfig ffmpegExecute:session];
    return session;
}

+ (FFmpegSession *)executeWithArgumentsAsync:(NSArray *)arguments
                        withCompleteCallback:
                            (FFmpegSessionCompleteCallback)completeCallback {
    FFmpegSession *session = [FFmpegSession create:arguments
                              withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncFFmpegExecute:session];
    return session;
}

+ (FFmpegSession *)
    executeWithArgumentsAsync:(NSArray *)arguments
         withCompleteCallback:(FFmpegSessionCompleteCallback)completeCallback
              withLogCallback:(LogCallback)logCallback
       withStatisticsCallback:(StatisticsCallback)statisticsCallback {
    FFmpegSession *session = [FFmpegSession create:arguments
                              withCompleteCallback:completeCallback
                                   withLogCallback:logCallback
                            withStatisticsCallback:statisticsCallback];
    [FFmpegKitConfig asyncFFmpegExecute:session];
    return session;
}

+ (FFmpegSession *)executeWithArgumentsAsync:(NSArray *)arguments
                        withCompleteCallback:
                            (FFmpegSessionCompleteCallback)completeCallback
                             onDispatchQueue:(dispatch_queue_t)queue {
    FFmpegSession *session = [FFmpegSession create:arguments
                              withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncFFmpegExecute:session onDispatchQueue:queue];
    return session;
}

+ (FFmpegSession *)
    executeWithArgumentsAsync:(NSArray *)arguments
         withCompleteCallback:(FFmpegSessionCompleteCallback)completeCallback
              withLogCallback:(LogCallback)logCallback
       withStatisticsCallback:(StatisticsCallback)statisticsCallback
              onDispatchQueue:(dispatch_queue_t)queue {
    FFmpegSession *session = [FFmpegSession create:arguments
                              withCompleteCallback:completeCallback
                                   withLogCallback:logCallback
                            withStatisticsCallback:statisticsCallback];
    [FFmpegKitConfig asyncFFmpegExecute:session onDispatchQueue:queue];
    return session;
}

+ (FFmpegSession *)execute:(NSString *)command {
    FFmpegSession *session =
        [FFmpegSession create:[FFmpegKitConfig parseArguments:command]];
    [FFmpegKitConfig ffmpegExecute:session];
    return session;
}

+ (FFmpegSession *)executeAsync:(NSString *)command
           withCompleteCallback:
               (FFmpegSessionCompleteCallback)completeCallback {
    FFmpegSession *session =
        [FFmpegSession create:[FFmpegKitConfig parseArguments:command]
            withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncFFmpegExecute:session];
    return session;
}

+ (FFmpegSession *)executeAsync:(NSString *)command
           withCompleteCallback:(FFmpegSessionCompleteCallback)completeCallback
                withLogCallback:(LogCallback)logCallback
         withStatisticsCallback:(StatisticsCallback)statisticsCallback {
    FFmpegSession *session =
        [FFmpegSession create:[FFmpegKitConfig parseArguments:command]
              withCompleteCallback:completeCallback
                   withLogCallback:logCallback
            withStatisticsCallback:statisticsCallback];
    [FFmpegKitConfig asyncFFmpegExecute:session];
    return session;
}

+ (FFmpegSession *)executeAsync:(NSString *)command
           withCompleteCallback:(FFmpegSessionCompleteCallback)completeCallback
                onDispatchQueue:(dispatch_queue_t)queue {
    FFmpegSession *session =
        [FFmpegSession create:[FFmpegKitConfig parseArguments:command]
            withCompleteCallback:completeCallback];
    [FFmpegKitConfig asyncFFmpegExecute:session onDispatchQueue:queue];
    return session;
}

+ (FFmpegSession *)executeAsync:(NSString *)command
           withCompleteCallback:(FFmpegSessionCompleteCallback)completeCallback
                withLogCallback:(LogCallback)logCallback
         withStatisticsCallback:(StatisticsCallback)statisticsCallback
                onDispatchQueue:(dispatch_queue_t)queue {
    FFmpegSession *session =
        [FFmpegSession create:[FFmpegKitConfig parseArguments:command]
              withCompleteCallback:completeCallback
                   withLogCallback:logCallback
            withStatisticsCallback:statisticsCallback];
    [FFmpegKitConfig asyncFFmpegExecute:session onDispatchQueue:queue];
    return session;
}

+ (void)cancel {

    /*
     * ZERO (0) IS A SPECIAL SESSION ID
     * WHEN IT IS PASSED TO THIS METHOD, A SIGINT IS GENERATED WHICH CANCELS ALL
     * ONGOING SESSIONS
     */
    cancel_operation(0);
}

+ (void)cancel:(long)sessionId {
    cancel_operation(sessionId);
}

+ (NSArray *)listSessions {
    return [FFmpegKitConfig getFFmpegSessions];
}

@end
