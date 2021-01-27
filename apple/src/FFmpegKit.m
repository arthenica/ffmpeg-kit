/*
 * Copyright (c) 2018-2021 Taner Sener
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

#include "fftools_ffmpeg.h"

#include "FFmpegKit.h"
#include "ArchDetect.h"
#include "AtomicLong.h"
#include "FFmpegExecution.h"
#include "FFmpegKitConfig.h"

/** Forward declaration for function defined in fftools_ffmpeg.c */
int ffmpeg_execute(int argc, char **argv);

@implementation FFmpegKit

/** Global library version */
NSString *const FFMPEG_KIT_VERSION = @"4.4";

extern int lastReturnCode;
extern NSMutableString *lastCommandOutput;

long const DEFAULT_EXECUTION_ID = 0;
AtomicLong *executionIdCounter;

extern __thread volatile long executionId;
int cancelRequested(long executionId);
void addExecution(long executionId);
void removeExecution(long executionId);

NSMutableArray *executions;
NSLock *executionsLock;

extern int configuredLogLevel;

+ (void)initialize {
    [FFmpegKitConfig class];

    executionIdCounter = [[AtomicLong alloc] initWithInitialValue:3000];

    executions = [[NSMutableArray alloc] init];
    executionsLock = [[NSLock alloc] init];

    NSLog(@"Loaded ffmpeg-kit-%@-%@-%@-%@\n", [FFmpegKitConfig getPackageName], [ArchDetect getArch], [FFmpegKitConfig getVersion], [FFmpegKitConfig getBuildDate]);
}

+ (int)executeWithId:(long)newExecutionId andArguments:(NSArray*)arguments {
    lastCommandOutput = [[NSMutableString alloc] init];

    // SETS DEFAULT LOG LEVEL BEFORE STARTING A NEW EXECUTION
    av_log_set_level(configuredLogLevel);

    FFmpegExecution* currentFFmpegExecution = [[FFmpegExecution alloc] initWithExecutionId:newExecutionId andArguments:arguments];
    [executionsLock lock];
    [executions addObject: currentFFmpegExecution];
    [executionsLock unlock];

    char **commandCharPArray = (char **)av_malloc(sizeof(char*) * ([arguments count] + 1));

    /* PRESERVING CALLING FORMAT
     *
     * ffmpeg <arguments>
     */
    commandCharPArray[0] = (char *)av_malloc(sizeof(char) * ([LIB_NAME length] + 1));
    strcpy(commandCharPArray[0], [LIB_NAME UTF8String]);

    for (int i=0; i < [arguments count]; i++) {
        NSString *argument = [arguments objectAtIndex:i];
        commandCharPArray[i + 1] = (char *) [argument UTF8String];
    }

    // REGISTER THE ID BEFORE STARTING EXECUTION
    executionId = newExecutionId;
    addExecution(newExecutionId);

    // RUN
    lastReturnCode = ffmpeg_execute(([arguments count] + 1), commandCharPArray);

    // ALWAYS REMOVE THE ID FROM THE MAP
    removeExecution(newExecutionId);

    // CLEANUP
    av_free(commandCharPArray[0]);
    av_free(commandCharPArray);

    [executionsLock lock];
    [executions removeObject: currentFFmpegExecution];
    [executionsLock unlock];

    return lastReturnCode;
}

/**
 * Synchronously executes FFmpeg with arguments provided.
 *
 * @param arguments FFmpeg command options/arguments as string array
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)executeWithArguments:(NSArray*)arguments {
    return [self executeWithId:DEFAULT_EXECUTION_ID andArguments:arguments];
}

/**
 * Asynchronously executes FFmpeg with arguments provided. Space character is used to split command into arguments.
 *
 * @param arguments FFmpeg command options/arguments as string array
 * @param delegate delegate that will be notified when execution is completed
 * @return a unique id that represents this execution
 */
+ (int)executeWithArgumentsAsync:(NSArray*)arguments withCallback:(id<ExecuteDelegate>)delegate {
    return [self executeWithArgumentsAsync:arguments withCallback:delegate andDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

/**
 * Asynchronously executes FFmpeg with arguments provided. Space character is used to split command into arguments.
 *
 * @param arguments FFmpeg command options/arguments as string array
 * @param delegate delegate that will be notified when execution is completed
 * @param queue dispatch queue that will be used to run this asynchronous operation
 * @return a unique id that represents this execution
 */
+ (int)executeWithArgumentsAsync:(NSArray*)arguments withCallback:(id<ExecuteDelegate>)delegate andDispatchQueue:(dispatch_queue_t)queue {
    const long newExecutionId = [executionIdCounter incrementAndGet];

    dispatch_async(queue, ^{
        const int returnCode = [self executeWithId:newExecutionId andArguments:arguments];
        if (delegate != nil) {
            [delegate executeCallback:executionId:returnCode];
        }
    });

    return newExecutionId;
}

/**
 * Synchronously executes FFmpeg command provided. Space character is used to split command into arguments.
 *
 * @param command FFmpeg command
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)execute:(NSString*)command {
    return [self executeWithArguments: [self parseArguments: command]];
}

/**
 * Asynchronously executes FFmpeg command provided. Space character is used to split command into arguments.
 *
 * @param command FFmpeg command
 * @param delegate delegate that will be notified when execution is completed
 * @return a unique id that represents this execution
 */
+ (int)executeAsync:(NSString*)command withCallback:(id<ExecuteDelegate>)delegate {
    return [self executeAsync:command withCallback:delegate andDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

/**
 * Asynchronously executes FFmpeg command provided. Space character is used to split command into arguments.
 *
 * @param command FFmpeg command
 * @param delegate delegate that will be notified when execution is completed
 * @param queue dispatch queue that will be used to run this asynchronous operation
 * @return a unique id that represents this execution
 */
+ (int)executeAsync:(NSString*)command withCallback:(id<ExecuteDelegate>)delegate andDispatchQueue:(dispatch_queue_t)queue {
    return [self executeWithArgumentsAsync:[self parseArguments:command] withCallback:delegate andDispatchQueue:queue];
}

/**
 * Synchronously executes FFmpeg command provided. Delimiter parameter is used to split command into arguments.
 *
 * @param command FFmpeg command
 * @param delimiter arguments delimiter
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)execute:(NSString*)command delimiter:(NSString*)delimiter {

    // SPLITTING ARGUMENTS
    NSArray* argumentArray = [command componentsSeparatedByString:(delimiter == nil ? @" ": delimiter)];
    return [self executeWithArguments:argumentArray];
}

/**
 * Cancels an ongoing operation.
 *
 * This function does not wait for termination to complete and returns immediately.
 */
+ (void)cancel {
    cancel_operation(DEFAULT_EXECUTION_ID);
}

/**
 * Cancels an ongoing operation.
 *
 * This function does not wait for termination to complete and returns immediately.
 *
 * @param executionId execution id
 */
+ (void)cancel:(long)executionId {
    cancel_operation(executionId);
}

/**
 * Parses the given command into arguments.
 *
 * @param command string command
 * @return array of arguments
 */
+ (NSArray*)parseArguments:(NSString*)command {
    NSMutableArray *argumentArray = [[NSMutableArray alloc] init];
    NSMutableString *currentArgument = [[NSMutableString alloc] init];

    bool singleQuoteStarted = false;
    bool doubleQuoteStarted = false;

    for (int i = 0; i < command.length; i++) {
        unichar previousChar;
        if (i > 0) {
            previousChar = [command characterAtIndex:(i - 1)];
        } else {
            previousChar = 0;
        }
        unichar currentChar = [command characterAtIndex:i];

        if (currentChar == ' ') {
            if (singleQuoteStarted || doubleQuoteStarted) {
                [currentArgument appendFormat: @"%C", currentChar];
            } else if ([currentArgument length] > 0) {
                [argumentArray addObject: currentArgument];
                currentArgument = [[NSMutableString alloc] init];
            }
        } else if (currentChar == '\'' && (previousChar == 0 || previousChar != '\\')) {
            if (singleQuoteStarted) {
                singleQuoteStarted = false;
            } else if (doubleQuoteStarted) {
                [currentArgument appendFormat: @"%C", currentChar];
            } else {
                singleQuoteStarted = true;
            }
        } else if (currentChar == '\"' && (previousChar == 0 || previousChar != '\\')) {
            if (doubleQuoteStarted) {
                doubleQuoteStarted = false;
            } else if (singleQuoteStarted) {
                [currentArgument appendFormat: @"%C", currentChar];
            } else {
                doubleQuoteStarted = true;
            }
        } else {
            [currentArgument appendFormat: @"%C", currentChar];
        }
    }

    if ([currentArgument length] > 0) {
        [argumentArray addObject: currentArgument];
    }

    return argumentArray;
}

/**
 * <p>Combines arguments into a string.
 *
 * @param arguments arguments
 * @return string containing all arguments
 */
+ (NSString*)argumentsToString:(NSArray*)arguments {
    if (arguments == nil) {
        return @"null";
    }

    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (int i=0; i < [arguments count]; i++) {
        NSString *argument = [arguments objectAtIndex:i];
        if (i > 0) {
            [string appendString:@" "];
        }
        [string appendString:argument];
    }

    return string;
}

/**
 * <p>Lists ongoing executions.
 *
 * @return list of ongoing executions
 */
+ (NSArray*)listExecutions {
    [executionsLock lock];
    NSArray *array = [NSArray arrayWithArray:executions];
    [executionsLock unlock];
    return array;
}

@end
