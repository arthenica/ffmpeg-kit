lib_LTLIBRARIES = libffmpegkit.la

libffmpegkit_la_LIBADD = @FFMPEG_FRAMEWORKS@

libffmpegkit_la_SOURCES = \
    AbstractSession.m \
    ArchDetect.m \
    AtomicLong.m \
    Chapter.m \
    FFmpegKit.m \
    FFmpegKitConfig.m \
    FFmpegSession.m \
    FFprobeKit.m \
    FFprobeSession.m \
    Log.m \
    MediaInformation.m \
    MediaInformationJsonParser.m \
    MediaInformationSession.m \
    Packages.m \
    ReturnCode.m \
    Statistics.m \
    StreamInformation.m \
    ffmpegkit_exception.m \
    fftools_cmdutils.c \
    fftools_ffmpeg.c \
    fftools_ffmpeg_filter.c \
    fftools_ffmpeg_hw.c \
    fftools_ffmpeg_opt.c \
    fftools_ffprobe.c

if FFMPEGKIT_VIDEOTOOLBOX
    libffmpegkit_la_SOURCES += fftools_ffmpeg_videotoolbox.c
endif

include_HEADERS = \
    AbstractSession.h \
    ArchDetect.h \
    AtomicLong.h \
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
    Statistics.h \
    StatisticsCallback.h \
    StreamInformation.h \
    ffmpegkit_exception.h \
    fftools_cmdutils.h \
    fftools_ffmpeg.h

libffmpegkit_la_CFLAGS = $(CFLAGS)
libffmpegkit_la_OBJCFLAGS = $(CFLAGS)
libffmpegkit_la_CXXFLAGS = $(CXXFLAGS)
libffmpegkit_la_LDFLAGS = $(LDFLAGS)
