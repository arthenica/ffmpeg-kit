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
import 'ffprobe_session.dart';
import 'log.dart';
import 'log_callback.dart';
import 'log_redirection_strategy.dart';
import 'media_information.dart';
import 'media_information_session.dart';
import 'return_code.dart';
import 'session.dart';
import 'session_state.dart';
import 'src/ffmpeg_kit_factory.dart';

/// Abstract session implementation which includes common features shared by
/// "FFmpeg", "FFprobe" and "MediaInformation" sessions.
abstract class AbstractSession extends Session {
  static FFmpegKitPlatform _platform = FFmpegKitPlatform.instance;

  /// Defines how long default "getAll" methods wait, in milliseconds.
  static const defaultTimeoutForAsynchronousMessagesInTransmit = 5000;

  /// Session identifier.
  int? _sessionId;

  /// Date and time the session was created.
  DateTime? _createTime;

  /// Date and time the session was started.
  DateTime? _startTime;

  /// Command string.
  String? _command;

  /// Command arguments as an array.
  List<String>? _argumentsArray;

  /// Session specific log redirection strategy.
  LogRedirectionStrategy? _logRedirectionStrategy;

  /// Creates a new FFmpeg session using [argumentsArray] and
  /// [logRedirectionStrategy].
  ///
  /// Returns FFmpeg session created.
  static Future<FFmpegSession> createFFmpegSession(List<String> argumentsArray,
      [LogRedirectionStrategy? logRedirectionStrategy]) async {
    try {
      await FFmpegKitConfig.init();
      final Map<dynamic, dynamic>? nativeSession =
          await _platform.abstractSessionCreateFFmpegSession(argumentsArray);

      final session = new FFmpegSession();

      session._sessionId = nativeSession?["sessionId"];
      session._createTime =
          FFmpegKitFactory.validDate(nativeSession?["createTime"]);
      session._startTime =
          FFmpegKitFactory.validDate(nativeSession?["startTime"]);
      session._command = nativeSession?["command"];
      session._argumentsArray = argumentsArray;
      session._logRedirectionStrategy =
          logRedirectionStrategy ?? FFmpegKitConfig.getLogRedirectionStrategy();

      FFmpegKitFactory.setLogRedirectionStrategy(
          session._sessionId, logRedirectionStrategy);

      return session;
    } on PlatformException catch (e, stack) {
      print("Plugin createFFmpegSession error: ${e.message}");
      return Future.error("createFFmpegSession failed.", stack);
    }
  }

  /// Creates a new FFmpeg session from [sessionMap], which includes session
  /// fields as map keys.
  ///
  /// Returns FFmpeg session created.
  static FFmpegSession createFFmpegSessionFromMap(
      Map<dynamic, dynamic> sessionMap) {
    final session = new FFmpegSession();

    session._sessionId = sessionMap["sessionId"];
    session._createTime = FFmpegKitFactory.validDate(sessionMap["createTime"]);
    session._startTime = FFmpegKitFactory.validDate(sessionMap["startTime"]);
    session._command = sessionMap["command"];
    session._argumentsArray =
        FFmpegKitConfig.parseArguments(sessionMap["command"]);
    session._logRedirectionStrategy =
        FFmpegKitFactory.getLogRedirectionStrategy(session._sessionId);

    return session;
  }

  /// Creates a new FFprobe session using [argumentsArray] and
  /// [logRedirectionStrategy].
  ///
  /// Returns FFprobe session created.
  static Future<FFprobeSession> createFFprobeSession(
      List<String> argumentsArray,
      [LogRedirectionStrategy? logRedirectionStrategy]) async {
    try {
      await FFmpegKitConfig.init();
      final Map<dynamic, dynamic>? nativeSession =
          await _platform.abstractSessionCreateFFprobeSession(argumentsArray);

      final session = new FFprobeSession();

      session._sessionId = nativeSession?["sessionId"];
      session._createTime =
          FFmpegKitFactory.validDate(nativeSession?["createTime"]);
      session._startTime =
          FFmpegKitFactory.validDate(nativeSession?["startTime"]);
      session._command = nativeSession?["command"];
      session._argumentsArray = argumentsArray;
      session._logRedirectionStrategy =
          logRedirectionStrategy ?? FFmpegKitConfig.getLogRedirectionStrategy();

      FFmpegKitFactory.setLogRedirectionStrategy(
          session._sessionId, logRedirectionStrategy);

      return session;
    } on PlatformException catch (e, stack) {
      print("Plugin createFFprobeSession error: ${e.message}");
      return Future.error("createFFprobeSession failed.", stack);
    }
  }

  /// Creates a new FFprobe session from [sessionMap], which includes session
  /// fields as map keys.
  ///
  /// Returns FFprobe session created.
  static FFprobeSession createFFprobeSessionFromMap(
      Map<dynamic, dynamic> sessionMap) {
    final session = new FFprobeSession();

    session._sessionId = sessionMap["sessionId"];
    session._createTime = FFmpegKitFactory.validDate(sessionMap["createTime"]);
    session._startTime = FFmpegKitFactory.validDate(sessionMap["startTime"]);
    session._command = sessionMap["command"];
    session._argumentsArray =
        FFmpegKitConfig.parseArguments(sessionMap["command"]);
    session._logRedirectionStrategy =
        FFmpegKitFactory.getLogRedirectionStrategy(session._sessionId);

    return session;
  }

  /// Creates a new MediaInformation session using [argumentsArray].
  ///
  /// Returns MediaInformation session created.
  static Future<MediaInformationSession> createMediaInformationSession(
      List<String> argumentsArray) async {
    try {
      await FFmpegKitConfig.init();
      final Map<dynamic, dynamic>? nativeSession = await _platform
          .abstractSessionCreateMediaInformationSession(argumentsArray);
      final session = new MediaInformationSession();

      session._sessionId = nativeSession?["sessionId"];
      session._createTime =
          FFmpegKitFactory.validDate(nativeSession?["createTime"]);
      session._startTime =
          FFmpegKitFactory.validDate(nativeSession?["startTime"]);
      session._command = nativeSession?["command"];
      session._argumentsArray = argumentsArray;
      session._logRedirectionStrategy = LogRedirectionStrategy.neverPrintLogs;

      FFmpegKitFactory.setLogRedirectionStrategy(
          session._sessionId, LogRedirectionStrategy.neverPrintLogs);

      return session;
    } on PlatformException catch (e, stack) {
      print("Plugin createMediaInformationSession error: ${e.message}");
      return Future.error("createMediaInformationSession failed.", stack);
    }
  }

  /// Creates a new MediaInformation session from [sessionMap], which includes
  /// session fields as map keys.
  ///
  /// Returns MediaInformation session created.
  static MediaInformationSession createMediaInformationSessionFromMap(
      Map<dynamic, dynamic> sessionMap) {
    final session = new MediaInformationSession();

    session._sessionId = sessionMap["sessionId"];
    session._createTime = FFmpegKitFactory.validDate(sessionMap["createTime"]);
    session._startTime = FFmpegKitFactory.validDate(sessionMap["startTime"]);
    session._command = sessionMap["command"];
    session._argumentsArray =
        FFmpegKitConfig.parseArguments(sessionMap["command"]);
    session._logRedirectionStrategy = LogRedirectionStrategy.neverPrintLogs;

    if (sessionMap.containsKey("mediaInformation")) {
      session.setMediaInformation(
          new MediaInformation(sessionMap["mediaInformation"]));
    }

    return session;
  }

  /// Returns the session specific log callback.
  LogCallback? getLogCallback() =>
      FFmpegKitFactory.getLogCallback(this.getSessionId());

  /// Returns the session identifier.
  int? getSessionId() => this._sessionId;

  /// Returns session create time.
  DateTime? getCreateTime() => this._createTime;

  /// Returns session start time.
  DateTime? getStartTime() => this._startTime;

  /// Returns session end time.
  Future<DateTime?> getEndTime() async {
    try {
      return _platform
          .abstractSessionGetEndTime(this.getSessionId())
          .then(FFmpegKitFactory.validDate);
    } on PlatformException catch (e, stack) {
      print("Plugin getEndTime error: ${e.message}");
      return Future.error("getEndTime failed.", stack);
    }
  }

  /// Returns time taken to execute this session in milliseconds or zero (0)
  /// if the session is not over yet.
  Future<int> getDuration() async {
    try {
      return _platform
          .abstractSessionGetDuration(this.getSessionId())
          .then((duration) => duration ?? 0);
    } on PlatformException catch (e, stack) {
      print("Plugin getDuration error: ${e.message}");
      return Future.error("getDuration failed.", stack);
    }
  }

  /// Returns command arguments as an array.
  List<String>? getArguments() => this._argumentsArray;

  /// Returns command arguments as a concatenated string.
  String? getCommand() => this._command;

  /// Returns all log entries generated for this session. If there are
  /// asynchronous logs that are not delivered yet, this method waits for
  /// them until [waitTimeout].
  Future<List<Log>> getAllLogs([int? waitTimeout = null]) async {
    try {
      return _platform
          .abstractSessionGetAllLogs(this.getSessionId(), waitTimeout)
          .then((allLogs) {
        if (allLogs == null) {
          return List.empty();
        } else {
          return allLogs
              .map((dynamic logObject) =>
                  FFmpegKitFactory.mapToLog(logObject as Map<dynamic, dynamic>))
              .toList();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getAllLogs error: ${e.message}");
      return Future.error("getAllLogs failed.", stack);
    }
  }

  /// Returns all log entries delivered for this session. Note that if there
  /// are asynchronous logs that are not delivered yet, this method
  /// will not wait for them and will return immediately.
  Future<List<Log>> getLogs() async {
    try {
      return _platform
          .abstractSessionGetLogs(this.getSessionId())
          .then((allLogs) {
        if (allLogs == null) {
          return List.empty();
        } else {
          return allLogs
              .map((dynamic logObject) =>
                  FFmpegKitFactory.mapToLog(logObject as Map<dynamic, dynamic>))
              .toList();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getLogs error: ${e.message}");
      return Future.error("getLogs failed.", stack);
    }
  }

  /// Returns all log entries generated for this session as a concatenated
  /// string. If there are asynchronous logs that are not delivered yet,
  /// this method waits for them until [waitTimeout].
  Future<String?> getAllLogsAsString([int? waitTimeout = null]) async {
    try {
      return _platform.abstractSessionGetAllLogsAsString(
          this.getSessionId(), waitTimeout);
    } on PlatformException catch (e, stack) {
      print("Plugin getAllLogsAsString error: ${e.message}");
      return Future.error("getAllLogsAsString failed.", stack);
    }
  }

  /// Returns all log entries delivered for this session as a concatenated
  /// string. Note that if there are asynchronous logs that are not
  /// delivered yet, this method will not wait for them and will return
  /// immediately.
  Future<String> getLogsAsString() async {
    final StringBuffer concatenatedString = new StringBuffer();

    void concatLog(Log log) => concatenatedString.write(log.getMessage());

    final List<Log> logs = await this.getLogs();

    logs.forEach(concatLog);

    return concatenatedString.toString();
  }

  /// Returns the log output generated while running the session.
  Future<String?> getOutput() async => this.getAllLogsAsString();

  /// Returns the state of the session.
  Future<SessionState> getState() async {
    try {
      return _platform
          .abstractSessionGetState(this.getSessionId())
          .then((state) {
        switch (state) {
          case 0:
            return SessionState.created;
          case 1:
            return SessionState.running;
          case 2:
            return SessionState.failed;
          case 3:
          default:
            return SessionState.completed;
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getState error: ${e.message}");
      return Future.error("getState failed.", stack);
    }
  }

  /// Returns the return code for this session. Note that return code is only
  /// set for sessions that end with COMPLETED state. If a session is not
  /// started, still running or failed then this method returns null.
  Future<ReturnCode?> getReturnCode() async {
    try {
      return _platform
          .abstractSessionGetReturnCode(this.getSessionId())
          .then((returnCode) {
        if (returnCode == null) {
          return null;
        } else {
          return new ReturnCode(returnCode);
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getReturnCode error: ${e.message}");
      return Future.error("getReturnCode failed.", stack);
    }
  }

  /// Returns the stack trace of the exception received while executing this
  /// session.
  ///
  /// The stack trace is only set for sessions that end with FAILED state. For
  /// sessions that has COMPLETED state this method returns null.
  Future<String?> getFailStackTrace() async {
    try {
      return _platform.abstractSessionGetFailStackTrace(this.getSessionId());
    } on PlatformException catch (e, stack) {
      print("Plugin getFailStackTrace error: ${e.message}");
      return Future.error("getFailStackTrace failed.", stack);
    }
  }

  /// Returns session specific log redirection strategy.
  LogRedirectionStrategy? getLogRedirectionStrategy() =>
      this._logRedirectionStrategy;

  /// Returns whether there are still asynchronous messages being transmitted
  /// for this session or not.
  Future<bool> thereAreAsynchronousMessagesInTransmit() async {
    try {
      return _platform.abstractSessionThereAreAsynchronousMessagesInTransmit(
          this.getSessionId());
    } on PlatformException catch (e, stack) {
      print(
          "Plugin thereAreAsynchronousMessagesInTransmit error: ${e.message}");
      return Future.error(
          "thereAreAsynchronousMessagesInTransmit failed.", stack);
    }
  }

  /// Returns whether it is an "FFmpeg" session or not.
  bool isFFmpeg() => false;

  /// Returns whether it is an "FFprobe" session or not.
  bool isFFprobe() => false;

  /// Returns whether it is an "MediaInformation" session or not.
  bool isMediaInformation() => false;

  /// Cancels running the session.
  Future<void> cancel() async {
    try {
      final int? sessionId = getSessionId();
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
}
