/*
 * Copyright (c) 2018, 2020 Taner Sener
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

#include <Foundation/Foundation.h>
#include "MediaInformation.h"

@interface MediaInformationParser : NSObject

/**
 * Extracts MediaInformation from the given ffprobe json output.
 */
+ (MediaInformation*)from:(NSString*)ffprobeJsonOutput;

/**
 * Extracts MediaInformation from the given ffprobe json output and saves parsing errors in error parameter.
 */
+ (MediaInformation*)from:(NSString*)ffprobeJsonOutput with:(NSError*)error;

@end
