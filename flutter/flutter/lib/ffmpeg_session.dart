/*
 * Copyright (c) 2019-2022 Taner Sener
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

import 'package:ffmpeg_kit_flutter_platform_interface/ffmpeg_kit_flutter_platform_interface.dart';
import 'package:flutter/services.dart';

import 'abstract_session.dart';
import 'ffmpeg_kit_config.dart';
import 'ffmpeg_session_complete_callback.dart';
import 'log_callback.dart';
import 'log_redirection_strategy.dart';
import 'src/ffmpeg_kit_factory.dart';
import 'statistics.dart';
import 'statistics_callback.dart';

/// An FFmpeg session.
class FFmpegSession extends AbstractSession {
  /// Creates a new FFmpeg session with [argumentsArray].
  static Future<FFmpegSession> create(List<String> argumentsArray,
      [FFmpegSessionCompleteCallback? completeCallback = null,
      LogCallback? logCallback = null,
      StatisticsCallback? statisticsCallback = null,
      LogRedirectionStrategy? logRedirectionStrategy = null]) async {
    final session = await AbstractSession.createFFmpegSession(
        argumentsArray, logRedirectionStrategy);
    final sessionId = session.getSessionId();

    FFmpegKitFactory.setFFmpegSessionCompleteCallback(
        sessionId, completeCallback);
    FFmpegKitFactory.setLogCallback(sessionId, logCallback);
    FFmpegKitFactory.setStatisticsCallback(sessionId, statisticsCallback);

    return session;
  }

  /// Returns the session specific statistics callback.
  StatisticsCallback? getStatisticsCallback() =>
      FFmpegKitFactory.getStatisticsCallback(this.getSessionId());

  /// Returns the session specific complete callback.
  FFmpegSessionCompleteCallback? getCompleteCallback() =>
      FFmpegKitFactory.getFFmpegSessionCompleteCallback(this.getSessionId());

  /// Returns all statistics entries generated for this session. If there are
  /// asynchronous statistics that are not delivered yet, this method waits for
  /// them until [waitTimeout].
  Future<List<Statistics>> getAllStatistics([int? waitTimeout]) async {
    try {
      await FFmpegKitConfig.init();
      return FFmpegKitPlatform.instance
          .ffmpegSessionGetAllStatistics(this.getSessionId(), waitTimeout)
          .then((allStatistics) {
        if (allStatistics == null) {
          return List.empty();
        } else {
          return allStatistics
              .map((dynamic statisticsObject) =>
                  FFmpegKitFactory.mapToStatistics(
                      statisticsObject as Map<dynamic, dynamic>))
              .toList();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getAllStatistics error: ${e.message}");
      return Future.error("getAllStatistics failed.", stack);
    }
  }

  /// Returns all statistics entries delivered for this session. Note that if
  /// there are asynchronous statistics that are not delivered yet, this method
  /// will not wait for them and will return immediately.
  Future<List<Statistics>> getStatistics() async {
    try {
      await FFmpegKitConfig.init();
      return FFmpegKitPlatform.instance
          .ffmpegSessionGetStatistics(this.getSessionId())
          .then((statistics) {
        if (statistics == null) {
          return List.empty();
        } else {
          return statistics
              .map((dynamic statisticsObject) =>
                  FFmpegKitFactory.mapToStatistics(
                      statisticsObject as Map<dynamic, dynamic>))
              .toList();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getStatistics error: ${e.message}");
      return Future.error("getStatistics failed.", stack);
    }
  }

  /// Returns the last received statistics entry.
  Future<Statistics?> getLastReceivedStatistics() async =>
      this.getStatistics().then((statistics) {
        if (statistics.length > 0) {
          return statistics[statistics.length - 1];
        } else {
          return null;
        }
      });

  bool isFFmpeg() => true;

  bool isFFprobe() => false;

  bool isMediaInformation() => false;
}
