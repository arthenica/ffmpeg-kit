/*
 * Copyright (c) 2024 ARTHENICA LTD
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

#ifndef FFMPEG_CONTEXT_H
#define FFMPEG_CONTEXT_H

#include "fftools_ffmpeg.h"
#include "libavformat/avio.h"
#include "libavutil/dict.h"

extern __thread BenchmarkTimeStamps current_time;
#if HAVE_TERMIOS_H
#include <termios.h>
extern __thread struct termios oldtty;
#endif
extern __thread int restore_tty;
extern __thread volatile int received_sigterm;
extern __thread volatile int received_nb_signals;
extern __thread atomic_int transcode_init_done;
extern __thread volatile int ffmpeg_exited;
extern __thread int64_t copy_ts_first_pts;
extern __thread int nb_hw_devices;
extern __thread HWDevice **hw_devices;
extern __thread int want_sdp;
extern __thread struct EncStatsFile *enc_stats_files;
extern __thread int nb_enc_stats_files;
extern __thread float audio_drift_threshold;
extern __thread int file_overwrite;
extern __thread int no_file_overwrite;
extern __thread FILE *report_file;
extern __thread int report_file_level;
extern __thread int warned_cfg;

typedef struct FFmpegContext {

    // cmdutils.c
    AVDictionary *sws_dict;
    AVDictionary *swr_opts;
    AVDictionary *format_opts, *codec_opts;
    int hide_banner;
#if HAVE_COMMANDLINETOARGVW && defined(_WIN32)
    /* Will be leaked on exit */
    char **win32_argv_utf8;
    int win32_argc;
#endif

    // ffmpeg.c
    FILE *vstats_file;
    unsigned nb_output_dumped;
    BenchmarkTimeStamps current_time;
    AVIOContext *progress_avio;
    InputFile **input_files;
    int nb_input_files;
    OutputFile **output_files;
    int nb_output_files;
    FilterGraph **filtergraphs;
    int nb_filtergraphs;
#if HAVE_TERMIOS_H
    /* init terminal so that we can grab keys */
    struct termios oldtty;
    int restore_tty;
#endif
    volatile int received_sigterm;
    volatile int received_nb_signals;
    atomic_int transcode_init_done;
    volatile int ffmpeg_exited;
    int64_t copy_ts_first_pts;

    // ffmpeg_hw.c
    int nb_hw_devices;
    HWDevice **hw_devices;

    // ffmpeg_mux.c
    int want_sdp;

    // ffmpeg_mux_init.c
    EncStatsFile *enc_stats_files;
    int nb_enc_stats_files;

    // ffmpeg_opt.c
    HWDevice *filter_hw_device;
    char *vstats_filename;
    char *sdp_filename;
    float audio_drift_threshold;
    float dts_delta_threshold;
    float dts_error_threshold;
    enum VideoSyncMethod video_sync_method;
    float frame_drop_threshold;
    int do_benchmark;
    int do_benchmark_all;
    int do_hex_dump;
    int do_pkt_dump;
    int copy_ts;
    int start_at_zero;
    int copy_tb;
    int debug_ts;
    int exit_on_error;
    int abort_on_flags;
    int print_stats;
    int stdin_interaction;
    float max_error_rate;
    char *filter_nbthreads;
    int filter_complex_nbthreads;
    int vstats_version;
    int auto_conversion_filters;
    int64_t stats_period;
    int file_overwrite;
    int no_file_overwrite;
#if FFMPEG_OPT_PSNR
    int do_psnr;
#endif
    int ignore_unknown_streams;
    int copy_unknown_streams;
    int recast_media;

    // opt_common.c
    FILE *report_file;
    int report_file_level;
    int warned_cfg;

    void *arg;

} FFmpegContext;

FFmpegContext *saveFFmpegContext();
void loadFFmpegContext(FFmpegContext *context);

#endif // FFMPEG_CONTEXT_H