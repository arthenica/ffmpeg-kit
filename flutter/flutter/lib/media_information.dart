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

import 'chapter.dart';
import 'stream_information.dart';

/// Media information class.
class MediaInformation {
  static const keyFormatProperties = "format";
  static const keyFilename = "filename";
  static const keyFormat = "format_name";
  static const keyFormatLong = "format_long_name";
  static const keyStartTime = "start_time";
  static const keyDuration = "duration";
  static const keySize = "size";
  static const keyBitRate = "bit_rate";
  static const keyTags = "tags";

  Map<dynamic, dynamic>? _allProperties;

  /// Creates a new [MediaInformation] instance
  MediaInformation(this._allProperties);

  /// Returns file name.
  String? getFilename() =>
      this.getStringFormatProperty(MediaInformation.keyFilename);

  /// Returns format.
  String? getFormat() =>
      this.getStringFormatProperty(MediaInformation.keyFormat);

  /// Returns long format.
  String? getLongFormat() =>
      this.getStringFormatProperty(MediaInformation.keyFormatLong);

  /// Returns duration.
  String? getDuration() =>
      this.getStringFormatProperty(MediaInformation.keyDuration);

  /// Returns start time.
  String? getStartTime() =>
      this.getStringFormatProperty(MediaInformation.keyStartTime);

  /// Returns size.
  String? getSize() => this.getStringFormatProperty(MediaInformation.keySize);

  /// Returns bitrate.
  String? getBitrate() =>
      this.getStringFormatProperty(MediaInformation.keyBitRate);

  /// Returns all tags.
  Map<dynamic, dynamic>? getTags() =>
      this.getFormatProperty(StreamInformation.keyTags);

  /// Returns the property associated with the key.
  String? getStringProperty(String key) => this.getAllProperties()?[key];

  /// Returns the property associated with the key.
  num? getNumberProperty(String key) => this.getAllProperties()?[key];

  /// Returns the property associated with the key.
  dynamic getProperty(String key) => this.getAllProperties()?[key];

  /// Returns the format property associated with the key.
  String? getStringFormatProperty(String key) =>
      this.getFormatProperties()?[key];

  /// Returns the format property associated with the key.
  num? getNumberFormatProperty(String key) => this.getFormatProperties()?[key];

  /// Returns the format property associated with the key.
  dynamic getFormatProperty(String key) => this.getFormatProperties()?[key];

  /// Returns all streams found as a list.
  List<StreamInformation> getStreams() {
    final List<StreamInformation> list =
        List<StreamInformation>.empty(growable: true);

    dynamic createStreamInformation(Map<dynamic, dynamic> streamProperties) =>
        list.add(new StreamInformation(streamProperties));

    this._allProperties?["streams"]?.forEach((Object? stream) {
      createStreamInformation(stream as Map<dynamic, dynamic>);
    });

    return list;
  }

  /// Returns all chapters found as a list.
  List<Chapter> getChapters() {
    final List<Chapter> list = List<Chapter>.empty(growable: true);

    dynamic createChapter(Map<dynamic, dynamic> chapterProperties) =>
        list.add(new Chapter(chapterProperties));

    this._allProperties?["chapters"]?.forEach((Object? chapter) {
      createChapter(chapter as Map<dynamic, dynamic>);
    });

    return list;
  }

  /// Returns all format properties found.
  Map<dynamic, dynamic>? getFormatProperties() =>
      this._allProperties?[keyFormatProperties];

  /// Returns all properties found, including stream properties.
  Map<dynamic, dynamic>? getAllProperties() => this._allProperties;
}
