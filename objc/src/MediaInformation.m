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

#include "MediaInformation.h"

#define KEY_MEDIA_PROPERTIES @"format"
#define KEY_FILENAME @"filename"
#define KEY_FORMAT @"format_name"
#define KEY_FORMAT_LONG @"format_long_name"
#define KEY_START_TIME @"start_time"
#define KEY_DURATION @"duration"
#define KEY_SIZE @"size"
#define KEY_BIT_RATE @"bit_rate"
#define KEY_TAGS @"tags"

@implementation MediaInformation {

    /**
     * Stores all properties.
     */
    NSDictionary *dictionary;

    /**
     * Stores streams.
     */
    NSArray *streamArray;

}

- (instancetype)init:(NSDictionary*)mediaDictionary withStreams:(NSArray*)streams{
    self = [super init];
    if (self) {
        dictionary = mediaDictionary;
        streamArray = streams;
    }

    return self;
}

- (NSString*)getFilename {
    return [self getStringProperty:KEY_FILENAME];
}

- (NSString*)getFormat {
    return [self getStringProperty:KEY_FORMAT];
}

- (NSString*)getLongFormat {
    return [self getStringProperty:KEY_FORMAT_LONG];
}

- (NSString*)getStartTime {
    return [self getStringProperty:KEY_START_TIME];
}

- (NSString*)getDuration {
    return [self getStringProperty:KEY_DURATION];
}

- (NSString*)getSize {
    return [self getStringProperty:KEY_SIZE];
}

- (NSString*)getBitrate {
    return [self getStringProperty:KEY_BIT_RATE];
}

- (NSDictionary*)getTags {
    return [self getProperties:KEY_TAGS];
}

- (NSArray*)getStreams {
    return streamArray;
}

- (NSString*)getStringProperty:(NSString*)key {
    NSDictionary* mediaProperties = [self getMediaProperties];
    if (mediaProperties == nil) {
        return nil;
    }

    return mediaProperties[key];
}

- (NSNumber*)getNumberProperty:(NSString*)key {
    NSDictionary* mediaProperties = [self getMediaProperties];
    if (mediaProperties == nil) {
        return nil;
    }

    return mediaProperties[key];
}

- (NSDictionary*)getProperties:(NSString*)key {
    NSDictionary* mediaProperties = [self getMediaProperties];
    if (mediaProperties == nil) {
        return nil;
    }

    return mediaProperties[key];
}

- (NSDictionary*)getMediaProperties {
    return dictionary[KEY_MEDIA_PROPERTIES];
}

- (NSDictionary*)getAllProperties {
    return dictionary;
}

@end
