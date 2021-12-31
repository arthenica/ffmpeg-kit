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

#import "FFprobeSession.h"
#import "FFmpegKitConfig.h"
#import "LogCallback.h"

@implementation FFprobeSession {
    FFprobeSessionCompleteCallback _completeCallback;
}

+ (void)initialize {
    // EMPTY INITIALIZE
}

- (instancetype)init:(NSArray*)arguments {

    self = [super init:arguments withLogCallback:nil withLogRedirectionStrategy:[FFmpegKitConfig getLogRedirectionStrategy]];

    if (self) {
        _completeCallback = nil;
    }

    return self;
}

- (instancetype)init:(NSArray*)arguments withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback {

    self = [super init:arguments withLogCallback:nil withLogRedirectionStrategy:[FFmpegKitConfig getLogRedirectionStrategy]];

    if (self) {
        _completeCallback = completeCallback;
    }

    return self;
}

- (instancetype)init:(NSArray*)arguments withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback {

    self = [super init:arguments withLogCallback:logCallback withLogRedirectionStrategy:[FFmpegKitConfig getLogRedirectionStrategy]];

    if (self) {
        _completeCallback = completeCallback;
    }

    return self;
}

- (instancetype)init:(NSArray*)arguments withCompleteCallback:(FFprobeSessionCompleteCallback)completeCallback withLogCallback:(LogCallback)logCallback withLogRedirectionStrategy:(LogRedirectionStrategy)logRedirectionStrategy {

    self = [super init:arguments withLogCallback:logCallback withLogRedirectionStrategy:logRedirectionStrategy];

    if (self) {
        _completeCallback = completeCallback;
    }

    return self;
}

- (FFprobeSessionCompleteCallback)getCompleteCallback {
    return _completeCallback;
}

- (BOOL)isFFmpeg {
    return false;
}

- (BOOL)isFFprobe {
    return true;
}

- (BOOL)isMediaInformation {
    return false;
}

@end

