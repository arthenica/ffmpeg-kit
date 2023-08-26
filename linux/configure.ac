# ffmpeg-kit 6.0 configure.ac

AC_INIT([ffmpeg-kit], [6.0], [https://github.com/arthenica/ffmpeg-kit/issues/new])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR([src/FFmpegKit.cpp])

AM_INIT_AUTOMAKE([-Wall -Werror foreign subdir-objects])
AM_MAINTAINER_MODE

# Check for os version
VERSION_OS=$(uname -s)
AC_DEFINE_UNQUOTED(VERSION_OS, "$VERSION_OS", [os version])

# Check host so we can infer target CPU (and assembly optimizations)
AC_CANONICAL_HOST

# Check for processor characteristics
AC_C_BIGENDIAN(AC_DEFINE([HIGHFIRST], [1], [big-endian machine]))

# Checks for programs.
cflags_bckup="$CFLAGS"
AC_LANG([C++])
AC_PROG_CXX(clang++ llvm-g++ g++)
AX_CXX_COMPILE_STDCXX(11, noext)
AM_PROG_AR
CFLAGS="$cflags_bckup"

FFMPEG_LIBS="-lavcodec -lavfilter -lavformat -lavutil -lswscale -lswresample"
AC_SUBST(FFMPEG_LIBS)

# CURRENT INTERFACE:REVISION:AGE
VERSION_INFO="11:0:6"
AC_SUBST(VERSION_INFO)

LT_INIT

# Checks for header files.
AC_CHECK_HEADERS([libavformat/avformat.h libavcodec/avcodec.h libavfilter/avfilter.h libavutil/avutil.h libswresample/swresample.h], [], [
  AC_MSG_ERROR([unable to find ffmpeg headers])
])
AC_CHECK_HEADERS([rapidjson/document.h], [], [
  AC_MSG_ERROR([unable to find rapidjson headers])
])
AC_CHECK_HEADERS([fcntl.h limits.h stdint.h stdlib.h string.h sys/ioctl.h sys/time.h termios.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_INLINE
AC_TYPE_INT32_T
AC_TYPE_INT64_T
AC_TYPE_INT8_T
AC_TYPE_SIZE_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T
AC_TYPE_UINT8_T

# Checks for library functions.
AC_CHECK_FUNCS([dup2 floor memmove memset select strchr strcspn strerror strrchr strstr strtol malloc strcpy strlen vsnprintf])

AC_CONFIG_FILES([Makefile src/Makefile])

AC_OUTPUT
