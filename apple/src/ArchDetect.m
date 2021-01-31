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

#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/machine.h>
#import "ArchDetect.h"
#import "FFmpegKitConfig.h"
#import "FFmpegKit.h"
#import "FFprobeKit.h"

@implementation ArchDetect

+ (void)initialize {
    [FFmpegKit class];
    [FFmpegKitConfig class];
    [FFprobeKit class];
}

+ (NSString*)getCpuArch {
    NSMutableString* cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, nil, 0);

    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, nil, 0);

    if (type == CPU_TYPE_X86_64) {
        [cpu appendString:@"x86_64"];

    } else if (type == CPU_TYPE_X86) {
        [cpu appendString:@"x86"];

        switch(subtype) {
            case CPU_SUBTYPE_X86_64_H:
                [cpu appendString:@"_64h"];
            break;
            case CPU_SUBTYPE_X86_64_ALL:
                [cpu appendString:@"_64all"];
            break;
            case CPU_SUBTYPE_X86_ARCH1:
                [cpu appendString:@"_arch1"];
            break;
        }

    } else if (type == CPU_TYPE_I386) {
        [cpu appendString:@"i386"];

    } else if (type == CPU_TYPE_ARM64) {
        [cpu appendString:@"arm64"];

        switch(subtype) {
            case CPU_SUBTYPE_ARM64_V8:
                [cpu appendString:@"v8"];
            break;

            #if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 120100
            case CPU_SUBTYPE_ARM64E:
                [cpu appendString:@"e"];
            break;
            #endif

        }

    } else if (type == CPU_TYPE_ARM) {
        [cpu appendString:@"arm"];

        switch(subtype) {
            case CPU_SUBTYPE_ARM_XSCALE:
                [cpu appendString:@"xscale"];
            break;
            case CPU_SUBTYPE_ARM_V4T:
                [cpu appendString:@"v4t"];
            break;
            case CPU_SUBTYPE_ARM_V5TEJ:
                [cpu appendString:@"v5tej"];
            break;
            case CPU_SUBTYPE_ARM_V6:
                [cpu appendString:@"v6"];
            break;
            case CPU_SUBTYPE_ARM_V6M:
                [cpu appendString:@"v6m"];
            break;
            case CPU_SUBTYPE_ARM_V7:
                [cpu appendString:@"v7"];
            break;
            case CPU_SUBTYPE_ARM_V7EM:
                [cpu appendString:@"v7em"];
            break;
            case CPU_SUBTYPE_ARM_V7F:
                [cpu appendString:@"v7f"];
            break;
            case CPU_SUBTYPE_ARM_V7K:
                [cpu appendString:@"v7k"];
            break;
            case CPU_SUBTYPE_ARM_V7M:
                [cpu appendString:@"v7m"];
            break;
            case CPU_SUBTYPE_ARM_V7S:
                [cpu appendString:@"v7s"];
            break;
#ifndef FFMPEG_KIT_LTS
            case CPU_SUBTYPE_ARM_V8:
                [cpu appendString:@"v8"];
            break;
#endif
        }

    #if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 120100
    } else if (type == CPU_TYPE_ARM64_32) {
        [cpu appendString:@"arm64_32"];

        switch(subtype) {
            case CPU_SUBTYPE_ARM64_32_V8:
                [cpu appendString:@"v8"];
            break;
        }
    #endif

    } else {
        [cpu appendString:[NSString stringWithFormat:@"%d", type]];
    }

    return cpu;
}

+ (NSString*)getArch {
    NSMutableString *arch = [[NSMutableString alloc] init];

#ifdef FFMPEG_KIT_ARMV7
    [arch appendString:@"armv7"];
#elif FFMPEG_KIT_ARMV7S
    [arch appendString:@"armv7s"];
#elif FFMPEG_KIT_ARM64
    [arch appendString:@"arm64"];
#elif FFMPEG_KIT_ARM64_MAC_CATALYST
    [arch appendString:@"arm64_mac_catalyst"];
#elif FFMPEG_KIT_ARM64_SIMULATOR
    [arch appendString:@"arm64_simulator"];
#elif FFMPEG_KIT_ARM64E
    [arch appendString:@"arm64e"];
#elif FFMPEG_KIT_I386
    [arch appendString:@"i386"];
#elif FFMPEG_KIT_X86_64
    [arch appendString:@"x86_64"];
#elif FFMPEG_KIT_X86_64_MAC_CATALYST
    [arch appendString:@"x86_64_mac_catalyst"];
#endif

    return arch;
}

@end
