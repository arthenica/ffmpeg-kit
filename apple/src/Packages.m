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

#import "config.h"
#import "libavutil/ffversion.h"
#import "FFmpegKitConfig.h"
#import "Packages.h"

static NSMutableArray *supportedExternalLibraries;

@implementation Packages

+ (void)initialize {
    supportedExternalLibraries = [[NSMutableArray alloc] init];
    [supportedExternalLibraries addObject:@"dav1d"];
    [supportedExternalLibraries addObject:@"fontconfig"];
    [supportedExternalLibraries addObject:@"freetype"];
    [supportedExternalLibraries addObject:@"fribidi"];
    [supportedExternalLibraries addObject:@"gmp"];
    [supportedExternalLibraries addObject:@"gnutls"];
    [supportedExternalLibraries addObject:@"kvazaar"];
    [supportedExternalLibraries addObject:@"mp3lame"];
    [supportedExternalLibraries addObject:@"libaom"];
    [supportedExternalLibraries addObject:@"libass"];
    [supportedExternalLibraries addObject:@"iconv"];
    [supportedExternalLibraries addObject:@"libilbc"];
    [supportedExternalLibraries addObject:@"libtheora"];
    [supportedExternalLibraries addObject:@"libvidstab"];
    [supportedExternalLibraries addObject:@"libvorbis"];
    [supportedExternalLibraries addObject:@"libvpx"];
    [supportedExternalLibraries addObject:@"libwebp"];
    [supportedExternalLibraries addObject:@"libxml2"];
    [supportedExternalLibraries addObject:@"opencore-amr"];
    [supportedExternalLibraries addObject:@"openh264"];
    [supportedExternalLibraries addObject:@"opus"];
    [supportedExternalLibraries addObject:@"rubberband"];
    [supportedExternalLibraries addObject:@"sdl2"];
    [supportedExternalLibraries addObject:@"shine"];
    [supportedExternalLibraries addObject:@"snappy"];
    [supportedExternalLibraries addObject:@"soxr"];
    [supportedExternalLibraries addObject:@"speex"];
    [supportedExternalLibraries addObject:@"tesseract"];
    [supportedExternalLibraries addObject:@"twolame"];
    [supportedExternalLibraries addObject:@"x264"];
    [supportedExternalLibraries addObject:@"x265"];
    [supportedExternalLibraries addObject:@"xvid"];
}

+ (NSString*)getBuildConf {
    return [NSString stringWithUTF8String:FFMPEG_CONFIGURATION];
}

+ (NSString*)getPackageName {
    NSArray *enabledLibraryArray = [Packages getExternalLibraries];
    Boolean speex = [enabledLibraryArray containsObject:@"speex"];
    Boolean fribidi = [enabledLibraryArray containsObject:@"fribidi"];
    Boolean gnutls = [enabledLibraryArray containsObject:@"gnutls"];
    Boolean xvid = [enabledLibraryArray containsObject:@"xvid"];

    Boolean minGpl = false;
    Boolean https = false;
    Boolean httpsGpl = false;
    Boolean audio = false;
    Boolean video = false;
    Boolean full = false;
    Boolean fullGpl = false;

    if (speex && fribidi) {
        if (xvid) {
            fullGpl = true;
        } else {
            full = true;
        }
    } else if (speex) {
        audio = true;
    } else if (fribidi) {
        video = true;
    } else if (xvid) {
        if (gnutls) {
            httpsGpl = true;
        } else {
            minGpl = true;
        }
    } else {
        if (gnutls) {
            https = true;
        }
    }

    if (fullGpl) {
        if ([enabledLibraryArray containsObject:@"dav1d"] &&
            [enabledLibraryArray containsObject:@"fontconfig"] &&
            [enabledLibraryArray containsObject:@"freetype"] &&
            [enabledLibraryArray containsObject:@"fribidi"] &&
            [enabledLibraryArray containsObject:@"gmp"] &&
            [enabledLibraryArray containsObject:@"gnutls"] &&
            [enabledLibraryArray containsObject:@"kvazaar"] &&
            [enabledLibraryArray containsObject:@"mp3lame"] &&
            [enabledLibraryArray containsObject:@"libass"] &&
            [enabledLibraryArray containsObject:@"iconv"] &&
            [enabledLibraryArray containsObject:@"libilbc"] &&
            [enabledLibraryArray containsObject:@"libtheora"] &&
            [enabledLibraryArray containsObject:@"libvidstab"] &&
            [enabledLibraryArray containsObject:@"libvorbis"] &&
            [enabledLibraryArray containsObject:@"libvpx"] &&
            [enabledLibraryArray containsObject:@"libwebp"] &&
            [enabledLibraryArray containsObject:@"libxml2"] &&
            [enabledLibraryArray containsObject:@"opencore-amr"] &&
            [enabledLibraryArray containsObject:@"opus"] &&
            [enabledLibraryArray containsObject:@"shine"] &&
            [enabledLibraryArray containsObject:@"snappy"] &&
            [enabledLibraryArray containsObject:@"soxr"] &&
            [enabledLibraryArray containsObject:@"speex"] &&
            [enabledLibraryArray containsObject:@"twolame"] &&
            [enabledLibraryArray containsObject:@"x264"] &&
            [enabledLibraryArray containsObject:@"x265"] &&
            [enabledLibraryArray containsObject:@"xvid"]) {
            return @"full-gpl";
        } else {
            return @"custom";
        }
    }

    if (full) {
        if ([enabledLibraryArray containsObject:@"dav1d"] &&
            [enabledLibraryArray containsObject:@"fontconfig"] &&
            [enabledLibraryArray containsObject:@"freetype"] &&
            [enabledLibraryArray containsObject:@"fribidi"] &&
            [enabledLibraryArray containsObject:@"gmp"] &&
            [enabledLibraryArray containsObject:@"gnutls"] &&
            [enabledLibraryArray containsObject:@"kvazaar"] &&
            [enabledLibraryArray containsObject:@"mp3lame"] &&
            [enabledLibraryArray containsObject:@"libass"] &&
            [enabledLibraryArray containsObject:@"iconv"] &&
            [enabledLibraryArray containsObject:@"libilbc"] &&
            [enabledLibraryArray containsObject:@"libtheora"] &&
            [enabledLibraryArray containsObject:@"libvorbis"] &&
            [enabledLibraryArray containsObject:@"libvpx"] &&
            [enabledLibraryArray containsObject:@"libwebp"] &&
            [enabledLibraryArray containsObject:@"libxml2"] &&
            [enabledLibraryArray containsObject:@"opencore-amr"] &&
            [enabledLibraryArray containsObject:@"opus"] &&
            [enabledLibraryArray containsObject:@"shine"] &&
            [enabledLibraryArray containsObject:@"snappy"] &&
            [enabledLibraryArray containsObject:@"soxr"] &&
            [enabledLibraryArray containsObject:@"speex"] &&
            [enabledLibraryArray containsObject:@"twolame"]) {
            return @"full";
        } else {
            return @"custom";
        }
    }

    if (video) {
        if ([enabledLibraryArray containsObject:@"dav1d"] &&
            [enabledLibraryArray containsObject:@"fontconfig"] &&
            [enabledLibraryArray containsObject:@"freetype"] &&
            [enabledLibraryArray containsObject:@"fribidi"] &&
            [enabledLibraryArray containsObject:@"kvazaar"] &&
            [enabledLibraryArray containsObject:@"libass"] &&
            [enabledLibraryArray containsObject:@"iconv"] &&
            [enabledLibraryArray containsObject:@"libtheora"] &&
            [enabledLibraryArray containsObject:@"libvpx"] &&
            [enabledLibraryArray containsObject:@"libwebp"] &&
            [enabledLibraryArray containsObject:@"snappy"]) {
            return @"video";
        } else {
            return @"custom";
        }
    }

    if (audio) {
        if ([enabledLibraryArray containsObject:@"mp3lame"] &&
            [enabledLibraryArray containsObject:@"libilbc"] &&
            [enabledLibraryArray containsObject:@"libvorbis"] &&
            [enabledLibraryArray containsObject:@"opencore-amr"] &&
            [enabledLibraryArray containsObject:@"opus"] &&
            [enabledLibraryArray containsObject:@"shine"] &&
            [enabledLibraryArray containsObject:@"soxr"] &&
            [enabledLibraryArray containsObject:@"speex"] &&
            [enabledLibraryArray containsObject:@"twolame"]) {
            return @"audio";
        } else {
            return @"custom";
        }
    }

    if (httpsGpl) {
        if ([enabledLibraryArray containsObject:@"gmp"] &&
            [enabledLibraryArray containsObject:@"gnutls"] &&
            [enabledLibraryArray containsObject:@"libvidstab"] &&
            [enabledLibraryArray containsObject:@"x264"] &&
            [enabledLibraryArray containsObject:@"x265"] &&
            [enabledLibraryArray containsObject:@"xvid"]) {
            return @"https-gpl";
        } else {
            return @"custom";
        }
    }

    if (https) {
        if ([enabledLibraryArray containsObject:@"gmp"] &&
            [enabledLibraryArray containsObject:@"gnutls"]) {
            return @"https";
        } else {
            return @"custom";
        }
    }

    if (minGpl) {
        if ([enabledLibraryArray containsObject:@"libvidstab"] &&
            [enabledLibraryArray containsObject:@"x264"] &&
            [enabledLibraryArray containsObject:@"x265"] &&
            [enabledLibraryArray containsObject:@"xvid"]) {
            return @"min-gpl";
        } else {
            return @"custom";
        }
    }

    return @"min";
}

+ (NSArray*)getExternalLibraries {
    NSString *buildConfiguration = [Packages getBuildConf];
    NSMutableArray *enabledLibraryArray = [[NSMutableArray alloc] init];

    for (int i=0; i < [supportedExternalLibraries count]; i++) {
        NSString *supportedExternalLibrary = [supportedExternalLibraries objectAtIndex:i];

        NSString *libraryName1 = [NSString stringWithFormat:@"enable-%@", supportedExternalLibrary];
        NSString *libraryName2 = [NSString stringWithFormat:@"enable-lib%@", supportedExternalLibrary];

        if ([buildConfiguration rangeOfString:libraryName1].location != NSNotFound || [buildConfiguration rangeOfString:libraryName2].location != NSNotFound) {
            [enabledLibraryArray addObject:supportedExternalLibrary];
        }
    }

    [enabledLibraryArray sortUsingSelector:@selector(compare:)];

    return enabledLibraryArray;
}

@end
