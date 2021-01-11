/*
 * Copyright (c) 2020-2021 Taner Sener
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

#ifndef FFMPEG_KIT_SAF_WRAPPER_H
#define FFMPEG_KIT_SAF_WRAPPER_H

/*
 *  These wrappers are intended to be used instead of the ffmpeg apis.
 *  You don't even need to change the source to call them.
 *  Instead, we redefine the public api names so that the wrapper be used.
 */

int android_avio_closep(AVIOContext **s);
#define avio_closep android_avio_closep

void android_avformat_close_input(AVFormatContext **s);
#define avformat_close_input android_avformat_close_input

int android_avio_open(AVIOContext **s, const char *url, int flags);
#define avio_open android_avio_open

int android_avio_open2(AVIOContext **s, const char *url, int flags,
               const AVIOInterruptCB *int_cb, AVDictionary **options);
#define avio_open2 android_avio_open2

int android_avformat_open_input(AVFormatContext **ps, const char *filename,
                        ff_const59 AVInputFormat *fmt, AVDictionary **options);
#define avformat_open_input android_avformat_open_input

#endif //FFMPEG_KIT_SAF_WRAPPER_H
