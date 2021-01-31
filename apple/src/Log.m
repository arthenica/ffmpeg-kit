/*
 * Copyright (c) 2021 Taner Sener
 *
 * This file is part of FFmpegKit.
 *
 * FFmpegKit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FFmpegKit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General License for more details.
 *
 *  You should have received a copy of the GNU Lesser General License
 *  along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Log.h"

@implementation Log {
    long _sessionId;
    int _level;
    NSString *_message;
}

- (instancetype)init:(long)sessionId :(int)level :(NSString*)message {
    self = [super init];
    if (self) {
        _sessionId = sessionId;
        _level = level;
        _message = message;
    }

    return self;
}

- (long)getSessionId {
    return _sessionId;
}

- (int)getLevel {
    return _level;
}

- (NSString*)getMessage {
    return _message;
}

@end
