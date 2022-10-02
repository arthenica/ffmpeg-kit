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
import 'log_callback.dart';
import 'media_information.dart';
import 'media_information_session_complete_callback.dart';
import 'src/ffmpeg_kit_factory.dart';

/// A custom FFprobe session, which produces a "MediaInformation" object
/// using the FFprobe output.
class MediaInformationSession extends AbstractSession {
  MediaInformation? _mediaInformation;

  /// Creates a new MediaInformation session with [argumentsArray].
  static Future<MediaInformationSession> create(List<String> argumentsArray,
      [MediaInformationSessionCompleteCallback? completeCallback = null,
      LogCallback? logCallback = null]) async {
    final session =
        await AbstractSession.createMediaInformationSession(argumentsArray);
    final sessionId = session.getSessionId();

    FFmpegKitFactory.setMediaInformationSessionCompleteCallback(
        sessionId, completeCallback);
    FFmpegKitFactory.setLogCallback(sessionId, logCallback);

    return session;
  }

  /// Returns the media information extracted in this session.
  MediaInformation? getMediaInformation() => this._mediaInformation;

  /// Sets the media information extracted in this session.
  void setMediaInformation(MediaInformation? mediaInformation) {
    this._mediaInformation = mediaInformation;
  }

  /// Returns the session specific complete callback.
  MediaInformationSessionCompleteCallback? getCompleteCallback() =>
      FFmpegKitFactory.getMediaInformationSessionCompleteCallback(
          this.getSessionId());

  bool isFFmpeg() => false;

  bool isFFprobe() => false;

  bool isMediaInformation() => true;
}
