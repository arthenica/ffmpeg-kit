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

#import "MediaInformation.h"

NSString* const MediaKeyFormatProperties =  @"format";
NSString* const MediaKeyFilename = @"filename";
NSString* const MediaKeyFormat = @"format_name";
NSString* const MediaKeyFormatLong = @"format_long_name";
NSString* const MediaKeyStartTime = @"start_time";
NSString* const MediaKeyDuration = @"duration";
NSString* const MediaKeySize = @"size";
NSString* const MediaKeyBitRate = @"bit_rate";
NSString* const MediaKeyTags = @"tags";

@implementation MediaInformation {

    /**
     * Stores all properties.
     */
    NSDictionary *dictionary;

    /**
     * Stores streams.
     */
    NSArray *streamArray;

    /**
     * Stores chapters.
     */
    NSArray *chapterArray;

}

- (instancetype)init:(NSDictionary*)mediaDictionary withStreams:(NSArray*)streams withChapters:(NSArray*)chapters{
    self = [super init];
    if (self) {
        dictionary = mediaDictionary;
        streamArray = streams;
        chapterArray = chapters;
    }

    return self;
}

- (NSString*)getFilename {
    return [self getStringFormatProperty:MediaKeyFilename];
}

- (NSString*)getFormat {
    return [self getStringFormatProperty:MediaKeyFormat];
}

- (NSString*)getLongFormat {
    return [self getStringFormatProperty:MediaKeyFormatLong];
}

- (NSString*)getStartTime {
    return [self getStringFormatProperty:MediaKeyStartTime];
}

- (NSString*)getDuration {
    return [self getStringFormatProperty:MediaKeyDuration];
}

- (NSString*)getSize {
    return [self getStringFormatProperty:MediaKeySize];
}

- (NSString*)getBitrate {
    return [self getStringFormatProperty:MediaKeyBitRate];
}

- (NSDictionary*)getTags {
    return [self getFormatProperty:MediaKeyTags];
}

- (NSArray*)getStreams {
    return streamArray;
}

- (NSArray*)getChapters {
    return chapterArray;
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

- (NSString*)getStringFormatProperty:(NSString*)key {
    NSDictionary* formatProperties = [self getFormatProperties];
    if (formatProperties == nil) {
        return nil;
    }

    return formatProperties[key];
}

- (NSNumber*)getNumberFormatProperty:(NSString*)key {
    NSDictionary* formatProperties = [self getFormatProperties];
    if (formatProperties == nil) {
        return nil;
    }

    return formatProperties[key];
}

- (id)getFormatProperty:(NSString*)key {
    NSDictionary* formatProperties = [self getFormatProperties];
    if (formatProperties == nil) {
        return nil;
    }

    return formatProperties[key];
}

- (NSDictionary*)getFormatProperties {
    return dictionary[MediaKeyFormatProperties];
}

- (NSDictionary*)getAllProperties {
    return dictionary;
}

@end
