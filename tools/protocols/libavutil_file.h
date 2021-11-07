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

#ifndef AVUTIL_FILE_FFMPEG_KIT_PROTOCOLS_H
#define AVUTIL_FILE_FFMPEG_KIT_PROTOCOLS_H

typedef int (*saf_open_function)(int);

typedef int (*saf_close_function)(int);

saf_open_function av_get_saf_open(void);

saf_close_function av_get_saf_close(void);

void av_set_saf_open(saf_open_function);

void av_set_saf_close(saf_close_function);

#endif /* AVUTIL_FILE_FFMPEG_KIT_PROTOCOLS_H */
