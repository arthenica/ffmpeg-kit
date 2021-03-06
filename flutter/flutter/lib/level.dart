/*
 * Copyright (c) 2019-2021 Taner Sener
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

/// Defines log levels.
class Level {
  /// This log level is defined by FFmpegKit. It is used to specify logs
  /// printed to stderr by FFmpeg. Logs that has this level are not filtered
  /// and always redirected.
  static const int avLogStderr = -16;

  /// Print no output.
  static const int avLogQuiet = -8;

  /// Something went really wrong and we will crash now.
  static const int avLogPanic = 0;

  /// Something went wrong and recovery is not possible.
  /// For example, no header was found for a format which depends
  /// on headers or an illegal combination of parameters is used.
  static const int avLogFatal = 8;

  /// Something went wrong and cannot losslessly be recovered.
  /// However, not all future data is affected.
  static const int avLogError = 16;

  /// Something somehow does not look correct. This may or may not
  /// lead to problems. An example would be the use of '-vstrict -2'.
  static const int avLogWarning = 24;

  /// int Standard information.
  static const int avLogInfo = 32;

  /// Detailed information.
  static const int avLogVerbose = 40;

  /// Stuff which is only useful for libav* developers.
  static const int avLogDebug = 48;

  /// Extremely verbose debugging, useful for libav* development.
  static const int avLogTrace = 56;

  /// Returns log level string from int
  static String levelToString(int level) {
    switch (level) {
      case Level.avLogTrace:
        return "TRACE";
      case Level.avLogDebug:
        return "DEBUG";
      case Level.avLogVerbose:
        return "VERBOSE";
      case Level.avLogInfo:
        return "INFO";
      case Level.avLogWarning:
        return "WARNING";
      case Level.avLogError:
        return "ERROR";
      case Level.avLogFatal:
        return "FATAL";
      case Level.avLogPanic:
        return "PANIC";
      case Level.avLogStderr:
        return "STDERR";
      case Level.avLogQuiet:
      default:
        return "";
    }
  }
}
