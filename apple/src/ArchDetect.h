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

#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>
#include <Foundation/Foundation.h>

/**
 * This class is used to detect running architecture.
 */
@interface ArchDetect : NSObject

/**
 * Returns running cpu architecture name.
 *
 * @return running cpu architecture name as NSString
 */
+ (NSString*)getCpuArch;

/**
 * Returns loaded architecture name.
 *
 * @return loaded architecture name as NSString
 */
+ (NSString*)getArch;

/**
 * Returns whether FFmpegKit release is a long term release or not.
 *
 * @return yes=1 or no=0
 */
+ (int)isLTSBuild;

@end
