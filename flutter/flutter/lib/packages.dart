/*
 * Copyright (c) 2021 Taner Sener
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

/// Helper class to extract binary package information.
class Packages {
  static FFmpegKitPlatform _platform = FFmpegKitPlatform.instance;

  /// Returns the FFmpegKit Flutter binary package name.
  static Future<String?> getPackageName() async {
    try {
      await FFmpegKitConfig.init();
      return _platform.getPackageName();
    } on PlatformException catch (e, stack) {
      print("Plugin getPackageName error: ${e.message}");
      return Future.error("getPackageName failed.", stack);
    }
  }

  /// Returns enabled external libraries by FFmpeg.
  static Future<List<String>> getExternalLibraries() async {
    try {
      await FFmpegKitConfig.init();
      return _platform.getExternalLibraries().then((externalLibraries) {
        if (externalLibraries == null) {
          return List.empty();
        } else {
          return externalLibraries.cast<String>();
        }
      });
    } on PlatformException catch (e, stack) {
      print("Plugin getExternalLibraries error: ${e.message}");
      return Future.error("getExternalLibraries failed.", stack);
    }
  }
}
