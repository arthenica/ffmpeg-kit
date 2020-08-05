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

#include "StreamInformation.h"

#define KEY_INDEX @"index"
#define KEY_TYPE @"codec_type"
#define KEY_CODEC @"codec_name"
#define KEY_CODEC_LONG @"codec_long_name"
#define KEY_FORMAT @"pix_fmt"
#define KEY_WIDTH @"width"
#define KEY_HEIGHT @"height"
#define KEY_BIT_RATE @"bit_rate"
#define KEY_SAMPLE_RATE @"sample_rate"
#define KEY_SAMPLE_FORMAT @"sample_fmt"
#define KEY_CHANNEL_LAYOUT @"channel_layout"
#define KEY_SAMPLE_ASPECT_RATIO @"sample_aspect_ratio"
#define KEY_DISPLAY_ASPECT_RATIO @"display_aspect_ratio"
#define KEY_AVERAGE_FRAME_RATE @"avg_frame_rate"
#define KEY_REAL_FRAME_RATE @"r_frame_rate"
#define KEY_TIME_BASE @"time_base"
#define KEY_CODEC_TIME_BASE @"codec_time_base"
#define KEY_TAGS @"tags"

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
    return [self getNumberProperty:KEY_INDEX];
}

- (NSString*)getType {
    return [self getStringProperty:KEY_TYPE];
}

- (NSString*)getCodec {
    return [self getStringProperty:KEY_CODEC];
}

- (NSString*)getFullCodec {
    return [self getStringProperty:KEY_CODEC_LONG];
}

- (NSString*)getFormat {
    return [self getStringProperty:KEY_FORMAT];
}

- (NSNumber*)getWidth {
    return [self getNumberProperty:KEY_WIDTH];
}

- (NSNumber*)getHeight {
    return [self getNumberProperty:KEY_HEIGHT];
}

- (NSString*)getBitrate {
    return [self getStringProperty:KEY_BIT_RATE];
}

- (NSString*)getSampleRate {
    return [self getStringProperty:KEY_SAMPLE_RATE];
}

- (NSString*)getSampleFormat {
    return [self getStringProperty:KEY_SAMPLE_FORMAT];
}

- (NSString*)getChannelLayout {
    return [self getStringProperty:KEY_CHANNEL_LAYOUT];
}

- (NSString*)getSampleAspectRatio {
    return [self getStringProperty:KEY_SAMPLE_ASPECT_RATIO];
}

- (NSString*)getDisplayAspectRatio {
    return [self getStringProperty:KEY_DISPLAY_ASPECT_RATIO];
}

- (NSString*)getAverageFrameRate {
    return [self getStringProperty:KEY_AVERAGE_FRAME_RATE];
}

- (NSString*)getRealFrameRate {
    return [self getStringProperty:KEY_REAL_FRAME_RATE];
}

- (NSString*)getTimeBase {
    return [self getStringProperty:KEY_TIME_BASE];
}

- (NSString*)getCodecTimeBase {
    return [self getStringProperty:KEY_CODEC_TIME_BASE];
}

- (NSDictionary*)getTags {
    return [self getProperties:KEY_TAGS];
}

- (NSString*)getStringProperty:(NSString*)key {
    NSDictionary* allProperties = [self getAllProperties];
    if (allProperties == nil) {
        return nil;
    }

    return allProperties[key];
}

- (NSNumber*)getNumberProperty:(NSString*)key {
    NSDictionary* mediaProperties = [self getAllProperties];
    if (mediaProperties == nil) {
        return nil;
    }

    return mediaProperties[key];
}

- (NSDictionary*)getProperties:(NSString*)key {
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
