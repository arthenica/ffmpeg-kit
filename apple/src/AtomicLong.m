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

#import "AtomicLong.h"

@interface AtomicLong()

@property (strong) NSRecursiveLock* lock;

@end

@implementation AtomicLong {
    long _value;
}

- (instancetype)initWithValue:(long)value {
    self = [super init];
    if (self) {
        _value = value;
        _lock = [[NSRecursiveLock alloc] init];
    }

    return self;
}

- (long)incrementAndGet {
    long returnValue;

    [self.lock lock];
    _value += 1;
    returnValue = _value;
    [self.lock unlock];

    return returnValue;
}

- (long)getAndIncrement {
    long returnValue;

    [self.lock lock];
    returnValue = _value;
    _value += 1;
    [self.lock unlock];

    return returnValue;
}

@end
