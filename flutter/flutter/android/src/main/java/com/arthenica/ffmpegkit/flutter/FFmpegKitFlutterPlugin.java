/*
 * Copyright (c) 2018-2021 Taner Sener
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

package com.arthenica.ffmpegkit.flutter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.arthenica.ffmpegkit.AbiDetect;
import com.arthenica.ffmpegkit.AbstractSession;
import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFmpegSession;
import com.arthenica.ffmpegkit.FFprobeKit;
import com.arthenica.ffmpegkit.FFprobeSession;
import com.arthenica.ffmpegkit.Level;
import com.arthenica.ffmpegkit.LogRedirectionStrategy;
import com.arthenica.ffmpegkit.MediaInformation;
import com.arthenica.ffmpegkit.MediaInformationJsonParser;
import com.arthenica.ffmpegkit.MediaInformationSession;
import com.arthenica.ffmpegkit.Packages;
import com.arthenica.ffmpegkit.ReturnCode;
import com.arthenica.ffmpegkit.Session;
import com.arthenica.ffmpegkit.SessionState;
import com.arthenica.ffmpegkit.Signal;
import com.arthenica.ffmpegkit.Statistics;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Collectors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class FFmpegKitFlutterPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, EventChannel.StreamHandler, PluginRegistry.ActivityResultListener {

    public static final String LIBRARY_NAME = "ffmpeg-kit-flutter";
    public static final String PLATFORM_NAME = "android";

    private static final String METHOD_CHANNEL = "flutter.arthenica.com/ffmpeg_kit";
    private static final String EVENT_CHANNEL = "flutter.arthenica.com/ffmpeg_kit_event";

    // LOG CLASS
    public static final String KEY_LOG_SESSION_ID = "sessionId";
    public static final String KEY_LOG_LEVEL = "level";
    public static final String KEY_LOG_MESSAGE = "message";

    // STATISTICS CLASS
    public static final String KEY_STATISTICS_SESSION_ID = "sessionId";
    public static final String KEY_STATISTICS_VIDEO_FRAME_NUMBER = "videoFrameNumber";
    public static final String KEY_STATISTICS_VIDEO_FPS = "videoFps";
    public static final String KEY_STATISTICS_VIDEO_QUALITY = "videoQuality";
    public static final String KEY_STATISTICS_SIZE = "size";
    public static final String KEY_STATISTICS_TIME = "time";
    public static final String KEY_STATISTICS_BITRATE = "bitrate";
    public static final String KEY_STATISTICS_SPEED = "speed";

    // SESSION CLASS
    public static final String KEY_SESSION_ID = "sessionId";
    public static final String KEY_SESSION_CREATE_TIME = "createTime";
    public static final String KEY_SESSION_START_TIME = "startTime";
    public static final String KEY_SESSION_COMMAND = "command";
    public static final String KEY_SESSION_TYPE = "type";
    public static final String KEY_SESSION_MEDIA_INFORMATION = "mediaInformation";

    // SESSION TYPE
    public static final int SESSION_TYPE_FFMPEG = 1;
    public static final int SESSION_TYPE_FFPROBE = 2;
    public static final int SESSION_TYPE_MEDIA_INFORMATION = 3;

    // EVENTS
    public static final String EVENT_LOG_CALLBACK_EVENT = "FFmpegKitLogCallbackEvent";
    public static final String EVENT_STATISTICS_CALLBACK_EVENT = "FFmpegKitStatisticsCallbackEvent";
    public static final String EVENT_EXECUTE_CALLBACK_EVENT = "FFmpegKitExecuteCallbackEvent";

    // REQUEST CODES
    public static final int READABLE_REQUEST_CODE = 10000;
    public static final int WRITABLE_REQUEST_CODE = 20000;

    // ARGUMENT NAMES
    public static final String ARGUMENT_SESSION_ID = "sessionId";
    public static final String ARGUMENT_WAIT_TIMEOUT = "waitTimeout";
    public static final String ARGUMENT_ARGUMENTS = "arguments";
    public static final String ARGUMENT_FFPROBE_JSON_OUTPUT = "ffprobeJsonOutput";
    public static final String ARGUMENT_WRITABLE = "writable";

    private static final int asyncWriteToPipeConcurrencyLimit = 10;

    private final AtomicBoolean logsEnabled;
    private final AtomicBoolean statisticsEnabled;
    private final ExecutorService asyncWriteToPipeExecutorService;

    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private Result lastInitiatedIntentResult;
    private Context context;
    private Activity activity;
    private FlutterPluginBinding flutterPluginBinding;
    private ActivityPluginBinding activityPluginBinding;

    private EventChannel.EventSink eventSink;
    private final FFmpegKitFlutterMethodResultHandler resultHandler;

    public FFmpegKitFlutterPlugin() {
        this.logsEnabled = new AtomicBoolean(false);
        this.statisticsEnabled = new AtomicBoolean(false);
        this.asyncWriteToPipeExecutorService = Executors.newFixedThreadPool(asyncWriteToPipeConcurrencyLimit);
        this.resultHandler = new FFmpegKitFlutterMethodResultHandler();

        registerGlobalCallbacks();
    }

    @SuppressWarnings("deprecation")
    public static void registerWith(final io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        final Context context = (registrar.activity() != null) ? registrar.activity() : registrar.context();
        if (context == null) {
            Log.w(LIBRARY_NAME, "FFmpegKitFlutterPlugin can not be registered without a context.");
            return;
        }
        FFmpegKitFlutterPlugin plugin = new FFmpegKitFlutterPlugin();
        plugin.init(registrar.messenger(), context, registrar.activity(), registrar, null);
    }

    protected void registerGlobalCallbacks() {
        FFmpegKitConfig.enableExecuteCallback(this::emitSession);

        FFmpegKitConfig.enableLogCallback(log -> {
            if (logsEnabled.get()) {
                emitLog(log);
            }
        });

        FFmpegKitConfig.enableStatisticsCallback(statistics -> {
            if (statisticsEnabled.get()) {
                emitStatistics(statistics);
            }
        });
    }

    @Override
    public void onAttachedToEngine(@NonNull final FlutterPluginBinding flutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull final FlutterPluginBinding binding) {
        this.flutterPluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
        Log.d(LIBRARY_NAME, String.format("FFmpegKitFlutterPlugin attached to activity %s.", activityPluginBinding.getActivity()));
        init(flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getApplicationContext(), activityPluginBinding.getActivity(), null, activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
        onAttachedToActivity(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        uninit();
        Log.d(LIBRARY_NAME, "FFmpegKitFlutterPlugin detached from activity.");
    }

    @Override
    public void onListen(final Object o, final EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        Log.d(LIBRARY_NAME, String.format("FFmpegKitFlutterPlugin started listening to events on %s.", eventSink));
    }

    @Override
    public void onCancel(final Object o) {
        this.eventSink = null;
        Log.d(LIBRARY_NAME, "FFmpegKitFlutterPlugin stopped listening to events.");
    }

    @Override
    public boolean onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        Log.d(LIBRARY_NAME, String.format("selectDocument completed with requestCode: %d, resultCode: %d, data: %s.", requestCode, resultCode, data == null ? null : data.toString()));

        if (requestCode == READABLE_REQUEST_CODE || requestCode == WRITABLE_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                if (data == null) {
                    resultHandler.successAsync(lastInitiatedIntentResult, null);
                } else {
                    final Uri uri = data.getData();
                    resultHandler.successAsync(lastInitiatedIntentResult, uri == null ? null : uri.toString());
                }
            } else {
                resultHandler.errorAsync(lastInitiatedIntentResult, "SELECT_CANCELLED", String.valueOf(resultCode));
            }

            return true;
        } else {
            Log.i(LIBRARY_NAME, String.format("FFmpegKitFlutterPlugin ignored unsupported activity result for requestCode: %d.", requestCode));
            return false;
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        final Optional<Integer> sessionIdOptional = Optional.ofNullable(call.argument(ARGUMENT_SESSION_ID));
        final Integer waitTimeout = call.argument(ARGUMENT_WAIT_TIMEOUT);
        final Optional<List<String>> argumentsOptional = Optional.ofNullable(call.argument(ARGUMENT_ARGUMENTS));
        final Optional<String> ffprobeJsonOutputOptional = Optional.ofNullable(call.argument(ARGUMENT_FFPROBE_JSON_OUTPUT));
        final Optional<Boolean> writableOptional = Optional.ofNullable(call.argument(ARGUMENT_WRITABLE));

        switch (call.method) {
            case "abstractSessionGetEndTime":
                if (sessionIdOptional.isPresent()) {
                    abstractSessionGetEndTime(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "abstractSessionGetDuration":
                if (sessionIdOptional.isPresent()) {
                    abstractSessionGetDuration(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "abstractSessionGetAllLogs":
                if (sessionIdOptional.isPresent()) {
                    abstractSessionGetAllLogs(sessionIdOptional.get(), waitTimeout, result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "abstractSessionGetLogs":
                if (sessionIdOptional.isPresent()) {
                    abstractSessionGetLogs(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "abstractSessionGetAllLogsAsString":
                if (sessionIdOptional.isPresent()) {
                    abstractSessionGetAllLogsAsString(sessionIdOptional.get(), waitTimeout, result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "abstractSessionGetState":
                if (sessionIdOptional.isPresent()) {
                    abstractSessionGetState(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "abstractSessionGetReturnCode":
                if (sessionIdOptional.isPresent()) {
                    abstractSessionGetReturnCode(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "abstractSessionGetFailStackTrace":
                if (sessionIdOptional.isPresent()) {
                    abstractSessionGetFailStackTrace(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "thereAreAsynchronousMessagesInTransmit":
                if (sessionIdOptional.isPresent()) {
                    abstractSessionThereAreAsynchronousMessagesInTransmit(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "getArch":
                getArch(result);
                break;
            case "ffmpegSession":
                if (argumentsOptional.isPresent()) {
                    ffmpegSession(argumentsOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_ARGUMENTS", "Invalid arguments array.");
                }
                break;
            case "ffmpegSessionGetAllStatistics":
                if (sessionIdOptional.isPresent()) {
                    ffmpegSessionGetAllStatistics(sessionIdOptional.get(), waitTimeout, result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "ffmpegSessionGetStatistics":
                if (sessionIdOptional.isPresent()) {
                    ffmpegSessionGetStatistics(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "ffprobeSession":
                if (argumentsOptional.isPresent()) {
                    ffprobeSession(argumentsOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_ARGUMENTS", "Invalid arguments array.");
                }
                break;
            case "mediaInformationSession":
                if (argumentsOptional.isPresent()) {
                    mediaInformationSession(argumentsOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_ARGUMENTS", "Invalid arguments array.");
                }
                break;
            case "mediaInformationJsonParserFrom":
                if (ffprobeJsonOutputOptional.isPresent()) {
                    mediaInformationJsonParserFrom(ffprobeJsonOutputOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_FFPROBE_JSON_OUTPUT", "Invalid ffprobe json output.");
                }
                break;
            case "mediaInformationJsonParserFromWithError":
                if (ffprobeJsonOutputOptional.isPresent()) {
                    mediaInformationJsonParserFromWithError(ffprobeJsonOutputOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_FFPROBE_JSON_OUTPUT", "Invalid ffprobe json output.");
                }
                break;
            case "enableRedirection":
                enableRedirection(result);
                break;
            case "disableRedirection":
                disableRedirection(result);
                break;
            case "enableLogs":
                enableLogs(result);
                break;
            case "disableLogs":
                disableLogs(result);
                break;
            case "enableStatistics":
                enableStatistics(result);
                break;
            case "disableStatistics":
                disableStatistics(result);
                break;
            case "setFontconfigConfigurationPath":
                final Optional<String> pathOptional = Optional.ofNullable(call.argument("path"));
                if (pathOptional.isPresent()) {
                    setFontconfigConfigurationPath(pathOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_PATH", "Invalid path.");
                }
                break;
            case "setFontDirectory": {
                final Optional<String> fontDirectoryOptional = Optional.ofNullable(call.argument("fontDirectory"));
                final Map<String, String> fontNameMap = call.argument("fontNameMap");
                if (fontDirectoryOptional.isPresent()) {
                    setFontDirectory(fontDirectoryOptional.get(), fontNameMap, result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_FONT_DIRECTORY", "Invalid font directory.");
                }
                break;
            }
            case "setFontDirectoryList": {
                final Optional<List<String>> fontDirectoryListOptional = Optional.ofNullable(call.argument("fontDirectoryList"));
                final Map<String, String> fontNameMap = call.argument("fontNameMap");
                if (fontDirectoryListOptional.isPresent()) {
                    setFontDirectoryList(fontDirectoryListOptional.get(), fontNameMap, result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_FONT_DIRECTORY_LIST", "Invalid font directory list.");
                }
                break;
            }
            case "registerNewFFmpegPipe":
                registerNewFFmpegPipe(result);
                break;
            case "closeFFmpegPipe":
                final Optional<String> ffmpegPipePathOptional = Optional.ofNullable(call.argument("ffmpegPipePath"));
                if (ffmpegPipePathOptional.isPresent()) {
                    closeFFmpegPipe(ffmpegPipePathOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_PIPE_PATH", "Invalid ffmpeg pipe path.");
                }
                break;
            case "getFFmpegVersion":
                getFFmpegVersion(result);
                break;
            case "isLTSBuild":
                isLTSBuild(result);
                break;
            case "getBuildDate":
                getBuildDate(result);
                break;
            case "setEnvironmentVariable":
                final Optional<String> variableNameOptional = Optional.ofNullable(call.argument("variableName"));
                final Optional<String> variableValueOptional = Optional.ofNullable(call.argument("variableValue"));

                if (variableNameOptional.isPresent() && variableValueOptional.isPresent()) {
                    setEnvironmentVariable(variableNameOptional.get(), variableValueOptional.get(), result);
                } else if (variableValueOptional.isPresent()) {
                    resultHandler.errorAsync(result, "INVALID_NAME", "Invalid environment variable name.");
                } else {
                    resultHandler.errorAsync(result, "INVALID_VALUE", "Invalid environment variable value.");
                }
                break;
            case "ignoreSignal":
                final Optional<Integer> signalOptional = Optional.ofNullable(call.argument("signal"));
                if (signalOptional.isPresent()) {
                    ignoreSignal(signalOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SIGNAL", "Invalid signal value.");
                }
                break;
            case "asyncFFmpegSessionExecute":
                if (sessionIdOptional.isPresent()) {
                    asyncFFmpegSessionExecute(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "asyncFFprobeSessionExecute":
                if (sessionIdOptional.isPresent()) {
                    asyncFFprobeSessionExecute(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "asyncMediaInformationSessionExecute":
                if (sessionIdOptional.isPresent()) {
                    asyncMediaInformationSessionExecute(sessionIdOptional.get(), waitTimeout, result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "getLogLevel":
                getLogLevel(result);
                break;
            case "setLogLevel":
                final Optional<Integer> levelOptional = Optional.ofNullable(call.argument("level"));
                if (levelOptional.isPresent()) {
                    setLogLevel(levelOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_LEVEL", "Invalid level value.");
                }
                break;
            case "getSessionHistorySize":
                getSessionHistorySize(result);
                break;
            case "setSessionHistorySize":
                final Optional<Integer> sessionHistorySizeOptional = Optional.ofNullable(call.argument("sessionHistorySize"));
                if (sessionHistorySizeOptional.isPresent()) {
                    setSessionHistorySize(sessionHistorySizeOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SIZE", "Invalid session history size value.");
                }
                break;
            case "getSession":
                if (sessionIdOptional.isPresent()) {
                    getSession(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "getLastSession":
                getLastSession(result);
                break;
            case "getLastCompletedSession":
                getLastCompletedSession(result);
                break;
            case "getSessions":
                getSessions(result);
                break;
            case "clearSessions":
                clearSessions(result);
                break;
            case "getSessionsByState":
                final Optional<Integer> stateOptional = Optional.ofNullable(call.argument("state"));
                if (stateOptional.isPresent()) {
                    getSessionsByState(stateOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION_STATE", "Invalid session state value.");
                }
                break;
            case "getLogRedirectionStrategy":
                getLogRedirectionStrategy(result);
                break;
            case "setLogRedirectionStrategy":
                final Optional<Integer> strategyOptional = Optional.ofNullable(call.argument("strategy"));
                if (strategyOptional.isPresent()) {
                    setLogRedirectionStrategy(strategyOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_LOG_REDIRECTION_STRATEGY", "Invalid log redirection strategy value.");
                }
                break;
            case "messagesInTransmit":
                if (sessionIdOptional.isPresent()) {
                    messagesInTransmit(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "getPlatform":
                getPlatform(result);
                break;
            case "writeToPipe":
                final Optional<String> inputOptional = Optional.ofNullable(call.argument("input"));
                final Optional<String> pipeOptional = Optional.ofNullable(call.argument("pipe"));
                if (inputOptional.isPresent() && pipeOptional.isPresent()) {
                    writeToPipe(inputOptional.get(), pipeOptional.get(), result);
                } else if (pipeOptional.isPresent()) {
                    resultHandler.errorAsync(result, "INVALID_INPUT", "Invalid input value.");
                } else {
                    resultHandler.errorAsync(result, "INVALID_PIPE", "Invalid pipe value.");
                }
                break;
            case "selectDocument":
                final String title = call.argument("title");
                final String type = call.argument("type");
                final Optional<List<String>> extraTypesOptional = Optional.ofNullable(call.argument("extraTypes"));
                final String[] extraTypesArray = extraTypesOptional.map(strings -> strings.toArray(new String[0])).orElse(null);
                if (writableOptional.isPresent()) {
                    selectDocument(writableOptional.get(), title, type, extraTypesArray, result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_WRITABLE", "Invalid writable value.");
                }
                break;
            case "getSafParameter":
                final Optional<String> uriOptional = Optional.ofNullable(call.argument("uri"));
                if (writableOptional.isPresent() && uriOptional.isPresent()) {
                    getSafParameter(writableOptional.get(), uriOptional.get(), result);
                } else if (uriOptional.isPresent()) {
                    resultHandler.errorAsync(result, "INVALID_WRITABLE", "Invalid writable value.");
                } else {
                    resultHandler.errorAsync(result, "INVALID_URI", "Invalid uri value.");
                }
                break;
            case "cancel":
                cancel(result);
                break;
            case "cancelSession":
                if (sessionIdOptional.isPresent()) {
                    cancelSession(sessionIdOptional.get(), result);
                } else {
                    resultHandler.errorAsync(result, "INVALID_SESSION", "Invalid session id.");
                }
                break;
            case "getFFmpegSessions":
                getFFmpegSessions(result);
                break;
            case "getFFprobeSessions":
                getFFprobeSessions(result);
                break;
            case "getPackageName":
                getPackageName(result);
                break;
            case "getExternalLibraries":
                getExternalLibraries(result);
                break;
            default:
                resultHandler.notImplementedAsync(result);
                break;
        }
    }

    @SuppressWarnings("deprecation")
    protected void init(final BinaryMessenger messenger, final Context context, final Activity activity, final io.flutter.plugin.common.PluginRegistry.Registrar registrar, final ActivityPluginBinding activityBinding) {
        if (methodChannel == null) {
            methodChannel = new MethodChannel(messenger, METHOD_CHANNEL);
            methodChannel.setMethodCallHandler(this);
        } else {
            Log.i(LIBRARY_NAME, "FFmpegKitFlutterPlugin method channel was already initialised.");
        }

        if (eventChannel == null) {
            eventChannel = new EventChannel(messenger, EVENT_CHANNEL);
            eventChannel.setStreamHandler(this);
        } else {
            Log.i(LIBRARY_NAME, "FFmpegKitFlutterPlugin event channel was already initialised.");
        }

        this.context = context;
        this.activity = activity;

        if (registrar != null) {
            // V1 embedding setup for activity listeners.
            registrar.addActivityResultListener(this);
        } else {
            // V2 embedding setup for activity listeners.
            activityBinding.addActivityResultListener(this);
        }

        Log.d(LIBRARY_NAME, String.format("FFmpegKitFlutterPlugin initialized with context %s and activity %s.", context, activity));
    }

    protected void uninit() {
        uninitMethodChannel();
        uninitEventChannel();

        if (this.activityPluginBinding != null) {
            this.activityPluginBinding.removeActivityResultListener(this);
        }

        this.context = null;
        this.activity = null;
        this.flutterPluginBinding = null;
        this.activityPluginBinding = null;

        Log.d(LIBRARY_NAME, "FFmpegKitFlutterPlugin uninitialized.");
    }

    protected void uninitMethodChannel() {
        if (methodChannel == null) {
            Log.i(LIBRARY_NAME, "FFmpegKitFlutterPlugin method channel was already uninitialised.");
            return;
        }

        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
    }

    protected void uninitEventChannel() {
        if (eventChannel == null) {
            Log.i(LIBRARY_NAME, "FFmpegKitFlutterPlugin event channel was already uninitialised.");
            return;
        }

        eventChannel.setStreamHandler(null);
        eventChannel = null;
    }

    // AbstractSession

    protected void abstractSessionGetEndTime(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            final Date endTime = session.getEndTime();
            if (endTime == null) {
                resultHandler.successAsync(result, null);
            } else {
                resultHandler.successAsync(result, endTime.getTime());
            }
        }
    }

    protected void abstractSessionGetDuration(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            resultHandler.successAsync(result, session.getDuration());
        }
    }

    protected void abstractSessionGetAllLogs(@NonNull final Integer sessionId, @Nullable final Integer waitTimeout, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            final int timeout;
            if (isValidPositiveNumber(waitTimeout)) {
                timeout = waitTimeout;
            } else {
                timeout = AbstractSession.DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT;
            }
            final List<com.arthenica.ffmpegkit.Log> allLogs = session.getAllLogs(timeout);
            resultHandler.successAsync(result, allLogs.stream().map(FFmpegKitFlutterPlugin::toMap).collect(Collectors.toList()));
        }
    }

    protected void abstractSessionGetLogs(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            final List<com.arthenica.ffmpegkit.Log> allLogs = session.getLogs();
            resultHandler.successAsync(result, allLogs.stream().map(FFmpegKitFlutterPlugin::toMap).collect(Collectors.toList()));
        }
    }

    protected void abstractSessionGetAllLogsAsString(@NonNull final Integer sessionId, @Nullable final Integer waitTimeout, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            final int timeout;
            if (isValidPositiveNumber(waitTimeout)) {
                timeout = waitTimeout;
            } else {
                timeout = AbstractSession.DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT;
            }
            final String allLogsAsString = session.getAllLogsAsString(timeout);
            resultHandler.successAsync(result, allLogsAsString);
        }
    }

    protected void abstractSessionGetState(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            resultHandler.successAsync(result, session.getState().ordinal());
        }
    }

    protected void abstractSessionGetReturnCode(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            final ReturnCode returnCode = session.getReturnCode();
            if (returnCode == null) {
                resultHandler.successAsync(result, null);
            } else {
                resultHandler.successAsync(result, returnCode.getValue());
            }
        }
    }

    protected void abstractSessionGetFailStackTrace(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            resultHandler.successAsync(result, session.getFailStackTrace());
        }
    }

    protected void abstractSessionThereAreAsynchronousMessagesInTransmit(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            resultHandler.successAsync(result, session.thereAreAsynchronousMessagesInTransmit());
        }
    }

    // ArchDetect

    protected void getArch(@NonNull final Result result) {
        resultHandler.successAsync(result, AbiDetect.getAbi());
    }

    // FFmpegSession

    protected void ffmpegSession(@NonNull final List<String> arguments, @NonNull final Result result) {
        final FFmpegSession session = new FFmpegSession(arguments.toArray(new String[0]), null, null, null, LogRedirectionStrategy.NEVER_PRINT_LOGS);
        resultHandler.successAsync(result, toMap(session));
    }

    protected void ffmpegSessionGetAllStatistics(@NonNull final Integer sessionId, @Nullable final Integer waitTimeout, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            if (session instanceof FFmpegSession) {
                final int timeout;
                if (isValidPositiveNumber(waitTimeout)) {
                    timeout = waitTimeout;
                } else {
                    timeout = AbstractSession.DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT;
                }
                final List<Statistics> allStatistics = ((FFmpegSession) session).getAllStatistics(timeout);
                resultHandler.successAsync(result, allStatistics.stream().map(FFmpegKitFlutterPlugin::toMap).collect(Collectors.toList()));
            } else {
                resultHandler.errorAsync(result, "NOT_FFMPEG_SESSION", "A session is found but it does not have the correct type.");
            }
        }
    }

    protected void ffmpegSessionGetStatistics(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            if (session instanceof FFmpegSession) {
                final List<Statistics> statistics = ((FFmpegSession) session).getStatistics();
                resultHandler.successAsync(result, statistics.stream().map(FFmpegKitFlutterPlugin::toMap).collect(Collectors.toList()));
            } else {
                resultHandler.errorAsync(result, "NOT_FFMPEG_SESSION", "A session is found but it does not have the correct type.");
            }
        }
    }

    // FFprobeSession

    protected void ffprobeSession(@NonNull final List<String> arguments, @NonNull final Result result) {
        final FFprobeSession session = new FFprobeSession(arguments.toArray(new String[0]), null, null, LogRedirectionStrategy.NEVER_PRINT_LOGS);
        resultHandler.successAsync(result, toMap(session));
    }

    // MediaInformationSession

    protected void mediaInformationSession(@NonNull final List<String> arguments, @NonNull final Result result) {
        final MediaInformationSession session = new MediaInformationSession(arguments.toArray(new String[0]), null, null);
        resultHandler.successAsync(result, toMap(session));
    }

    // MediaInformationJsonParser

    protected void mediaInformationJsonParserFrom(@NonNull final String ffprobeJsonOutput, @NonNull final Result result) {
        try {
            final MediaInformation mediaInformation = MediaInformationJsonParser.fromWithError(ffprobeJsonOutput);
            resultHandler.successAsync(result, toMap(mediaInformation));
        } catch (final JSONException e) {
            Log.i(LIBRARY_NAME, "Parsing MediaInformation failed.", e);
            resultHandler.successAsync(result, null);
        }
    }

    protected void mediaInformationJsonParserFromWithError(@NonNull final String ffprobeJsonOutput, @NonNull final Result result) {
        try {
            final MediaInformation mediaInformation = MediaInformationJsonParser.fromWithError(ffprobeJsonOutput);
            resultHandler.successAsync(result, toMap(mediaInformation));
        } catch (JSONException e) {
            Log.i(LIBRARY_NAME, "Parsing MediaInformation failed.", e);
            resultHandler.errorAsync(result, "PARSE_FAILED", "Parsing MediaInformation failed with JSON error.");
        }
    }

    // FFmpegKitConfig

    protected void enableRedirection(@NonNull final Result result) {
        enableLogs();
        enableStatistics();
        FFmpegKitConfig.enableRedirection();

        resultHandler.successAsync(result, null);
    }

    protected void disableRedirection(@NonNull final Result result) {
        FFmpegKitConfig.disableRedirection();

        resultHandler.successAsync(result, null);
    }

    protected void enableLogs(@NonNull final Result result) {
        enableLogs();

        resultHandler.successAsync(result, null);
    }

    protected void disableLogs(@NonNull final Result result) {
        disableLogs();

        resultHandler.successAsync(result, null);
    }

    protected void enableStatistics(@NonNull final Result result) {
        enableStatistics();

        resultHandler.successAsync(result, null);
    }

    protected void disableStatistics(@NonNull final Result result) {
        disableStatistics();

        resultHandler.successAsync(result, null);
    }

    protected void setFontconfigConfigurationPath(@NonNull final String path, @NonNull final Result result) {
        FFmpegKitConfig.setFontconfigConfigurationPath(path);

        resultHandler.successAsync(result, null);
    }

    protected void setFontDirectory(@NonNull final String fontDirectoryPath, @Nullable final Map<String, String> fontNameMapping, @NonNull final Result result) {
        if (context != null) {
            FFmpegKitConfig.setFontDirectory(context, fontDirectoryPath, fontNameMapping);
            resultHandler.successAsync(result, null);
        } else {
            Log.w(LIBRARY_NAME, "Cannot setFontDirectory. Context is null.");
            resultHandler.errorAsync(result, "INVALID_CONTEXT", "Context is null.");
        }
    }

    protected void setFontDirectoryList(@NonNull final List<String> fontDirectoryList, @Nullable final Map<String, String> fontNameMapping, @NonNull final Result result) {
        if (context != null) {
            FFmpegKitConfig.setFontDirectoryList(context, fontDirectoryList, fontNameMapping);
            resultHandler.successAsync(result, null);
        } else {
            Log.w(LIBRARY_NAME, "Cannot setFontDirectoryList. Context is null.");
            resultHandler.errorAsync(result, "INVALID_CONTEXT", "Context is null.");
        }
    }

    protected void registerNewFFmpegPipe(@NonNull final Result result) {
        if (context != null) {
            resultHandler.successAsync(result, FFmpegKitConfig.registerNewFFmpegPipe(context));
        } else {
            Log.w(LIBRARY_NAME, "Cannot registerNewFFmpegPipe. Context is null.");
            resultHandler.errorAsync(result, "INVALID_CONTEXT", "Context is null.");
        }
    }

    protected void closeFFmpegPipe(@NonNull final String ffmpegPipePath, @NonNull final Result result) {
        FFmpegKitConfig.closeFFmpegPipe(ffmpegPipePath);

        resultHandler.successAsync(result, null);
    }

    protected void getFFmpegVersion(@NonNull final Result result) {
        resultHandler.successAsync(result, FFmpegKitConfig.getFFmpegVersion());
    }

    protected void isLTSBuild(@NonNull final Result result) {
        resultHandler.successAsync(result, FFmpegKitConfig.isLTSBuild());
    }

    protected void getBuildDate(@NonNull final Result result) {
        resultHandler.successAsync(result, FFmpegKitConfig.getBuildDate());
    }

    protected void setEnvironmentVariable(@NonNull final String variableName, @NonNull final String variableValue, @NonNull final Result result) {
        FFmpegKitConfig.setEnvironmentVariable(variableName, variableValue);

        resultHandler.successAsync(result, null);
    }

    protected void ignoreSignal(@NonNull final Integer signalIndex, @NonNull final Result result) {
        Signal signal = null;

        if (signalIndex == Signal.SIGINT.ordinal()) {
            signal = Signal.SIGINT;
        } else if (signalIndex == Signal.SIGQUIT.ordinal()) {
            signal = Signal.SIGQUIT;
        } else if (signalIndex == Signal.SIGPIPE.ordinal()) {
            signal = Signal.SIGPIPE;
        } else if (signalIndex == Signal.SIGTERM.ordinal()) {
            signal = Signal.SIGTERM;
        } else if (signalIndex == Signal.SIGXCPU.ordinal()) {
            signal = Signal.SIGXCPU;
        }

        if (signal != null) {
            FFmpegKitConfig.ignoreSignal(signal);

            resultHandler.successAsync(result, null);
        } else {
            resultHandler.errorAsync(result, "INVALID_SIGNAL", "Signal value not supported.");
        }
    }

    protected void asyncFFmpegSessionExecute(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            if (session instanceof FFmpegSession) {
                FFmpegKitConfig.asyncFFmpegExecute((FFmpegSession) session);
                resultHandler.successAsync(result, null);
            } else {
                resultHandler.errorAsync(result, "NOT_FFMPEG_SESSION", "A session is found but it does not have the correct type.");
            }
        }
    }

    protected void asyncFFprobeSessionExecute(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            if (session instanceof FFprobeSession) {
                FFmpegKitConfig.asyncFFprobeExecute((FFprobeSession) session);
                resultHandler.successAsync(result, null);
            } else {
                resultHandler.errorAsync(result, "NOT_FFPROBE_SESSION", "A session is found but it does not have the correct type.");
            }
        }
    }

    protected void asyncMediaInformationSessionExecute(@NonNull final Integer sessionId, @Nullable final Integer waitTimeout, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            if (session instanceof MediaInformationSession) {
                final int timeout;
                if (isValidPositiveNumber(waitTimeout)) {
                    timeout = waitTimeout;
                } else {
                    timeout = AbstractSession.DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT;
                }
                FFmpegKitConfig.asyncGetMediaInformationExecute((MediaInformationSession) session, timeout);
                resultHandler.successAsync(result, null);
            } else {
                resultHandler.errorAsync(result, "NOT_MEDIA_INFORMATION_SESSION", "A session is found but it does not have the correct type.");
            }
        }
    }

    protected void getLogLevel(@NonNull final Result result) {
        resultHandler.successAsync(result, toInt(FFmpegKitConfig.getLogLevel()));
    }

    protected void setLogLevel(@NonNull final Integer level, @NonNull final Result result) {
        FFmpegKitConfig.setLogLevel(Level.from(level));
        resultHandler.successAsync(result, null);
    }

    protected void getSessionHistorySize(@NonNull final Result result) {
        resultHandler.successAsync(result, FFmpegKitConfig.getSessionHistorySize());
    }

    protected void setSessionHistorySize(@NonNull final Integer sessionHistorySize, @NonNull final Result result) {
        FFmpegKitConfig.setSessionHistorySize(sessionHistorySize);
        resultHandler.successAsync(result, null);
    }

    protected void getSession(@NonNull final Integer sessionId, @NonNull final Result result) {
        final Session session = FFmpegKitConfig.getSession(sessionId.longValue());
        if (session == null) {
            resultHandler.errorAsync(result, "SESSION_NOT_FOUND", "Session not found.");
        } else {
            resultHandler.successAsync(result, toMap(session));
        }
    }

    protected void getLastSession(@NonNull final Result result) {
        final Session session = FFmpegKitConfig.getLastSession();
        resultHandler.successAsync(result, toMap(session));
    }

    protected void getLastCompletedSession(@NonNull final Result result) {
        final Session session = FFmpegKitConfig.getLastCompletedSession();
        resultHandler.successAsync(result, toMap(session));
    }

    protected void getSessions(@NonNull final Result result) {
        resultHandler.successAsync(result, toSessionArray(FFmpegKitConfig.getSessions()));
    }

    protected void clearSessions(@NonNull final Result result) {
        FFmpegKitConfig.clearSessions();
        resultHandler.successAsync(result, null);
    }

    protected void getSessionsByState(@NonNull final Integer sessionState, @NonNull final Result result) {
        resultHandler.successAsync(result, toSessionArray(FFmpegKitConfig.getSessionsByState(toSessionState(sessionState))));
    }

    protected void getLogRedirectionStrategy(@NonNull final Result result) {
        resultHandler.successAsync(result, toInt(FFmpegKitConfig.getLogRedirectionStrategy()));
    }

    protected void setLogRedirectionStrategy(@NonNull final Integer logRedirectionStrategy, @NonNull final Result result) {
        FFmpegKitConfig.setLogRedirectionStrategy(toLogRedirectionStrategy(logRedirectionStrategy));
        resultHandler.successAsync(result, null);
    }

    protected void messagesInTransmit(@NonNull final Integer sessionId, @NonNull final Result result) {
        resultHandler.successAsync(result, FFmpegKitConfig.messagesInTransmit(sessionId.longValue()));
    }

    protected void getPlatform(@NonNull final Result result) {
        resultHandler.successAsync(result, PLATFORM_NAME);
    }

    protected void writeToPipe(@NonNull final String inputPath, @NonNull final String namedPipePath, @NonNull final Result result) {
        final AsyncWriteToPipeTask asyncTask = new AsyncWriteToPipeTask(inputPath, namedPipePath, resultHandler, result);
        asyncWriteToPipeExecutorService.submit(asyncTask);
    }

    protected void selectDocument(@NonNull final Boolean writable, @Nullable final String title, @Nullable final String type, @Nullable final String[] extraTypes, @NonNull final Result result) {
        final Intent intent;
        if (writable) {
            intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        } else {
            intent = new Intent(Intent.ACTION_GET_CONTENT);
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }

        if (type != null) {
            intent.setType(type);
        } else {
            intent.setType("*/*");
        }

        if (title != null) {
            intent.putExtra(Intent.EXTRA_TITLE, title);
        }

        if (extraTypes != null) {
            intent.putExtra(Intent.EXTRA_MIME_TYPES, extraTypes);
        }

        if (context != null) {
            if (activity != null) {
                try {
                    lastInitiatedIntentResult = result;
                    activity.startActivityForResult(intent, writable ? WRITABLE_REQUEST_CODE : READABLE_REQUEST_CODE);
                } catch (final Exception e) {
                    Log.i(LIBRARY_NAME, String.format("Failed to selectDocument using parameters writable: %s, type: %s, title: %s and extra types: %s!", writable, type, title, extraTypes == null ? null : Arrays.toString(extraTypes)), e);
                    resultHandler.errorAsync(result, "SELECT_FAILED", e.getMessage());
                }
            } else {
                Log.w(LIBRARY_NAME, String.format("Cannot selectDocument using parameters writable: %s, type: %s, title: %s and extra types: %s. Activity is null.", writable, type, title, extraTypes == null ? null : Arrays.toString(extraTypes)));
                resultHandler.errorAsync(result, "INVALID_ACTIVITY", "Activity is null.");
            }
        } else {
            Log.w(LIBRARY_NAME, String.format("Cannot selectDocument using parameters writable: %s, type: %s, title: %s and extra types: %s. Context is null.", writable, type, title, extraTypes == null ? null : Arrays.toString(extraTypes)));
            resultHandler.errorAsync(result, "INVALID_CONTEXT", "Context is null.");
        }
    }

    protected void getSafParameter(@NonNull final Boolean writable, @NonNull final String uriString, @NonNull final Result result) {
        if (context != null) {
            final Uri uri = Uri.parse(uriString);
            if (uri == null) {
                Log.w(LIBRARY_NAME, String.format("Cannot getSafParameter using parameters writable: %s, uriString: %s. Uri string cannot be parsed.", writable, uriString));
                resultHandler.errorAsync(result, "GET_SAF_PARAMETER_FAILED", "Uri string cannot be parsed.");
            } else {
                final String safParameter;
                if (writable) {
                    safParameter = FFmpegKitConfig.getSafParameterForWrite(context, uri);
                } else {
                    safParameter = FFmpegKitConfig.getSafParameterForRead(context, uri);
                }

                Log.d(LIBRARY_NAME, String.format("getSafParameter using parameters writable: %s, uriString: %s completed with saf parameter: %s.", writable, uriString, safParameter));

                resultHandler.successAsync(result, safParameter);
            }
        } else {
            Log.w(LIBRARY_NAME, String.format("Cannot getSafParameter using parameters writable: %s, uriString: %s. Context is null.", writable, uriString));
            resultHandler.errorAsync(result, "INVALID_CONTEXT", "Context is null.");
        }
    }

    // FFmpegKit

    protected void cancel(@NonNull final Result result) {
        FFmpegKit.cancel();
        resultHandler.successAsync(result, null);
    }

    protected void cancelSession(@NonNull final Integer sessionId, @NonNull final Result result) {
        FFmpegKit.cancel(sessionId.longValue());
        resultHandler.successAsync(result, null);
    }

    protected void getFFmpegSessions(@NonNull final Result result) {
        resultHandler.successAsync(result, toSessionArray(FFmpegKit.listSessions()));
    }

    // FFprobeKit

    protected void getFFprobeSessions(@NonNull final Result result) {
        resultHandler.successAsync(result, toSessionArray(FFprobeKit.listSessions()));
    }

    // Packages

    protected void getPackageName(@NonNull final Result result) {
        resultHandler.successAsync(result, Packages.getPackageName());
    }

    protected void getExternalLibraries(@NonNull final Result result) {
        resultHandler.successAsync(result, Packages.getExternalLibraries());
    }

    protected void enableLogs() {
        logsEnabled.compareAndSet(false, true);
    }

    protected void disableLogs() {
        logsEnabled.compareAndSet(true, false);
    }

    protected void enableStatistics() {
        statisticsEnabled.compareAndSet(false, true);
    }

    protected void disableStatistics() {
        statisticsEnabled.compareAndSet(true, false);
    }

    protected static int toInt(final Level level) {
        return (level == null) ? Level.AV_LOG_TRACE.getValue() : level.getValue();
    }

    protected static Map<String, Object> toMap(final Session session) {
        if (session == null) {
            return null;
        }

        final Map<String, Object> sessionMap = new HashMap<>();

        sessionMap.put(KEY_SESSION_ID, session.getSessionId());
        sessionMap.put(KEY_SESSION_CREATE_TIME, toLong(session.getCreateTime()));
        sessionMap.put(KEY_SESSION_START_TIME, toLong(session.getStartTime()));
        sessionMap.put(KEY_SESSION_COMMAND, session.getCommand());

        if (session.isFFprobe()) {
            if (session instanceof MediaInformationSession) {
                final MediaInformationSession mediaInformationSession = (MediaInformationSession) session;
                final MediaInformation mediaInformation = mediaInformationSession.getMediaInformation();
                if (mediaInformation != null) {
                    sessionMap.put(KEY_SESSION_MEDIA_INFORMATION, toMap(mediaInformation));
                }
                sessionMap.put(KEY_SESSION_TYPE, SESSION_TYPE_MEDIA_INFORMATION);
            } else {
                sessionMap.put(KEY_SESSION_TYPE, SESSION_TYPE_FFPROBE);
            }
        } else {
            sessionMap.put(KEY_SESSION_TYPE, SESSION_TYPE_FFMPEG);
        }

        return sessionMap;
    }

    protected static long toLong(final Date date) {
        if (date != null) {
            return date.getTime();
        } else {
            return 0;
        }
    }

    protected static int toInt(final LogRedirectionStrategy logRedirectionStrategy) {
        switch (logRedirectionStrategy) {
            case ALWAYS_PRINT_LOGS:
                return 0;
            case PRINT_LOGS_WHEN_NO_CALLBACKS_DEFINED:
                return 1;
            case PRINT_LOGS_WHEN_GLOBAL_CALLBACK_NOT_DEFINED:
                return 2;
            case PRINT_LOGS_WHEN_SESSION_CALLBACK_NOT_DEFINED:
                return 3;
            case NEVER_PRINT_LOGS:
            default:
                return 4;
        }
    }

    protected static LogRedirectionStrategy toLogRedirectionStrategy(final int value) {
        switch (value) {
            case 0:
                return LogRedirectionStrategy.ALWAYS_PRINT_LOGS;
            case 1:
                return LogRedirectionStrategy.PRINT_LOGS_WHEN_NO_CALLBACKS_DEFINED;
            case 2:
                return LogRedirectionStrategy.PRINT_LOGS_WHEN_GLOBAL_CALLBACK_NOT_DEFINED;
            case 3:
                return LogRedirectionStrategy.PRINT_LOGS_WHEN_SESSION_CALLBACK_NOT_DEFINED;
            case 4:
            default:
                return LogRedirectionStrategy.NEVER_PRINT_LOGS;
        }
    }

    protected static SessionState toSessionState(final int value) {
        switch (value) {
            case 0:
                return SessionState.CREATED;
            case 1:
                return SessionState.RUNNING;
            case 2:
                return SessionState.FAILED;
            case 3:
            default:
                return SessionState.COMPLETED;
        }
    }

    protected static Map<String, Object> toMap(final com.arthenica.ffmpegkit.Log log) {
        final HashMap<String, Object> logMap = new HashMap<>();

        logMap.put(KEY_LOG_SESSION_ID, log.getSessionId());
        logMap.put(KEY_LOG_LEVEL, toInt(log.getLevel()));
        logMap.put(KEY_LOG_MESSAGE, log.getMessage());

        return logMap;
    }

    protected static Map<String, Object> toMap(final Statistics statistics) {
        final HashMap<String, Object> statisticsMap = new HashMap<>();

        if (statistics != null) {
            statisticsMap.put(KEY_STATISTICS_SESSION_ID, statistics.getSessionId());
            statisticsMap.put(KEY_STATISTICS_VIDEO_FRAME_NUMBER, statistics.getVideoFrameNumber());
            statisticsMap.put(KEY_STATISTICS_VIDEO_FPS, statistics.getVideoFps());
            statisticsMap.put(KEY_STATISTICS_VIDEO_QUALITY, statistics.getVideoQuality());
            statisticsMap.put(KEY_STATISTICS_SIZE, (statistics.getSize() < Integer.MAX_VALUE) ? (int) statistics.getSize() : (int) (statistics.getSize() % Integer.MAX_VALUE));
            statisticsMap.put(KEY_STATISTICS_TIME, statistics.getTime());
            statisticsMap.put(KEY_STATISTICS_BITRATE, statistics.getBitrate());
            statisticsMap.put(KEY_STATISTICS_SPEED, statistics.getSpeed());
        }

        return statisticsMap;
    }

    protected static List<Map<String, Object>> toSessionArray(final List<? extends Session> sessions) {
        final List<Map<String, Object>> sessionArray = new ArrayList<>();

        for (int i = 0; i < sessions.size(); i++) {
            sessionArray.add(toMap(sessions.get(i)));
        }

        return sessionArray;
    }

    protected static Map<String, Object> toMap(final MediaInformation mediaInformation) {
        Map<String, Object> map = new HashMap<>();

        if (mediaInformation != null) {
            if (mediaInformation.getAllProperties() != null) {
                JSONObject allProperties = mediaInformation.getAllProperties();
                if (allProperties != null) {
                    map = toMap(allProperties);
                }
            }
        }

        return map;
    }

    protected static Map<String, Object> toMap(final JSONObject jsonObject) {
        final HashMap<String, Object> map = new HashMap<>();

        if (jsonObject != null) {
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                Object value = jsonObject.opt(key);
                if (value != null) {
                    if (value instanceof JSONArray) {
                        value = toList((JSONArray) value);
                    } else if (value instanceof JSONObject) {
                        value = toMap((JSONObject) value);
                    }
                    map.put(key, value);
                }
            }
        }

        return map;
    }

    protected static List<Object> toList(final JSONArray array) {
        final List<Object> list = new ArrayList<>();

        for (int i = 0; i < array.length(); i++) {
            Object value = array.opt(i);
            if (value != null) {
                if (value instanceof JSONArray) {
                    value = toList((JSONArray) value);
                } else if (value instanceof JSONObject) {
                    value = toMap((JSONObject) value);
                }
                list.add(value);
            }
        }

        return list;
    }

    protected static boolean isValidPositiveNumber(final Integer value) {
        return (value != null) && (value >= 0);
    }

    protected void emitLog(final com.arthenica.ffmpegkit.Log log) {
        final HashMap<String, Object> logMap = new HashMap<>();
        logMap.put(EVENT_LOG_CALLBACK_EVENT, toMap(log));
        resultHandler.successAsync(eventSink, logMap);
    }

    protected void emitStatistics(final Statistics statistics) {
        final HashMap<String, Object> statisticsMap = new HashMap<>();
        statisticsMap.put(EVENT_STATISTICS_CALLBACK_EVENT, toMap(statistics));
        resultHandler.successAsync(eventSink, statisticsMap);
    }

    protected void emitSession(final Session session) {
        final HashMap<String, Object> sessionMap = new HashMap<>();
        sessionMap.put(EVENT_EXECUTE_CALLBACK_EVENT, toMap(session));
        resultHandler.successAsync(eventSink, sessionMap);
    }

}
