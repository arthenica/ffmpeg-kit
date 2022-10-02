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

import 'abstract_session.dart';
import 'ffprobe_session_complete_callback.dart';
import 'log_callback.dart';
import 'log_redirection_strategy.dart';
import 'src/ffmpeg_kit_factory.dart';

/// An FFprobe session.
class FFprobeSession extends AbstractSession {
  /// Creates a new FFprobe session with [argumentsArray].
  static Future<FFprobeSession> create(List<String> argumentsArray,
      [FFprobeSessionCompleteCallback? completeCallback = null,
      LogCallback? logCallback = null,
      LogRedirectionStrategy? logRedirectionStrategy = null]) async {
    final session = await AbstractSession.createFFprobeSession(
        argumentsArray, logRedirectionStrategy);
    final sessionId = session.getSessionId();

    FFmpegKitFactory.setFFprobeSessionCompleteCallback(
        sessionId, completeCallback);
    FFmpegKitFactory.setLogCallback(sessionId, logCallback);

    return session;
  }

  /// Returns the session specific complete callback.
  FFprobeSessionCompleteCallback? getCompleteCallback() =>
      FFmpegKitFactory.getFFprobeSessionCompleteCallback(this.getSessionId());

  bool isFFmpeg() => false;

  bool isFFprobe() => true;

  bool isMediaInformation() => false;
}
