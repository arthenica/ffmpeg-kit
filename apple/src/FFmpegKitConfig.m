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

#include <sys/types.h>
#include <sys/stat.h>
#include "libavutil/ffversion.h"
#include "fftools_ffmpeg.h"
#include "ArchDetect.h"
#include "FFmpegKitConfig.h"
#include "FFmpegKit.h"

typedef enum {
    LogType = 1,
    StatisticsType = 2
} CallbackType;

/**
 * Callback data class.
 */
@interface CallbackData : NSObject

@end

@implementation CallbackData {

    CallbackType type;
    long executionId;                   // execution id

    int logLevel;                       // log level
    NSString *logData;                  // log data

    int statisticsFrameNumber;          // statistics frame number
    float statisticsFps;                // statistics fps
    float statisticsQuality;            // statistics quality
    int64_t statisticsSize;             // statistics size
    int statisticsTime;                 // statistics time
    double statisticsBitrate;           // statistics bitrate
    double statisticsSpeed;             // statistics speed
}

 - (instancetype)initWithId:(long)currentExecutionId logLevel:(int)newLogLevel data:(NSString*)newData {
    self = [super init];
    if (self) {
        type = LogType;
        executionId = currentExecutionId;
        logLevel = newLogLevel;
        logData = newData;
    }

    return self;
}

 - (instancetype)initWithId:(long)currentExecutionId
                            videoFrameNumber:(int)videoFrameNumber
                            fps:(float)videoFps
                            quality:(float)videoQuality
                            size:(int64_t)size
                            time:(int)time
                            bitrate:(double)bitrate
                            speed:(double)speed {
    self = [super init];
    if (self) {
        type = StatisticsType;
        executionId = currentExecutionId;
        statisticsFrameNumber = videoFrameNumber;
        statisticsFps = videoFps;
        statisticsQuality = videoQuality;
        statisticsSize = size;
        statisticsTime = time;
        statisticsBitrate = bitrate;
        statisticsSpeed = speed;
    }

    return self;
}

- (CallbackType)getType {
    return type;
}

- (long)getExecutionId {
    return executionId;
}

- (int)getLogLevel {
    return logLevel;
}

- (NSString*)getLogData {
    return logData;
}

- (int)getStatisticsFrameNumber {
    return statisticsFrameNumber;
}

- (float)getStatisticsFps {
    return statisticsFps;
}

- (float)getStatisticsQuality {
    return statisticsQuality;
}

- (int64_t)getStatisticsSize {
    return statisticsSize;
}

- (int)getStatisticsTime {
    return statisticsTime;
}

- (double)getStatisticsBitrate {
    return statisticsBitrate;
}

- (double)getStatisticsSpeed {
    return statisticsSpeed;
}

@end

/** Execution map variables */
const int EXECUTION_MAP_SIZE = 1000;
static volatile int executionMap[EXECUTION_MAP_SIZE];
static NSRecursiveLock *executionMapLock;

/** Redirection control variables */
static int redirectionEnabled;
static NSRecursiveLock *lock;
static dispatch_semaphore_t semaphore;
static NSMutableArray *callbackDataArray;

/** Holds delegate defined to redirect logs */
static id<LogDelegate> logDelegate = nil;

/** Holds delegate defined to redirect statistics */
static id<StatisticsDelegate> statisticsDelegate = nil;

/** Common return code values */
int const RETURN_CODE_SUCCESS = 0;
int const RETURN_CODE_CANCEL = 255;

int lastReturnCode;
NSMutableString *lastCommandOutput;

NSString *const LIB_NAME = @"ffmpeg-kit";
NSString *const FFMPEG_KIT_PIPE_PREFIX = @"mf_pipe_";

static Statistics *lastReceivedStatistics = nil;

static NSMutableArray *supportedExternalLibraries;

static int lastCreatedPipeIndex;

/** Fields that control the handling of SIGNALs */
volatile int handleSIGQUIT = 1;
volatile int handleSIGINT = 1;
volatile int handleSIGTERM = 1;
volatile int handleSIGXCPU = 1;
volatile int handleSIGPIPE = 1;

/** Holds the id of the current execution */
__thread volatile long executionId = 0;

/** Holds the default log level */
int configuredLogLevel = AV_LOG_INFO;

void callbackWait(int milliSeconds) {
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(milliSeconds * NSEC_PER_MSEC)));
}

void callbackNotify() {
    dispatch_semaphore_signal(semaphore);
}

/**
 * Adds log data to the end of callback data list.
 *
 * @param level log level
 * @param logData log data
 */
void logCallbackDataAdd(int level, NSString *logData) {
    CallbackData *callbackData = [[CallbackData alloc] initWithId:executionId logLevel:level data:logData];

    [lock lock];
    [callbackDataArray addObject:callbackData];
    [lastCommandOutput appendString:logData];
    [lock unlock];

    callbackNotify();
}

/**
 * Adds statistics data to the end of callback data list.
 */
void statisticsCallbackDataAdd(int frameNumber, float fps, float quality, int64_t size, int time, double bitrate, double speed) {
    CallbackData *callbackData = [[CallbackData alloc] initWithId:executionId videoFrameNumber:frameNumber fps:fps quality:quality size:size time:time bitrate:bitrate speed:speed];

    [lock lock];
    [callbackDataArray addObject:callbackData];
    [lock unlock];

    callbackNotify();
}

/**
 * Adds an execution id to the execution map.
 *
 * @param id execution id
 */
void addExecution(long id) {
    [executionMapLock lock];

    int key = id % EXECUTION_MAP_SIZE;
    executionMap[key] = 1;

    [executionMapLock unlock];
}

/**
 * Removes head of callback data list.
 */
CallbackData *callbackDataRemove() {
    CallbackData *newData = nil;

    [lock lock];

    @try {
        newData = [callbackDataArray objectAtIndex:0];
        [callbackDataArray removeObjectAtIndex:0];
    } @catch(NSException *exception) {
        // DO NOTHING
    } @finally {
        [lock unlock];
    }

    return newData;
}

/**
 * Removes an execution id from the execution map.
 *
 * @param id execution id
 */
void removeExecution(long id) {
    [executionMapLock lock];

    int key = id % EXECUTION_MAP_SIZE;
    executionMap[key] = 0;

    [executionMapLock unlock];
}

/**
 * Checks whether a cancel request for the given execution id exists in the execution map.
 *
 * @param id execution id
 * @return 1 if exists, false otherwise
 */
int cancelRequested(long id) {
    int found = 0;

    [executionMapLock lock];

    int key = id % EXECUTION_MAP_SIZE;
    if (executionMap[key] == 0) {
        found = 1;
    }

    [executionMapLock unlock];

    return found;
}

/**
 * Callback function for FFmpeg logs.
 *
 * @param ptr pointer to AVClass struct
 * @param level log level
 * @param format format string
 * @param vargs arguments
 */
void ffmpegkit_log_callback_function(void *ptr, int level, const char* format, va_list vargs) {

    // DO NOT PROCESS UNWANTED LOGS
    if (level >= 0) {
        level &= 0xff;
    }
    int activeLogLevel = av_log_get_level();

    // AV_LOG_STDERR logs are always redirected
    if ((activeLogLevel == AV_LOG_QUIET && level != AV_LOG_STDERR) || (level > activeLogLevel)) {
        return;
    }

    NSString *logData = [[NSString alloc] initWithFormat:[NSString stringWithCString:format encoding:NSUTF8StringEncoding] arguments:vargs];

    if (logData.length > 0) {
        logCallbackDataAdd(level, logData);
    }
}

/**
 * Callback function for FFmpeg statistics.
 *
 * @param frameNumber last processed frame number
 * @param fps frames processed per second
 * @param quality quality of the output stream (video only)
 * @param size size in bytes
 * @param time processed output duration
 * @param bitrate output bit rate in kbits/s
 * @param speed processing speed = processed duration / operation duration
 */
void ffmpegkit_statistics_callback_function(int frameNumber, float fps, float quality, int64_t size, int time, double bitrate, double speed) {
    statisticsCallbackDataAdd(frameNumber, fps, quality, size, time, bitrate, speed);
}

/**
 * Forwards callback messages to Delegates.
 */
void callbackBlockFunction() {
    int activeLogLevel = av_log_get_level();
    if ((activeLogLevel != AV_LOG_QUIET) && (AV_LOG_DEBUG <= activeLogLevel)) {
        NSLog(@"Async callback block started.\n");
    }

    while(redirectionEnabled) {
        @autoreleasepool {
            @try {

                CallbackData *callbackData = callbackDataRemove();
                if (callbackData != nil) {

                    if ([callbackData getType] == LogType) {

                        // LOG CALLBACK
                        int activeLogLevel = av_log_get_level();
                        int levelValue = [callbackData getLogLevel];

                        if ((activeLogLevel == AV_LOG_QUIET && levelValue != AV_LOG_STDERR) || (levelValue > activeLogLevel)) {

                            // LOG NEITHER PRINTED NOR FORWARDED
                        } else {
                            if (logDelegate != nil) {

                                // FORWARD LOG TO DELEGATE
                                [logDelegate logCallback:[callbackData getExecutionId]:[callbackData getLogLevel]:[callbackData getLogData]];

                            } else {
                                switch (levelValue) {
                                    case AV_LOG_QUIET:
                                        // PRINT NO OUTPUT
                                        break;
                                    default:
                                        // WRITE TO NSLOG
                                        NSLog(@"%@: %@", [FFmpegKitConfig logLevelToString:[callbackData getLogLevel]], [callbackData getLogData]);
                                        break;
                                }
                            }
                        }

                    } else {

                        // STATISTICS CALLBACK
                        Statistics *newStatistics = [[Statistics alloc] initWithId:[callbackData getExecutionId] videoFrameNumber:[callbackData getStatisticsFrameNumber] fps:[callbackData getStatisticsFps] quality:[callbackData getStatisticsQuality] size:[callbackData getStatisticsSize] time:[callbackData getStatisticsTime] bitrate:[callbackData getStatisticsBitrate] speed:[callbackData getStatisticsSpeed]];
                        [lastReceivedStatistics update:newStatistics];

                        if (logDelegate != nil) {

                            // FORWARD STATISTICS TO DELEGATE
                            [statisticsDelegate statisticsCallback:lastReceivedStatistics];
                        }
                    }

                } else {
                    callbackWait(100);
                }

            } @catch(NSException *exception) {
                activeLogLevel = av_log_get_level();
                if ((activeLogLevel != AV_LOG_QUIET) && (AV_LOG_WARNING <= activeLogLevel)) {
                    NSLog(@"Async callback block received error: %@n\n", exception);
                    NSLog(@"%@", [exception callStackSymbols]);
                }
            }
        }
    }

    activeLogLevel = av_log_get_level();
    if ((activeLogLevel != AV_LOG_QUIET) && (AV_LOG_DEBUG <= activeLogLevel)) {
        NSLog(@"Async callback block stopped.\n");
    }
}

@interface FFmpegKitConfig()

/**
 * Returns build configuration for FFmpeg.
 *
 * @return build configuration string
 */
+ (NSString*)getBuildConf;

@end

@implementation FFmpegKitConfig

+ (void)initialize {
    supportedExternalLibraries = [[NSMutableArray alloc] init];
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
    [supportedExternalLibraries addObject:@"wavpack"];
    [supportedExternalLibraries addObject:@"x264"];
    [supportedExternalLibraries addObject:@"x265"];
    [supportedExternalLibraries addObject:@"xvid"];

    for(int i = 0; i<EXECUTION_MAP_SIZE; i++) {
        executionMap[i] = 0;
    }

    [ArchDetect class];
    [FFmpegKit class];

    redirectionEnabled = 0;
    lock = [[NSRecursiveLock alloc] init];
    executionMapLock = [[NSRecursiveLock alloc] init];
    semaphore = dispatch_semaphore_create(0);
    lastReceivedStatistics = [[Statistics alloc] init];
    callbackDataArray = [[NSMutableArray alloc] init];

    lastCreatedPipeIndex = 0;

    lastReturnCode = 0;
    lastCommandOutput = [[NSMutableString alloc] init];

    [FFmpegKitConfig enableRedirection];
}

/**
 * Enables log and statistics redirection.
 */
+ (void)enableRedirection {
    [lock lock];

    if (redirectionEnabled != 0) {
        [lock unlock];
        return;
    }
    redirectionEnabled = 1;

    [lock unlock];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        callbackBlockFunction();
    });

    av_log_set_callback(ffmpegkit_log_callback_function);
    set_report_callback(ffmpegkit_statistics_callback_function);
}

/**
 * Disables log and statistics redirection.
 */
+ (void)disableRedirection {
    [lock lock];

    if (redirectionEnabled != 1) {
        [lock unlock];
        return;
    }
    redirectionEnabled = 0;

    [lock unlock];

    av_log_set_callback(av_log_default_callback);
    set_report_callback(nil);

    callbackNotify();
}

/**
 * Returns log level.
 *
 * @return log level
 */
+ (int)getLogLevel {
    return configuredLogLevel;
}

/**
 * Sets log level.
 *
 * @param level log level
 */
+ (void)setLogLevel:(int)level {
    configuredLogLevel = level;
}

/**
 * Converts int log level to string.
 *
 * @param level value
 * @return string value
 */
+ (NSString*)logLevelToString:(int)level {
    switch (level) {
        case AV_LOG_STDERR: return @"STDERR";
        case AV_LOG_TRACE: return @"TRACE";
        case AV_LOG_DEBUG: return @"DEBUG";
        case AV_LOG_VERBOSE: return @"VERBOSE";
        case AV_LOG_INFO: return @"INFO";
        case AV_LOG_WARNING: return @"WARNING";
        case AV_LOG_ERROR: return @"ERROR";
        case AV_LOG_FATAL: return @"FATAL";
        case AV_LOG_PANIC: return @"PANIC";
        case AV_LOG_QUIET:
        default: return @"";
    }
}

/**
 * Sets a LogDelegate. logCallback method inside LogDelegate is used to redirect logs.
 *
 * @param newLogDelegate new log delegate
 */
+ (void)setLogDelegate:(id<LogDelegate>)newLogDelegate {
    logDelegate = newLogDelegate;
}

/**
 * Sets a StatisticsDelegate.
 *
 * @param newStatisticsDelegate statistics delegate
 */
+ (void)setStatisticsDelegate:(id<StatisticsDelegate>)newStatisticsDelegate {
    statisticsDelegate = newStatisticsDelegate;
}

/**
 * Returns the last received statistics data.
 *
 * @return last received statistics data
 */
+ (Statistics*)getLastReceivedStatistics {
    return lastReceivedStatistics;
}

/**
 * Resets last received statistics.
 */
+ (void)resetStatistics {
    lastReceivedStatistics = [[Statistics alloc] init];
}

/**
 * Sets and overrides fontconfig configuration directory.
 *
 * @param path directory which contains fontconfig configuration (fonts.conf)
 */
+ (void)setFontconfigConfigurationPath:(NSString*)path {
    if (path != nil) {
        setenv("FONTCONFIG_PATH", [path UTF8String], true);
    }
}

/**
 * Registers the fonts inside the given path, so they become available to use in FFmpeg filters.
 *
 * Note that you need to build FFmpegKit with fontconfig enabled or use a prebuilt package with
 * fontconfig inside to use this feature.
 *
 * @param fontDirectoryPath directory which contains fonts (.ttf and .otf files)
 * @param fontNameMapping custom font name mappings, useful to access your fonts with more friendly names
 */
+ (void)setFontDirectory:(NSString*)fontDirectoryPath with:(NSDictionary*)fontNameMapping {
    [FFmpegKitConfig setFontDirectoryList:[NSArray arrayWithObject:fontDirectoryPath] with:fontNameMapping];
}

/**
 * Registers the fonts inside the given array of font directories, so they become available to use
 * in FFmpeg filters.
 *
 * Note that you need to build FFmpegKit with fontconfig enabled or use a prebuilt package with
 * fontconfig inside to use this feature.
 *
 * @param fontDirectoryArray array of directories which contain fonts (.ttf and .otf files)
 * @param fontNameMapping custom font name mappings, useful to access your fonts with more friendly names
 */
+ (void)setFontDirectoryList:(NSArray*)fontDirectoryArray with:(NSDictionary*)fontNameMapping {
    NSError *error = nil;
    BOOL isDirectory = YES;
    BOOL isFile = NO;
    int validFontNameMappingCount = 0;
    NSString *tempConfigurationDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"fontconfig"];
    NSString *fontConfigurationFile = [tempConfigurationDirectory stringByAppendingPathComponent:@"fonts.conf"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:tempConfigurationDirectory isDirectory:&isDirectory]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:tempConfigurationDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to set font directory. Error received while creating temp conf directory: %@.", error);
            return;
        }
        NSLog(@"Created temporary font conf directory: TRUE.");
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:fontConfigurationFile isDirectory:&isFile]) {
        BOOL fontConfigurationDeleted = [[NSFileManager defaultManager] removeItemAtPath:fontConfigurationFile error:NULL];
        NSLog(@"Deleted old temporary font configuration: %s.", fontConfigurationDeleted?"TRUE":"FALSE");
    }

    /* PROCESS MAPPINGS FIRST */
    NSString *fontNameMappingBlock = @"";
    for (NSString *fontName in [fontNameMapping allKeys]) {
        NSString *mappedFontName = [fontNameMapping objectForKey:fontName];

        if ((fontName != nil) && (mappedFontName != nil) && ([fontName length] > 0) && ([mappedFontName length] > 0)) {

            fontNameMappingBlock = [NSString stringWithFormat:@"%@\n%@\n%@%@%@\n%@\n%@\n%@%@%@\n%@\n%@\n",
                @"        <match target=\"pattern\">",
                @"                <test qual=\"any\" name=\"family\">",
                @"                        <string>", fontName, @"</string>",
                @"                </test>",
                @"                <edit name=\"family\" mode=\"assign\" binding=\"same\">",
                @"                        <string>", mappedFontName, @"</string>",
                @"                </edit>",
                @"        </match>"];

            validFontNameMappingCount++;
        }
    }

    NSMutableString *fontConfiguration = [NSMutableString stringWithFormat:@"%@\n%@\n%@\n%@\n",
                            @"<?xml version=\"1.0\"?>",
                            @"<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">",
                            @"<fontconfig>",
                            @"    <dir prefix=\"cwd\">.</dir>"];
    for (int i=0; i < [fontDirectoryArray count]; i++) {
        NSString *fontDirectoryPath = [fontDirectoryArray objectAtIndex:i];
        [fontConfiguration appendString: @"    <dir>"];
        [fontConfiguration appendString: fontDirectoryPath];
        [fontConfiguration appendString: @"</dir>"];
    }
    [fontConfiguration appendString:fontNameMappingBlock];
    [fontConfiguration appendString:@"</fontconfig>"];

    if (![fontConfiguration writeToFile:fontConfigurationFile atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"Failed to set font directory. Error received while saving font configuration: %@.", error);
        return;
    }

    NSLog(@"Saved new temporary font configuration with %d font name mappings.", validFontNameMappingCount);

    [FFmpegKitConfig setFontconfigConfigurationPath:tempConfigurationDirectory];

    for (int i=0; i < [fontDirectoryArray count]; i++) {
        NSString *fontDirectoryPath = [fontDirectoryArray objectAtIndex:i];
        NSLog(@"Font directory %@ registered successfully.", fontDirectoryPath);
    }
}

/**
 * Returns build configuration for FFmpeg.
 *
 * @return build configuration string
 */
+ (NSString*)getBuildConf {
    return [NSString stringWithUTF8String:FFMPEG_CONFIGURATION];
}

/**
 * Returns package name.
 *
 * @return guessed package name according to supported external libraries
 */
+ (NSString*)getPackageName {
    NSArray *enabledLibraryArray = [FFmpegKitConfig getExternalLibraries];
    Boolean speex = [enabledLibraryArray containsObject:@"speex"];
    Boolean fribidi = [enabledLibraryArray containsObject:@"fribidi"];
    Boolean gnutls = [enabledLibraryArray containsObject:@"gnutls"];
    Boolean xvid = [enabledLibraryArray containsObject:@"xvid"];

    Boolean min = false;
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
        } else {
            min = true;
        }
    }

    if (fullGpl) {
        if ([enabledLibraryArray containsObject:@"fontconfig"] &&
            [enabledLibraryArray containsObject:@"freetype"] &&
            [enabledLibraryArray containsObject:@"fribidi"] &&
            [enabledLibraryArray containsObject:@"gmp"] &&
            [enabledLibraryArray containsObject:@"gnutls"] &&
            [enabledLibraryArray containsObject:@"kvazaar"] &&
            [enabledLibraryArray containsObject:@"mp3lame"] &&
            [enabledLibraryArray containsObject:@"libaom"] &&
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
            [enabledLibraryArray containsObject:@"wavpack"] &&
            [enabledLibraryArray containsObject:@"x264"] &&
            [enabledLibraryArray containsObject:@"x265"] &&
            [enabledLibraryArray containsObject:@"xvid"]) {
            return @"full-gpl";
        } else {
            return @"custom";
        }
    }

    if (full) {
        if ([enabledLibraryArray containsObject:@"fontconfig"] &&
            [enabledLibraryArray containsObject:@"freetype"] &&
            [enabledLibraryArray containsObject:@"fribidi"] &&
            [enabledLibraryArray containsObject:@"gmp"] &&
            [enabledLibraryArray containsObject:@"gnutls"] &&
            [enabledLibraryArray containsObject:@"kvazaar"] &&
            [enabledLibraryArray containsObject:@"mp3lame"] &&
            [enabledLibraryArray containsObject:@"libaom"] &&
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
            [enabledLibraryArray containsObject:@"twolame"] &&
            [enabledLibraryArray containsObject:@"wavpack"]) {
            return @"full";
        } else {
            return @"custom";
        }
    }

    if (video) {
        if ([enabledLibraryArray containsObject:@"fontconfig"] &&
            [enabledLibraryArray containsObject:@"freetype"] &&
            [enabledLibraryArray containsObject:@"fribidi"] &&
            [enabledLibraryArray containsObject:@"kvazaar"] &&
            [enabledLibraryArray containsObject:@"libaom"] &&
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
            [enabledLibraryArray containsObject:@"twolame"] &&
            [enabledLibraryArray containsObject:@"wavpack"]) {
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

/**
 * Returns supported external libraries.
 *
 * @return array of supported external libraries
 */
+ (NSArray*)getExternalLibraries {
    NSString *buildConfiguration = [FFmpegKitConfig getBuildConf];
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

/**
 * Creates a new named pipe to use in FFmpeg operations.
 *
 * Please note that creator is responsible of closing created pipes.
 *
 * @return the full path of named pipe
 */
+ (NSString*)registerNewFFmpegPipe {
    NSError *error = nil;
    BOOL isDirectory;

    // PIPES ARE CREATED UNDER THE PIPES DIRECTORY
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pipesDir = [cacheDir stringByAppendingPathComponent:@"pipes"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:pipesDir isDirectory:&isDirectory]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:pipesDir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to create pipes directory: %@. Operation failed with %@.", pipesDir, error);
            return nil;
        }
    }

    NSString *newFFmpegPipePath = [NSString stringWithFormat:@"%@/%@%d", pipesDir, FFMPEG_KIT_PIPE_PREFIX, (++lastCreatedPipeIndex)];

    // FIRST CLOSE OLD PIPES WITH THE SAME NAME
    [FFmpegKitConfig closeFFmpegPipe:newFFmpegPipePath];

    int rc = mkfifo([newFFmpegPipePath UTF8String], S_IRWXU | S_IRWXG | S_IROTH);
    if (rc == 0) {
        return newFFmpegPipePath;
    } else {
        NSLog(@"Failed to register new FFmpeg pipe %@. Operation failed with rc=%d.", newFFmpegPipePath, rc);
        return nil;
    }
}

/**
 * Closes a previously created FFmpeg pipe.
 *
 * @param ffmpegPipePath full path of ffmpeg pipe
 */
+ (void)closeFFmpegPipe:(NSString*)ffmpegPipePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:ffmpegPipePath]){
        [fileManager removeItemAtPath:ffmpegPipePath error:NULL];
    }
}

/**
 * Returns FFmpeg version bundled within the library.
 *
 * @return FFmpeg version string
 */
+ (NSString*)getFFmpegVersion {
    return [NSString stringWithUTF8String:FFMPEG_VERSION];
}

/**
 * Returns FFmpegKit library version.
 *
 * @return FFmpegKit version string
 */
+ (NSString*)getVersion {
    if ([ArchDetect isLTSBuild] == 1) {
        return [NSString stringWithFormat:@"%@-lts", FFMPEG_KIT_VERSION];
    } else {
        return FFMPEG_KIT_VERSION;
    }
}

/**
 * Returns FFmpegKit library build date.
 *
 * @return FFmpegKit library build date
 */
+ (NSString*)getBuildDate {
    char buildDate[10];
    sprintf(buildDate, "%d", FFMPEG_KIT_BUILD_DATE);
    return [NSString stringWithUTF8String:buildDate];
}

/**
 * Returns return code of last executed command.
 *
 * @return return code of last executed command
 */
+ (int)getLastReturnCode {
    return lastReturnCode;
}

/**
 * Returns log output of last executed single FFmpeg/FFprobe command.
 *
 * This method does not support executing multiple concurrent commands. If you execute
 * multiple commands at the same time, this method will return output from all executions.
 *
 * Please note that disabling redirection using FFmpegKitConfig.disableRedirection() method
 * also disables this functionality.
 *
 * @return output of last executed command
 */
+ (NSString*)getLastCommandOutput {
    return lastCommandOutput;
}

/**
 * Registers a new ignored signal. Ignored signals are not handled by the library.
 *
 * @param signum signal number to ignore
 */
+ (void)ignoreSignal:(int)signum {
    if (signum == SIGQUIT) {
        handleSIGQUIT = 0;
    } else if (signum == SIGINT) {
        handleSIGINT = 0;
    } else if (signum == SIGTERM) {
        handleSIGTERM = 0;
    } else if (signum == SIGXCPU) {
        handleSIGXCPU = 0;
    } else if (signum == SIGPIPE) {
        handleSIGPIPE = 0;
    }
}

@end
