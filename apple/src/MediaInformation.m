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

NSString* const MediaKeyMediaProperties =  @"format";
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
    return [self getStringProperty:MediaKeyFilename];
}

- (NSString*)getFormat {
    return [self getStringProperty:MediaKeyFormat];
}

- (NSString*)getLongFormat {
    return [self getStringProperty:MediaKeyFormatLong];
}

- (NSString*)getStartTime {
    return [self getStringProperty:MediaKeyStartTime];
}

- (NSString*)getDuration {
    return [self getStringProperty:MediaKeyDuration];
}

- (NSString*)getSize {
    return [self getStringProperty:MediaKeySize];
}

- (NSString*)getBitrate {
    return [self getStringProperty:MediaKeyBitRate];
}

- (NSDictionary*)getTags {
    return [self getProperties:MediaKeyTags];
}

- (NSArray*)getStreams {
    return streamArray;
}

- (NSArray*)getChapters {
    return chapterArray;
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
    return dictionary[MediaKeyMediaProperties];
}

- (NSDictionary*)getAllProperties {
    return dictionary;
}

@end
