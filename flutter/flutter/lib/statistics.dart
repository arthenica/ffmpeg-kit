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

/// Statistics entry for an FFmpeg execute session.
class Statistics {
  int _sessionId;
  int _videoFrameNumber;
  double _videoFps;
  double _videoQuality;
  int _size;
  double _time;
  double _bitrate;
  double _speed;

  Statistics(this._sessionId, this._videoFrameNumber, this._videoFps,
      this._videoQuality, this._size, this._time, this._bitrate, this._speed);

  int getSessionId() => this._sessionId;

  void setSessionId(int sessionId) {
    this._sessionId = sessionId;
  }

  int getVideoFrameNumber() => this._videoFrameNumber;

  void setVideoFrameNumber(int videoFrameNumber) {
    this._videoFrameNumber = videoFrameNumber;
  }

  double getVideoFps() => this._videoFps;

  void setVideoFps(double videoFps) {
    this._videoFps = videoFps;
  }

  double getVideoQuality() => this._videoQuality;

  void setVideoQuality(double videoQuality) {
    this._videoQuality = videoQuality;
  }

  int getSize() => this._size;

  void setSize(int size) {
    this._size = size;
  }

  double getTime() => this._time;

  void setTime(double time) {
    this._time = time;
  }

  double getBitrate() => this._bitrate;

  void setBitrate(double bitrate) {
    this._bitrate = bitrate;
  }

  double getSpeed() => this._speed;

  void setSpeed(double speed) {
    this._speed = speed;
  }
}
