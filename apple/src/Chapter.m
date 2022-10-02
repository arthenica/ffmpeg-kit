/*
 * Copyright (c) 2021 Taner Sener
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

#import "Chapter.h"

NSString* const ChapterKeyId = @"id";
NSString* const ChapterKeyTimeBase = @"time_base";
NSString* const ChapterKeyStart = @"start";
NSString* const ChapterKeyStartTime = @"start_time";
NSString* const ChapterKeyEnd = @"end";
NSString* const ChapterKeyEndTime = @"end_time";
NSString* const ChapterKeyTags = @"tags";

@implementation Chapter {

    /**
     * Stores all properties.
     */
    NSDictionary *dictionary;

}

- (instancetype)init:(NSDictionary*)chapterDictionary {
    self = [super init];
    if (self) {
        dictionary = chapterDictionary;
    }

    return self;
}

- (NSNumber*)getId {
    return [self getNumberProperty:ChapterKeyId];
}

- (NSString*)getTimeBase {
    return [self getStringProperty:ChapterKeyTimeBase];
}

- (NSNumber*)getStart {
    return [self getNumberProperty:ChapterKeyStart];
}

- (NSString*)getStartTime {
    return [self getStringProperty:ChapterKeyStartTime];
}

- (NSNumber*)getEnd {
    return [self getNumberProperty:ChapterKeyEnd];
}

- (NSString*)getEndTime {
    return [self getStringProperty:ChapterKeyEndTime];
}

- (NSDictionary*)getTags {
    return [self getProperty:ChapterKeyTags];
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
