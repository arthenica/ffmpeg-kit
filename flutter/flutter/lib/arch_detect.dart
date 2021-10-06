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

/// Detects the running architecture.
class ArchDetect {
  static FFmpegKitPlatform _platform = FFmpegKitPlatform.instance;

  /// Returns architecture name loaded.
  static Future<String> getArch() async {
    try {
      await FFmpegKitConfig.init();
      return _platform.archDetectGetArch();
    } on PlatformException catch (e, stack) {
      print("Plugin getArch error: ${e.message}");
      return Future.error("getArch failed.", stack);
    }
  }
}
