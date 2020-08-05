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

#include "AtomicLong.h"

@implementation AtomicLong {
    NSRecursiveLock *lock;
    long value;
}

- (instancetype)initWithInitialValue:(long)initialValue {
    self = [super init];
    if (self) {
        value = initialValue;
    }

    return self;
}

- (long)incrementAndGet {
    long returnValue;

    [lock lock];
    value += 1;
    returnValue = value;
    [lock unlock];

    return returnValue;
}

@end
