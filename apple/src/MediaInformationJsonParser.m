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

#import "MediaInformationJsonParser.h"

NSString* const MediaInformationJsonParserKeyStreams =  @"streams";
NSString* const MediaInformationJsonParserKeyChapters = @"chapters";

@implementation MediaInformationJsonParser

+ (MediaInformation*)from:(NSString*)ffprobeJsonOutput {
    @try {
        return [self fromWithError:ffprobeJsonOutput];
    } @catch (NSException *exception) {
        NSLog(@"MediaInformation parsing failed: %@.\n", [NSString stringWithFormat:@"%@\n%@", [exception userInfo], [exception callStackSymbols]]);
        return nil;
    }
}

+ (MediaInformation*)fromWithError:(NSString*)ffprobeJsonOutput {
    NSError* error = nil;
    NSData *jsonData = [ffprobeJsonOutput dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error != nil) {
        @throw [NSException exceptionWithName:@"ParsingException" reason:[NSString stringWithFormat:@"%ld",(long)[error code]] userInfo:[error userInfo]];
    }
    if (jsonDictionary == nil) {
        return nil;
    }

    NSArray* jsonStreamArray = [jsonDictionary objectForKey:MediaInformationJsonParserKeyStreams];
    NSMutableArray *streamArray = [[NSMutableArray alloc] init];
    for(int i = 0; i<jsonStreamArray.count; i++) {
        NSDictionary *streamDictionary = [jsonStreamArray objectAtIndex:i];
        [streamArray addObject:[[StreamInformation alloc] init:streamDictionary]];
    }

    NSArray* jsonChapterArray = [jsonDictionary objectForKey:MediaInformationJsonParserKeyChapters];
    NSMutableArray *chapterArray = [[NSMutableArray alloc] init];
    for(int i = 0; i<jsonChapterArray.count; i++) {
        NSDictionary *chapterDictionary = [jsonChapterArray objectAtIndex:i];
        [chapterArray addObject:[[Chapter alloc] init:chapterDictionary]];
    }

    return [[MediaInformation alloc] init:jsonDictionary withStreams:streamArray withChapters:chapterArray];
}

@end
