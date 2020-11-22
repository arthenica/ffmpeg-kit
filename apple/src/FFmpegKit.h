/*
 * Copyright (c) 2018-2020 Taner Sener
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

#include <string.h>
#include <stdlib.h>
#include <Foundation/Foundation.h>
#include "ExecuteDelegate.h"

/** Global library version */
extern NSString *const FFMPEG_KIT_VERSION;

/**
 * Main class for FFmpeg operations.
 */
@interface FFmpegKit : NSObject

/**
 * Synchronously executes FFmpeg with arguments provided.
 *
 * @param arguments FFmpeg command options/arguments as string array
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)executeWithArguments:(NSArray*)arguments;

/**
 * Asynchronously executes FFmpeg with arguments provided. Space character is used to split command into arguments.
 *
 * @param arguments FFmpeg command options/arguments as string array
 * @param delegate delegate that will be notified when execution is completed
 * @return returns a unique id that represents this execution
 */
+ (int)executeWithArgumentsAsync:(NSArray*)arguments withCallback:(id<ExecuteDelegate>)delegate;

/**
 * Asynchronously executes FFmpeg with arguments provided. Space character is used to split command into arguments.
 *
 * @param arguments FFmpeg command options/arguments as string array
 * @param delegate delegate that will be notified when execution is completed
 * @param queue dispatch queue that will be used to run this asynchronous operation
 * @return returns a unique id that represents this execution
 */
+ (int)executeWithArgumentsAsync:(NSArray*)arguments withCallback:(id<ExecuteDelegate>)delegate andDispatchQueue:(dispatch_queue_t)queue;

/**
 * Synchronously executes FFmpeg command provided. Space character is used to split command into arguments.
 *
 * @param command FFmpeg command
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)execute:(NSString*)command;

/**
 * Asynchronously executes FFmpeg command provided. Space character is used to split command into arguments.
 *
 * @param command FFmpeg command
 * @param delegate delegate that will be notified when execution is completed
 * @return returns a unique id that represents this execution
 */
+ (int)executeAsync:(NSString*)command withCallback:(id<ExecuteDelegate>)delegate;

/**
 * Asynchronously executes FFmpeg command provided. Space character is used to split command into arguments.
 *
 * @param command FFmpeg command
 * @param delegate delegate that will be notified when execution is completed
 * @param queue dispatch queue that will be used to run this asynchronous operation
 * @return returns a unique id that represents this execution
 */
+ (int)executeAsync:(NSString*)command withCallback:(id<ExecuteDelegate>)delegate andDispatchQueue:(dispatch_queue_t)queue;

/**
 * Synchronously executes FFmpeg command provided. Delimiter parameter is used to split command into arguments.
 *
 * @param command FFmpeg command
 * @param delimiter arguments delimiter
 * @deprecated argument splitting mechanism used in this method is pretty simple and prone to errors. Consider
 * using a more advanced method like execute or executeWithArguments
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)execute:(NSString*)command delimiter:(NSString*)delimiter __attribute__((deprecated));

/**
 * Cancels an ongoing operation.
 *
 * This function does not wait for termination to complete and returns immediately.
 */
+ (void)cancel;

/**
 * Cancels an ongoing operation.
 *
 * This function does not wait for termination to complete and returns immediately.
 *
 * @param executionId execution id
 */
+ (void)cancel:(long)executionId;

/**
 * Parses the given command into arguments.
 *
 * @param command string command
 * @return array of arguments
 */
+ (NSArray*)parseArguments:(NSString*)command;

/**
 * <p>Combines arguments into a string.
 *
 * @param arguments arguments
 * @return string containing all arguments
 */
+ (NSString*)argumentsToString:(NSArray*)arguments;

/**
 * <p>Lists ongoing executions.
 *
 * @return list of ongoing executions
 */
+ (NSArray*)listExecutions;

@end