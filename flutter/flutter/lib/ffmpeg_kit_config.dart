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

import 'ffmpeg_session.dart';
import 'ffmpeg_session_complete_callback.dart';
import 'ffprobe_session.dart';
import 'ffprobe_session_complete_callback.dart';
import 'level.dart';
import 'log_callback.dart';
import 'log_redirection_strategy.dart';
import 'media_information_session.dart';
import 'media_information_session_complete_callback.dart';
import 'session.dart';
import 'session_state.dart';
import 'signal.dart';
import 'src/ffmpeg_kit_factory.dart';
import 'src/ffmpeg_kit_flutter_initializer.dart';
import 'statistics_callback.dart';

/// Configuration class of "FFmpegKit" library.
class FFmpegKitConfig {
  static FFmpegKitPlatform _platform = FFmpegKitPlatform.instance;

  static LogRedirectionStrategy _globalLogRedirectionStrategy =
      LogRedirectionStrategy.printLogsWhenNoCallbacksDefined;

  static int _activeLogLevel = Level.avLogTrace;

  /// Initializes the library asynchronously.
  static Future<void> init() async {
    await FFmpegKitInitializer.initialize();
  }

  /// Enables log and statistics redirection.
  ///
  /// When redirection is enabled FFmpeg/FFprobe logs are redirected to console
  /// and sessions collect log and statistics entries for the executions. It
  /// is possible to define global or session specific log/statistics callbacks
  /// as well.
  ///
  /// Note that redirection is enabled by default. If you do not want to use
  /// its functionality please use [disableRedirection] to disable it.
  static Future<void> enableRedirection() async {
    try {
      await init();
      return _platform.ffmpegKitConfigEnableRedirection();
    } on PlatformException catch (e, stack) {
      print("Plugin enableRedirection error: ${e.message}");
      return Future.error("enableRedirection failed.", stack);
    }
  }

  /// Disables log and statistics redirection.
  ///
  /// When redirection is disabled logs are printed to stderr, all logs and
  /// statistics callbacks are disabled and "FFprobeKit.getMediaInformation"
  /// methods do not work.
  static Future<void> disableRedirection() async {
    try {
      await init();
      return _platform.ffmpegKitConfigDisableRedirection();
    } on PlatformException catch (e, stack) {
      print("Plugin disableRedirection error: ${e.message}");
      return Future.error("disableRedirection failed.", stack);
    }
  }

  /// Sets and overrides "fontconfig" configuration directory.
  static Future<void> setFontconfigConfigurationPath(String path) async {
    try {
      await init();
      return _platform.ffmpegKitConfigSetFontconfigConfigurationPath(path);
    } on PlatformException catch (e, stack) {
      print("Plugin setFontconfigConfigurationPath error: ${e.message}");
      return Future.error("setFontconfigConfigurationPath failed.", stack);
    }
  }

  /// Registers the fonts inside the given path, so they become available to
  /// use in FFmpeg filters.
  ///
  /// Note that you need to use a package with "fontconfig" inside to be able
  /// to use fonts in "FFmpeg".
  static Future<void> setFontDirectory(String path,
      [Map<String, String>? mapping = null]) async {
    try {
      await init();
      return _platform.ffmpegKitConfigSetFontDirectory(path, mapping);
    } on PlatformException catch (e, stack) {
      print("Plugin setFontDirectory error: ${e.message}");
      return Future.error("setFontDirectory failed.", stack);
    }
  }

  /// Registers the fonts inside the given list of font directories, so they
  /// become available to use in FFmpeg filters.
  ///
  /// Note that you need to use a package with "fontconfig" inside to be able
  /// to use fonts in "FFmpeg".
  static Future<void> setFontDirectoryList(List<String> fontDirectoryList,
      [Map<String, String>? mapping = null]) async {
    try {
      await init();
      return _platform.ffmpegKitConfigSetFontDirectoryList(
          fontDirectoryList, mapping);
    } on PlatformException catch (e, stack) {
      print("Plugin setFontDirectoryList error: ${e.message}");
      return Future.error("setFontDirectoryList failed.", stack);
    }
  }

  /// Creates a new named pipe to use in "FFmpeg" operations.
  ///
  /// Please note that creator is responsible of closing created pipes.
  static Future<String?> registerNewFFmpegPipe() async {
    try {
      await init();
      return _platform.ffmpegKitConfigRegisterNewFFmpegPipe();
    } on PlatformException catch (e, stack) {
      print("Plugin registerNewFFmpegPipe error: ${e.message}");
      return Future.error("registerNewFFmpegPipe failed.", stack);
    }
  }

  /// Closes a previously created "FFmpeg" pipe.
  static Future<void> closeFFmpegPipe(String ffmpegPipePath) async {
    try {
      await init();
      return _platform.ffmpegKitConfigCloseFFmpegPipe(ffmpegPipePath);
    } on PlatformException catch (e, stack) {
      print("Plugin closeFFmpegPipe error: ${e.message}");
      return Future.error("closeFFmpegPipe failed.", stack);
    }
  }

  /// Returns the version of FFmpeg bundled within "FFmpegKit" library.
  static Future<String?> getFFmpegVersion() async {
    try {
      await init();
      return _platform.ffmpegKitConfigGetFFmpegVersion();
    } on PlatformException catch (e, stack) {
      print("Plugin getFFmpegVersion error: ${e.message}");
      return Future.error("getFFmpegVersion failed.", stack);
    }
  }

  /// Returns FFmpegKit Flutter library version.
  static Future<String> getVersion() async => FFmpegKitFactory.getVersion();

  /// Returns whether FFmpegKit release is a Long Term Release or not.
  static Future<bool> isLTSBuild() async {
    try {
      await init();
      return _platform.ffmpegKitConfigIsLTSBuild().then((value) {
        if (value == null) {
          return false;
        } else {
          return value;
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin isLTSBuild error: ${e.message}");
      return Future.error("isLTSBuild failed.", stack);
    }
  }

  /// Returns FFmpegKit native library build date.
  static Future<String?> getBuildDate() async {
    try {
      await init();
      return _platform.ffmpegKitConfigGetBuildDate();
    } on PlatformException catch (e, stack) {
      print("Plugin getBuildDate error: ${e.message}");
      return Future.error("getBuildDate failed.", stack);
    }
  }

  /// Sets an environment variable.
  static Future<void> setEnvironmentVariable(String name, String value) async {
    try {
      await init();
      return _platform.ffmpegKitConfigSetEnvironmentVariable(name, value);
    } on PlatformException catch (e, stack) {
      print("Plugin setEnvironmentVariable error: ${e.message}");
      return Future.error("setEnvironmentVariable failed.", stack);
    }
  }

  /// Registers a new ignored signal. Ignored signals are not handled by
  /// "FFmpegKit" library.
  static Future<void> ignoreSignal(Signal signal) async {
    try {
      await init();
      return _platform.ffmpegKitConfigIgnoreSignal(signal.index);
    } on PlatformException catch (e, stack) {
      print("Plugin ignoreSignal error: ${e.message}");
      return Future.error("ignoreSignal failed.", stack);
    }
  }

  /// Synchronously executes the FFmpeg session provided.
  static Future<void> ffmpegExecute(FFmpegSession ffmpegSession) async {
    try {
      await init();
      return _platform
          .ffmpegKitConfigFFmpegExecute(ffmpegSession.getSessionId());
    } on PlatformException catch (e, stack) {
      print("Plugin ffmpegExecute error: ${e.message}");
      return Future.error("ffmpegExecute failed.", stack);
    }
  }

  /// Synchronously executes the FFprobe session provided.
  static Future<void> ffprobeExecute(FFprobeSession ffprobeSession) async {
    try {
      await init();
      return _platform
          .ffmpegKitConfigFFprobeExecute(ffprobeSession.getSessionId());
    } on PlatformException catch (e, stack) {
      print("Plugin ffprobeExecute error: ${e.message}");
      return Future.error("ffprobeExecute failed.", stack);
    }
  }

  /// Synchronously executes the media information session provided.
  static Future<void> getMediaInformationExecute(
      MediaInformationSession mediaInformationSession,
      [int? waitTimeout = null]) async {
    try {
      await init();
      return _platform.ffmpegKitConfigGetMediaInformationExecute(
          mediaInformationSession.getSessionId(), waitTimeout);
    } on PlatformException catch (e, stack) {
      print("Plugin getMediaInformationExecute error: ${e.message}");
      return Future.error("getMediaInformationExecute failed.", stack);
    }
  }

  /// Starts an asynchronous FFmpeg execution for the given session.
  ///
  /// Note that this method returns immediately and does not wait the execution to complete. You must use an
  /// [FFmpegSessionCompleteCallback] if you want to be notified about the result.
  static Future<void> asyncFFmpegExecute(FFmpegSession ffmpegSession) async {
    try {
      await init();
      return _platform
          .ffmpegKitConfigAsyncFFmpegExecute(ffmpegSession.getSessionId());
    } on PlatformException catch (e, stack) {
      print("Plugin asyncFFmpegExecute error: ${e.message}");
      return Future.error("asyncFFmpegExecute failed.", stack);
    }
  }

  /// Starts an asynchronous FFprobe execution for the given session.
  ///
  /// Note that this method returns immediately and does not wait the execution to complete. You must use an
  /// [FFprobeSessionCompleteCallback] if you want to be notified about the result.
  static Future<void> asyncFFprobeExecute(FFprobeSession ffprobeSession) async {
    try {
      await init();
      return _platform
          .ffmpegKitConfigAsyncFFprobeExecute(ffprobeSession.getSessionId());
    } on PlatformException catch (e, stack) {
      print("Plugin asyncFFprobeExecute error: ${e.message}");
      return Future.error("asyncFFprobeExecute failed.", stack);
    }
  }

  /// Starts an asynchronous FFprobe execution for the given media information session.
  ///
  /// Note that this method returns immediately and does not wait the execution to complete. You must use an
  /// [MediaInformationSessionCompleteCallback] if you want to be notified about the result.
  static Future<void> asyncGetMediaInformationExecute(
      MediaInformationSession mediaInformationSession,
      [int? waitTimeout = null]) async {
    try {
      await init();
      return _platform.ffmpegKitConfigAsyncGetMediaInformationExecute(
          mediaInformationSession.getSessionId(), waitTimeout);
    } on PlatformException catch (e, stack) {
      print("Plugin asyncGetMediaInformationExecute error: ${e.message}");
      return Future.error("asyncGetMediaInformationExecute failed.", stack);
    }
  }

  /// Sets a global callback to redirect FFmpeg/FFprobe logs.
  static void enableLogCallback([LogCallback? logCallback = null]) {
    FFmpegKitFactory.setGlobalLogCallback(logCallback);
  }

  /// Sets a global callback to redirect FFmpeg statistics.
  static void enableStatisticsCallback(
      [StatisticsCallback? statisticsCallback = null]) {
    FFmpegKitFactory.setGlobalStatisticsCallback(statisticsCallback);
  }

  /// Sets a global FFmpegSessionCompleteCallback to receive execution results
  /// for FFmpeg sessions.
  static void enableFFmpegSessionCompleteCallback(
      [FFmpegSessionCompleteCallback? ffmpegSessionCompleteCallback = null]) {
    FFmpegKitFactory.setGlobalFFmpegSessionCompleteCallback(
        ffmpegSessionCompleteCallback);
  }

  /// Returns the global FFmpegSessionCompleteCallback set.
  static FFmpegSessionCompleteCallback? getFFmpegSessionCompleteCallback() =>
      FFmpegKitFactory.getGlobalFFmpegSessionCompleteCallback();

  /// Sets a global FFprobeSessionCompleteCallback to receive execution results
  /// for FFprobe sessions.
  static void enableFFprobeSessionCompleteCallback(
      [FFprobeSessionCompleteCallback? ffprobeSessionCompleteCallback = null]) {
    FFmpegKitFactory.setGlobalFFprobeSessionCompleteCallback(
        ffprobeSessionCompleteCallback);
  }

  /// Returns the global FFprobeSessionCompleteCallback set.
  static FFprobeSessionCompleteCallback? getFFprobeSessionCompleteCallback() =>
      FFmpegKitFactory.getGlobalFFprobeSessionCompleteCallback();

  /// Sets a global MediaInformationSessionCompleteCallback to receive
  /// execution results for MediaInformation sessions.
  static void enableMediaInformationSessionCompleteCallback(
      [MediaInformationSessionCompleteCallback?
          mediaInformationSessionCompleteCallback = null]) {
    FFmpegKitFactory.setGlobalMediaInformationSessionCompleteCallback(
        mediaInformationSessionCompleteCallback);
  }

  /// Returns the global MediaInformationSessionCompleteCallback set.
  static MediaInformationSessionCompleteCallback?
      getMediaInformationSessionCompleteCallback() =>
          FFmpegKitFactory.getGlobalMediaInformationSessionCompleteCallback();

  /// Returns the current log level.
  static int getLogLevel() => _activeLogLevel;

  /// Sets the log level.
  static Future<void> setLogLevel(int logLevel) async {
    _activeLogLevel = logLevel;
    try {
      await init();
      return _platform.ffmpegKitConfigSetLogLevel(logLevel);
    } on PlatformException catch (e, stack) {
      print("Plugin setLogLevel error: ${e.message}");
      return Future.error("setLogLevel failed.", stack);
    }
  }

  /// Converts the given Structured Access Framework Uri ("content:…") into
  /// an input url that can be used in FFmpeg and FFprobe commands.
  ///
  /// Note that this method is Android only. It will fail if called on other
  /// platforms. It also requires API Level &ge; 19. On older API levels it
  /// returns an empty url.
  static Future<String?> getSafParameterForRead(String uriString) async {
    try {
      await init();
      return _platform.ffmpegKitConfigGetSafParameter(uriString, "r");
    } on PlatformException catch (e, stack) {
      print("Plugin getSafParameterForRead error: ${e.message}");
      return Future.error("getSafParameterForRead failed.", stack);
    }
  }

  /// Converts the given Structured Access Framework Uri ("content:…") into
  /// an output url that can be used in FFmpeg and FFprobe commands.
  ///
  /// Note that this method is Android only. It will fail if called on other
  /// platforms. It also requires API Level &ge; 19. On older API levels it
  /// returns an empty url.
  static Future<String?> getSafParameterForWrite(String uriString) async {
    try {
      await init();
      return _platform.ffmpegKitConfigGetSafParameter(uriString, "w");
    } on PlatformException catch (e, stack) {
      print("Plugin getSafParameterForWrite error: ${e.message}");
      return Future.error("getSafParameterForWrite failed.", stack);
    }
  }

  /// Converts the given Structured Access Framework Uri into an saf protocol
  /// url opened with the given open mode.
  ///
  /// Note that this method is Android only. It will fail if called on other
  /// platforms. It also requires API Level &ge; 19. On older API levels it
  /// returns an empty url.
  static Future<String?> getSafParameter(
      String uriString, String openMode) async {
    try {
      await init();
      return _platform.ffmpegKitConfigGetSafParameter(uriString, openMode);
    } on PlatformException catch (e, stack) {
      print("Plugin getSafParameter error: ${e.message}");
      return Future.error("getSafParameter failed.", stack);
    }
  }

  /// Returns the session history size.
  static Future<int?> getSessionHistorySize() async {
    try {
      await init();
      return _platform.ffmpegKitConfigGetSessionHistorySize();
    } on PlatformException catch (e, stack) {
      print("Plugin getSessionHistorySize error: ${e.message}");
      return Future.error("getSessionHistorySize failed.", stack);
    }
  }

  /// Sets the session history size.
  static Future<void> setSessionHistorySize(int sessionHistorySize) async {
    try {
      await init();
      return _platform.ffmpegKitConfigSetSessionHistorySize(sessionHistorySize);
    } on PlatformException catch (e, stack) {
      print("Plugin setSessionHistorySize error: ${e.message}");
      return Future.error("setSessionHistorySize failed.", stack);
    }
  }

  /// Returns the session specified with "sessionId" from the session history.
  static Future<Session?> getSession(int sessionId) async {
    try {
      await init();
      return _platform
          .ffmpegKitConfigGetSession(sessionId)
          .then(FFmpegKitFactory.mapToNullableSession);
    } on PlatformException catch (e, stack) {
      print("Plugin getSession error: ${e.message}");
      return Future.error("getSession failed.", stack);
    }
  }

  /// Returns the last session created from the session history.
  static Future<Session?> getLastSession() async {
    try {
      await init();
      return _platform
          .ffmpegKitConfigGetLastSession()
          .then(FFmpegKitFactory.mapToNullableSession);
    } on PlatformException catch (e, stack) {
      print("Plugin getLastSession error: ${e.message}");
      return Future.error("getLastSession failed.", stack);
    }
  }

  /// Returns the last session completed from the session history.
  static Future<Session?> getLastCompletedSession() async {
    try {
      await init();
      return _platform
          .ffmpegKitConfigGetLastCompletedSession()
          .then(FFmpegKitFactory.mapToNullableSession);
    } on PlatformException catch (e, stack) {
      print("Plugin getLastCompletedSession error: ${e.message}");
      return Future.error("getLastCompletedSession failed.", stack);
    }
  }

  /// Returns all sessions in the session history.
  static Future<List<Session>> getSessions() async {
    try {
      await init();
      return _platform.ffmpegKitConfigGetSessions().then((sessions) {
        if (sessions == null) {
          return List.empty();
        } else {
          return sessions
              .map((dynamic sessionObject) => FFmpegKitFactory.mapToSession(
                  sessionObject as Map<dynamic, dynamic>))
              .toList();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getSessions error: ${e.message}");
      return Future.error("getSessions failed.", stack);
    }
  }

  /// Clears all, including ongoing, sessions in the session history.
  /// Note that callbacks cannot be triggered for deleted sessions.
  static Future<void> clearSessions() async {
    try {
      await init();
      return _platform.clearSessions();
    } on PlatformException catch (e, stack) {
      print("Plugin clearSessions error: ${e.message}");
      return Future.error("clearSessions failed.", stack);
    }
  }

  /// Returns all FFmpeg sessions in the session history.
  static Future<List<FFmpegSession>> getFFmpegSessions() async {
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
      print("Plugin getFFmpegSessions error: ${e.message}");
      return Future.error("getFFmpegSessions failed.", stack);
    }
  }

  /// Returns all FFprobe sessions in the session history.
  static Future<List<FFprobeSession>> getFFprobeSessions() async {
    try {
      await FFmpegKitConfig.init();
      return _platform.ffprobeKitListFFprobeSessions().then((sessions) {
        if (sessions == null) {
          return List.empty();
        } else {
          return sessions
              .map((dynamic sessionObject) => FFmpegKitFactory.mapToSession(
                  sessionObject as Map<dynamic, dynamic>))
              .map((session) => session as FFprobeSession)
              .toList();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getFFprobeSessions error: ${e.message}");
      return Future.error("getFFprobeSessions failed.", stack);
    }
  }

  /// Returns all MediaInformation sessions in the session history.
  static Future<List<MediaInformationSession>>
      getMediaInformationSessions() async {
    try {
      await FFmpegKitConfig.init();
      return _platform
          .ffprobeKitListMediaInformationSessions()
          .then((sessions) {
        if (sessions == null) {
          return List.empty();
        } else {
          return sessions
              .map((dynamic sessionObject) => FFmpegKitFactory.mapToSession(
                  sessionObject as Map<dynamic, dynamic>))
              .map((session) => session as MediaInformationSession)
              .toList();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getMediaInformationSessions error: ${e.message}");
      return Future.error("getMediaInformationSessions failed.", stack);
    }
  }

  /// Returns sessions that have [sessionState].
  static Future<List<Session>> getSessionsByState(
      SessionState sessionState) async {
    try {
      await init();
      return _platform
          .ffmpegKitConfigGetSessionsByState(sessionState.index)
          .then((sessions) {
        if (sessions == null) {
          return List.empty();
        } else {
          return sessions
              .map((dynamic sessionObject) => FFmpegKitFactory.mapToSession(
                  sessionObject as Map<dynamic, dynamic>))
              .toList();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getSessionsByState error: ${e.message}");
      return Future.error("getSessionsByState failed.", stack);
    }
  }

  /// Returns the active log redirection strategy.
  static LogRedirectionStrategy getLogRedirectionStrategy() =>
      _globalLogRedirectionStrategy;

  /// Sets the log redirection strategy.
  static void setLogRedirectionStrategy(
      LogRedirectionStrategy logRedirectionStrategy) {
    _globalLogRedirectionStrategy = logRedirectionStrategy;
  }

  /// Returns the number of messages that are not transmitted to the
  /// Flutter callbacks yet for this session.
  static Future<int?> messagesInTransmit(int sessionId) async {
    try {
      await init();
      return _platform.ffmpegKitConfigMessagesInTransmit(sessionId);
    } on PlatformException catch (e, stack) {
      print("Plugin messagesInTransmit error: ${e.message}");
      return Future.error("messagesInTransmit failed.", stack);
    }
  }

  /// Returns the string representation of the SessionState provided.
  static String sessionStateToString(SessionState state) {
    switch (state) {
      case SessionState.created:
        return "CREATED";
      case SessionState.running:
        return "RUNNING";
      case SessionState.failed:
        return "FAILED";
      case SessionState.completed:
        return "COMPLETED";
      default:
        return "";
    }
  }

  /// Parses [command] into arguments. Uses space character to split the
  /// arguments. Supports single and double quote characters.
  static List<String> parseArguments(String command) {
    final List<String> argumentList = List<String>.empty(growable: true);
    StringBuffer currentArgument = new StringBuffer();

    bool singleQuoteStarted = false;
    bool doubleQuoteStarted = false;

    for (int i = 0; i < command.length; i++) {
      int? previousChar;
      if (i > 0) {
        previousChar = command.codeUnitAt(i - 1);
      } else {
        previousChar = null;
      }
      final currentChar = command.codeUnitAt(i);

      if (currentChar == ' '.codeUnitAt(0)) {
        if (singleQuoteStarted || doubleQuoteStarted) {
          currentArgument.write(String.fromCharCode(currentChar));
        } else if (currentArgument.length > 0) {
          argumentList.add(currentArgument.toString());
          currentArgument = new StringBuffer();
        }
      } else if (currentChar == '\''.codeUnitAt(0) &&
          (previousChar == null || previousChar != '\\'.codeUnitAt(0))) {
        if (singleQuoteStarted) {
          singleQuoteStarted = false;
        } else if (doubleQuoteStarted) {
          currentArgument.write(String.fromCharCode(currentChar));
        } else {
          singleQuoteStarted = true;
        }
      } else if (currentChar == '\"'.codeUnitAt(0) &&
          (previousChar == null || previousChar != '\\'.codeUnitAt(0))) {
        if (doubleQuoteStarted) {
          doubleQuoteStarted = false;
        } else if (singleQuoteStarted) {
          currentArgument.write(String.fromCharCode(currentChar));
        } else {
          doubleQuoteStarted = true;
        }
      } else {
        currentArgument.write(String.fromCharCode(currentChar));
      }
    }

    if (currentArgument.length > 0) {
      argumentList.add(currentArgument.toString());
    }

    return argumentList;
  }

  /// Concatenates arguments into a string adding a space character between
  /// two arguments.
  static String argumentsToString(List<String>? arguments) {
    if (arguments == null) {
      return "null";
    }

    final StringBuffer stringBuffer = new StringBuffer();
    for (int i = 0; i < arguments.length; i++) {
      if (i > 0) {
        stringBuffer.write(" ");
      }
      stringBuffer.write(arguments[i]);
    }

    return stringBuffer.toString();
  }

  // THE FOLLOWING METHODS ARE FLUTTER SPECIFIC

  /// Enables logs.
  static Future<void> enableLogs() async {
    try {
      await init();
      return _platform.ffmpegKitConfigEnableLogs();
    } on PlatformException catch (e, stack) {
      print("Plugin enableLogs error: ${e.message}");
      return Future.error("enableLogs failed.", stack);
    }
  }

  /// Disable logs.
  static Future<void> disableLogs() async {
    try {
      await init();
      return _platform.ffmpegKitConfigDisableLogs();
    } on PlatformException catch (e, stack) {
      print("Plugin disableLogs error: ${e.message}");
      return Future.error("disableLogs failed.", stack);
    }
  }

  /// Enables statistics.
  static Future<void> enableStatistics() async {
    try {
      await init();
      return _platform.ffmpegKitConfigEnableStatistics();
    } on PlatformException catch (e, stack) {
      print("Plugin enableStatistics error: ${e.message}");
      return Future.error("enableStatistics failed.", stack);
    }
  }

  /// Disables statistics.
  static Future<void> disableStatistics() async {
    try {
      await init();
      return _platform.ffmpegKitConfigDisableStatistics();
    } on PlatformException catch (e, stack) {
      print("Plugin disableStatistics error: ${e.message}");
      return Future.error("disableStatistics failed.", stack);
    }
  }

  /// Returns the platform name the library is loaded on.
  static Future<String?> getPlatform() async {
    try {
      await init();
      return _platform.ffmpegKitConfigGetPlatform();
    } on PlatformException catch (e, stack) {
      print("Plugin getPlatform error: ${e.message}");
      return Future.error("getPlatform failed.", stack);
    }
  }

  /// Writes [inputPath] to [pipePath].
  static Future<int?> writeToPipe(String inputPath, String pipePath) async {
    try {
      await init();
      return _platform.ffmpegKitConfigWriteToPipe(inputPath, pipePath);
    } on PlatformException catch (e, stack) {
      print("Plugin writeToPipe error: ${e.message}");
      return Future.error("writeToPipe failed.", stack);
    }
  }

  /// Displays the native file dialog to select a file in read mode. If a file
  /// is selected then this method returns the Structured Access Framework Uri
  /// ("content:…") for that file.
  ///
  /// Note that this method is Android only. It will fail if called on other
  /// platforms.
  static Future<String?> selectDocumentForRead(
      [String? type = null, List<String>? extraTypes = null]) async {
    try {
      await init();
      return _platform.ffmpegKitConfigSelectDocumentForRead(type, extraTypes);
    } on PlatformException catch (e, stack) {
      print("Plugin selectDocumentForRead error: ${e.message}");
      return Future.error("selectDocumentForRead failed.", stack);
    }
  }

  /// Displays the native file dialog to select a file in write mode. If a file
  /// is selected then this method returns the Structured Access Framework Uri
  /// ("content:…") for that file.
  ///
  /// Note that this method is Android only. It will fail if called on other
  /// platforms.
  static Future<String?> selectDocumentForWrite(
      [String? title = null,
      String? type = null,
      List<String>? extraTypes = null]) async {
    try {
      await init();
      return _platform.ffmpegKitConfigSelectDocumentForWrite(
          title, type, extraTypes);
    } on PlatformException catch (e, stack) {
      print("Plugin selectDocumentForWrite error: ${e.message}");
      return Future.error("selectDocumentForWrite failed.", stack);
    }
  }
}
