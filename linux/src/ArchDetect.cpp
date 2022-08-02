/*
 * Copyright (c) 2022 Taner Sener
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

#include "ArchDetect.h"

extern void* ffmpegKitInitialize();

const void* _archDetectInitializer{ffmpegKitInitialize()};

std::string ffmpegkit::ArchDetect::getArch() {
#ifdef FFMPEG_KIT_ARM64
    return "arm64";
#elif FFMPEG_KIT_I386
    return "i386";
#elif FFMPEG_KIT_X86_64
    return "x86_64";
#else
    return "";
#endif
}
