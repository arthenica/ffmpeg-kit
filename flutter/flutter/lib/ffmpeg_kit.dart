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

import 'ffmpeg_kit_config.dart';
import 'ffmpeg_session.dart';
import 'ffmpeg_session_complete_callback.dart';
import 'log_callback.dart';
import 'src/ffmpeg_kit_factory.dart';
import 'statistics_callback.dart';

/// Main class to run "FFmpeg" commands.
class FFmpegKit {
  static FFmpegKitPlatform _platform = FFmpegKitPlatform.instance;

  /// Synchronously executes FFmpeg command provided. Space character is used
  /// to split command into arguments. You can use single or double quote
  /// characters to specify arguments inside your command.
  static Future<FFmpegSession> execute(String command) async =>
      FFmpegKit.executeWithArguments(FFmpegKitConfig.parseArguments(command));

  /// Synchronously executes FFmpeg with arguments provided.
  static Future<FFmpegSession> executeWithArguments(
      List<String> commandArguments) async {
    final session =
        await FFmpegSession.create(commandArguments, null, null, null, null);

    await FFmpegKitConfig.ffmpegExecute(session);

    return session;
  }

  /// Starts an asynchronous FFmpeg execution for the given command. Space character is used to split the command
  /// into arguments. You can use single or double quote characters to specify arguments inside your command.
  ///
  /// Note that this method returns immediately and does not wait the execution to complete. You must use an
  /// [FFmpegSessionCompleteCallback] if you want to be notified about the result.
  static Future<FFmpegSession> executeAsync(String command,
          [FFmpegSessionCompleteCallback? completeCallback = null,
          LogCallback? logCallback = null,
          StatisticsCallback? statisticsCallback = null]) async =>
      FFmpegKit.executeWithArgumentsAsync(
          FFmpegKitConfig.parseArguments(command),
          completeCallback,
          logCallback,
          statisticsCallback);

  /// Starts an asynchronous FFmpeg execution with arguments provided.
  ///
  /// Note that this method returns immediately and does not wait the execution to complete. You must use an
  /// [FFmpegSessionCompleteCallback] if you want to be notified about the result.
  static Future<FFmpegSession> executeWithArgumentsAsync(
      List<String> commandArguments,
      [FFmpegSessionCompleteCallback? completeCallback = null,
      LogCallback? logCallback = null,
      StatisticsCallback? statisticsCallback = null]) async {
    final session = await FFmpegSession.create(commandArguments,
        completeCallback, logCallback, statisticsCallback, null);

    await FFmpegKitConfig.asyncFFmpegExecute(session);

    return session;
  }

  /// Cancels the session specified with [sessionId].
  static Future<void> cancel([int? sessionId = null]) async {
    try {
      await FFmpegKitConfig.init();
      if (sessionId == null) {
        return _platform.ffmpegKitCancel();
      } else {
        return _platform.ffmpegKitCancelSession(sessionId);
      }
    } on PlatformException catch (e, stack) {
      print("Plugin cancel error: ${e.message}");
      return Future.error("cancel failed.", stack);
    }
  }

  /// Lists all FFmpeg sessions in the session history.
  static Future<List<FFmpegSession>> listSessions() async {
    try {
      await FFmpegKitConfig.init();
      return _platform.ffmpegKitListSessions().then((sessions) {
        if (sessions == null) {
          return List.empty();
        } else {
          return sessions
              .map((dynamic sessionObject) => FFmpegKitFactory.mapToSession(
                  sessionObject as Map<dynamic, dynamic>))
              .map((session) => session as FFmpegSession)
              .toList();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin listSessions error: ${e.message}");
      return Future.error("listSessions failed.", stack);
    }
  }
}
