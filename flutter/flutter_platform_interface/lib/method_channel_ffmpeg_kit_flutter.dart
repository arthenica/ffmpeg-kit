/*
 * Copyright (c) 2021-2022 Taner Sener
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ffmpeg_kit_flutter_platform_interface.dart';

const MethodChannel _channel =
    const MethodChannel('flutter.arthenica.com/ffmpeg_kit');

/// An implementation of [FFmpegKitPlatform] that uses method channels.
class MethodChannelFFmpegKit extends FFmpegKitPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  // AbstractSession

  @override
  Future<Map<dynamic, dynamic>?> abstractSessionCreateFFmpegSession(
          List<String> argumentsArray) async =>
      _channel.invokeMethod<Map<dynamic, dynamic>>(
          'ffmpegSession', {'arguments': argumentsArray});

  @override
  Future<Map<dynamic, dynamic>?> abstractSessionCreateFFprobeSession(
          List<String> argumentsArray) async =>
      _channel.invokeMethod<Map<dynamic, dynamic>>(
          'ffprobeSession', {'arguments': argumentsArray});

  @override
  Future<Map<dynamic, dynamic>?> abstractSessionCreateMediaInformationSession(
          List<String> argumentsArray) async =>
      _channel.invokeMethod<Map<dynamic, dynamic>>(
          'mediaInformationSession', {'arguments': argumentsArray});

  @override
  Future<int?> abstractSessionGetEndTime(int? sessionId) async => _channel
      .invokeMethod<int>('abstractSessionGetEndTime', {'sessionId': sessionId});

  @override
  Future<int?> abstractSessionGetDuration(int? sessionId) async =>
      _channel.invokeMethod<int>(
          'abstractSessionGetDuration', {'sessionId': sessionId});

  @override
  Future<List<dynamic>?> abstractSessionGetAllLogs(
          int? sessionId, int? waitTimeout) async =>
      _channel.invokeMethod<List<dynamic>>('abstractSessionGetAllLogs',
          {'sessionId': sessionId, 'waitTimeout': waitTimeout});

  @override
  Future<List<dynamic>?> abstractSessionGetLogs(int? sessionId) async =>
      _channel.invokeMethod<List<dynamic>>(
          'abstractSessionGetLogs', {'sessionId': sessionId});

  @override
  Future<String?> abstractSessionGetAllLogsAsString(
          int? sessionId, int? waitTimeout) async =>
      _channel.invokeMethod<String>('abstractSessionGetAllLogsAsString',
          {'sessionId': sessionId, 'waitTimeout': waitTimeout});

  @override
  Future<int?> abstractSessionGetState(int? sessionId) async => _channel
      .invokeMethod<int>('abstractSessionGetState', {'sessionId': sessionId});

  @override
  Future<int?> abstractSessionGetReturnCode(int? sessionId) async =>
      _channel.invokeMethod<int>(
          'abstractSessionGetReturnCode', {'sessionId': sessionId});

  @override
  Future<String?> abstractSessionGetFailStackTrace(int? sessionId) async =>
      _channel.invokeMethod<String>(
          'abstractSessionGetFailStackTrace', {'sessionId': sessionId});

  @override
  Future<bool> abstractSessionThereAreAsynchronousMessagesInTransmit(
          int? sessionId) async =>
      _channel.invokeMethod<bool>(
          'abstractSessionThereAreAsynchronousMessagesInTransmit',
          {'sessionId': sessionId}).then((bool? value) => value ?? false);

  // ArchDetect

  @override
  Future<String> archDetectGetArch() async => _channel
      .invokeMethod<String>('getArch')
      .then((String? value) => value ?? "");

  // FFmpegKit

  @override
  Future<void> ffmpegKitCancel() async => _channel.invokeMethod<void>('cancel');

  @override
  Future<void> ffmpegKitCancelSession(int sessionId) async =>
      _channel.invokeMethod<void>('cancelSession', {'sessionId': sessionId});

  @override
  Future<List<dynamic>?> ffmpegKitListSessions() async =>
      _channel.invokeMethod<List<dynamic>>('getFFmpegSessions');

  // FFmpegKitConfig

  @override
  Future<void> ffmpegKitConfigEnableRedirection() async =>
      _channel.invokeMethod<void>('enableRedirection');

  @override
  Future<void> ffmpegKitConfigDisableRedirection() async =>
      _channel.invokeMethod<void>('disableRedirection');

  @override
  Future<void> ffmpegKitConfigSetFontconfigConfigurationPath(
          String path) async =>
      _channel
          .invokeMethod<void>('setFontconfigConfigurationPath', {'path': path});

  @override
  Future<void> ffmpegKitConfigSetFontDirectory(
          String path, Map<String, String>? mapping) async =>
      _channel.invokeMethod<void>(
          'setFontDirectory', {'fontDirectory': path, 'fontNameMap': mapping});

  @override
  Future<void> ffmpegKitConfigSetFontDirectoryList(
          List<String> fontDirectoryList, Map<String, String>? mapping) async =>
      _channel.invokeMethod<void>('setFontDirectoryList',
          {'fontDirectoryList': fontDirectoryList, 'fontNameMap': mapping});

  @override
  Future<String?> ffmpegKitConfigRegisterNewFFmpegPipe() async =>
      _channel.invokeMethod<String>('registerNewFFmpegPipe');

  @override
  Future<void> ffmpegKitConfigCloseFFmpegPipe(String ffmpegPipePath) async =>
      _channel.invokeMethod<void>(
          'closeFFmpegPipe', {'ffmpegPipePath': ffmpegPipePath});

  @override
  Future<String?> ffmpegKitConfigGetFFmpegVersion() async =>
      _channel.invokeMethod<String>('getFFmpegVersion');

  @override
  Future<bool?> ffmpegKitConfigIsLTSBuild() async =>
      _channel.invokeMethod<bool>('isLTSBuild');

  @override
  Future<String?> ffmpegKitConfigGetBuildDate() async =>
      _channel.invokeMethod<String>('getBuildDate');

  @override
  Future<void> ffmpegKitConfigSetEnvironmentVariable(
          String name, String value) async =>
      _channel.invokeMethod<void>('setEnvironmentVariable',
          {'variableName': name, 'variableValue': value});

  @override
  Future<void> ffmpegKitConfigIgnoreSignal(int signal) async =>
      _channel.invokeMethod<void>('ignoreSignal', {'signal': signal});

  @override
  Future<void> ffmpegKitConfigFFmpegExecute(int? sessionId) async => _channel
      .invokeMethod<void>('ffmpegSessionExecute', {'sessionId': sessionId});

  @override
  Future<void> ffmpegKitConfigFFprobeExecute(int? sessionId) async => _channel
      .invokeMethod<void>('ffprobeSessionExecute', {'sessionId': sessionId});

  @override
  Future<void> ffmpegKitConfigGetMediaInformationExecute(
          int? sessionId, int? waitTimeout) async =>
      _channel.invokeMethod<void>('mediaInformationSessionExecute',
          {'sessionId': sessionId, 'waitTimeout': waitTimeout});

  @override
  Future<void> ffmpegKitConfigAsyncFFmpegExecute(int? sessionId) async =>
      _channel.invokeMethod<void>(
          'asyncFFmpegSessionExecute', {'sessionId': sessionId});

  @override
  Future<void> ffmpegKitConfigAsyncFFprobeExecute(int? sessionId) async =>
      _channel.invokeMethod<void>(
          'asyncFFprobeSessionExecute', {'sessionId': sessionId});

  @override
  Future<void> ffmpegKitConfigAsyncGetMediaInformationExecute(
          int? sessionId, int? waitTimeout) async =>
      _channel.invokeMethod<void>('asyncMediaInformationSessionExecute',
          {'sessionId': sessionId, 'waitTimeout': waitTimeout});

  @override
  Future<void> ffmpegKitConfigSetLogLevel(int logLevel) async =>
      _channel.invokeMethod<void>('setLogLevel', {'level': logLevel});

  @override
  Future<int?> ffmpegKitConfigGetSessionHistorySize() async =>
      _channel.invokeMethod<int>('getSessionHistorySize');

  @override
  Future<void> ffmpegKitConfigSetSessionHistorySize(
          int sessionHistorySize) async =>
      _channel.invokeMethod<void>(
          'setSessionHistorySize', {'sessionHistorySize': sessionHistorySize});

  @override
  Future<Map<dynamic, dynamic>?> ffmpegKitConfigGetSession(
          int sessionId) async =>
      _channel.invokeMethod<Map<dynamic, dynamic>>(
          'getSession', {'sessionId': sessionId});

  @override
  Future<Map<dynamic, dynamic>?> ffmpegKitConfigGetLastSession() async =>
      _channel.invokeMethod<Map<dynamic, dynamic>>('getLastSession');

  @override
  Future<Map<dynamic, dynamic>?>
      ffmpegKitConfigGetLastCompletedSession() async => _channel
          .invokeMethod<Map<dynamic, dynamic>>('getLastCompletedSession');

  @override
  Future<List<dynamic>?> ffmpegKitConfigGetSessions() async =>
      _channel.invokeMethod<List<dynamic>>('getSessions');

  @override
  Future<void> clearSessions() async =>
      _channel.invokeMethod<void>('clearSessions');

  @override
  Future<List<dynamic>?> ffmpegKitConfigGetSessionsByState(
          int sessionState) async =>
      _channel.invokeMethod<List<dynamic>>(
          'getSessionsByState', {'state': sessionState});

  @override
  Future<int?> ffmpegKitConfigMessagesInTransmit(int sessionId) async =>
      _channel
          .invokeMethod<int>('messagesInTransmit', {'sessionId': sessionId});

  @override
  Future<void> ffmpegKitConfigEnableLogs() async =>
      _channel.invokeMethod<void>('enableLogs');

  @override
  Future<void> ffmpegKitConfigDisableLogs() async =>
      _channel.invokeMethod<void>('disableLogs');

  @override
  Future<void> ffmpegKitConfigEnableStatistics() async =>
      _channel.invokeMethod<void>('enableStatistics');

  @override
  Future<void> ffmpegKitConfigDisableStatistics() async =>
      _channel.invokeMethod<void>('disableStatistics');

  @override
  Future<String?> ffmpegKitConfigGetPlatform() async =>
      _channel.invokeMethod<String>('getPlatform');

  @override
  Future<int?> ffmpegKitConfigWriteToPipe(
          String inputPath, String pipePath) async =>
      _channel.invokeMethod<int>(
          'writeToPipe', {'input': inputPath, 'pipe': pipePath});

  @override
  Future<String?> ffmpegKitConfigSelectDocumentForRead(
          String? type, List<String>? extraTypes) async =>
      _channel.invokeMethod<String>('selectDocument',
          {'writable': false, 'type': type, 'extraTypes': extraTypes});

  @override
  Future<String?> ffmpegKitConfigSelectDocumentForWrite(
          String? title, String? type, List<String>? extraTypes) async =>
      _channel.invokeMethod<String>('selectDocument', {
        'writable': true,
        'title': title,
        'type': type,
        'extraTypes': extraTypes
      });

  @override
  Future<String?> ffmpegKitConfigGetSafParameter(
          String uriString, String openMode) async =>
      _channel.invokeMethod<String>(
          'getSafParameter', {'uri': uriString, 'openMode': openMode});

  // FFmpegKitFlutterInitializer

  Future<int?> ffmpegKitFlutterInitializerGetLogLevel() async =>
      _channel.invokeMethod<int>('getLogLevel');

  // FFmpegSession

  @override
  Future<List<dynamic>?> ffmpegSessionGetAllStatistics(
          int? sessionId, int? waitTimeout) async =>
      _channel.invokeMethod<List<dynamic>>('ffmpegSessionGetAllStatistics',
          {'sessionId': sessionId, 'waitTimeout': waitTimeout});

  @override
  Future<List<dynamic>?> ffmpegSessionGetStatistics(int? sessionId) async =>
      _channel.invokeMethod<List<dynamic>>(
          'ffmpegSessionGetStatistics', {'sessionId': sessionId});

  // FFprobeKit

  @override
  Future<List<dynamic>?> ffprobeKitListFFprobeSessions() async =>
      _channel.invokeMethod<List<dynamic>>('getFFprobeSessions');

  @override
  Future<List<dynamic>?> ffprobeKitListMediaInformationSessions() async =>
      _channel.invokeMethod<List<dynamic>>('getMediaInformationSessions');

  // MediaInformationJsonParser

  @override
  Future<Map<dynamic, dynamic>?> mediaInformationJsonParserFrom(
          String ffprobeJsonOutput) async =>
      _channel.invokeMethod<Map<dynamic, dynamic>>(
          'mediaInformationJsonParserFrom',
          {'ffprobeJsonOutput': ffprobeJsonOutput});

  @override
  Future<Map<dynamic, dynamic>?> mediaInformationJsonParserFromWithError(
          String ffprobeJsonOutput) async =>
      _channel.invokeMethod<Map<dynamic, dynamic>>(
          'mediaInformationJsonParserFromWithError',
          {'ffprobeJsonOutput': ffprobeJsonOutput});

  // MediaInformationSession

  @override
  Future<Map<dynamic, dynamic>?> mediaInformationSessionGetMediaInformation(
          int? sessionId) async =>
      _channel.invokeMethod<Map<dynamic, dynamic>>(
          'getMediaInformation', {'sessionId': sessionId});

  @override
  Future<String?> getPackageName() async =>
      _channel.invokeMethod<String>('getPackageName');

  @override
  Future<List<dynamic>?> getExternalLibraries() async =>
      _channel.invokeMethod<List<dynamic>>('getExternalLibraries');
}
