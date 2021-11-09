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

import 'package:ffmpeg_kit_flutter_platform_interface/ffmpeg_kit_flutter_platform_interface.dart';
import 'package:flutter/services.dart';

import 'ffmpeg_kit_config.dart';
import 'media_information.dart';

/// A parser that constructs "MediaInformation" from FFprobe's json output.
class MediaInformationJsonParser {
  static FFmpegKitPlatform _platform = FFmpegKitPlatform.instance;

  /// Extracts MediaInformation from the given FFprobe json output. Note that
  /// this method does not fail as [fromWithError] does and returns null on
  /// error.
  static Future<MediaInformation?> from(String ffprobeJsonOutput) async {
    try {
      await FFmpegKitConfig.init();
      return _platform
          .mediaInformationJsonParserFrom(ffprobeJsonOutput)
          .then((properties) {
        if (properties == null || properties.length == 0) {
          return null;
        } else {
          return new MediaInformation(properties);
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin from error: ${e.message}");
      return Future.error("from failed.", stack);
    }
  }

  /// Extracts MediaInformation from the given FFprobe json output.
  static Future<MediaInformation> fromWithError(
      String ffprobeJsonOutput) async {
    try {
      await FFmpegKitConfig.init();
      return _platform
          .mediaInformationJsonParserFromWithError(ffprobeJsonOutput)
          .then((properties) => new MediaInformation(properties));
    } on PlatformException catch (e, stack) {
      print("Plugin fromWithError error: ${e.message}");
      return Future.error("fromWithError failed.", stack);
    }
  }
}
