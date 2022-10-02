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

import 'log.dart';
import 'log_callback.dart';
import 'log_redirection_strategy.dart';
import 'return_code.dart';
import 'session_state.dart';

/// Common interface for all "FFmpegKit" sessions.
abstract class Session {
  /// Returns the session specific log callback.
  LogCallback? getLogCallback();

  /// Returns the session identifier.
  int? getSessionId();

  /// Returns session create time.
  DateTime? getCreateTime();

  /// Returns session start time.
  DateTime? getStartTime();

  /// Returns session end time.
  Future<DateTime?> getEndTime();

  /// Returns time taken to execute this session in milliseconds or zero (0)
  /// if the session is not over yet.
  Future<int> getDuration();

  /// Returns command arguments as an array.
  List<String>? getArguments();

  /// Returns command arguments as a concatenated string.
  String? getCommand();

  /// Returns all log entries generated for this session. If there are
  /// asynchronous logs that are not delivered yet, this method waits for
  /// them until [waitTimeout].
  Future<List<Log>> getAllLogs([int? waitTimeout = null]);

  /// Returns all log entries delivered for this session. Note that if there
  /// are asynchronous logs that are not delivered yet, this method
  /// will not wait for them and will return immediately.
  Future<List<Log>> getLogs();

  /// Returns all log entries generated for this session as a concatenated
  /// string. If there are asynchronous logs that are not delivered yet,
  /// this method waits for them until [waitTimeout].
  Future<String?> getAllLogsAsString([int? waitTimeout = null]);

  /// Returns all log entries delivered for this session as a concatenated
  /// string. Note that if there are asynchronous logs that are not
  /// delivered yet, this method will not wait for them and will return
  /// immediately.
  Future<String> getLogsAsString();

  /// Returns the log output generated while running the session.
  Future<String?> getOutput();

  /// Returns the state of the session.
  Future<SessionState> getState();

  /// Returns the return code for this session. Note that return code is only
  /// set for sessions that end with COMPLETED state. If a session is not
  /// started, still running or failed then this method returns null.
  Future<ReturnCode?> getReturnCode();

  /// Returns the stack trace of the exception received while executing this
  /// session.
  ///
  /// The stack trace is only set for sessions that end with FAILED state. For
  /// sessions that has COMPLETED state this method returns null.
  Future<String?> getFailStackTrace();

  /// Returns session specific log redirection strategy.
  LogRedirectionStrategy? getLogRedirectionStrategy();

  /// Returns whether there are still asynchronous messages being transmitted
  /// for this session or not.
  Future<bool> thereAreAsynchronousMessagesInTransmit();

  /// Returns whether it is an "FFmpeg" session or not.
  bool isFFmpeg();

  /// Returns whether it is an "FFprobe" session or not.
  bool isFFprobe();

  /// Returns whether it is an "MediaInformation" session or not.
  bool isMediaInformation();

  /// Cancels running the session.
  Future<void> cancel();
}
