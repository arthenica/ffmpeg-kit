lib_LTLIBRARIES = libffmpegkit.la

libffmpegkit_la_LIBADD = @FFMPEG_LIBS@

libffmpegkit_la_SOURCES = \
    AbstractSession.cpp \
    ArchDetect.cpp \
    Chapter.cpp \
    FFmpegKit.cpp \
    FFmpegKitConfig.cpp \
    FFmpegSession.cpp \
    FFprobeKit.cpp \
    FFprobeSession.cpp \
    Log.cpp \
    MediaInformation.cpp \
    MediaInformationJsonParser.cpp \
    MediaInformationSession.cpp \
    Packages.cpp \
    ReturnCode.cpp \
    Statistics.cpp \
    StreamInformation.cpp \
    ffmpegkit_exception.cpp \
    fftools_cmdutils.c \
    fftools_ffmpeg.c \
    fftools_ffmpeg_demux.c \
    fftools_ffmpeg_filter.c \
    fftools_ffmpeg_hw.c \
    fftools_ffmpeg_mux.c \
    fftools_ffmpeg_mux_init.c \
    fftools_ffmpeg_opt.c \
    fftools_ffprobe.c \
    fftools_objpool.c \
    fftools_opt_common.c \
    fftools_sync_queue.c \
    fftools_thread_queue.c

include_HEADERS = \
    AbstractSession.h \
    ArchDetect.h \
    Chapter.h \
    FFmpegKit.h \
    FFmpegKitConfig.h \
    FFmpegSession.h \
    FFmpegSessionCompleteCallback.h \
    FFprobeKit.h \
    FFprobeSession.h \
    FFprobeSessionCompleteCallback.h \
    Level.h \
    Log.h \
    LogCallback.h \
    LogRedirectionStrategy.h \
    MediaInformation.h \
    MediaInformationJsonParser.h \
    MediaInformationSession.h \
    MediaInformationSessionCompleteCallback.h \
    Packages.h \
    ReturnCode.h \
    Session.h \
    SessionState.h \
    Signal.h \
    Statistics.h \
    StatisticsCallback.h \
    StreamInformation.h \
    ffmpegkit_exception.h \
    fftools_cmdutils.h \
    fftools_ffmpeg.h \
    fftools_ffmpeg_mux.h \
    fftools_fopen_utf8.h \
    fftools_objpool.h \
    fftools_opt_common.h \
    fftools_sync_queue.h \
    fftools_thread_queue.h

libffmpegkit_la_CFLAGS = $(CFLAGS)
libffmpegkit_la_OBJCFLAGS = $(CFLAGS)
libffmpegkit_la_CXXFLAGS = $(CXXFLAGS)
libffmpegkit_la_LDFLAGS = -version-info @VERSION_INFO@
