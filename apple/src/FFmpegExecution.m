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

#include "FFmpegExecution.h"
#include "FFmpegKit.h"

@implementation FFmpegExecution {
    NSDate* startTime;
    long executionId;
    NSString* command;
}

- (instancetype)initWithExecutionId:(long)newExecutionId andArguments:(NSArray*)arguments {
    self = [super init];
    if (self) {
        startTime = [NSDate date];
        executionId = newExecutionId;
        command = [FFmpegKit argumentsToString:arguments];
    }

    return self;
}

- (NSDate*)getStartTime {
    return startTime;
}

- (long)getExecutionId {
    return executionId;
}

- (NSString*)getCommand {
    return command;
}

@end