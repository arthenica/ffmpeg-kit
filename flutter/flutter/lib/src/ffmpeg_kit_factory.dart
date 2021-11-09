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

import '../execute_callback.dart';
import '../ffmpeg_session.dart';
import '../ffprobe_session.dart';
import '../log.dart';
import '../log_callback.dart';
import '../log_redirection_strategy.dart';
import '../media_information_session.dart';
import '../session.dart';
import '../statistics.dart';
import '../statistics_callback.dart';

final executeCallbackMap = new Map<int, ExecuteCallback>();
final logCallbackMap = new Map<int, LogCallback>();
final statisticsCallbackMap = new Map<int, StatisticsCallback>();
final logRedirectionStrategyMap = new Map<int, LogRedirectionStrategy>();

class FFmpegKitFactory {
  static LogCallback? _logCallback;
  static StatisticsCallback? _statisticsCallback;
  static ExecuteCallback? _executeCallback;

  static Statistics mapToStatistics(Map<dynamic, dynamic> statisticsMap) =>
      new Statistics(
          statisticsMap["sessionId"],
          statisticsMap["videoFrameNumber"],
          statisticsMap["videoFps"],
          statisticsMap["videoQuality"],
          statisticsMap["size"],
          statisticsMap["time"],
          statisticsMap["bitrate"],
          statisticsMap["speed"]);

  static Log mapToLog(Map<dynamic, dynamic> logMap) =>
      new Log(logMap["sessionId"], logMap["level"], logMap["message"]);

  static Session mapToSession(Map<dynamic, dynamic> sessionMap) {
    switch (sessionMap["type"]) {
      case 2:
        return FFprobeSession.fromMap(sessionMap);
      case 3:
        return MediaInformationSession.fromMap(sessionMap);
      case 1:
      default:
        return FFmpegSession.fromMap(sessionMap);
    }
  }

  static Session? mapToNullableSession(Map<dynamic, dynamic>? sessionMap) {
    if (sessionMap != null) {
      switch (sessionMap["type"]) {
        case 2:
          return FFprobeSession.fromMap(sessionMap);
        case 3:
          return MediaInformationSession.fromMap(sessionMap);
        case 1:
        default:
          return FFmpegSession.fromMap(sessionMap);
      }
    } else {
      return null;
    }
  }

  static String getVersion() => "4.5.0";

  static LogRedirectionStrategy? getLogRedirectionStrategy(int? sessionId) =>
      logRedirectionStrategyMap[sessionId];

  static void setLogRedirectionStrategy(
      int? sessionId, LogRedirectionStrategy? logRedirectionStrategy) {
    if (sessionId != null && logRedirectionStrategy != null) {
      logRedirectionStrategyMap[sessionId] = logRedirectionStrategy;
    }
  }

  static LogCallback? getLogCallback(int? sessionId) =>
      logCallbackMap[sessionId];

  static void setLogCallback(int? sessionId, LogCallback? logCallback) {
    if (sessionId != null && logCallback != null) {
      logCallbackMap[sessionId] = logCallback;
    }
  }

  static LogCallback? getGlobalLogCallback() => _logCallback;

  static void setGlobalLogCallback(LogCallback? logCallback) {
    _logCallback = logCallback;
  }

  static StatisticsCallback? getStatisticsCallback(int? sessionId) =>
      statisticsCallbackMap[sessionId];

  static void setStatisticsCallback(
      int? sessionId, StatisticsCallback? statisticsCallback) {
    if (sessionId != null && statisticsCallback != null) {
      statisticsCallbackMap[sessionId] = statisticsCallback;
    }
  }

  static StatisticsCallback? getGlobalStatisticsCallback() =>
      _statisticsCallback;

  static void setGlobalStatisticsCallback(
      StatisticsCallback? statisticsCallback) {
    _statisticsCallback = statisticsCallback;
  }

  static ExecuteCallback? getExecuteCallback(int? sessionId) =>
      executeCallbackMap[sessionId];

  static void setExecuteCallback(
      int? sessionId, ExecuteCallback? executeCallback) {
    if (sessionId != null && executeCallback != null) {
      executeCallbackMap[sessionId] = executeCallback;
    }
  }

  static ExecuteCallback? getGlobalExecuteCallback() => _executeCallback;

  static void setGlobalExecuteCallback(ExecuteCallback? executeCallback) {
    _executeCallback = executeCallback;
  }

  static DateTime? validDate(int? time) {
    if (time == null || time <= 0) {
      return null;
    } else {
      return DateTime.fromMillisecondsSinceEpoch(time, isUtc: false);
    }
  }
}
