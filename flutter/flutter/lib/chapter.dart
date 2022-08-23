/*
 * Copyright (c) 2021-2022 Taner Sener
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

/// Chapter class.
class Chapter {
  static const keyId = "id";
  static const keyTimeBase = "time_base";
  static const keyStart = "start";
  static const keyStartTime = "start_time";
  static const keyEnd = "end";
  static const keyEndTime = "end_time";
  static const keyTags = "tags";

  Map<dynamic, dynamic>? _allProperties;

  /// Creates a new [Chapter] instance
  Chapter(this._allProperties);

  /// Returns id.
  int? getId() => this.getNumberProperty(Chapter.keyId)?.toInt();

  /// Returns time base.
  String? getTimeBase() => this.getStringProperty(Chapter.keyTimeBase);

  /// Returns start.
  int? getStart() => this.getNumberProperty(Chapter.keyStart)?.toInt();

  /// Returns start time.
  String? getStartTime() => this.getStringProperty(Chapter.keyStartTime);

  /// Returns end.
  int? getEnd() => this.getNumberProperty(Chapter.keyEnd)?.toInt();

  /// Returns end time.
  String? getEndTime() => this.getStringProperty(Chapter.keyEndTime);

  /// Returns all tags.
  Map<dynamic, dynamic>? getTags() => this.getProperty(Chapter.keyTags);

  /// Returns the chapter property associated with the key.
  String? getStringProperty(String key) => this._allProperties?[key];

  /// Returns the chapter property associated with the key.
  num? getNumberProperty(String key) => this._allProperties?[key];

  /// Returns the chapter property associated with the key.
  dynamic getProperty(String key) => this._allProperties?[key];

  /// Returns all properties found.
  Map<dynamic, dynamic>? getAllProperties() => this._allProperties;
}
