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

#include <sys/stat.h>
#include <stdlib.h>
#include <unistd.h>

#include "config.h"
#include "libavformat/avformat.h"
#include "libavutil/avstring.h"

#include "saf_wrapper.h"

/** JNI wrapper in ffmpegkit.c */
void closeParcelFileDescriptor(int fd);

// in these wrappers, we call the original functions, so we remove the shadow defines
#undef avio_closep
#undef avformat_close_input
#undef avio_open
#undef avio_open2
#undef avformat_open_input

static int fd_read_packet(void* opaque, uint8_t* buf, int buf_size) {
    int *fd = opaque;
    return read(*fd, buf, buf_size);
}

static int fd_write_packet(void* opaque, uint8_t* buf, int buf_size) {
    int *fd = opaque;
    return write(*fd, buf, buf_size);
}

static int64_t fd_seek(void *opaque, int64_t offset, int whence) {
    int *fd = opaque;

    if (*fd < 0) {
        return AVERROR(EINVAL);
    }

    int64_t ret;
    if (whence == AVSEEK_SIZE) {
        struct stat st;
        ret = fstat(*fd, &st);
        return ret < 0 ? AVERROR(errno) : (S_ISFIFO(st.st_mode) ? 0 : st.st_size);
    }

    ret = lseek(*fd, offset, whence);

    return ret < 0 ? AVERROR(errno) : ret;
}

/*
 * returns NULL if the filename is not of expected format (e.g. 'saf:72/video.md4')
 */
static AVIOContext *create_fd_avio_context(const char *filename, int flags) {
    int *fd = av_mallocz(sizeof(int));
    *fd = -1;
    const char *fd_ptr = NULL;
    if (av_strstart(filename, "saf:", &fd_ptr)) {
        char *final;
        *fd = strtol(fd_ptr, &final, 10);
        if (fd_ptr == final) { /* No digits found */
            *fd = -1;
        }
    }

    if (*fd >= 0) {
        int write_flag = flags & AVIO_FLAG_WRITE ? 1 : 0;
        return avio_alloc_context(av_malloc(4096), 4096, write_flag, fd, fd_read_packet, write_flag ? fd_write_packet : NULL, fd_seek);
    }
    return NULL;
}

static void close_fd_avio_context(AVIOContext *ctx) {
    if (fd_seek(ctx->opaque, 0, AVSEEK_SIZE) >= 0) {
        int *fd = ctx->opaque;
        closeParcelFileDescriptor(*fd);
        av_freep(&fd);
    }
    ctx->opaque = NULL;
}

int android_avformat_open_input(AVFormatContext **ps, const char *filename,
                        ff_const59 AVInputFormat *fmt, AVDictionary **options) {
    if (!(*ps) && !(*ps = avformat_alloc_context()))
        return AVERROR(ENOMEM);

    (*ps)->pb = create_fd_avio_context(filename, AVIO_FLAG_READ);

    return avformat_open_input(ps, filename, fmt, options);
}

int android_avio_open2(AVIOContext **s, const char *filename, int flags,
               const AVIOInterruptCB *int_cb, AVDictionary **options) {
    AVIOContext *fd_context = create_fd_avio_context(filename, flags);

    if (fd_context) {
        *s = fd_context;
        return 0;
    }
    return avio_open2(s, filename, flags, int_cb, options);
}

int android_avio_open(AVIOContext **s, const char *url, int flags) {
    return android_avio_open2(s, url, flags, NULL, NULL);
}

int android_avio_closep(AVIOContext **s) {
    close_fd_avio_context(*s);
    return avio_closep(s);
}

void android_avformat_close_input(AVFormatContext **ps) {
    if (*ps && (*ps)->pb) {
        close_fd_avio_context((*ps)->pb);
    }
    avformat_close_input(ps);
}
