lib_LTLIBRARIES = libffmpegkit.la

libffmpegkit_la_LIBADD = @FFMPEG_LIBS@

libffmpegkit_la_SOURCES = \
    ArchDetect.m \
    AtomicLong.m \
    FFmpegExecution.m \
    FFmpegKit.m \
    ffmpegkit_exception.m \
    FFmpegKitConfig.m \
    FFprobeKit.m \
    fftools_cmdutils.c \
    fftools_ffmpeg.c \
    fftools_ffmpeg_filter.c \
    fftools_ffmpeg_hw.c \
    fftools_ffmpeg_opt.c \
    fftools_ffprobe.c \
    MediaInformation.m \
    MediaInformationParser.m \
    Statistics.m \
    StreamInformation.m

if FFMPEGKIT_VIDEOTOOLBOX
    libffmpegkit_la_SOURCES += fftools_ffmpeg_videotoolbox.c
endif

include_HEADERS = \
    ArchDetect.h \
    AtomicLong.h \
    ExecuteDelegate.h \
    FFmpegExecution.h \
    FFmpegKit.h \
	ffmpegkit_exception.h \
    FFmpegKitConfig.h \
	FFprobeKit.h \
	fftools_cmdutils.h \
    fftools_ffmpeg.h \
	LogDelegate.h \
	MediaInformation.h \
	MediaInformationParser.h \
	Statistics.h \
	StatisticsDelegate.h \
	StreamInformation.h

libffmpegkit_la_CFLAGS = $(CFLAGS)
libffmpegkit_la_OBJCFLAGS = $(CFLAGS)
libffmpegkit_la_CXXFLAGS = $(CXXFLAGS)
libffmpegkit_la_LDFLAGS = $(LDFLAGS)
