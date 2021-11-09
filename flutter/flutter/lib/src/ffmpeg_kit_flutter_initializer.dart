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

import 'dart:io';

import 'package:ffmpeg_kit_flutter_platform_interface/ffmpeg_kit_flutter_platform_interface.dart';
import 'package:flutter/services.dart';

import '../arch_detect.dart';
import '../execute_callback.dart';
import '../ffmpeg_kit_config.dart';
import '../ffmpeg_session.dart';
import '../level.dart';
import '../log_callback.dart';
import '../log_redirection_strategy.dart';
import '../packages.dart';
import '../session.dart';
import '../statistics.dart';
import '../statistics_callback.dart';
import 'ffmpeg_kit_factory.dart';

class FFmpegKitInitializer {
  static FFmpegKitPlatform _platform = FFmpegKitPlatform.instance;
  static const EventChannel _eventChannel =
      const EventChannel('flutter.arthenica.com/ffmpeg_kit_event');

  static FFmpegKitInitializer _instance = new FFmpegKitInitializer();

  static bool _initialized = false;

  static Future<bool> initialize() async {
    if (!_initialized) {
      _initialized = true;
      await _instance._initialize();
    }
    return _initialized;
  }

  void _onEvent(dynamic event) {
    if (event is Map<dynamic, dynamic>) {
      final Map<String, dynamic> eventMap = event.cast<String, dynamic>();
      final Map<dynamic, dynamic>? logEvent =
          eventMap['FFmpegKitLogCallbackEvent'];
      final Map<dynamic, dynamic>? statisticsEvent =
          eventMap['FFmpegKitStatisticsCallbackEvent'];
      final Map<dynamic, dynamic>? executeEvent =
          eventMap['FFmpegKitExecuteCallbackEvent'];

      if (logEvent != null) {
        _processLogCallbackEvent(logEvent);
      }

      if (statisticsEvent != null) {
        _processStatisticsCallbackEvent(statisticsEvent);
      }

      if (executeEvent != null) {
        _processExecuteCallbackEvent(executeEvent);
      }
    }
  }

  void _onError(Object error) {
    print('Event error: $error');
  }

  void _processLogCallbackEvent(Map<dynamic, dynamic> event) {
    final log = FFmpegKitFactory.mapToLog(event);
    final int sessionId = event["sessionId"];
    final int level = event["level"];
    final String text = event["message"];
    final int activeLogLevel = FFmpegKitConfig.getLogLevel();
    var globalCallbackDefined = false;
    var sessionCallbackDefined = false;
    LogRedirectionStrategy activeLogRedirectionStrategy =
        FFmpegKitConfig.getLogRedirectionStrategy();

    // avLogStderr logs are always redirected
    if ((activeLogLevel == Level.avLogQuiet && level != Level.avLogStderr) ||
        level > activeLogLevel) {
      // LOG NEITHER PRINTED NOR FORWARDED
      return;
    }

    FFmpegKitConfig.getSession(sessionId).then((Session? session) {
      activeLogRedirectionStrategy =
          session?.getLogRedirectionStrategy() ?? activeLogRedirectionStrategy;
      final LogCallback? logCallback = session?.getLogCallback();

      if (logCallback != null) {
        sessionCallbackDefined = true;

        try {
          // NOTIFY SESSION CALLBACK DEFINED
          logCallback(log);
        } on Exception catch (e, stack) {
          print("Exception thrown inside session LogCallback block. $e");
          print(stack);
        }
      }

      final globalLogCallbackFunction = FFmpegKitFactory.getGlobalLogCallback();
      if (globalLogCallbackFunction != null) {
        globalCallbackDefined = true;

        try {
          // NOTIFY GLOBAL CALLBACK DEFINED
          globalLogCallbackFunction(log);
        } on Exception catch (e, stack) {
          print("Exception thrown inside global LogCallback block. $e");
          print(stack);
        }
      }

      // EXECUTE THE LOG STRATEGY
      switch (activeLogRedirectionStrategy) {
        case LogRedirectionStrategy.neverPrintLogs:
          {
            return;
          }
        case LogRedirectionStrategy.printLogsWhenGlobalCallbackNotDefined:
          {
            if (globalCallbackDefined) {
              return;
            }
          }
          break;
        case LogRedirectionStrategy.printLogsWhenSessionCallbackNotDefined:
          {
            if (sessionCallbackDefined) {
              return;
            }
          }
          break;
        case LogRedirectionStrategy.printLogsWhenNoCallbacksDefined:
          {
            if (globalCallbackDefined || sessionCallbackDefined) {
              return;
            }
          }
          break;
        case LogRedirectionStrategy.alwaysPrintLogs:
          {}
          break;
      }

      // PRINT LOGS
      switch (level) {
        case Level.avLogQuiet:
          {
            // PRINT NO OUTPUT
          }
          break;
        default:
          {
            stdout.write(text);
          }
      }
    });
  }

  void _processStatisticsCallbackEvent(Map<dynamic, dynamic> event) {
    final Statistics statistics = FFmpegKitFactory.mapToStatistics(event);
    final int sessionId = event["sessionId"];

    FFmpegKitConfig.getSession(sessionId).then((Session? session) {
      if (session != null && session.isFFmpeg()) {
        final FFmpegSession ffmpegSession = session as FFmpegSession;
        final StatisticsCallback? statisticsCallback =
            ffmpegSession.getStatisticsCallback();

        if (statisticsCallback != null) {
          try {
            // NOTIFY SESSION CALLBACK DEFINED
            statisticsCallback(statistics);
          } on Exception catch (e, stack) {
            print(
                "Exception thrown inside session StatisticsCallback block. $e");
            print(stack);
          }
        }
      }

      final globalStatisticsCallbackFunction =
          FFmpegKitFactory.getGlobalStatisticsCallback();
      if (globalStatisticsCallbackFunction != null) {
        try {
          // NOTIFY GLOBAL CALLBACK DEFINED
          globalStatisticsCallbackFunction(statistics);
        } on Exception catch (e, stack) {
          print("Exception thrown inside global StatisticsCallback block. $e");
          print(stack);
        }
      }
    });
  }

  void _processExecuteCallbackEvent(Map<dynamic, dynamic> event) {
    final int sessionId = event["sessionId"];

    FFmpegKitConfig.getSession(sessionId).then((Session? session) {
      final ExecuteCallback? executeCallback = session?.getExecuteCallback();

      if (executeCallback != null && session != null) {
        try {
          // NOTIFY SESSION CALLBACK DEFINED
          executeCallback(session);
        } on Exception catch (e, stack) {
          print("Exception thrown inside session ExecuteCallback block. $e");
          print(stack);
        }
      }

      final globalExecuteCallbackFunction =
          FFmpegKitFactory.getGlobalExecuteCallback();
      if (globalExecuteCallbackFunction != null && session != null) {
        try {
          // NOTIFY GLOBAL CALLBACK DEFINED
          globalExecuteCallbackFunction(session);
        } on Exception catch (e, stack) {
          print("Exception thrown inside global ExecuteCallback block. $e");
          print(stack);
        }
      }
    });
  }

  Future<int?> _getLogLevel() async {
    try {
      return _platform.ffmpegKitFlutterInitializerGetLogLevel();
    } on PlatformException catch (e, stack) {
      print("Plugin _getLogLevel error: ${e.message}");
      return Future.error("_getLogLevel failed.", stack);
    }
  }

  Future<void> _initialize() async {
    print("Loading ffmpeg-kit-flutter.");

    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);

    final logLevel = await _getLogLevel();
    if (logLevel != null) {
      FFmpegKitConfig.setLogLevel(logLevel);
    }
    final version = FFmpegKitFactory.getVersion();
    final platform = await FFmpegKitConfig.getPlatform();
    final arch = await ArchDetect.getArch();
    final packageName = await Packages.getPackageName();
    await FFmpegKitConfig.enableRedirection();
    final isLTSPostfix = (await FFmpegKitConfig.isLTSBuild()) ? "-lts" : "";

    final fullVersion = "$platform-$packageName-$arch-$version$isLTSPostfix";
    print("Loaded ffmpeg-kit-flutter-$fullVersion.");
  }
}
