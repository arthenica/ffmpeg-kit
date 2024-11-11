/*
 * Copyright (c) 2000-2003 Fabrice Bellard
 * Copyright (c) 2018-2022 Taner Sener
 * Copyright (c) 2023-2024 ARTHENICA LTD
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/**
 * @file
 * multimedia converter based on the FFmpeg libraries
 */

/*
 * This file is the modified version of ffmpeg.c file living in ffmpeg source
 * code under the fftools folder. We manually update it each time we depend on a
 * new ffmpeg version. Below you can see the list of changes applied by us to
 * develop mobile-ffmpeg and later ffmpeg-kit libraries.
 *
 * ffmpeg-kit changes by ARTHENICA LTD
 *
 * 11.2024
 * --------------------------------------------------------
 * - FFmpeg 6.1 changes migrated
 * - longjmp_value dropped
 *
 * 09.2023
 * --------------------------------------------------------
 * - forward_report method signature accepts pts to calculate the time
 *
 * 07.2023
 * --------------------------------------------------------
 * - FFmpeg 6.0 changes migrated
 * - cherry-picked commit 7357012bb5205e0d03634aff48fc0167a9248190
 * - vstats_file, received_sigterm and received_nb_signals updated as
 * thread-local
 * - forward_report method signature updated
 * - time field in report_callback/forward_report/set_report_callback updated as
 * double
 *
 * mobile-ffmpeg / ffmpeg-kit changes by Taner Sener
 *
 * 09.2022
 * --------------------------------------------------------
 * - added opt_common.h include
 * - volatile dropped from thread local variables
 * - setvbuf call dropped
 * - flushing stderr dropped
 * - muxing overhead printed in single line
 *
 * 08.2020
 * --------------------------------------------------------
 * - OptionDef defines combined
 *
 * 06.2020
 * --------------------------------------------------------
 * - ignoring signals implemented
 * - cancel_operation() method signature updated with id
 * - cancel by execution id implemented
 * - volatile modifier added to critical variables
 *
 * 01.2020
 * --------------------------------------------------------
 * - ffprobe support (added ffmpeg_ prefix to methods and variables defined for
 * both ffmpeg and ffprobe)
 *
 * 12.2019
 * --------------------------------------------------------
 * - concurrent execution support ("__thread" specifier added to variables used
 * by multiple threads, extern signatures of ffmpeg_opt.c methods called by both
 * ffmpeg and ffprobe added, copied options from ffmpeg_opt.c and defined them
 * as inline in execute method)
 *
 * 08.2018
 * --------------------------------------------------------
 * - fftools_ prefix added to file name and parent headers
 * - forward_report() method, report_callback function pointer and
 * set_report_callback() setter method added to forward stats
 * - forward_report() call added from print_report()
 * - cancel_operation() method added to trigger sigterm_handler
 * - (!received_sigterm) validation added inside ifilter_send_eof() to complete
 * cancellation
 *
 * 07.2018
 * --------------------------------------------------------
 * - main() function renamed as execute()
 * - exit_program() implemented with setjmp
 * - extern longjmp_value added to access exit code stored in exit_program()
 * - cleanup() method added
 */

#include "config.h"

#include <errno.h>
#include <limits.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if HAVE_IO_H
#include <io.h>
#endif
#if HAVE_UNISTD_H
#include <unistd.h>
#endif

#if HAVE_SYS_RESOURCE_H
#include <sys/resource.h>
#include <sys/time.h>
#include <sys/types.h>
#elif HAVE_GETPROCESSTIMES
#include <windows.h>
#endif
#if HAVE_GETPROCESSMEMORYINFO
#include <psapi.h>
#include <windows.h>
#endif
#if HAVE_SETCONSOLECTRLHANDLER
#include <windows.h>
#endif

#if HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif

#if HAVE_TERMIOS_H
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <termios.h>
#elif HAVE_KBHIT
#include <conio.h>
#endif

#include "libavutil/avassert.h"
#include "libavutil/avstring.h"
#include "libavutil/bprint.h"
#include "libavutil/channel_layout.h"
#include "libavutil/dict.h"
#include "libavutil/display.h"
#include "libavutil/fifo.h"
#include "libavutil/hwcontext.h"
#include "libavutil/imgutils.h"
#include "libavutil/intreadwrite.h"
#include "libavutil/libm.h"
#include "libavutil/mathematics.h"
#include "libavutil/opt.h"
#include "libavutil/parseutils.h"
#include "libavutil/pixdesc.h"
#include "libavutil/samplefmt.h"
#include "libavutil/thread.h"
#include "libavutil/threadmessage.h"
#include "libavutil/time.h"
#include "libavutil/timestamp.h"

#include "libavcodec/version.h"

#include "libavformat/avformat.h"

#include "libavdevice/avdevice.h"

#include "libswresample/swresample.h"

#include "ffmpegkit_exception.h"
#include "fftools_cmdutils.h"
#include "fftools_ffmpeg.h"
#include "fftools_opt_common.h"
#include "fftools_sync_queue.h"

__thread FILE *vstats_file;

static BenchmarkTimeStamps get_benchmark_time_stamps(void);
static int64_t getmaxrss(void);

__thread int64_t nb_frames_dup = 0;
__thread int64_t nb_frames_drop = 0;
__thread unsigned nb_output_dumped = 0;

__thread BenchmarkTimeStamps current_time;
__thread AVIOContext *progress_avio = NULL;

__thread InputFile **input_files = NULL;
__thread int nb_input_files = 0;

__thread OutputFile **output_files = NULL;
__thread int nb_output_files = 0;

__thread FilterGraph **filtergraphs;
__thread int nb_filtergraphs;

__thread int64_t last_time = -1;
__thread int64_t keyboard_last_time = 0;
__thread int first_report = 1;

void (*report_callback)(int, float, float, int64_t, double, double,
                        double) = NULL;

extern int opt_map(void *optctx, const char *opt, const char *arg);
extern int opt_map_channel(void *optctx, const char *opt, const char *arg);
extern int opt_recording_timestamp(void *optctx, const char *opt,
                                   const char *arg);
extern int opt_data_frames(void *optctx, const char *opt, const char *arg);
extern int opt_progress(void *optctx, const char *opt, const char *arg);
extern int opt_target(void *optctx, const char *opt, const char *arg);
extern int opt_vsync(void *optctx, const char *opt, const char *arg);
extern int opt_adrift_threshold(void *optctx, const char *opt, const char *arg);
extern int opt_abort_on(void *optctx, const char *opt, const char *arg);
extern int opt_qscale(void *optctx, const char *opt, const char *arg);
extern int opt_profile(void *optctx, const char *opt, const char *arg);
extern int opt_filter_threads(void *optctx, const char *opt, const char *arg);
extern int opt_filter_complex(void *optctx, const char *opt, const char *arg);
extern int opt_filter_complex_script(void *optctx, const char *opt,
                                     const char *arg);
extern int opt_stats_period(void *optctx, const char *opt, const char *arg);
extern int opt_attach(void *optctx, const char *opt, const char *arg);
extern int opt_video_frames(void *optctx, const char *opt, const char *arg);
extern int opt_video_codec(void *optctx, const char *opt, const char *arg);
extern int opt_timecode(void *optctx, const char *opt, const char *arg);
extern int opt_vstats(void *optctx, const char *opt, const char *arg);
extern int opt_vstats_file(void *optctx, const char *opt, const char *arg);
extern int opt_video_filters(void *optctx, const char *opt, const char *arg);
extern int opt_old2new(void *optctx, const char *opt, const char *arg);
extern int opt_qphist(void *optctx, const char *opt, const char *arg);
extern int opt_streamid(void *optctx, const char *opt, const char *arg);
extern int opt_bitrate(void *optctx, const char *opt, const char *arg);
extern int show_hwaccels(void *optctx, const char *opt, const char *arg);
extern int opt_audio_frames(void *optctx, const char *opt, const char *arg);
extern int opt_audio_qscale(void *optctx, const char *opt, const char *arg);
extern int opt_audio_codec(void *optctx, const char *opt, const char *arg);
extern int opt_audio_filters(void *optctx, const char *opt, const char *arg);
extern int opt_subtitle_codec(void *optctx, const char *opt, const char *arg);
extern int opt_sdp_file(void *optctx, const char *opt, const char *arg);
extern int opt_preset(void *optctx, const char *opt, const char *arg);
extern int opt_data_codec(void *optctx, const char *opt, const char *arg);
extern int opt_init_hw_device(void *optctx, const char *opt, const char *arg);
extern int opt_filter_hw_device(void *optctx, const char *opt, const char *arg);

extern __thread int file_overwrite;
extern __thread int no_file_overwrite;

#if HAVE_TERMIOS_H

/* init terminal so that we can grab keys */
__thread struct termios oldtty;
__thread int restore_tty;
#endif

extern volatile int handleSIGQUIT;
extern volatile int handleSIGINT;
extern volatile int handleSIGTERM;
extern volatile int handleSIGXCPU;
extern volatile int handleSIGPIPE;

extern __thread long globalSessionId;
extern void cancelSession(long sessionId);
extern int cancelRequested(long sessionId);

/* sub2video hack:
   Convert subtitles to video with alpha to insert them in filter graphs.
   This is a temporary solution until libavfilter gets real subtitles support.
 */

static void sub2video_heartbeat(InputFile *infile, int64_t pts, AVRational tb) {
    /* When a frame is read from a file, examine all sub2video streams in
       the same file and send the sub2video frame again. Otherwise, decoded
       video frames could be accumulating in the filter graph while a filter
       (possibly overlay) is desperately waiting for a subtitle frame. */
    for (int i = 0; i < infile->nb_streams; i++) {
        InputStream *ist = infile->streams[i];

        if (ist->dec_ctx->codec_type != AVMEDIA_TYPE_SUBTITLE)
            continue;

        for (int j = 0; j < ist->nb_filters; j++)
            ifilter_sub2video_heartbeat(ist->filters[j], pts, tb);
    }
}

/* end of sub2video hack */

static void term_exit_sigsafe(void) {
#if HAVE_TERMIOS_H
    if (restore_tty)
        tcsetattr(0, TCSANOW, &oldtty);
#endif
}

void term_exit(void) {
    av_log(NULL, AV_LOG_QUIET, "%s", "");
    term_exit_sigsafe();
}

__thread volatile int received_sigterm = 0;
__thread volatile int received_nb_signals = 0;
__thread atomic_int transcode_init_done = ATOMIC_VAR_INIT(0);
__thread volatile int ffmpeg_exited = 0;
__thread int main_ffmpeg_return_code = 0;
__thread int64_t copy_ts_first_pts = AV_NOPTS_VALUE;
extern __thread int want_sdp;
extern __thread struct EncStatsFile *enc_stats_files;
extern __thread int nb_enc_stats_files;

static void sigterm_handler(int sig) {
    // int ret;
    received_sigterm = sig;
    received_nb_signals++;
    term_exit_sigsafe();
    // FFmpegKit - Hard Exit Disabled
    // if(received_nb_signals > 3) {
    //     ret = write(2/*STDERR_FILENO*/, "Received > 3 system signals, hard
    //     exiting\n",
    //                 strlen("Received > 3 system signals, hard exiting\n"));
    //     if (ret < 0) { /* Do nothing */ };
    //     exit(123);
    // }
}

#if HAVE_SETCONSOLECTRLHANDLER
static BOOL WINAPI CtrlHandler(DWORD fdwCtrlType) {
    av_log(NULL, AV_LOG_DEBUG, "\nReceived windows signal %ld\n", fdwCtrlType);

    switch (fdwCtrlType) {
    case CTRL_C_EVENT:
    case CTRL_BREAK_EVENT:
        sigterm_handler(SIGINT);
        return TRUE;

    case CTRL_CLOSE_EVENT:
    case CTRL_LOGOFF_EVENT:
    case CTRL_SHUTDOWN_EVENT:
        sigterm_handler(SIGTERM);
        /* Basically, with these 3 events, when we return from this method the
           process is hard terminated, so stall as long as we need to
           to try and let the main thread(s) clean up and gracefully terminate
           (we have at most 5 seconds, but should be done far before that). */
        while (!ffmpeg_exited) {
            Sleep(0);
        }
        return TRUE;

    default:
        av_log(NULL, AV_LOG_ERROR, "Received unknown windows signal %ld\n",
               fdwCtrlType);
        return FALSE;
    }
}
#endif

#ifdef __linux__
#define SIGNAL(sig, func)                                                      \
    do {                                                                       \
        action.sa_handler = func;                                              \
        sigaction(sig, &action, NULL);                                         \
    } while (0)
#else
#define SIGNAL(sig, func) signal(sig, func)
#endif

void term_init(void) {
#if defined __linux__
#if defined __aarch64__ || defined __amd64__ || defined __x86_64__
    struct sigaction action = {0};
#else
    struct sigaction action = {{0}};
#endif

    action.sa_handler = sigterm_handler;

    /* block other interrupts while processing this one */
    sigfillset(&action.sa_mask);

    /* restart interruptible functions (i.e. don't fail with EINTR)  */
    action.sa_flags = SA_RESTART;
#endif

#if HAVE_TERMIOS_H
    if (stdin_interaction) {
        struct termios tty;
        if (tcgetattr(0, &tty) == 0) {
            oldtty = tty;
            restore_tty = 1;

            tty.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR |
                             ICRNL | IXON);
            tty.c_oflag |= OPOST;
            tty.c_lflag &= ~(ECHO | ECHONL | ICANON | IEXTEN);
            tty.c_cflag &= ~(CSIZE | PARENB);
            tty.c_cflag |= CS8;
            tty.c_cc[VMIN] = 1;
            tty.c_cc[VTIME] = 0;

            tcsetattr(0, TCSANOW, &tty);
        }
        if (handleSIGQUIT == 1) {
            SIGNAL(SIGQUIT, sigterm_handler); /* Quit (POSIX).  */
        }
    }
#endif

    if (handleSIGINT == 1) {
        SIGNAL(SIGINT, sigterm_handler); /* Interrupt (ANSI).    */
    }
    if (handleSIGTERM == 1) {
        SIGNAL(SIGTERM, sigterm_handler); /* Termination (ANSI).  */
    }
#ifdef SIGXCPU
    if (handleSIGXCPU == 1) {
        SIGNAL(SIGXCPU, sigterm_handler);
    }
#endif
#ifdef SIGPIPE
    if (handleSIGPIPE == 1) {
        signal(SIGPIPE, SIG_IGN); /* Broken pipe (POSIX). */
    }
#endif
#if HAVE_SETCONSOLECTRLHANDLER
    SetConsoleCtrlHandler((PHANDLER_ROUTINE)CtrlHandler, TRUE);
#endif
}

/* read a key without blocking */
static int read_key(void) {
    unsigned char ch;
#if HAVE_TERMIOS_H
    int n = 1;
    struct timeval tv;
    fd_set rfds;

    FD_ZERO(&rfds);
    FD_SET(0, &rfds);
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    n = select(1, &rfds, NULL, NULL, &tv);
    if (n > 0) {
        n = read(0, &ch, 1);
        if (n == 1)
            return ch;

        return n;
    }
#elif HAVE_KBHIT
#if HAVE_PEEKNAMEDPIPE && HAVE_GETSTDHANDLE
    static int is_pipe;
    static HANDLE input_handle;
    DWORD dw, nchars;
    if (!input_handle) {
        input_handle = GetStdHandle(STD_INPUT_HANDLE);
        is_pipe = !GetConsoleMode(input_handle, &dw);
    }

    if (is_pipe) {
        /* When running under a GUI, you will end here. */
        if (!PeekNamedPipe(input_handle, NULL, 0, NULL, &nchars, NULL)) {
            // input pipe may have been closed by the program that ran ffmpeg
            return -1;
        }
        // Read it
        if (nchars != 0) {
            if (read(0, &ch, 1) == 1)
                return ch;
            return 0;
        } else {
            return -1;
        }
    }
#endif
    if (kbhit())
        return (getch());
#endif
    return -1;
}

int decode_interrupt_cb(void *ctx);

int decode_interrupt_cb(void *ctx) {
    return received_nb_signals > atomic_load(&transcode_init_done);
}

__thread const AVIOInterruptCB int_cb = {decode_interrupt_cb, NULL};

static void ffmpeg_cleanup(int ret) {
    int i;

    if (do_benchmark) {
        int maxrss = getmaxrss() / 1024;
        av_log(NULL, AV_LOG_INFO, "bench: maxrss=%ikB\n", maxrss);
    }

    for (i = 0; i < nb_filtergraphs; i++)
        fg_free(&filtergraphs[i]);
    av_freep(&filtergraphs);

    for (i = 0; i < nb_output_files; i++)
        of_free(&output_files[i]);

    for (i = 0; i < nb_input_files; i++)
        ifile_close(&input_files[i]);

    if (vstats_file) {
        if (fclose(vstats_file))
            av_log(
                NULL, AV_LOG_ERROR,
                "Error closing vstats file, loss of information possible: %s\n",
                av_err2str(AVERROR(errno)));
    }
    av_freep(&vstats_filename);
    of_enc_stats_close();

    hw_device_free_all();

    av_freep(&filter_nbthreads);

    av_freep(&input_files);
    av_freep(&output_files);

    uninit_opts();

    avformat_network_deinit();

    if (received_sigterm) {
        av_log(NULL, AV_LOG_INFO, "Exiting normally, received signal %d.\n",
               (int)received_sigterm);
    } else if (cancelRequested(globalSessionId)) {
        av_log(NULL, AV_LOG_INFO,
               "Exiting normally, received cancel request.\n");
    } else if (ret && atomic_load(&transcode_init_done)) {
        av_log(NULL, AV_LOG_INFO, "Conversion failed!\n");
    }
    term_exit();
    ffmpeg_exited = 1;
}

OutputStream *ost_iter(OutputStream *prev) {
    int of_idx = prev ? prev->file_index : 0;
    int ost_idx = prev ? prev->index + 1 : 0;

    for (; of_idx < nb_output_files; of_idx++) {
        OutputFile *of = output_files[of_idx];
        if (ost_idx < of->nb_streams)
            return of->streams[ost_idx];

        ost_idx = 0;
    }

    return NULL;
}

InputStream *ist_iter(InputStream *prev) {
    int if_idx = prev ? prev->file_index : 0;
    int ist_idx = prev ? prev->index + 1 : 0;

    for (; if_idx < nb_input_files; if_idx++) {
        InputFile *f = input_files[if_idx];
        if (ist_idx < f->nb_streams)
            return f->streams[ist_idx];

        ist_idx = 0;
    }

    return NULL;
}

FrameData *frame_data(AVFrame *frame) {
    if (!frame->opaque_ref) {
        FrameData *fd;

        frame->opaque_ref = av_buffer_allocz(sizeof(*fd));
        if (!frame->opaque_ref)
            return NULL;
        fd = (FrameData *)frame->opaque_ref->data;

        fd->dec.frame_num = UINT64_MAX;
        fd->dec.pts = AV_NOPTS_VALUE;
    }

    return (FrameData *)frame->opaque_ref->data;
}

void remove_avoptions(AVDictionary **a, AVDictionary *b) {
    const AVDictionaryEntry *t = NULL;

    while ((t = av_dict_iterate(b, t))) {
        av_dict_set(a, t->key, NULL, AV_DICT_MATCH_CASE);
    }
}

int check_avoptions(AVDictionary *m) {
    const AVDictionaryEntry *t;
    if ((t = av_dict_get(m, "", NULL, AV_DICT_IGNORE_SUFFIX))) {
        av_log(NULL, AV_LOG_FATAL, "Option %s not found.\n", t->key);
        return AVERROR_OPTION_NOT_FOUND;
    }

    return 0;
}

void update_benchmark(const char *fmt, ...) {
    if (do_benchmark_all) {
        BenchmarkTimeStamps t = get_benchmark_time_stamps();
        va_list va;
        char buf[1024];

        if (fmt) {
            va_start(va, fmt);
            vsnprintf(buf, sizeof(buf), fmt, va);
            va_end(va);
            av_log(NULL, AV_LOG_INFO,
                   "bench: %8" PRIu64 " user %8" PRIu64 " sys %8" PRIu64
                   " real %s \n",
                   t.user_usec - current_time.user_usec,
                   t.sys_usec - current_time.sys_usec,
                   t.real_usec - current_time.real_usec, buf);
        }
        current_time = t;
    }
}

void close_output_stream(OutputStream *ost) {
    OutputFile *of = output_files[ost->file_index];
    ost->finished |= ENCODER_FINISHED;

    if (ost->sq_idx_encode >= 0)
        sq_send(of->sq_encode, ost->sq_idx_encode, SQFRAME(NULL));
}

static void forward_report(uint64_t frame_number, float fps, float quality,
                           int64_t total_size, int64_t pts, double bitrate,
                           double speed) {
    // FORWARD DATA
    if (report_callback != NULL) {
        double milliseconds = 0;
        if (pts != AV_NOPTS_VALUE) {
            milliseconds = ((double)FFABS64U(pts)) / 1000;
        }
        if (pts < 0) {
            report_callback(frame_number, fps, quality, total_size,
                            0 - milliseconds, bitrate, speed);
        } else {
            report_callback(frame_number, fps, quality, total_size,
                            milliseconds, bitrate, speed);
        }
    }
}

void print_report(int is_last_report, int64_t timer_start, int64_t cur_time) {
    AVBPrint buf, buf_script;
    int64_t total_size = of_filesize(output_files[0]);
    int vid;
    double bitrate;
    double speed;
    int64_t pts = AV_NOPTS_VALUE;
    int mins, secs, us;
    int64_t hours;
    const char *hours_sign;
    int ret;
    float t;

    // FFmpegKit field declarations
    int local_print_stats = 1;
    uint64_t frame_number = 0;
    float fps = 0;
    float q = 0;

    if (!print_stats && !is_last_report && !progress_avio)
        local_print_stats = 0;

    if (!is_last_report) {
        if (last_time == -1) {
            last_time = cur_time;
        }
        if (((cur_time - last_time) < stats_period && !first_report) ||
            (first_report && nb_output_dumped < nb_output_files))
            return;
        last_time = cur_time;
    }

    t = (cur_time - timer_start) / 1000000.0;

    vid = 0;
    if (local_print_stats) {
        av_bprint_init(&buf, 0, AV_BPRINT_SIZE_AUTOMATIC);
        av_bprint_init(&buf_script, 0, AV_BPRINT_SIZE_AUTOMATIC);
    }
    for (OutputStream *ost = ost_iter(NULL); ost; ost = ost_iter(ost)) {
        q = ost->enc ? ost->quality / (float)FF_QP2LAMBDA : -1;

        if (local_print_stats && vid && ost->type == AVMEDIA_TYPE_VIDEO) {
            av_bprintf(&buf, "q=%2.1f ", q);
            av_bprintf(&buf_script, "stream_%d_%d_q=%.1f\n", ost->file_index,
                       ost->index, q);
        }
        if (!vid && ost->type == AVMEDIA_TYPE_VIDEO && ost->filter) {
            frame_number = atomic_load(&ost->packets_written);

            fps = t > 1 ? frame_number / t : 0;
            if (local_print_stats) {
                av_bprintf(&buf, "frame=%5" PRId64 " fps=%3.*f q=%3.1f ",
                           frame_number, fps < 9.95, fps, q);
                av_bprintf(&buf_script, "frame=%" PRId64 "\n", frame_number);
                av_bprintf(&buf_script, "fps=%.2f\n", fps);
                av_bprintf(&buf_script, "stream_%d_%d_q=%.1f\n",
                           ost->file_index, ost->index, q);
                if (is_last_report)
                    av_bprintf(&buf, "L");
            }

            nb_frames_dup = ost->filter->nb_frames_dup;
            nb_frames_drop = ost->filter->nb_frames_drop;

            vid = 1;
        }
        /* compute min output value */
        if (ost->last_mux_dts != AV_NOPTS_VALUE) {
            if (pts == AV_NOPTS_VALUE || ost->last_mux_dts > pts)
                pts = ost->last_mux_dts;
            if (copy_ts) {
                if (copy_ts_first_pts == AV_NOPTS_VALUE && pts > 1)
                    copy_ts_first_pts = pts;
                if (copy_ts_first_pts != AV_NOPTS_VALUE)
                    pts -= copy_ts_first_pts;
            }
        }
    }

    us = FFABS64U(pts) % AV_TIME_BASE;
    secs = FFABS64U(pts) / AV_TIME_BASE % 60;
    mins = FFABS64U(pts) / AV_TIME_BASE / 60 % 60;
    hours = FFABS64U(pts) / AV_TIME_BASE / 3600;
    hours_sign = (pts < 0) ? "-" : "";

    bitrate = pts != AV_NOPTS_VALUE && pts && total_size >= 0
                  ? total_size * 8 / (pts / 1000.0)
                  : -1;
    speed =
        pts != AV_NOPTS_VALUE && t != 0.0 ? (double)pts / AV_TIME_BASE / t : -1;

    // FFmpegKit forward report
    forward_report(frame_number, fps, q, total_size, pts, bitrate, speed);

    if (local_print_stats) {
        if (total_size < 0)
            av_bprintf(&buf, "size=N/A time=");
        else
            av_bprintf(&buf, "size=%8.0fkB time=", total_size / 1024.0);
        if (pts == AV_NOPTS_VALUE) {
            av_bprintf(&buf, "N/A ");
        } else {
            av_bprintf(&buf, "%s%02" PRId64 ":%02d:%02d.%02d ", hours_sign,
                       hours, mins, secs, (100 * us) / AV_TIME_BASE);
        }

        if (bitrate < 0) {
            av_bprintf(&buf, "bitrate=N/A");
            av_bprintf(&buf_script, "bitrate=N/A\n");
        } else {
            av_bprintf(&buf, "bitrate=%6.1fkbits/s", bitrate);
            av_bprintf(&buf_script, "bitrate=%6.1fkbits/s\n", bitrate);
        }

        if (total_size < 0)
            av_bprintf(&buf_script, "total_size=N/A\n");
        else
            av_bprintf(&buf_script, "total_size=%" PRId64 "\n", total_size);
        if (pts == AV_NOPTS_VALUE) {
            av_bprintf(&buf_script, "out_time_us=N/A\n");
            av_bprintf(&buf_script, "out_time_ms=N/A\n");
            av_bprintf(&buf_script, "out_time=N/A\n");
        } else {
            av_bprintf(&buf_script, "out_time_us=%" PRId64 "\n", pts);
            av_bprintf(&buf_script, "out_time_ms=%" PRId64 "\n", pts);
            av_bprintf(&buf_script, "out_time=%s%02" PRId64 ":%02d:%02d.%06d\n",
                       hours_sign, hours, mins, secs, us);
        }

        if (nb_frames_dup || nb_frames_drop)
            av_bprintf(&buf, " dup=%" PRId64 " drop=%" PRId64, nb_frames_dup,
                       nb_frames_drop);
        av_bprintf(&buf_script, "dup_frames=%" PRId64 "\n", nb_frames_dup);
        av_bprintf(&buf_script, "drop_frames=%" PRId64 "\n", nb_frames_drop);

        if (speed < 0) {
            av_bprintf(&buf, " speed=N/A");
            av_bprintf(&buf_script, "speed=N/A\n");
        } else {
            av_bprintf(&buf, " speed=%4.3gx", speed);
            av_bprintf(&buf_script, "speed=%4.3gx\n", speed);
        }

        if (print_stats || is_last_report) {
            const char end = is_last_report ? '\n' : '\r';
            if (print_stats == 1 && AV_LOG_INFO > av_log_get_level()) {
                av_log(NULL, AV_LOG_STDERR, "%s    %c", buf.str, end);
            } else
                av_log(NULL, AV_LOG_INFO, "%s    %c", buf.str, end);
        }
        av_bprint_finalize(&buf, NULL);

        if (progress_avio) {
            av_bprintf(&buf_script, "progress=%s\n",
                       is_last_report ? "end" : "continue");
            avio_write(progress_avio, buf_script.str,
                       FFMIN(buf_script.len, buf_script.size - 1));
            avio_flush(progress_avio);
            av_bprint_finalize(&buf_script, NULL);
            if (is_last_report) {
                if ((ret = avio_closep(&progress_avio)) < 0)
                    av_log(NULL, AV_LOG_ERROR,
                           "Error closing progress log, loss of information "
                           "possible: %s\n",
                           av_err2str(ret));
            }
        }

        first_report = 0;
    }
}

int copy_av_subtitle(AVSubtitle *dst, const AVSubtitle *src) {
    int ret = AVERROR_BUG;
    AVSubtitle tmp = {.format = src->format,
                      .start_display_time = src->start_display_time,
                      .end_display_time = src->end_display_time,
                      .num_rects = 0,
                      .rects = NULL,
                      .pts = src->pts};

    if (!src->num_rects)
        goto success;

    if (!(tmp.rects = av_calloc(src->num_rects, sizeof(*tmp.rects))))
        return AVERROR(ENOMEM);

    for (int i = 0; i < src->num_rects; i++) {
        AVSubtitleRect *src_rect = src->rects[i];
        AVSubtitleRect *dst_rect;

        if (!(dst_rect = tmp.rects[i] = av_mallocz(sizeof(*tmp.rects[0])))) {
            ret = AVERROR(ENOMEM);
            goto cleanup;
        }

        tmp.num_rects++;

        dst_rect->type = src_rect->type;
        dst_rect->flags = src_rect->flags;

        dst_rect->x = src_rect->x;
        dst_rect->y = src_rect->y;
        dst_rect->w = src_rect->w;
        dst_rect->h = src_rect->h;
        dst_rect->nb_colors = src_rect->nb_colors;

        if (src_rect->text)
            if (!(dst_rect->text = av_strdup(src_rect->text))) {
                ret = AVERROR(ENOMEM);
                goto cleanup;
            }

        if (src_rect->ass)
            if (!(dst_rect->ass = av_strdup(src_rect->ass))) {
                ret = AVERROR(ENOMEM);
                goto cleanup;
            }

        for (int j = 0; j < 4; j++) {
            // SUBTITLE_BITMAP images are special in the sense that they
            // are like PAL8 images. first pointer to data, second to
            // palette. This makes the size calculation match this.
            size_t buf_size = src_rect->type == SUBTITLE_BITMAP && j == 1
                                  ? AVPALETTE_SIZE
                                  : src_rect->h * src_rect->linesize[j];

            if (!src_rect->data[j])
                continue;

            if (!(dst_rect->data[j] = av_memdup(src_rect->data[j], buf_size))) {
                ret = AVERROR(ENOMEM);
                goto cleanup;
            }
            dst_rect->linesize[j] = src_rect->linesize[j];
        }
    }

success:
    *dst = tmp;

    return 0;

cleanup:
    avsubtitle_free(&tmp);

    return ret;
}

static void subtitle_free(void *opaque, uint8_t *data) {
    AVSubtitle *sub = (AVSubtitle *)data;
    avsubtitle_free(sub);
    av_free(sub);
}

int subtitle_wrap_frame(AVFrame *frame, AVSubtitle *subtitle, int copy) {
    AVBufferRef *buf;
    AVSubtitle *sub;
    int ret;

    if (copy) {
        sub = av_mallocz(sizeof(*sub));
        ret = sub ? copy_av_subtitle(sub, subtitle) : AVERROR(ENOMEM);
        if (ret < 0) {
            av_freep(&sub);
            return ret;
        }
    } else {
        sub = av_memdup(subtitle, sizeof(*subtitle));
        if (!sub)
            return AVERROR(ENOMEM);
        memset(subtitle, 0, sizeof(*subtitle));
    }

    buf =
        av_buffer_create((uint8_t *)sub, sizeof(*sub), subtitle_free, NULL, 0);
    if (!buf) {
        avsubtitle_free(sub);
        av_freep(&sub);
        return AVERROR(ENOMEM);
    }

    frame->buf[0] = buf;

    return 0;
}

int trigger_fix_sub_duration_heartbeat(OutputStream *ost, const AVPacket *pkt) {
    OutputFile *of = output_files[ost->file_index];
    int64_t signal_pts = av_rescale_q(pkt->pts, pkt->time_base, AV_TIME_BASE_Q);

    if (!ost->fix_sub_duration_heartbeat || !(pkt->flags & AV_PKT_FLAG_KEY))
        // we are only interested in heartbeats on streams configured, and
        // only on random access points.
        return 0;

    for (int i = 0; i < of->nb_streams; i++) {
        OutputStream *iter_ost = of->streams[i];
        InputStream *ist = iter_ost->ist;
        int ret = AVERROR_BUG;

        if (iter_ost == ost || !ist || !ist->decoding_needed ||
            ist->dec_ctx->codec_type != AVMEDIA_TYPE_SUBTITLE)
            // We wish to skip the stream that causes the heartbeat,
            // output streams without an input stream, streams not decoded
            // (as fix_sub_duration is only done for decoded subtitles) as
            // well as non-subtitle streams.
            continue;

        if ((ret = fix_sub_duration_heartbeat(ist, signal_pts)) < 0)
            return ret;
    }

    return 0;
}

/* pkt = NULL means EOF (needed to flush decoder buffers) */
int process_input_packet(InputStream *ist, const AVPacket *pkt, int no_eof) {
    InputFile *f = input_files[ist->file_index];
    int64_t dts_est = AV_NOPTS_VALUE;
    int ret = 0;
    int eof_reached = 0;

    if (ist->decoding_needed) {
        ret = dec_packet(ist, pkt, no_eof);
        if (ret < 0 && ret != AVERROR_EOF)
            return ret;
    }
    if (ret == AVERROR_EOF || (!pkt && !ist->decoding_needed))
        eof_reached = 1;

    if (pkt && pkt->opaque_ref) {
        DemuxPktData *pd = (DemuxPktData *)pkt->opaque_ref->data;
        dts_est = pd->dts_est;
    }

    if (f->recording_time != INT64_MAX) {
        int64_t start_time = 0;
        if (copy_ts) {
            start_time += f->start_time != AV_NOPTS_VALUE ? f->start_time : 0;
            start_time += start_at_zero ? 0 : f->start_time_effective;
        }
        if (dts_est >= f->recording_time + start_time)
            pkt = NULL;
    }

    for (int oidx = 0; oidx < ist->nb_outputs; oidx++) {
        OutputStream *ost = ist->outputs[oidx];
        if (ost->enc || (!pkt && no_eof))
            continue;

        ret = of_streamcopy(ost, pkt, dts_est);
        if (ret < 0)
            return ret;
    }

    return !eof_reached;
}

static void print_stream_maps(void) {
    av_log(NULL, AV_LOG_INFO, "Stream mapping:\n");
    for (InputStream *ist = ist_iter(NULL); ist; ist = ist_iter(ist)) {
        for (int j = 0; j < ist->nb_filters; j++) {
            if (!filtergraph_is_simple(ist->filters[j]->graph)) {
                av_log(NULL, AV_LOG_INFO, "  Stream #%d:%d (%s) -> %s",
                       ist->file_index, ist->index,
                       ist->dec ? ist->dec->name : "?", ist->filters[j]->name);
                if (nb_filtergraphs > 1)
                    av_log(NULL, AV_LOG_INFO, " (graph %d)",
                           ist->filters[j]->graph->index);
                av_log(NULL, AV_LOG_INFO, "\n");
            }
        }
    }

    for (OutputStream *ost = ost_iter(NULL); ost; ost = ost_iter(ost)) {
        if (ost->attachment_filename) {
            /* an attached file */
            av_log(NULL, AV_LOG_INFO, "  File %s -> Stream #%d:%d\n",
                   ost->attachment_filename, ost->file_index, ost->index);
            continue;
        }

        if (ost->filter && !filtergraph_is_simple(ost->filter->graph)) {
            /* output from a complex graph */
            av_log(NULL, AV_LOG_INFO, "  %s", ost->filter->name);
            if (nb_filtergraphs > 1)
                av_log(NULL, AV_LOG_INFO, " (graph %d)",
                       ost->filter->graph->index);

            av_log(NULL, AV_LOG_INFO, " -> Stream #%d:%d (%s)\n",
                   ost->file_index, ost->index, ost->enc_ctx->codec->name);
            continue;
        }

        av_log(NULL, AV_LOG_INFO, "  Stream #%d:%d -> #%d:%d",
               ost->ist->file_index, ost->ist->index, ost->file_index,
               ost->index);
        if (ost->enc_ctx) {
            const AVCodec *in_codec = ost->ist->dec;
            const AVCodec *out_codec = ost->enc_ctx->codec;
            const char *decoder_name = "?";
            const char *in_codec_name = "?";
            const char *encoder_name = "?";
            const char *out_codec_name = "?";
            const AVCodecDescriptor *desc;

            if (in_codec) {
                decoder_name = in_codec->name;
                desc = avcodec_descriptor_get(in_codec->id);
                if (desc)
                    in_codec_name = desc->name;
                if (!strcmp(decoder_name, in_codec_name))
                    decoder_name = "native";
            }

            if (out_codec) {
                encoder_name = out_codec->name;
                desc = avcodec_descriptor_get(out_codec->id);
                if (desc)
                    out_codec_name = desc->name;
                if (!strcmp(encoder_name, out_codec_name))
                    encoder_name = "native";
            }

            av_log(NULL, AV_LOG_INFO, " (%s (%s) -> %s (%s))", in_codec_name,
                   decoder_name, out_codec_name, encoder_name);
        } else
            av_log(NULL, AV_LOG_INFO, " (copy)");
        av_log(NULL, AV_LOG_INFO, "\n");
    }
}

/**
 * Select the output stream to process.
 *
 * @retval 0 an output stream was selected
 * @retval AVERROR(EAGAIN) need to wait until more input is available
 * @retval AVERROR_EOF no more streams need output
 */
static int choose_output(OutputStream **post) {
    int64_t opts_min = INT64_MAX;
    OutputStream *ost_min = NULL;

    for (OutputStream *ost = ost_iter(NULL); ost; ost = ost_iter(ost)) {
        int64_t opts;

        if (ost->filter && ost->filter->last_pts != AV_NOPTS_VALUE) {
            opts = ost->filter->last_pts;
        } else {
            opts = ost->last_mux_dts == AV_NOPTS_VALUE ? INT64_MIN
                                                       : ost->last_mux_dts;
        }

        if (!ost->initialized && !ost->finished) {
            ost_min = ost;
            break;
        }
        if (!ost->finished && opts < opts_min) {
            opts_min = opts;
            ost_min = ost;
        }
    }
    if (!ost_min)
        return AVERROR_EOF;
    *post = ost_min;
    return ost_min->unavailable ? AVERROR(EAGAIN) : 0;
}

static void set_tty_echo(int on) {
#if HAVE_TERMIOS_H
    struct termios tty;
    if (tcgetattr(0, &tty) == 0) {
        if (on)
            tty.c_lflag |= ECHO;
        else
            tty.c_lflag &= ~ECHO;
        tcsetattr(0, TCSANOW, &tty);
    }
#endif
}

static int check_keyboard_interaction(int64_t cur_time) {
    int i, key;
    if (received_nb_signals)
        return AVERROR_EXIT;
    /* read_key() returns 0 on EOF */
    if (cur_time - keyboard_last_time >= 100000) {
        key = read_key();
        keyboard_last_time = cur_time;
    } else
        key = -1;
    if (key == 'q') {
        av_log(NULL, AV_LOG_INFO, "\n\n[q] command received. Exiting.\n\n");
        return AVERROR_EXIT;
    }
    if (key == '+')
        av_log_set_level(av_log_get_level() + 10);
    if (key == '-')
        av_log_set_level(av_log_get_level() - 10);
    if (key == 'c' || key == 'C') {
        char buf[4096], target[64], command[256], arg[256] = {0};
        double time;
        int k, n = 0;
        av_log(
            NULL, AV_LOG_STDERR,
            "\nEnter command: <target>|all <time>|-1 <command>[ <argument>]\n");
        i = 0;
        set_tty_echo(1);
        while ((k = read_key()) != '\n' && k != '\r' && i < sizeof(buf) - 1)
            if (k > 0)
                buf[i++] = k;
        buf[i] = 0;
        set_tty_echo(0);
        av_log(NULL, AV_LOG_STDERR, "\n");
        if (k > 0 && (n = sscanf(buf, "%63[^ ] %lf %255[^ ] %255[^\n]", target,
                                 &time, command, arg)) >= 3) {
            av_log(NULL, AV_LOG_DEBUG,
                   "Processing command target:%s time:%f command:%s arg:%s",
                   target, time, command, arg);
            for (i = 0; i < nb_filtergraphs; i++)
                fg_send_command(filtergraphs[i], time, target, command, arg,
                                key == 'C');
        } else {
            av_log(NULL, AV_LOG_ERROR,
                   "Parse error, at least 3 arguments were expected, "
                   "only %d given in string '%s'\n",
                   n, buf);
        }
    }
    if (key == '?') {
        av_log(NULL, AV_LOG_ERROR,
               "key    function\n"
               "?      show this help\n"
               "+      increase verbosity\n"
               "-      decrease verbosity\n"
               "c      Send command to first matching filter supporting it\n"
               "C      Send/Queue command to all matching filters\n"
               "h      dump packets/hex press to cycle through the 3 states\n"
               "q      quit\n"
               "s      Show QP histogram\n");
    }
    return 0;
}

static void reset_eagain(void) {
    int i;
    for (i = 0; i < nb_input_files; i++)
        input_files[i]->eagain = 0;
    for (OutputStream *ost = ost_iter(NULL); ost; ost = ost_iter(ost))
        ost->unavailable = 0;
}

static void decode_flush(InputFile *ifile) {
    for (int i = 0; i < ifile->nb_streams; i++) {
        InputStream *ist = ifile->streams[i];

        if (ist->discard || !ist->decoding_needed)
            continue;

        dec_packet(ist, NULL, 1);
    }
}

/*
 * Return
 * - 0 -- one packet was read and processed
 * - AVERROR(EAGAIN) -- no packets were available for selected file,
 *   this function should be called again
 * - AVERROR_EOF -- this function should not be called again
 */
static int process_input(int file_index) {
    InputFile *ifile = input_files[file_index];
    InputStream *ist;
    AVPacket *pkt;
    int ret, i;

    ret = ifile_get_packet(ifile, &pkt);

    if (ret == AVERROR(EAGAIN)) {
        ifile->eagain = 1;
        return ret;
    }
    if (ret == 1) {
        /* the input file is looped: flush the decoders */
        decode_flush(ifile);
        return AVERROR(EAGAIN);
    }
    if (ret < 0) {
        if (ret != AVERROR_EOF) {
            av_log(ifile, AV_LOG_ERROR,
                   "Error retrieving a packet from demuxer: %s\n",
                   av_err2str(ret));
            if (exit_on_error)
                return ret;
        }

        for (i = 0; i < ifile->nb_streams; i++) {
            ist = ifile->streams[i];
            if (!ist->discard) {
                ret = process_input_packet(ist, NULL, 0);
                if (ret > 0)
                    return 0;
                else if (ret < 0)
                    return ret;
            }

            /* mark all outputs that don't go through lavfi as finished */
            for (int oidx = 0; oidx < ist->nb_outputs; oidx++) {
                OutputStream *ost = ist->outputs[oidx];
                OutputFile *of = output_files[ost->file_index];

                ret = of_output_packet(of, ost, NULL);
                if (ret < 0)
                    return ret;
            }
        }

        ifile->eof_reached = 1;
        return AVERROR(EAGAIN);
    }

    reset_eagain();

    ist = ifile->streams[pkt->stream_index];

    sub2video_heartbeat(ifile, pkt->pts, pkt->time_base);

    ret = process_input_packet(ist, pkt, 0);

    av_packet_free(&pkt);

    return ret < 0 ? ret : 0;
}

/**
 * Run a single step of transcoding.
 *
 * @return  0 for success, <0 for error
 */
static int transcode_step(OutputStream *ost) {
    InputStream *ist = NULL;
    int ret;

    if (ost->filter) {
        if ((ret = fg_transcode_step(ost->filter->graph, &ist)) < 0)
            return ret;
        if (!ist)
            return 0;
    } else {
        ist = ost->ist;
        av_assert0(ist);
    }

    ret = process_input(ist->file_index);
    if (ret == AVERROR(EAGAIN)) {
        if (input_files[ist->file_index]->eagain)
            ost->unavailable = 1;
        return 0;
    }

    if (ret < 0)
        return ret == AVERROR_EOF ? 0 : ret;

    // process_input() above might have caused output to become available
    // in multiple filtergraphs, so we process all of them
    for (int i = 0; i < nb_filtergraphs; i++) {
        ret = reap_filters(filtergraphs[i], 0);
        if (ret < 0)
            return ret;
    }

    return 0;
}

/*
 * The following code is the main loop of the file converter
 */
static int transcode(int *err_rate_exceeded) {
    int ret = 0, i;
    InputStream *ist;
    int64_t timer_start;

    print_stream_maps();

    *err_rate_exceeded = 0;
    atomic_store(&transcode_init_done, 1);

    if (stdin_interaction) {
        av_log(NULL, AV_LOG_INFO, "Press [q] to stop, [?] for help\n");
    }

    timer_start = av_gettime_relative();

    while (!received_sigterm && !cancelRequested(globalSessionId)) {
        OutputStream *ost;
        int64_t cur_time = av_gettime_relative();

        /* if 'q' pressed, exits */
        if (stdin_interaction)
            if (check_keyboard_interaction(cur_time) < 0)
                break;

        ret = choose_output(&ost);
        if (ret == AVERROR(EAGAIN)) {
            reset_eagain();
            av_usleep(10000);
            ret = 0;
            continue;
        } else if (ret < 0) {
            av_log(NULL, AV_LOG_VERBOSE,
                   "No more output streams to write to, finishing.\n");
            ret = 0;
            break;
        }

        ret = transcode_step(ost);
        if (ret < 0 && ret != AVERROR_EOF) {
            av_log(NULL, AV_LOG_ERROR, "Error while filtering: %s\n",
                   av_err2str(ret));
            break;
        }

        /* dump report by using the output first video and audio streams */
        print_report(0, timer_start, cur_time);
    }

    /* at the end of stream, we must flush the decoder buffers */
    for (ist = ist_iter(NULL); ist; ist = ist_iter(ist)) {
        float err_rate;

        if (!input_files[ist->file_index]->eof_reached) {
            int err = process_input_packet(ist, NULL, 0);
            ret = err_merge(ret, err);
        }

        err_rate = (ist->frames_decoded || ist->decode_errors)
                       ? ist->decode_errors /
                             (ist->frames_decoded + ist->decode_errors)
                       : 0.f;
        if (err_rate > max_error_rate) {
            av_log(ist, AV_LOG_FATAL,
                   "Decode error rate %g exceeds maximum %g\n", err_rate,
                   max_error_rate);
            *err_rate_exceeded = 1;
        } else if (err_rate)
            av_log(ist, AV_LOG_VERBOSE, "Decode error rate %g\n", err_rate);
    }
    ret = err_merge(ret, enc_flush());

    term_exit();

    /* write the trailer if needed */
    for (i = 0; i < nb_output_files; i++) {
        int err = of_write_trailer(output_files[i]);
        ret = err_merge(ret, err);
    }

    /* dump report by using the first video and audio streams */
    print_report(1, timer_start, av_gettime_relative());

    return ret;
}

static BenchmarkTimeStamps get_benchmark_time_stamps(void) {
    BenchmarkTimeStamps time_stamps = {av_gettime_relative()};
#if HAVE_GETRUSAGE
    struct rusage rusage;

    getrusage(RUSAGE_SELF, &rusage);
    time_stamps.user_usec =
        (rusage.ru_utime.tv_sec * 1000000LL) + rusage.ru_utime.tv_usec;
    time_stamps.sys_usec =
        (rusage.ru_stime.tv_sec * 1000000LL) + rusage.ru_stime.tv_usec;
#elif HAVE_GETPROCESSTIMES
    HANDLE proc;
    FILETIME c, e, k, u;
    proc = GetCurrentProcess();
    GetProcessTimes(proc, &c, &e, &k, &u);
    time_stamps.user_usec =
        ((int64_t)u.dwHighDateTime << 32 | u.dwLowDateTime) / 10;
    time_stamps.sys_usec =
        ((int64_t)k.dwHighDateTime << 32 | k.dwLowDateTime) / 10;
#else
    time_stamps.user_usec = time_stamps.sys_usec = 0;
#endif
    return time_stamps;
}

static int64_t getmaxrss(void) {
#if HAVE_GETRUSAGE && HAVE_STRUCT_RUSAGE_RU_MAXRSS
    struct rusage rusage;
    getrusage(RUSAGE_SELF, &rusage);
    return (int64_t)rusage.ru_maxrss * 1024;
#elif HAVE_GETPROCESSMEMORYINFO
    HANDLE proc;
    PROCESS_MEMORY_COUNTERS memcounters;
    proc = GetCurrentProcess();
    memcounters.cb = sizeof(memcounters);
    GetProcessMemoryInfo(proc, &memcounters, sizeof(memcounters));
    return memcounters.PeakPagefileUsage;
#else
    return 0;
#endif
}

void ffmpeg_var_cleanup() {
    received_sigterm = 0;
    received_nb_signals = 0;
    transcode_init_done = ATOMIC_VAR_INIT(0);
    ffmpeg_exited = 0;
    main_ffmpeg_return_code = 0;
    copy_ts_first_pts = AV_NOPTS_VALUE;
    want_sdp = 1;
    enc_stats_files = NULL;
    nb_enc_stats_files = 0;

    vstats_file = NULL;

    nb_frames_dup = 0;
    nb_frames_drop = 0;
    nb_output_dumped = 0;

    progress_avio = NULL;

    input_files = NULL;
    nb_input_files = 0;

    output_files = NULL;
    nb_output_files = 0;

    filtergraphs = NULL;
    nb_filtergraphs = 0;

    last_time = -1;
    keyboard_last_time = 0;
    first_report = 1;
}

void set_report_callback(void (*callback)(int, float, float, int64_t, double,
                                          double, double)) {
    report_callback = callback;
}

void cancel_operation(long id) {
    if (id == 0) {
        sigterm_handler(SIGINT);
    } else {
        cancelSession(id);
    }
}

__thread OptionDef *ffmpeg_options = NULL;

int ffmpeg_execute(int argc, char **argv) {
    char _program_name[] = "ffmpeg";
    program_name = (char *)&_program_name;
    program_birth_year = 2000;

#define OFFSET(x) offsetof(OptionsContext, x)
    OptionDef options[] = {

        /* main options */
        {"L", OPT_EXIT, {.func_arg = show_license}, "show license"},
        {"h", OPT_EXIT, {.func_arg = show_help}, "show help", "topic"},
        {"?", OPT_EXIT, {.func_arg = show_help}, "show help", "topic"},
        {"help", OPT_EXIT, {.func_arg = show_help}, "show help", "topic"},
        {"-help", OPT_EXIT, {.func_arg = show_help}, "show help", "topic"},
        {"version", OPT_EXIT, {.func_arg = show_version}, "show version"},
        {"buildconf",
         OPT_EXIT,
         {.func_arg = show_buildconf},
         "show build configuration"},
        {"formats",
         OPT_EXIT,
         {.func_arg = show_formats},
         "show available formats"},
        {"muxers",
         OPT_EXIT,
         {.func_arg = show_muxers},
         "show available muxers"},
        {"demuxers",
         OPT_EXIT,
         {.func_arg = show_demuxers},
         "show available demuxers"},
        {"devices",
         OPT_EXIT,
         {.func_arg = show_devices},
         "show available devices"},
        {"codecs",
         OPT_EXIT,
         {.func_arg = show_codecs},
         "show available codecs"},
        {"decoders",
         OPT_EXIT,
         {.func_arg = show_decoders},
         "show available decoders"},
        {"encoders",
         OPT_EXIT,
         {.func_arg = show_encoders},
         "show available encoders"},
        {"bsfs",
         OPT_EXIT,
         {.func_arg = show_bsfs},
         "show available bit stream filters"},
        {"protocols",
         OPT_EXIT,
         {.func_arg = show_protocols},
         "show available protocols"},
        {"filters",
         OPT_EXIT,
         {.func_arg = show_filters},
         "show available filters"},
        {"pix_fmts",
         OPT_EXIT,
         {.func_arg = show_pix_fmts},
         "show available pixel formats"},
        {"layouts",
         OPT_EXIT,
         {.func_arg = show_layouts},
         "show standard channel layouts"},
        {"sample_fmts",
         OPT_EXIT,
         {.func_arg = show_sample_fmts},
         "show available audio sample formats"},
        {"dispositions",
         OPT_EXIT,
         {.func_arg = show_dispositions},
         "show available stream dispositions"},
        {"colors",
         OPT_EXIT,
         {.func_arg = show_colors},
         "show available color names"},
        {"loglevel",
         HAS_ARG,
         {.func_arg = opt_loglevel},
         "set logging level",
         "loglevel"},
        {"v",
         HAS_ARG,
         {.func_arg = opt_loglevel},
         "set logging level",
         "loglevel"},
        {"report", 0, {.func_arg = opt_report}, "generate a report"},
        {"max_alloc",
         HAS_ARG,
         {.func_arg = opt_max_alloc},
         "set maximum size of a single allocated block",
         "bytes"},
        {"cpuflags",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_cpuflags},
         "force specific cpu flags",
         "flags"},
        {"cpucount",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_cpucount},
         "force specific cpu count",
         "count"},
        {"hide_banner",
         OPT_BOOL | OPT_EXPERT,
         {&hide_banner},
         "do not show program banner",
         "hide_banner"},

#if CONFIG_AVDEVICE
        {"sources",
         OPT_EXIT | HAS_ARG,
         {.func_arg = show_sources},
         "list sources of the input device",
         "device"},
        {"sinks",
         OPT_EXIT | HAS_ARG,
         {.func_arg = show_sinks},
         "list sinks of the output device",
         "device"},
#endif

        {"f",
         HAS_ARG | OPT_STRING | OPT_OFFSET | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(format)},
         "force format",
         "fmt"},
        {"y", OPT_BOOL, {&file_overwrite}, "overwrite output files"},
        {"n", OPT_BOOL, {&no_file_overwrite}, "never overwrite output files"},
        {"ignore_unknown",
         OPT_BOOL,
         {&ignore_unknown_streams},
         "Ignore unknown stream types"},
        {"copy_unknown",
         OPT_BOOL | OPT_EXPERT,
         {&copy_unknown_streams},
         "Copy unknown stream types"},
        {"recast_media",
         OPT_BOOL | OPT_EXPERT,
         {&recast_media},
         "allow recasting stream type in order to force a decoder of different "
         "media type"},
        {"c",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(codec_names)},
         "codec name",
         "codec"},
        {"codec",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(codec_names)},
         "codec name",
         "codec"},
        {"pre",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(presets)},
         "preset name",
         "preset"},
        {"map",
         HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_map},
         "set input stream mapping",
         "[-]input_file_id[:stream_specifier][,sync_file_id[:stream_specifier]"
         "]"},
#if FFMPEG_OPT_MAP_CHANNEL
        {"map_channel",
         HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_map_channel},
         "map an audio channel from one stream to another (deprecated)",
         "file.stream.channel[:syncfile.syncstream]"},
#endif
        {"map_metadata",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(metadata_map)},
         "set metadata information of outfile from infile",
         "outfile[,metadata]:infile[,metadata]"},
        {"map_chapters",
         HAS_ARG | OPT_INT | OPT_EXPERT | OPT_OFFSET | OPT_OUTPUT,
         {.off = OFFSET(chapters_input_file)},
         "set chapters mapping",
         "input_file_index"},
        {"t",
         HAS_ARG | OPT_TIME | OPT_OFFSET | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(recording_time)},
         "record or transcode \"duration\" seconds of audio/video",
         "duration"},
        {"to",
         HAS_ARG | OPT_TIME | OPT_OFFSET | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(stop_time)},
         "record or transcode stop time",
         "time_stop"},
        {"fs",
         HAS_ARG | OPT_INT64 | OPT_OFFSET | OPT_OUTPUT,
         {.off = OFFSET(limit_filesize)},
         "set the limit file size in bytes",
         "limit_size"},
        {"ss",
         HAS_ARG | OPT_TIME | OPT_OFFSET | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(start_time)},
         "set the start time offset",
         "time_off"},
        {"sseof",
         HAS_ARG | OPT_TIME | OPT_OFFSET | OPT_INPUT,
         {.off = OFFSET(start_time_eof)},
         "set the start time offset relative to EOF",
         "time_off"},
        {"seek_timestamp",
         HAS_ARG | OPT_INT | OPT_OFFSET | OPT_INPUT,
         {.off = OFFSET(seek_timestamp)},
         "enable/disable seeking by timestamp with -ss"},
        {"accurate_seek",
         OPT_BOOL | OPT_OFFSET | OPT_EXPERT | OPT_INPUT,
         {.off = OFFSET(accurate_seek)},
         "enable/disable accurate seeking with -ss"},
        {"isync",
         HAS_ARG | OPT_INT | OPT_OFFSET | OPT_EXPERT | OPT_INPUT,
         {.off = OFFSET(input_sync_ref)},
         "Indicate the input index for sync reference",
         "sync ref"},
        {"itsoffset",
         HAS_ARG | OPT_TIME | OPT_OFFSET | OPT_EXPERT | OPT_INPUT,
         {.off = OFFSET(input_ts_offset)},
         "set the input ts offset",
         "time_off"},
        {"itsscale",
         HAS_ARG | OPT_DOUBLE | OPT_SPEC | OPT_EXPERT | OPT_INPUT,
         {.off = OFFSET(ts_scale)},
         "set the input ts scale",
         "scale"},
        {"timestamp",
         HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_recording_timestamp},
         "set the recording timestamp ('now' to set the current time)",
         "time"},
        {"metadata",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(metadata)},
         "add metadata",
         "string=string"},
        {"program",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(program)},
         "add program with specified streams",
         "title=string:st=number..."},
        {"dframes",
         HAS_ARG | OPT_PERFILE | OPT_EXPERT | OPT_OUTPUT,
         {.func_arg = opt_data_frames},
         "set the number of data frames to output",
         "number"},
        {"benchmark",
         OPT_BOOL | OPT_EXPERT,
         {&do_benchmark},
         "add timings for benchmarking"},
        {"benchmark_all",
         OPT_BOOL | OPT_EXPERT,
         {&do_benchmark_all},
         "add timings for each task"},
        {"progress",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_progress},
         "write program-readable progress information",
         "url"},
        {"stdin",
         OPT_BOOL | OPT_EXPERT,
         {&stdin_interaction},
         "enable or disable interaction on standard input"},
        {"timelimit",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_timelimit},
         "set max runtime in seconds in CPU user time",
         "limit"},
        {"dump",
         OPT_BOOL | OPT_EXPERT,
         {&do_pkt_dump},
         "dump each input packet"},
        {"hex",
         OPT_BOOL | OPT_EXPERT,
         {&do_hex_dump},
         "when dumping packets, also dump the payload"},
        {"re",
         OPT_BOOL | OPT_EXPERT | OPT_OFFSET | OPT_INPUT,
         {.off = OFFSET(rate_emu)},
         "read input at native frame rate; equivalent to -readrate 1",
         ""},
        {"readrate",
         HAS_ARG | OPT_FLOAT | OPT_OFFSET | OPT_EXPERT | OPT_INPUT,
         {.off = OFFSET(readrate)},
         "read input at specified rate",
         "speed"},
        {"readrate_initial_burst",
         HAS_ARG | OPT_DOUBLE | OPT_OFFSET | OPT_EXPERT | OPT_INPUT,
         {.off = OFFSET(readrate_initial_burst)},
         "The initial amount of input to burst read before imposing any "
         "readrate",
         "seconds"},
        {"target",
         HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_target},
         "specify target file type (\"vcd\", \"svcd\", \"dvd\", \"dv\" or "
         "\"dv50\" "
         "with optional prefixes \"pal-\", \"ntsc-\" or \"film-\")",
         "type"},
        {"vsync",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_vsync},
         "set video sync method globally; deprecated, use -fps_mode",
         ""},
        {"frame_drop_threshold",
         HAS_ARG | OPT_FLOAT | OPT_EXPERT,
         {&frame_drop_threshold},
         "frame drop threshold",
         ""},
#if FFMPEG_OPT_ADRIFT_THRESHOLD
        {"adrift_threshold",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_adrift_threshold},
         "deprecated, does nothing",
         "threshold"},
#endif
        {"copyts", OPT_BOOL | OPT_EXPERT, {&copy_ts}, "copy timestamps"},
        {"start_at_zero",
         OPT_BOOL | OPT_EXPERT,
         {&start_at_zero},
         "shift input timestamps to start at 0 when using copyts"},
        {"copytb",
         HAS_ARG | OPT_INT | OPT_EXPERT,
         {&copy_tb},
         "copy input stream time base when stream copying",
         "mode"},
        {"shortest",
         OPT_BOOL | OPT_EXPERT | OPT_OFFSET | OPT_OUTPUT,
         {.off = OFFSET(shortest)},
         "finish encoding within shortest input"},
        {"shortest_buf_duration",
         HAS_ARG | OPT_FLOAT | OPT_EXPERT | OPT_OFFSET | OPT_OUTPUT,
         {.off = OFFSET(shortest_buf_duration)},
         "maximum buffering duration (in seconds) for the -shortest option"},
        {"bitexact",
         OPT_BOOL | OPT_EXPERT | OPT_OFFSET | OPT_OUTPUT | OPT_INPUT,
         {.off = OFFSET(bitexact)},
         "bitexact mode"},
        {"apad",
         OPT_STRING | HAS_ARG | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(apad)},
         "audio pad",
         ""},
        {"dts_delta_threshold",
         HAS_ARG | OPT_FLOAT | OPT_EXPERT,
         {&dts_delta_threshold},
         "timestamp discontinuity delta threshold",
         "threshold"},
        {"dts_error_threshold",
         HAS_ARG | OPT_FLOAT | OPT_EXPERT,
         {&dts_error_threshold},
         "timestamp error delta threshold",
         "threshold"},
        {"xerror",
         OPT_BOOL | OPT_EXPERT,
         {&exit_on_error},
         "exit on error",
         "error"},
        {"abort_on",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_abort_on},
         "abort on the specified condition flags",
         "flags"},
        {"copyinkf",
         OPT_BOOL | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(copy_initial_nonkeyframes)},
         "copy initial non-keyframes"},
        {"copypriorss",
         OPT_INT | HAS_ARG | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(copy_prior_start)},
         "copy or discard frames before start time"},
        {"frames",
         OPT_INT64 | HAS_ARG | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(max_frames)},
         "set the number of frames to output",
         "number"},
        {"tag",
         OPT_STRING | HAS_ARG | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT | OPT_INPUT,
         {.off = OFFSET(codec_tags)},
         "force codec tag/fourcc",
         "fourcc/tag"},
        {"q",
         HAS_ARG | OPT_EXPERT | OPT_DOUBLE | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(qscale)},
         "use fixed quality scale (VBR)",
         "q"},
        {"qscale",
         HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_qscale},
         "use fixed quality scale (VBR)",
         "q"},
        {"profile",
         HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_profile},
         "set profile",
         "profile"},
        {"filter",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(filters)},
         "set stream filtergraph",
         "filter_graph"},
        {"filter_threads",
         HAS_ARG,
         {.func_arg = opt_filter_threads},
         "number of non-complex filter threads"},
        {"filter_script",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(filter_scripts)},
         "read stream filtergraph description from a file",
         "filename"},
        {"reinit_filter",
         HAS_ARG | OPT_INT | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(reinit_filters)},
         "reinit filtergraph on input parameter changes",
         ""},
        {"filter_complex",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_filter_complex},
         "create a complex filtergraph",
         "graph_description"},
        {"filter_complex_threads",
         HAS_ARG | OPT_INT,
         {&filter_complex_nbthreads},
         "number of threads for -filter_complex"},
        {"lavfi",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_filter_complex},
         "create a complex filtergraph",
         "graph_description"},
        {"filter_complex_script",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_filter_complex_script},
         "read complex filtergraph description from a file",
         "filename"},
        {"auto_conversion_filters",
         OPT_BOOL | OPT_EXPERT,
         {&auto_conversion_filters},
         "enable automatic conversion filters globally"},
        {
            "stats",
            OPT_BOOL,
            {&print_stats},
            "print progress report during encoding",
        },
        {"stats_period",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_stats_period},
         "set the period at which ffmpeg updates stats and -progress output",
         "time"},
        {"attach",
         HAS_ARG | OPT_PERFILE | OPT_EXPERT | OPT_OUTPUT,
         {.func_arg = opt_attach},
         "add an attachment to the output file",
         "filename"},
        {"dump_attachment",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_EXPERT | OPT_INPUT,
         {.off = OFFSET(dump_attachment)},
         "extract an attachment into a file",
         "filename"},
        {"stream_loop",
         OPT_INT | HAS_ARG | OPT_EXPERT | OPT_INPUT | OPT_OFFSET,
         {.off = OFFSET(loop)},
         "set number of times input stream shall be looped",
         "loop count"},
        {"debug_ts",
         OPT_BOOL | OPT_EXPERT,
         {&debug_ts},
         "print timestamp debugging info"},
        {"max_error_rate",
         HAS_ARG | OPT_FLOAT,
         {&max_error_rate},
         "ratio of decoding errors (0.0: no errors, 1.0: 100% errors) above "
         "which ffmpeg returns an error instead of success.",
         "maximum error rate"},
        {"discard",
         OPT_STRING | HAS_ARG | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(discard)},
         "discard",
         ""},
        {"disposition",
         OPT_STRING | HAS_ARG | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(disposition)},
         "disposition",
         ""},
        {"thread_queue_size",
         HAS_ARG | OPT_INT | OPT_OFFSET | OPT_EXPERT | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(thread_queue_size)},
         "set the maximum number of queued packets from the demuxer"},
        {"find_stream_info",
         OPT_BOOL | OPT_INPUT | OPT_EXPERT | OPT_OFFSET,
         {.off = OFFSET(find_stream_info)},
         "read and decode the streams to fill missing information with "
         "heuristics"},
        {"bits_per_raw_sample",
         OPT_INT | HAS_ARG | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(bits_per_raw_sample)},
         "set the number of bits per raw sample",
         "number"},

        {"stats_enc_pre",
         HAS_ARG | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT | OPT_STRING,
         {.off = OFFSET(enc_stats_pre)},
         "write encoding stats before encoding"},
        {"stats_enc_post",
         HAS_ARG | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT | OPT_STRING,
         {.off = OFFSET(enc_stats_post)},
         "write encoding stats after encoding"},
        {"stats_mux_pre",
         HAS_ARG | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT | OPT_STRING,
         {.off = OFFSET(mux_stats)},
         "write packets stats before muxing"},
        {"stats_enc_pre_fmt",
         HAS_ARG | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT | OPT_STRING,
         {.off = OFFSET(enc_stats_pre_fmt)},
         "format of the stats written with -stats_enc_pre"},
        {"stats_enc_post_fmt",
         HAS_ARG | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT | OPT_STRING,
         {.off = OFFSET(enc_stats_post_fmt)},
         "format of the stats written with -stats_enc_post"},
        {"stats_mux_pre_fmt",
         HAS_ARG | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT | OPT_STRING,
         {.off = OFFSET(mux_stats_fmt)},
         "format of the stats written with -stats_mux_pre"},

        /* video options */
        {"vframes",
         OPT_VIDEO | HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_video_frames},
         "set the number of video frames to output",
         "number"},
        {"r",
         OPT_VIDEO | HAS_ARG | OPT_STRING | OPT_SPEC | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(frame_rates)},
         "set frame rate (Hz value, fraction or abbreviation)",
         "rate"},
        {"fpsmax",
         OPT_VIDEO | HAS_ARG | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(max_frame_rates)},
         "set max frame rate (Hz value, fraction or abbreviation)",
         "rate"},
        {"s",
         OPT_VIDEO | HAS_ARG | OPT_SUBTITLE | OPT_STRING | OPT_SPEC |
             OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(frame_sizes)},
         "set frame size (WxH or abbreviation)",
         "size"},
        {"aspect",
         OPT_VIDEO | HAS_ARG | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(frame_aspect_ratios)},
         "set aspect ratio (4:3, 16:9 or 1.3333, 1.7777)",
         "aspect"},
        {"pix_fmt",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_STRING | OPT_SPEC | OPT_INPUT |
             OPT_OUTPUT,
         {.off = OFFSET(frame_pix_fmts)},
         "set pixel format",
         "format"},
        {"display_rotation",
         OPT_VIDEO | HAS_ARG | OPT_DOUBLE | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(display_rotations)},
         "set pure counter-clockwise rotation in degrees for stream(s)",
         "angle"},
        {"display_hflip",
         OPT_VIDEO | OPT_BOOL | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(display_hflips)},
         "set display horizontal flip for stream(s) "
         "(overrides any display rotation if it is not set)"},
        {"display_vflip",
         OPT_VIDEO | OPT_BOOL | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(display_vflips)},
         "set display vertical flip for stream(s) "
         "(overrides any display rotation if it is not set)"},
        {"vn",
         OPT_VIDEO | OPT_BOOL | OPT_OFFSET | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(video_disable)},
         "disable video"},
        {"rc_override",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(rc_overrides)},
         "rate control override for specific intervals",
         "override"},
        {"vcodec",
         OPT_VIDEO | HAS_ARG | OPT_PERFILE | OPT_INPUT | OPT_OUTPUT,
         {.func_arg = opt_video_codec},
         "force video codec ('copy' to copy stream)",
         "codec"},
        {"timecode",
         OPT_VIDEO | HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_timecode},
         "set initial TimeCode value.",
         "hh:mm:ss[:;.]ff"},
        {"pass",
         OPT_VIDEO | HAS_ARG | OPT_SPEC | OPT_INT | OPT_OUTPUT,
         {.off = OFFSET(pass)},
         "select the pass number (1 to 3)",
         "n"},
        {"passlogfile",
         OPT_VIDEO | HAS_ARG | OPT_STRING | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(passlogfiles)},
         "select two pass log file name prefix",
         "prefix"},
#if FFMPEG_OPT_PSNR
        {"psnr",
         OPT_VIDEO | OPT_BOOL | OPT_EXPERT,
         {&do_psnr},
         "calculate PSNR of compressed frames (deprecated, use -flags +psnr)"},
#endif
        {"vstats",
         OPT_VIDEO | OPT_EXPERT,
         {.func_arg = opt_vstats},
         "dump video coding statistics to file"},
        {"vstats_file",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_vstats_file},
         "dump video coding statistics to file",
         "file"},
        {"vstats_version",
         OPT_VIDEO | OPT_INT | HAS_ARG | OPT_EXPERT,
         {&vstats_version},
         "Version of the vstats format to use."},
        {"vf",
         OPT_VIDEO | HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_video_filters},
         "set video filters",
         "filter_graph"},
        {"intra_matrix",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(intra_matrices)},
         "specify intra matrix coeffs",
         "matrix"},
        {"inter_matrix",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(inter_matrices)},
         "specify inter matrix coeffs",
         "matrix"},
        {"chroma_intra_matrix",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_STRING | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(chroma_intra_matrices)},
         "specify intra matrix coeffs",
         "matrix"},
#if FFMPEG_OPT_TOP
        {"top",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_INT | OPT_SPEC | OPT_INPUT |
             OPT_OUTPUT,
         {.off = OFFSET(top_field_first)},
         "deprecated, use the setfield video filter",
         ""},
#endif
        {"vtag",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_INPUT |
             OPT_OUTPUT,
         {.func_arg = opt_old2new},
         "force video tag/fourcc",
         "fourcc/tag"},
#if FFMPEG_OPT_QPHIST
        {"qphist",
         OPT_VIDEO | OPT_EXPERT,
         {.func_arg = opt_qphist},
         "deprecated, does nothing"},
#endif
        {"fps_mode",
         OPT_VIDEO | HAS_ARG | OPT_STRING | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(fps_mode)},
         "set framerate mode for matching video streams; overrides vsync"},
        {"force_fps",
         OPT_VIDEO | OPT_BOOL | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(force_fps)},
         "force the selected framerate, disable the best supported framerate "
         "selection"},
        {"streamid",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_streamid},
         "set the value of an outfile streamid",
         "streamIndex:value"},
        {"force_key_frames",
         OPT_VIDEO | OPT_STRING | HAS_ARG | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(forced_key_frames)},
         "force key frames at specified timestamps",
         "timestamps"},
        {"b",
         OPT_VIDEO | HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_bitrate},
         "video bitrate (please use -b:v)",
         "bitrate"},
        {"hwaccel",
         OPT_VIDEO | OPT_STRING | HAS_ARG | OPT_EXPERT | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(hwaccels)},
         "use HW accelerated decoding",
         "hwaccel name"},
        {"hwaccel_device",
         OPT_VIDEO | OPT_STRING | HAS_ARG | OPT_EXPERT | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(hwaccel_devices)},
         "select a device for HW acceleration",
         "devicename"},
        {"hwaccel_output_format",
         OPT_VIDEO | OPT_STRING | HAS_ARG | OPT_EXPERT | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(hwaccel_output_formats)},
         "select output format used with HW accelerated decoding",
         "format"},
        {"hwaccels",
         OPT_EXIT,
         {.func_arg = show_hwaccels},
         "show available HW acceleration methods"},
        {"autorotate",
         HAS_ARG | OPT_BOOL | OPT_SPEC | OPT_EXPERT | OPT_INPUT,
         {.off = OFFSET(autorotate)},
         "automatically insert correct rotate filters"},
        {"autoscale",
         HAS_ARG | OPT_BOOL | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT,
         {.off = OFFSET(autoscale)},
         "automatically insert a scale filter at the end of the filter graph"},
        {"fix_sub_duration_heartbeat",
         OPT_VIDEO | OPT_BOOL | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(fix_sub_duration_heartbeat)},
         "set this video output stream to be a heartbeat stream for "
         "fix_sub_duration, according to which subtitles should be split at "
         "random access points"},

        /* audio options */
        {"aframes",
         OPT_AUDIO | HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_audio_frames},
         "set the number of audio frames to output",
         "number"},
        {
            "aq",
            OPT_AUDIO | HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
            {.func_arg = opt_audio_qscale},
            "set audio quality (codec-specific)",
            "quality",
        },
        {"ar",
         OPT_AUDIO | HAS_ARG | OPT_INT | OPT_SPEC | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(audio_sample_rate)},
         "set audio sampling rate (in Hz)",
         "rate"},
        {"ac",
         OPT_AUDIO | HAS_ARG | OPT_INT | OPT_SPEC | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(audio_channels)},
         "set number of audio channels",
         "channels"},
        {"an",
         OPT_AUDIO | OPT_BOOL | OPT_OFFSET | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(audio_disable)},
         "disable audio"},
        {"acodec",
         OPT_AUDIO | HAS_ARG | OPT_PERFILE | OPT_INPUT | OPT_OUTPUT,
         {.func_arg = opt_audio_codec},
         "force audio codec ('copy' to copy stream)",
         "codec"},
        {"ab",
         OPT_AUDIO | HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_bitrate},
         "audio bitrate (please use -b:a)",
         "bitrate"},
        {"atag",
         OPT_AUDIO | HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_old2new},
         "force audio tag/fourcc",
         "fourcc/tag"},
        {"sample_fmt",
         OPT_AUDIO | HAS_ARG | OPT_EXPERT | OPT_SPEC | OPT_STRING | OPT_INPUT |
             OPT_OUTPUT,
         {.off = OFFSET(sample_fmts)},
         "set sample format",
         "format"},
        {"channel_layout",
         OPT_AUDIO | HAS_ARG | OPT_EXPERT | OPT_SPEC | OPT_STRING | OPT_INPUT |
             OPT_OUTPUT,
         {.off = OFFSET(audio_ch_layouts)},
         "set channel layout",
         "layout"},
        {"ch_layout",
         OPT_AUDIO | HAS_ARG | OPT_EXPERT | OPT_SPEC | OPT_STRING | OPT_INPUT |
             OPT_OUTPUT,
         {.off = OFFSET(audio_ch_layouts)},
         "set channel layout",
         "layout"},
        {"af",
         OPT_AUDIO | HAS_ARG | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_audio_filters},
         "set audio filters",
         "filter_graph"},
        {"guess_layout_max",
         OPT_AUDIO | HAS_ARG | OPT_INT | OPT_SPEC | OPT_EXPERT | OPT_INPUT,
         {.off = OFFSET(guess_layout_max)},
         "set the maximum number of channels to try to guess the channel "
         "layout"},

        /* subtitle options */
        {"sn",
         OPT_SUBTITLE | OPT_BOOL | OPT_OFFSET | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(subtitle_disable)},
         "disable subtitle"},
        {"scodec",
         OPT_SUBTITLE | HAS_ARG | OPT_PERFILE | OPT_INPUT | OPT_OUTPUT,
         {.func_arg = opt_subtitle_codec},
         "force subtitle codec ('copy' to copy stream)",
         "codec"},
        {"stag",
         OPT_SUBTITLE | HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_old2new},
         "force subtitle tag/fourcc",
         "fourcc/tag"},
        {"fix_sub_duration",
         OPT_BOOL | OPT_EXPERT | OPT_SUBTITLE | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(fix_sub_duration)},
         "fix subtitles duration"},
        {"canvas_size",
         OPT_SUBTITLE | HAS_ARG | OPT_STRING | OPT_SPEC | OPT_INPUT,
         {.off = OFFSET(canvas_sizes)},
         "set canvas size (WxH or abbreviation)",
         "size"},

        /* muxer options */
        {"muxdelay",
         OPT_FLOAT | HAS_ARG | OPT_EXPERT | OPT_OFFSET | OPT_OUTPUT,
         {.off = OFFSET(mux_max_delay)},
         "set the maximum demux-decode delay",
         "seconds"},
        {"muxpreload",
         OPT_FLOAT | HAS_ARG | OPT_EXPERT | OPT_OFFSET | OPT_OUTPUT,
         {.off = OFFSET(mux_preload)},
         "set the initial demux-decode delay",
         "seconds"},
        {"sdp_file",
         HAS_ARG | OPT_EXPERT | OPT_OUTPUT,
         {.func_arg = opt_sdp_file},
         "specify a file in which to print sdp information",
         "file"},

        {"time_base",
         HAS_ARG | OPT_STRING | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(time_bases)},
         "set the desired time base hint for output stream (1:24, 1:48000 or "
         "0.04166, 2.0833e-5)",
         "ratio"},
        {"enc_time_base",
         HAS_ARG | OPT_STRING | OPT_EXPERT | OPT_SPEC | OPT_OUTPUT,
         {.off = OFFSET(enc_time_bases)},
         "set the desired time base for the encoder (1:24, 1:48000 or 0.04166, "
         "2.0833e-5). "
         "two special values are defined - "
         "0 = use frame rate (video) or sample rate (audio),"
         "-1 = match source time base",
         "ratio"},

        {"bsf",
         HAS_ARG | OPT_STRING | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT,
         {.off = OFFSET(bitstream_filters)},
         "A comma-separated list of bitstream filters",
         "bitstream_filters"},
        {"absf",
         HAS_ARG | OPT_AUDIO | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_old2new},
         "deprecated",
         "audio bitstream_filters"},
        {"vbsf",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_old2new},
         "deprecated",
         "video bitstream_filters"},

        {"apre",
         HAS_ARG | OPT_AUDIO | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_preset},
         "set the audio options to the indicated preset",
         "preset"},
        {"vpre",
         OPT_VIDEO | HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_preset},
         "set the video options to the indicated preset",
         "preset"},
        {"spre",
         HAS_ARG | OPT_SUBTITLE | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_preset},
         "set the subtitle options to the indicated preset",
         "preset"},
        {"fpre",
         HAS_ARG | OPT_EXPERT | OPT_PERFILE | OPT_OUTPUT,
         {.func_arg = opt_preset},
         "set options from indicated preset file",
         "filename"},

        {"max_muxing_queue_size",
         HAS_ARG | OPT_INT | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT,
         {.off = OFFSET(max_muxing_queue_size)},
         "maximum number of packets that can be buffered while waiting for all "
         "streams to initialize",
         "packets"},
        {"muxing_queue_data_threshold",
         HAS_ARG | OPT_INT | OPT_SPEC | OPT_EXPERT | OPT_OUTPUT,
         {.off = OFFSET(muxing_queue_data_threshold)},
         "set the threshold after which max_muxing_queue_size is taken into "
         "account",
         "bytes"},

        /* data codec support */
        {"dcodec",
         HAS_ARG | OPT_DATA | OPT_PERFILE | OPT_EXPERT | OPT_INPUT | OPT_OUTPUT,
         {.func_arg = opt_data_codec},
         "force data codec ('copy' to copy stream)",
         "codec"},
        {"dn",
         OPT_BOOL | OPT_VIDEO | OPT_OFFSET | OPT_INPUT | OPT_OUTPUT,
         {.off = OFFSET(data_disable)},
         "disable data"},

#if CONFIG_VAAPI
        {"vaapi_device",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_vaapi_device},
         "set VAAPI hardware device (DirectX adapter index, DRM path or X11 "
         "display name)",
         "device"},
#endif

#if CONFIG_QSV
        {"qsv_device",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_qsv_device},
         "set QSV hardware device (DirectX adapter index, DRM path or X11 "
         "display name)",
         "device"},
#endif

        {"init_hw_device",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_init_hw_device},
         "initialise hardware device",
         "args"},
        {"filter_hw_device",
         HAS_ARG | OPT_EXPERT,
         {.func_arg = opt_filter_hw_device},
         "set hardware device used when filtering",
         "device"},

        {
            NULL,
        },
    };

    ffmpeg_options = options;

    int err_rate_exceeded;
    BenchmarkTimeStamps ti;

    int savedCode = setjmp(ex_buf__);
    if (savedCode == 0) {

        ffmpeg_var_cleanup();

        init_dynload();

        setvbuf(stderr, NULL, _IONBF, 0); /* win32 runtime needs this */

        av_log_set_flags(AV_LOG_SKIP_REPEATED);
        parse_loglevel(argc, argv, options);

#if CONFIG_AVDEVICE
        avdevice_register_all();
#endif
        avformat_network_init();

        show_banner(argc, argv, options);

        /* parse options and open all input/output files */
        main_ffmpeg_return_code = ffmpeg_parse_options(argc, argv);
        if (main_ffmpeg_return_code < 0)
            goto finish;

        if (nb_output_files <= 0 && nb_input_files == 0) {
            show_usage();
            av_log(NULL, AV_LOG_WARNING,
                   "Use -h to get full help or, even better, run 'man %s'\n",
                   program_name);
            main_ffmpeg_return_code = 1;
            goto finish;
        }

        if (nb_output_files <= 0) {
            av_log(NULL, AV_LOG_FATAL,
                   "At least one output file must be specified\n");
            main_ffmpeg_return_code = 1;
            goto finish;
        }

        current_time = ti = get_benchmark_time_stamps();
        main_ffmpeg_return_code = transcode(&err_rate_exceeded);
        if (main_ffmpeg_return_code >= 0 && do_benchmark) {
            int64_t utime, stime, rtime;
            current_time = get_benchmark_time_stamps();
            utime = current_time.user_usec - ti.user_usec;
            stime = current_time.sys_usec - ti.sys_usec;
            rtime = current_time.real_usec - ti.real_usec;
            av_log(NULL, AV_LOG_INFO,
                   "bench: utime=%0.3fs stime=%0.3fs rtime=%0.3fs\n",
                   utime / 1000000.0, stime / 1000000.0, rtime / 1000000.0);
        }

        main_ffmpeg_return_code =
            (received_nb_signals || cancelRequested(globalSessionId)) ? 255
            : err_rate_exceeded                                       ? 69
                                : main_ffmpeg_return_code;
    } else {
        main_ffmpeg_return_code =
            (received_nb_signals || cancelRequested(globalSessionId))
                ? 255
                : savedCode;
    }

finish:
    if (main_ffmpeg_return_code == AVERROR_EXIT)
        main_ffmpeg_return_code = 0;

    ffmpeg_cleanup(main_ffmpeg_return_code);
    return main_ffmpeg_return_code;
}
