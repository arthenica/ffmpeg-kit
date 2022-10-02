/*
 * Copyright (c) 2018-2022 Taner Sener
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

#import "StreamInformation.h"

NSString* const StreamKeyIndex = @"index";
NSString* const StreamKeyType = @"codec_type";
NSString* const StreamKeyCodec = @"codec_name";
NSString* const StreamKeyCodecLong = @"codec_long_name";
NSString* const StreamKeyFormat = @"pix_fmt";
NSString* const StreamKeyWidth = @"width";
NSString* const StreamKeyHeight = @"height";
NSString* const StreamKeyBitRate = @"bit_rate";
NSString* const StreamKeySampleRate = @"sample_rate";
NSString* const StreamKeySampleFormat = @"sample_fmt";
NSString* const StreamKeyChannelLayout = @"channel_layout";
NSString* const StreamKeySampleAspectRatio = @"sample_aspect_ratio";
NSString* const StreamKeyDisplayAspectRatio = @"display_aspect_ratio";
NSString* const StreamKeyAverageFrameRate = @"avg_frame_rate";
NSString* const StreamKeyRealFrameRate = @"r_frame_rate";
NSString* const StreamKeyTimeBase = @"time_base";
NSString* const StreamKeyCodecTimeBase = @"codec_time_base";
NSString* const StreamKeyTags = @"tags";

@implementation StreamInformation {

    /**
     * Stores all properties.
     */
    NSDictionary *dictionary;

}

- (instancetype)init:(NSDictionary*)streamDictionary {
    self = [super init];
    if (self) {
        dictionary = streamDictionary;
    }

    return self;
}

- (NSNumber*)getIndex {
    return [self getNumberProperty:StreamKeyIndex];
}

- (NSString*)getType {
    return [self getStringProperty:StreamKeyType];
}

- (NSString*)getCodec {
    return [self getStringProperty:StreamKeyCodec];
}

- (NSString*)getCodecLong {
    return [self getStringProperty:StreamKeyCodecLong];
}

- (NSString*)getFormat {
    return [self getStringProperty:StreamKeyFormat];
}

- (NSNumber*)getWidth {
    return [self getNumberProperty:StreamKeyWidth];
}

- (NSNumber*)getHeight {
    return [self getNumberProperty:StreamKeyHeight];
}

- (NSString*)getBitrate {
    return [self getStringProperty:StreamKeyBitRate];
}

- (NSString*)getSampleRate {
    return [self getStringProperty:StreamKeySampleRate];
}

- (NSString*)getSampleFormat {
    return [self getStringProperty:StreamKeySampleFormat];
}

- (NSString*)getChannelLayout {
    return [self getStringProperty:StreamKeyChannelLayout];
}

- (NSString*)getSampleAspectRatio {
    return [self getStringProperty:StreamKeySampleAspectRatio];
}

- (NSString*)getDisplayAspectRatio {
    return [self getStringProperty:StreamKeyDisplayAspectRatio];
}

- (NSString*)getAverageFrameRate {
    return [self getStringProperty:StreamKeyAverageFrameRate];
}

- (NSString*)getRealFrameRate {
    return [self getStringProperty:StreamKeyRealFrameRate];
}

- (NSString*)getTimeBase {
    return [self getStringProperty:StreamKeyTimeBase];
}

- (NSString*)getCodecTimeBase {
    return [self getStringProperty:StreamKeyCodecTimeBase];
}

- (NSDictionary*)getTags {
    return [self getProperty:StreamKeyTags];
}

- (NSString*)getStringProperty:(NSString*)key {
    NSDictionary* allProperties = [self getAllProperties];
    if (allProperties == nil) {
        return nil;
    }

    return allProperties[key];
}

- (NSNumber*)getNumberProperty:(NSString*)key {
    NSDictionary* allProperties = [self getAllProperties];
    if (allProperties == nil) {
        return nil;
    }

    return allProperties[key];
}

- (id)getProperty:(NSString*)key {
    NSDictionary* allProperties = [self getAllProperties];
    if (allProperties == nil) {
        return nil;
    }

    return allProperties[key];
}

- (NSDictionary*)getAllProperties {
    return dictionary;
}

@end
