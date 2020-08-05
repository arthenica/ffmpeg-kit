/*
 * Copyright (c) 2020 Taner Sener
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

#include "MediaInformationParser.h"

/**
 * Main class for FFprobe operations.
 */
@interface FFprobeKit : NSObject

/**
 * Synchronously executes FFprobe with arguments provided.
 *
 * @param arguments FFprobe command options/arguments as string array
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)executeWithArguments:(NSArray*)arguments;

/**
 * Synchronously executes FFprobe command provided. Space character is used to split command
 * into arguments.
 *
 * @param command FFprobe command
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)execute:(NSString*)command;

/**
 * Returns media information for the given file.
 *
 * This method does not support executing multiple concurrent operations. If you execute
 * multiple operations (execute or getMediaInformation) at the same time, the response of this
 * method is not predictable.
 *
 * @param path or uri of media file
 * @return media information
 */
+ (MediaInformation*)getMediaInformation:(NSString*)path;

/**
 * Returns media information for the given command.
 *
 * This method does not support executing multiple concurrent operations. If you execute
 * multiple operations (execute or getMediaInformation) at the same time, the response of this
 * method is not predictable.
 *
 * @param command ffprobe command
 * @return media information
 */
+ (MediaInformation*)getMediaInformationFromCommand:(NSString*)command;

/**
 * Returns media information for given file.
 *
 * This method does not support executing multiple concurrent operations. If you execute
 * multiple operations (execute or getMediaInformation) at the same time, the response of this
 * method is not predictable.
 *
 * @param path path or uri of media file
 * @param timeout complete timeout
 * @deprecated this method is deprecated since v4.3.1. You can still use this method but
 * timeout parameter is not effective anymore.
 * @return media information
 */
+ (MediaInformation*)getMediaInformation:(NSString*)path timeout:(long)timeout __attribute__((deprecated));

@end