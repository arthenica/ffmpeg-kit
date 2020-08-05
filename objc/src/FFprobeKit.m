/*
 * Copyright (c) 2020 Taner Sener
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

#include "libavutil/ffversion.h"
#include "fftools_ffmpeg.h"

#include "FFmpegKit.h"
#include "FFmpegKitConfig.h"
#include "FFprobeKit.h"

/** Forward declaration for function defined in fftools_ffprobe.c */
int ffprobe_execute(int argc, char **argv);

@implementation FFprobeKit

extern int lastReturnCode;
extern NSMutableString *lastCommandOutput;
extern int configuredLogLevel;

+ (void)initialize {
    [FFmpegKitConfig class];
}

/**
 * Synchronously executes FFprobe with arguments provided.
 *
 * @param arguments FFprobe command options/arguments as string array
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)executeWithArguments:(NSArray*)arguments {
    lastCommandOutput = [[NSMutableString alloc] init];

    // SETS DEFAULT LOG LEVEL BEFORE STARTING A NEW EXECUTION
    av_log_set_level(configuredLogLevel);

    char **commandCharPArray = (char **)av_malloc(sizeof(char*) * ([arguments count] + 1));

    /* PRESERVING CALLING FORMAT
     *
     * ffprobe <arguments>
     */
    commandCharPArray[0] = (char *)av_malloc(sizeof(char) * ([LIB_NAME length] + 1));
    strcpy(commandCharPArray[0], [LIB_NAME UTF8String]);

    for (int i=0; i < [arguments count]; i++) {
        NSString *argument = [arguments objectAtIndex:i];
        commandCharPArray[i + 1] = (char *) [argument UTF8String];
    }

    // RUN
    lastReturnCode = ffprobe_execute(([arguments count] + 1), commandCharPArray);

    // CLEANUP
    av_free(commandCharPArray[0]);
    av_free(commandCharPArray);

    return lastReturnCode;
}

/**
 * Synchronously executes FFprobe command provided. Space character is used to split command
 * into arguments.
 *
 * @param command FFprobe command
 * @return zero on successful execution, 255 on user cancel and non-zero on error
 */
+ (int)execute:(NSString*)command {
    return [FFprobeKit executeWithArguments: [FFmpegKit parseArguments: command]];
}

/**
 * Returns media information for the given file.
 *
 * This method does not support executing multiple concurrent operations. If you execute
 * multiple operations (execute or getMediaInformation) at the same time, the response of this
 * method is not predictable.
 *
 * @param path or uri of media file
 * @return media information
 */
+ (MediaInformation*)getMediaInformation:(NSString*)path {
    return [FFprobeKit getMediaInformationFromCommandArguments:[[NSArray alloc] initWithObjects:@"-v", @"error", @"-hide_banner", @"-print_format", @"json", @"-show_format", @"-show_streams", @"-i", path, nil]];
}

/**
 * Returns media information for the given command.
 *
 * This method does not support executing multiple concurrent operations. If you execute
 * multiple operations (execute or getMediaInformation) at the same time, the response of this
 * method is not predictable.
 *
 * @param command
 * @return media information
 */
+ (MediaInformation*)getMediaInformationFromCommand:(NSString*)command {
    return [FFprobeKit getMediaInformationFromCommandArguments:[FFmpegKit parseArguments: command]];
}

/**
 * Returns media information for given file.
 *
 * This method does not support executing multiple concurrent operations. If you execute
 * multiple operations (execute or getMediaInformation) at the same time, the response of this
 * method is not predictable.
 *
 * @param path path or uri of media file
 * @param timeout complete timeout
 * @deprecated this method is deprecated since v4.3.1. You can still use this method but
 * timeout parameter is not effective anymore.
 * @return media information
 */
+ (MediaInformation*)getMediaInformation:(NSString*)path timeout:(long)timeout {
    return [FFprobeKit getMediaInformation:path];
}

+ (MediaInformation*)getMediaInformationFromCommandArguments:(NSArray*)arguments {
    int rc = [FFprobeKit executeWithArguments:arguments];

    if (rc == 0) {
        return [MediaInformationParser from:[FFmpegKitConfig getLastCommandOutput]];
    } else {
        int activeLogLevel = av_log_get_level();
        if ((activeLogLevel != AV_LOG_QUIET) && (AV_LOG_WARNING <= activeLogLevel)) {
            NSLog(@"%@", [FFmpegKitConfig getLastCommandOutput]);
        }

        return nil;
    }
}

@end
