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

import 'ffprobe_session.dart';

/// Callback function that is invoked when an asynchronous FFprobe session has
/// ended. Session has either SessionState.completed or SessionState.failed
/// state when the callback is invoked.
/// If it has SessionState.completed state, "ReturnCode" should be checked to
/// see the execution result.
/// If "getState" returns SessionState.failed then "getFailStackTrace" should
/// be used to get the failure reason.
typedef FFprobeSessionCompleteCallback = void Function(FFprobeSession session);
