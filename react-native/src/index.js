import {NativeEventEmitter, NativeModules} from 'react-native';

const {FFmpegKitReactNativeModule} = NativeModules;

const ffmpegSessionCompleteCallbackMap = new Map()
const ffprobeSessionCompleteCallbackMap = new Map()
const mediaInformationSessionCompleteCallbackMap = new Map()
const logCallbackMap = new Map()
const statisticsCallbackMap = new Map()
const logRedirectionStrategyMap = new Map()

const eventLogCallbackEvent = "FFmpegKitLogCallbackEvent";
const eventStatisticsCallbackEvent = "FFmpegKitStatisticsCallbackEvent";
const eventCompleteCallbackEvent = "FFmpegKitCompleteCallbackEvent";

export const LogRedirectionStrategy = {
  ALWAYS_PRINT_LOGS: 0,
  PRINT_LOGS_WHEN_NO_CALLBACKS_DEFINED: 1,
  PRINT_LOGS_WHEN_GLOBAL_CALLBACK_NOT_DEFINED: 2,
  PRINT_LOGS_WHEN_SESSION_CALLBACK_NOT_DEFINED: 3,
  NEVER_PRINT_LOGS: 4
}

export const SessionState = {
  CREATED: 0, RUNNING: 1, FAILED: 2, COMPLETED: 3
}

export const Signal = {
  SIGINT: 2, SIGQUIT: 3, SIGPIPE: 13, SIGTERM: 15, SIGXCPU: 24
}

class FFmpegKitReactNativeEventEmitter extends NativeEventEmitter {
  constructor() {
    super(FFmpegKitReactNativeModule);
  }

  addListener(eventType, listener, context) {
    let subscription = super.addListener(eventType, listener, context);
    subscription.eventType = eventType;
    let subscriptionRemove = subscription.remove;
    subscription.remove = () => {
      if (super.removeSubscription != null) {
        super.removeSubscription(subscription);
      } else if (subscriptionRemove != null) {
        subscriptionRemove();
      }
    };
    return subscription;
  }

  removeSubscription(subscription) {
    if (super.removeSubscription) {
      super.removeSubscription(subscription);
    }
  }
}

/**
 * <p>Common interface for all <code>FFmpegKit</code> sessions.
 */
export class Session {

  /**
   * Returns the session specific log callback.
   *
   * @return session specific log callback
   */
  getLogCallback() {
  }

  /**
   * Returns the session identifier.
   *
   * @return session identifier
   */
  getSessionId() {
  }

  /**
   * Returns session create time.
   *
   * @return session create time
   */
  getCreateTime() {
  }

  /**
   * Returns session start time.
   *
   * @return session start time
   */
  getStartTime() {
  }

  /**
   * Returns session end time.
   *
   * @return session end time
   */
  getEndTime() {
  }

  /**
   * Returns the time taken to execute this session.
   *
   * @return time taken to execute this session in milliseconds or zero (0) if the session is
   * not over yet
   */
  getDuration() {
  }

  /**
   * Returns command arguments as an array.
   *
   * @return command arguments as an array
   */
  getArguments() {
  }

  /**
   * Returns command arguments as a concatenated string.
   *
   * @return command arguments as a concatenated string
   */
  getCommand() {
  }

  /**
   * Returns all log entries generated for this session. If there are asynchronous
   * messages that are not delivered yet, this method waits for them until the given timeout.
   *
   * @param waitTimeout wait timeout for asynchronous messages in milliseconds
   * @return list of log entries generated for this session
   */
  getAllLogs(waitTimeout) {
  }

  /**
   * Returns all log entries delivered for this session. Note that if there are asynchronous log
   * messages that are not delivered yet, this method will not wait for them and will return
   * immediately.
   *
   * @return list of log entries received for this session
   */
  getLogs() {
  }

  /**
   * Returns all log entries generated for this session as a concatenated string. If there are
   * asynchronous messages that are not delivered yet, this method waits for them until
   * the given timeout.
   *
   * @param waitTimeout wait timeout for asynchronous messages in milliseconds
   * @return all log entries generated for this session as a concatenated string
   */
  getAllLogsAsString(waitTimeout) {
  }

  /**
   * Returns all log entries delivered for this session as a concatenated string. Note that if
   * there are asynchronous log messages that are not delivered yet, this method will not wait
   * for them and will return immediately.
   *
   * @return list of log entries received for this session
   */
  getLogsAsString() {
  }

  /**
   * Returns the log output generated while running the session.
   *
   * @return log output generated
   */
  getOutput() {
  }

  /**
   * Returns the state of the session.
   *
   * @return state of the session
   */
  getState() {
  }

  /**
   * Returns the return code for this session. Note that return code is only set for sessions
   * that end with COMPLETED state. If a session is not started, still running or failed then
   * this method returns undefined.
   *
   * @return the return code for this session if the session is COMPLETED, undefined if session is
   * not started, still running or failed
   */
  getReturnCode() {
  }

  /**
   * Returns the stack trace of the exception received while executing this session.
   * <p>
   * The stack trace is only set for sessions that end with FAILED state. For sessions that has
   * COMPLETED state this method returns undefined.
   *
   * @return stack trace of the exception received while executing this session, undefined if session
   * is not started, still running or completed
   */
  getFailStackTrace() {
  }

  /**
   * Returns session specific log redirection strategy.
   *
   * @return session specific log redirection strategy
   */
  getLogRedirectionStrategy() {
  }

  /**
   * Returns whether there are still asynchronous messages being transmitted for this
   * session or not.
   *
   * @return true if there are still asynchronous messages being transmitted, false
   * otherwise
   */
  thereAreAsynchronousMessagesInTransmit() {
  }

  /**
   * Returns whether it is an <code>FFmpeg</code> session or not.
   *
   * @return true if it is an <code>FFmpeg</code> session, false otherwise
   */
  isFFmpeg() {
  }

  /**
   * Returns whether it is an <code>FFprobe</code> session or not.
   *
   * @return true if it is an <code>FFprobe</code> session, false otherwise
   */
  isFFprobe() {
  }

  /**
   * Returns whether it is a <code>MediaInformation</code> session or not.
   *
   * @return true if it is a <code>MediaInformation</code> session, false otherwise
   */
  isMediaInformation() {
  }

  /**
   * Cancels running the session.
   */
  cancel() {
  }

}

/**
 * Abstract session implementation which includes common features shared by <code>FFmpeg</code>,
 * <code>FFprobe</code> and <code>MediaInformation</code> sessions.
 */
export class AbstractSession extends Session {

  /**
   * Defines how long default "getAll" methods wait, in milliseconds.
   */
  static DEFAULT_TIMEOUT_FOR_ASYNCHRONOUS_MESSAGES_IN_TRANSMIT = 5000;

  /**
   * Session identifier.
   */
  #sessionId;

  /**
   * Date and time the session was created.
   */
  #createTime;

  /**
   * Date and time the session was started.
   */
  #startTime;

  /**
   * Command string.
   */
  #command;

  /**
   * Command arguments as an array.
   */
  #argumentsArray;

  /**
   * Session specific log redirection strategy.
   */
  #logRedirectionStrategy;

  /**
   * Creates a new FFmpeg session.
   *
   * @param argumentsArray FFmpeg command arguments
   * @param logRedirectionStrategy defines how logs will be redirected
   * @returns FFmpeg session created
   */
  static async createFFmpegSession(argumentsArray, logRedirectionStrategy) {
    await FFmpegKitConfig.init();

    if (logRedirectionStrategy === undefined) {
      logRedirectionStrategy = FFmpegKitConfig.getLogRedirectionStrategy();
    }

    let nativeSession = await FFmpegKitReactNativeModule.ffmpegSession(argumentsArray);
    let session = new FFmpegSession();

    session.#sessionId = nativeSession.sessionId;
    session.#createTime = FFmpegKitFactory.validDate(nativeSession.createTime);
    session.#startTime = FFmpegKitFactory.validDate(nativeSession.startTime);
    session.#command = nativeSession.command;
    session.#argumentsArray = argumentsArray;
    session.#logRedirectionStrategy = logRedirectionStrategy;

    FFmpegKitFactory.setLogRedirectionStrategy(session.#sessionId, logRedirectionStrategy);

    return session;
  }

  /**
   * Creates a new FFmpeg session from the given map.
   *
   * @param sessionMap map that includes session fields as map keys
   * @returns FFmpeg session created
   */
  static createFFmpegSessionFromMap(sessionMap) {
    let session = new FFmpegSession();

    session.#sessionId = sessionMap.sessionId;
    session.#createTime = FFmpegKitFactory.validDate(sessionMap.createTime);
    session.#startTime = FFmpegKitFactory.validDate(sessionMap.startTime);
    session.#command = sessionMap.command;
    session.#argumentsArray = FFmpegKitConfig.parseArguments(sessionMap.command);
    session.#logRedirectionStrategy = FFmpegKitFactory.getLogRedirectionStrategy(session.#sessionId);

    return session;
  }

  /**
   * Creates a new FFprobe session.
   *
   * @param argumentsArray FFprobe command arguments
   * @param logRedirectionStrategy defines how logs will be redirected
   * @returns FFprobe session created
   */
  static async createFFprobeSession(argumentsArray, logRedirectionStrategy) {
    await FFmpegKitConfig.init();

    if (logRedirectionStrategy === undefined) {
      logRedirectionStrategy = FFmpegKitConfig.getLogRedirectionStrategy();
    }

    let nativeSession = await FFmpegKitReactNativeModule.ffprobeSession(argumentsArray);
    let session = new FFprobeSession();

    session.#sessionId = nativeSession.sessionId;
    session.#createTime = FFmpegKitFactory.validDate(nativeSession.createTime);
    session.#startTime = FFmpegKitFactory.validDate(nativeSession.startTime);
    session.#command = nativeSession.command;
    session.#argumentsArray = argumentsArray;
    session.#logRedirectionStrategy = logRedirectionStrategy;

    FFmpegKitFactory.setLogRedirectionStrategy(session.#sessionId, logRedirectionStrategy);

    return session;
  }

  /**
   * Creates a new FFprobe session from the given map.
   *
   * @param sessionMap map that includes session fields as map keys
   * @returns FFprobe session created
   */
  static createFFprobeSessionFromMap(sessionMap) {
    let session = new FFprobeSession();

    session.#sessionId = sessionMap.sessionId;
    session.#createTime = FFmpegKitFactory.validDate(sessionMap.createTime);
    session.#startTime = FFmpegKitFactory.validDate(sessionMap.startTime);
    session.#command = sessionMap.command;
    session.#argumentsArray = FFmpegKitConfig.parseArguments(sessionMap.command);
    session.#logRedirectionStrategy = FFmpegKitFactory.getLogRedirectionStrategy(session.#sessionId);

    return session;
  }

  /**
   * Creates a new MediaInformationSession session.
   *
   * @param argumentsArray FFprobe command arguments
   * @returns MediaInformationSession session created
   */
  static async createMediaInformationSession(argumentsArray) {
    await FFmpegKitConfig.init();

    let nativeSession = await FFmpegKitReactNativeModule.mediaInformationSession(argumentsArray);
    let session = new MediaInformationSession();

    session.#sessionId = nativeSession.sessionId;
    session.#createTime = FFmpegKitFactory.validDate(nativeSession.createTime);
    session.#startTime = FFmpegKitFactory.validDate(nativeSession.startTime);
    session.#command = nativeSession.command;
    session.#argumentsArray = argumentsArray;
    session.#logRedirectionStrategy = LogRedirectionStrategy.NEVER_PRINT_LOGS;

    FFmpegKitFactory.setLogRedirectionStrategy(session.#sessionId, LogRedirectionStrategy.NEVER_PRINT_LOGS);

    return session;
  }

  /**
   * Creates a new MediaInformationSession from the given map.
   *
   * @param sessionMap map that includes session fields as map keys
   * @returns MediaInformationSession created
   */
  static createMediaInformationSessionFromMap(sessionMap) {
    let session = new MediaInformationSession();

    session.#sessionId = sessionMap.sessionId;
    session.#createTime = FFmpegKitFactory.validDate(sessionMap.createTime);
    session.#startTime = FFmpegKitFactory.validDate(sessionMap.startTime);
    session.#command = sessionMap.command;
    session.#argumentsArray = FFmpegKitConfig.parseArguments(sessionMap.command);
    session.#logRedirectionStrategy = LogRedirectionStrategy.NEVER_PRINT_LOGS;

    if (sessionMap.mediaInformation !== undefined && sessionMap.mediaInformation !== null) {
      session.setMediaInformation(new MediaInformation(sessionMap.mediaInformation));
    }

    return session;
  }

  /**
   * Returns the session specific log callback.
   *
   * @return session specific log callback
   */
  getLogCallback() {
    return FFmpegKitFactory.getLogCallback(this.getSessionId())
  }

  /**
   * Returns the session identifier.
   *
   * @return session identifier
   */
  getSessionId() {
    return this.#sessionId;
  }

  /**
   * Returns session create time.
   *
   * @return session create time
   */
  getCreateTime() {
    return this.#createTime;
  }

  /**
   * Returns session start time.
   *
   * @return session start time
   */
  getStartTime() {
    return this.#startTime;
  }

  /**
   * Returns session end time.
   *
   * @return session end time
   */
  async getEndTime() {
    const endTime = FFmpegKitReactNativeModule.abstractSessionGetEndTime(this.getSessionId());
    return FFmpegKitFactory.validDate(endTime);
  }

  /**
   * Returns the time taken to execute this session.
   *
   * @return time taken to execute this session in milliseconds or zero (0) if the session is
   * not over yet
   */
  getDuration() {
    return FFmpegKitReactNativeModule.abstractSessionGetDuration(this.getSessionId());
  }

  /**
   * Returns command arguments as an array.
   *
   * @return command arguments as an array
   */
  getArguments() {
    return this.#argumentsArray;
  }

  /**
   * Returns command arguments as a concatenated string.
   *
   * @return command arguments as a concatenated string
   */
  getCommand() {
    return this.#command;
  }

  /**
   * Returns all log entries generated for this session. If there are asynchronous
   * messages that are not delivered yet, this method waits for them until the given timeout.
   *
   * @param waitTimeout wait timeout for asynchronous messages in milliseconds
   * @return list of log entries generated for this session
   */
  async getAllLogs(waitTimeout) {
    const allLogs = await FFmpegKitReactNativeModule.abstractSessionGetAllLogs(this.getSessionId(), FFmpegKitFactory.optionalNumericParameter(waitTimeout));
    return allLogs.map(FFmpegKitFactory.mapToLog);
  }

  /**
   * Returns all log entries delivered for this session. Note that if there are asynchronous log
   * messages that are not delivered yet, this method will not wait for them and will return
   * immediately.
   *
   * @return list of log entries received for this session
   */
  async getLogs() {
    const logs = await FFmpegKitReactNativeModule.abstractSessionGetLogs(this.getSessionId());
    return logs.map(FFmpegKitFactory.mapToLog);
  }

  /**
   * Returns all log entries generated for this session as a concatenated string. If there are
   * asynchronous messages that are not delivered yet, this method waits for them until
   * the given timeout.
   *
   * @param waitTimeout wait timeout for asynchronous messages in milliseconds
   * @return all log entries generated for this session as a concatenated string
   */
  async getAllLogsAsString(waitTimeout) {
    return FFmpegKitReactNativeModule.abstractSessionGetAllLogsAsString(this.getSessionId(), FFmpegKitFactory.optionalNumericParameter(waitTimeout));
  }

  /**
   * Returns all log entries delivered for this session as a concatenated string. Note that if
   * there are asynchronous log messages that are not delivered yet, this method will not wait
   * for them and will return immediately.
   *
   * @return list of log entries received for this session
   */
  async getLogsAsString() {
    let logs = await this.getLogs();

    let concatenatedString = '';

    logs.forEach(log => concatenatedString += log.getMessage());

    return concatenatedString;
  }

  /**
   * Returns the log output generated while running the session.
   *
   * @return log output generated
   */
  async getOutput() {
    return this.getAllLogsAsString();
  }

  /**
   * Returns the state of the session.
   *
   * @return state of the session
   */
  async getState() {
    return FFmpegKitReactNativeModule.abstractSessionGetState(this.getSessionId());
  }

  /**
   * Returns the return code for this session. Note that return code is only set for sessions
   * that end with COMPLETED state. If a session is not started, still running or failed then
   * this method returns undefined.
   *
   * @return the return code for this session if the session is COMPLETED, undefined if session is
   * not started, still running or failed
   */
  async getReturnCode() {
    const returnCodeValue = await FFmpegKitReactNativeModule.abstractSessionGetReturnCode(this.getSessionId());
    if (returnCodeValue === undefined) {
      return undefined;
    } else {
      return new ReturnCode(returnCodeValue);
    }
  }

  /**
   * Returns the stack trace of the exception received while executing this session.
   * <p>
   * The stack trace is only set for sessions that end with FAILED state. For sessions that has
   * COMPLETED state this method returns undefined.
   *
   * @return stack trace of the exception received while executing this session, undefined if session
   * is not started, still running or completed
   */
  getFailStackTrace() {
    return FFmpegKitReactNativeModule.abstractSessionGetFailStackTrace(this.getSessionId());
  }

  /**
   * Returns session specific log redirection strategy.
   *
   * @return session specific log redirection strategy
   */
  getLogRedirectionStrategy() {
    return this.#logRedirectionStrategy;
  }

  /**
   * Returns whether there are still asynchronous messages being transmitted for this
   * session or not.
   *
   * @return true if there are still asynchronous messages being transmitted, false
   * otherwise
   */
  thereAreAsynchronousMessagesInTransmit() {
    return FFmpegKitReactNativeModule.abstractSessionThereAreAsynchronousMessagesInTransmit(this.getSessionId());
  }

  /**
   * Returns whether it is an <code>FFmpeg</code> session or not.
   *
   * @return true if it is an <code>FFmpeg</code> session, false otherwise
   */
  isFFmpeg() {
    return false;
  }

  /**
   * Returns whether it is an <code>FFprobe</code> session or not.
   *
   * @return true if it is an <code>FFprobe</code> session, false otherwise
   */
  isFFprobe() {
    return false;
  }

  /**
   * Returns whether it is a <code>MediaInformation</code> session or not.
   *
   * @return true if it is a <code>MediaInformation</code> session, false otherwise
   */
  isMediaInformation() {
    return false;
  }

  /**
   * Cancels running the session. Only starts cancellation. Does not guarantee that session is cancelled when promise resolves.
   */
  async cancel() {
    const sessionId = this.getSessionId();
    if (sessionId === undefined) {
      return Promise.reject(new Error('sessionId is not defined'));
    } else {
      return FFmpegKitReactNativeModule.cancelSession(sessionId);
    }
  }

}

/**
 * Detects the running architecture.
 */
export class ArchDetect {

  /**
   * Returns architecture name loaded.
   *
   * @return architecture name loaded
   */
  static async getArch() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getArch();
  }

}

/**
 * <p>Main class to run <code>FFmpeg</code> commands.
 */
export class FFmpegKit {

  /**
   * <p>Synchronously executes FFmpeg command provided. Space character is used to split the command
   * into arguments. You can use single or double quote characters to specify arguments inside your command.
   *
   * @param command            FFmpeg command
   * @return FFmpeg session created for this execution
   */
  static async execute(command) {
    return FFmpegKit.executeWithArguments(FFmpegKitConfig.parseArguments(command));
  }

  /**
   * <p>Synchronously executes FFmpeg with arguments provided.
   *
   * @param commandArguments   FFmpeg command options/arguments as string array
   * @return FFmpeg session created for this execution
   */
  static async executeWithArguments(commandArguments) {
    let session = await FFmpegSession.create(commandArguments, undefined, undefined, undefined);

    await FFmpegKitConfig.ffmpegExecute(session);

    return session;
  }

  /**
   * <p>Starts an asynchronous FFmpeg execution for the given command. Space character is used to split the command
   * into arguments. You can use single or double quote characters to specify arguments inside your command.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * FFmpegSessionCompleteCallback if you want to be notified about the result.
   *
   * @param command            FFmpeg command
   * @param completeCallback   callback that will be called when the execution has completed
   * @param logCallback        callback that will receive logs
   * @param statisticsCallback callback that will receive statistics
   * @return FFmpeg session created for this execution
   */
  static async executeAsync(command, completeCallback, logCallback, statisticsCallback) {
    return FFmpegKit.executeWithArgumentsAsync(FFmpegKitConfig.parseArguments(command), completeCallback, logCallback, statisticsCallback);
  }

  /**
   * <p>Starts an asynchronous FFmpeg execution with arguments provided.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * FFmpegSessionCompleteCallback if you want to be notified about the result.
   *
   * @param commandArguments   FFmpeg command options/arguments as string array
   * @param completeCallback   callback that will be called when the execution has completed
   * @param logCallback        callback that will receive logs
   * @param statisticsCallback callback that will receive statistics
   * @return FFmpeg session created for this execution
   */
  static async executeWithArgumentsAsync(commandArguments, completeCallback, logCallback, statisticsCallback) {
    let session = await FFmpegSession.create(commandArguments, completeCallback, logCallback, statisticsCallback);

    await FFmpegKitConfig.asyncFFmpegExecute(session);

    return session;
  }

  /**
   * <p>Cancels the session specified with <code>sessionId</code>.
   *
   * <p>This method does not wait for termination to complete and returns immediately.
   *
   * @param sessionId id of the session that will be cancelled
   */
  static async cancel(sessionId) {
    await FFmpegKitConfig.init();

    if (sessionId === undefined) {
      return FFmpegKitReactNativeModule.cancel();
    } else {
      return FFmpegKitReactNativeModule.cancelSession(sessionId);
    }
  }

  /**
   * <p>Lists all FFmpeg sessions in the session history.
   *
   * @return all FFmpeg sessions in the session history
   */
  static async listSessions() {
    await FFmpegKitConfig.init();

    const sessionArray = await FFmpegKitReactNativeModule.getFFmpegSessions();
    return sessionArray.map(FFmpegKitFactory.mapToSession);
  }

}

/**
 * <p>Configuration class of <code>FFmpegKit</code> library.
 */
export class FFmpegKitConfig {

  static #globalLogRedirectionStrategy = LogRedirectionStrategy.PRINT_LOGS_WHEN_NO_CALLBACKS_DEFINED;

  /**
   * Initializes the library asynchronously.
   */
  static async init() {
    await FFmpegKitInitializer.initialize();
  }

  /**
   * Uninitializes the library.
   *
   * Calling this method before application termination is recommended but not required.
   */
  static async uninit() {
    return FFmpegKitReactNativeModule.uninit();
  }

  /**
   * <p>Enables log and statistics redirection.
   *
   * <p>When redirection is enabled FFmpeg/FFprobe logs are redirected to console and sessions
   * collect log and statistics entries for the executions. It is possible to define global or
   * session specific log/statistics callbacks as well.
   *
   * <p>Note that redirection is enabled by default. If you do not want to use its functionality
   * please use {@link #disableRedirection()} to disable it.
   */
  static async enableRedirection() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.enableRedirection();
  }

  /**
   * <p>Disables log and statistics redirection.
   *
   * <p>When redirection is disabled logs are printed to stderr, all logs and statistics
   * callbacks are disabled and <code>FFprobe</code>'s <code>getMediaInformation</code> methods
   * do not work.
   */
  static async disableRedirection() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.disableRedirection();
  }

  /**
   * <p>Sets and overrides <code>fontconfig</code> configuration directory.
   *
   * @param path directory that contains fontconfig configuration (fonts.conf)
   * @return zero on success, non-zero on error
   */
  static async setFontconfigConfigurationPath(path) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.setFontconfigConfigurationPath(path);
  }

  /**
   * <p>Registers the fonts inside the given path, so they become available to use in FFmpeg
   * filters.
   *
   * <p>Note that you need to use a package with <code>fontconfig</code> inside to be
   * able to use fonts in <code>FFmpeg</code>.
   *
   * @param fontDirectoryPath directory that contains fonts (.ttf and .otf files)
   * @param fontNameMapping   custom font name mappings, useful to access your fonts with more
   *                          friendly names
   */
  static async setFontDirectory(fontDirectoryPath, fontNameMapping) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.setFontDirectory(fontDirectoryPath, fontNameMapping);
  }

  /**
   * <p>Registers the fonts inside the given list of font directories, so they become available
   * to use in FFmpeg filters.
   *
   * <p>Note that you need to use a package with <code>fontconfig</code> inside to be
   * able to use fonts in <code>FFmpeg</code>.
   *
   * @param fontDirectoryList list of directories that contain fonts (.ttf and .otf files)
   * @param fontNameMapping   custom font name mappings, useful to access your fonts with more
   *                          friendly names
   */
  static async setFontDirectoryList(fontDirectoryList, fontNameMapping) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.setFontDirectoryList(fontDirectoryList, fontNameMapping);
  }

  /**
   * <p>Creates a new named pipe to use in <code>FFmpeg</code> operations.
   *
   * <p>Please note that creator is responsible of closing created pipes.
   *
   * @return the full path of the named pipe
   */
  static async registerNewFFmpegPipe() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.registerNewFFmpegPipe();
  }

  /**
   * <p>Closes a previously created <code>FFmpeg</code> pipe.
   *
   * @param ffmpegPipePath full path of the FFmpeg pipe
   */
  static async closeFFmpegPipe(ffmpegPipePath) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.closeFFmpegPipe(ffmpegPipePath);
  }

  /**
   * <p>Returns the version of FFmpeg bundled within <code>FFmpegKit</code> library.
   *
   * @return the version of FFmpeg
   */
  static async getFFmpegVersion() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getFFmpegVersion();
  }

  /**
   * <p>Returns FFmpegKit ReactNative library version.
   *
   * @return FFmpegKit version
   */
  static async getVersion() {
    return new Promise((resolve) => resolve(FFmpegKitFactory.getVersion()));
  }

  /**
   * <p>Returns whether FFmpegKit release is a Long Term Release or not.
   *
   * @return true/yes or false/no
   */
  static async isLTSBuild() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.isLTSBuild();
  }

  /**
   * <p>Returns FFmpegKit native library build date.
   *
   * @return FFmpegKit native library build date
   */
  static async getBuildDate() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getBuildDate();
  }

  /**
   * <p>Sets an environment variable.
   *
   * @param variableName  environment variable name
   * @param variableValue environment variable value
   * @return zero on success, non-zero on error
   */
  static async setEnvironmentVariable(variableName, variableValue) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.setEnvironmentVariable(variableName, variableValue);
  }

  /**
   * <p>Registers a new ignored signal. Ignored signals are not handled by <code>FFmpegKit</code>
   * library.
   *
   * @param signal signal to be ignored
   */
  static async ignoreSignal(signal) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.ignoreSignal(signal);
  }

  /**
   * <p>Synchronously executes the FFmpeg session provided.
   *
   * @param ffmpegSession FFmpeg session which includes command options/arguments
   */
  static async ffmpegExecute(ffmpegSession) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.ffmpegSessionExecute(ffmpegSession.getSessionId());
  }

  /**
   * <p>Synchronously executes the FFprobe session provided.
   *
   * @param ffprobeSession FFprobe session which includes command options/arguments
   */
  static async ffprobeExecute(ffprobeSession) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.ffprobeSessionExecute(ffprobeSession.getSessionId());
  }

  /**
   * <p>Synchronously executes the media information session provided.
   *
   * @param mediaInformationSession media information session which includes command options/arguments
   * @param waitTimeout             max time to wait until media information is transmitted
   */
  static async getMediaInformationExecute(mediaInformationSession, waitTimeout) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.mediaInformationSessionExecute(mediaInformationSession.getSessionId(), FFmpegKitFactory.optionalNumericParameter(waitTimeout));
  }

  /**
   * <p>Starts an asynchronous FFmpeg execution for the given session.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * FFmpegSessionCompleteCallback if you want to be notified about the result.
   *
   * @param ffmpegSession FFmpeg session which includes command options/arguments
   */
  static async asyncFFmpegExecute(ffmpegSession) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.asyncFFmpegSessionExecute(ffmpegSession.getSessionId());
  }

  /**
   * <p>Starts an asynchronous FFprobe execution for the given session.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * FFprobeSessionCompleteCallback if you want to be notified about the result.
   *
   * @param ffprobeSession FFprobe session which includes command options/arguments
   */
  static async asyncFFprobeExecute(ffprobeSession) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.asyncFFprobeSessionExecute(ffprobeSession.getSessionId());
  }

  /**
   * <p>Starts an asynchronous FFprobe execution for the given media information session.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * MediaInformationSessionCompleteCallback if you want to be notified about the result.
   *
   * @param mediaInformationSession media information session which includes command options/arguments
   * @param waitTimeout             max time to wait until media information is transmitted
   */
  static async asyncGetMediaInformationExecute(mediaInformationSession, waitTimeout) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.asyncMediaInformationSessionExecute(mediaInformationSession.getSessionId(), FFmpegKitFactory.optionalNumericParameter(waitTimeout));
  }

  /**
   * <p>Sets a global callback to redirect FFmpeg/FFprobe logs.
   *
   * @param logCallback log callback or undefined to disable a previously defined
   *                    callback
   */
  static enableLogCallback(logCallback) {
    FFmpegKitFactory.setGlobalLogCallback(logCallback);
  }

  /**
   * <p>Sets a global callback to redirect FFmpeg statistics.
   *
   * @param statisticsCallback statistics callback or undefined to disable a previously
   *                           defined callback
   */
  static enableStatisticsCallback(statisticsCallback) {
    FFmpegKitFactory.setGlobalStatisticsCallback(statisticsCallback);
  }

  /**
   * <p>Sets a global FFmpegSessionCompleteCallback to receive execution results for FFmpeg sessions.
   *
   * @param ffmpegSessionCompleteCallback complete callback or undefined to disable a previously defined callback
   */
  static enableFFmpegSessionCompleteCallback(ffmpegSessionCompleteCallback) {
    FFmpegKitFactory.setGlobalFFmpegSessionCompleteCallback(ffmpegSessionCompleteCallback);
  }

  /**
   * <p>Returns the global FFmpegSessionCompleteCallback set.
   *
   * @return global FFmpegSessionCompleteCallback or undefined if it is not set
   */
  static getFFmpegSessionCompleteCallback() {
    return FFmpegKitFactory.getGlobalFFmpegSessionCompleteCallback();
  }

  /**
   * <p>Sets a global FFprobeSessionCompleteCallback to receive execution results for FFprobe sessions.
   *
   * @param ffprobeSessionCompleteCallback complete callback or undefined to disable a previously defined callback
   */
  static enableFFprobeSessionCompleteCallback(ffprobeSessionCompleteCallback) {
    FFmpegKitFactory.setGlobalFFprobeSessionCompleteCallback(ffprobeSessionCompleteCallback);
  }

  /**
   * <p>Returns the global FFprobeSessionCompleteCallback set.
   *
   * @return global FFprobeSessionCompleteCallback or undefined if it is not set
   */
  static getFFprobeSessionCompleteCallback() {
    return FFmpegKitFactory.getGlobalFFprobeSessionCompleteCallback();
  }

  /**
   * <p>Sets a global MediaInformationSessionCompleteCallback to receive execution results for MediaInformation sessions.
   *
   * @param mediaInformationSessionCompleteCallback complete callback or undefined to disable a previously defined
   * callback
   */
  static enableMediaInformationSessionCompleteCallback(mediaInformationSessionCompleteCallback) {
    FFmpegKitFactory.setGlobalMediaInformationSessionCompleteCallback(mediaInformationSessionCompleteCallback);
  }

  /**
   * <p>Returns the global MediaInformationSessionCompleteCallback set.
   *
   * @return global MediaInformationSessionCompleteCallback or undefined if it is not set
   */
  static getMediaInformationSessionCompleteCallback() {
    return FFmpegKitFactory.getGlobalMediaInformationSessionCompleteCallback();
  }

  /**
   * Returns the current log level.
   *
   * @return current log level
   */
  static getLogLevel() {
    return FFmpegKitFactory.getLogLevel();
  }

  /**
   * Sets the log level.
   *
   * @param level new log level
   */
  static async setLogLevel(level) {
    await FFmpegKitConfig.init();

    FFmpegKitFactory.setLogLevel(level);
    return FFmpegKitReactNativeModule.setLogLevel(level);
  }

  /**
   * <p>Converts the given Structured Access Framework Uri into an input url that can be used in FFmpeg
   * and FFprobe commands.
   *
   * <p>Note that this method is Android only. It will fail if called on other platforms. It also requires
   * API Level &ge; 19. On older API levels it returns an empty url.
   *
   * @param uriString SAF uri (<code>"content:…"</code>)
   * @return input url that can be passed to FFmpegKit or FFprobeKit
   */
  static async getSafParameterForRead(uriString) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getSafParameter(uriString, "r");
  }

  /**
   * <p>Converts the given Structured Access Framework Uri into an output url that can be used in FFmpeg
   * and FFprobe commands.
   *
   * <p>Note that this method is Android only. It will fail if called on other platforms. It also requires
   * API Level &ge; 19. On older API levels it returns an empty url.
   *
   * @param uriString SAF uri (<code>"content:…"</code>)
   * @return output url that can be passed to FFmpegKit or FFprobeKit
   */
  static async getSafParameterForWrite(uriString) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getSafParameter(uriString, "w");
  }

  /**
   * <p>Converts the given Structured Access Framework Uri into an saf protocol url opened with the given open mode.
   *
   * <p>Note that this method is Android only. It will fail if called on other platforms. It also requires
   * API Level &ge; 19. On older API levels it returns an empty url.
   *
   * @param uriString SAF uri (<code>"content:…"</code>)
   * @param openMode file mode to use as defined in Android Structured Access Framework documentation
   * @return saf protocol url that can be passed to FFmpegKit or FFprobeKit
   */
  static async getSafParameter(uriString, openMode) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getSafParameter(uriString, openMode);
  }

  /**
   * Returns the session history size.
   *
   * @return session history size
   */
  static async getSessionHistorySize() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getSessionHistorySize();
  }

  /**
   * Sets the session history size.
   *
   * @param sessionHistorySize session history size, should be smaller than 1000
   */
  static async setSessionHistorySize(sessionHistorySize) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.setSessionHistorySize(sessionHistorySize);
  }

  /**
   * Returns the session specified with <code>sessionId</code> from the session history.
   *
   * @param sessionId session identifier
   * @return session specified with sessionId or undefined if it is not found in the history
   */
  static async getSession(sessionId) {
    await FFmpegKitConfig.init();

    if (sessionId === undefined) {
      return undefined;
    } else {
      const sessionMap = await FFmpegKitReactNativeModule.getSession(sessionId);
      return FFmpegKitFactory.mapToSession(sessionMap);
    }
  }

  /**
   * Returns the last session created from the session history.
   *
   * @return the last session created or undefined if session history is empty
   */
  static async getLastSession() {
    await FFmpegKitConfig.init();

    const sessionMap = await FFmpegKitReactNativeModule.getLastSession();
    return FFmpegKitFactory.mapToSession(sessionMap);
  }

  /**
   * Returns the last session completed from the session history.
   *
   * @return the last session completed. If there are no completed sessions in the history this
   * method will return undefined
   */
  static async getLastCompletedSession() {
    await FFmpegKitConfig.init();

    const sessionMap = await FFmpegKitReactNativeModule.getLastCompletedSession();
    return FFmpegKitFactory.mapToSession(sessionMap);
  }

  /**
   * <p>Returns all sessions in the session history.
   *
   * @return all sessions in the session history
   */
  static async getSessions() {
    await FFmpegKitConfig.init();

    const sessionArray = await FFmpegKitReactNativeModule.getSessions();
    return sessionArray.map(FFmpegKitFactory.mapToSession);
  }

  /**
   * <p>Clears all, including ongoing, sessions in the session history.
   * <p>Note that callbacks cannot be triggered for deleted sessions.
   */
  static async clearSessions() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.clearSessions();
  }

  /**
   * <p>Returns all FFmpeg sessions in the session history.
   *
   * @return all FFmpeg sessions in the session history
   */
  static async getFFmpegSessions() {
    await FFmpegKitConfig.init();

    const sessionArray = await FFmpegKitReactNativeModule.getFFmpegSessions();
    return sessionArray.map(FFmpegKitFactory.mapToSession);
  }

  /**
   * <p>Returns all FFprobe sessions in the session history.
   *
   * @return all FFprobe sessions in the session history
   */
  static async getFFprobeSessions() {
    await FFmpegKitConfig.init();

    const sessionArray = await FFmpegKitReactNativeModule.getFFprobeSessions();
    return sessionArray.map(FFmpegKitFactory.mapToSession);
  }

  /**
   * <p>Returns all MediaInformation sessions in the session history.
   *
   * @return all MediaInformation sessions in the session history
   */
  static async getMediaInformationSessions() {
    await FFmpegKitConfig.init();

    const sessionArray = await FFmpegKitReactNativeModule.getMediaInformationSessions();
    return sessionArray.map(FFmpegKitFactory.mapToSession);
  }

  /**
   * <p>Returns sessions that have the given state.
   *
   * @param state session state
   * @return sessions that have the given state from the session history
   */
  static async getSessionsByState(state) {
    await FFmpegKitConfig.init();

    const sessionArray = await FFmpegKitReactNativeModule.getSessionsByState(state);
    return sessionArray.map(FFmpegKitFactory.mapToSession);
  }

  /**
   * Returns the active log redirection strategy.
   *
   * @return log redirection strategy
   */
  static getLogRedirectionStrategy() {
    return this.#globalLogRedirectionStrategy;
  }

  /**
   * <p>Sets the log redirection strategy.
   *
   * @param logRedirectionStrategy log redirection strategy
   */
  static setLogRedirectionStrategy(logRedirectionStrategy) {
    this.#globalLogRedirectionStrategy = logRedirectionStrategy;
  }

  /**
   * <p>Returns the number of messages that are not transmitted to the ReactNative callbacks yet for
   * this session.
   *
   * @param sessionId id of the session
   * @return number of messages that are not transmitted to the ReactNative callbacks yet for
   * this session
   */
  static async messagesInTransmit(sessionId) {
    await FFmpegKitConfig.init();

    const sessionMap = await FFmpegKitReactNativeModule.messagesInTransmit(sessionId);
    return FFmpegKitFactory.mapToSession(sessionMap);
  }

  /**
   * Returns the string representation of the SessionState provided.
   *
   * @param state session state instance
   * @returns string representation of the SessionState provided
   */
  static sessionStateToString(state) {
    switch (state) {
      case SessionState.CREATED:
        return "CREATED";
      case SessionState.RUNNING:
        return "RUNNING";
      case SessionState.FAILED:
        return "FAILED";
      case SessionState.COMPLETED:
        return "COMPLETED";
      default:
        return "";
    }
  }

  /**
   * <p>Parses the given command into arguments. Uses space character to split the arguments.
   * Supports single and double quote characters.
   *
   * @param command string command
   * @return array of arguments
   */
  static parseArguments(command) {
    let argumentList = [];
    let currentArgument = "";

    let singleQuoteStarted = 0;
    let doubleQuoteStarted = 0;

    for (let i = 0; i < command.length; i++) {
      let previousChar;
      if (i > 0) {
        previousChar = command.charAt(i - 1);
      } else {
        previousChar = null;
      }
      let currentChar = command.charAt(i);

      if (currentChar === ' ') {
        if (singleQuoteStarted === 1 || doubleQuoteStarted === 1) {
          currentArgument += currentChar;
        } else if (currentArgument.length > 0) {
          argumentList.push(currentArgument);
          currentArgument = "";
        }
      } else if (currentChar === '\'' && (previousChar == null || previousChar !== '\\')) {
        if (singleQuoteStarted === 1) {
          singleQuoteStarted = 0;
        } else if (doubleQuoteStarted === 1) {
          currentArgument += currentChar;
        } else {
          singleQuoteStarted = 1;
        }
      } else if (currentChar === '\"' && (previousChar == null || previousChar !== '\\')) {
        if (doubleQuoteStarted === 1) {
          doubleQuoteStarted = 0;
        } else if (singleQuoteStarted === 1) {
          currentArgument += currentChar;
        } else {
          doubleQuoteStarted = 1;
        }
      } else {
        currentArgument += currentChar;
      }
    }

    if (currentArgument.length > 0) {
      argumentList.push(currentArgument);
    }

    return argumentList;
  }

  /**
   * <p>Concatenates arguments into a string adding a space character between two arguments.
   *
   * @param commandArguments arguments
   * @return concatenated string containing all arguments
   */
  static argumentsToString(commandArguments) {
    if (commandArguments === undefined) {
      return 'undefined';
    }

    let command = '';

    function appendArgument(value, index) {
      if (index > 0) {
        command += ' ';
      }
      command += value;
    }

    commandArguments.forEach(appendArgument);
    return command;
  }

  // THE FOLLOWING TWO METHODS ARE REACT-NATIVE SPECIFIC

  /**
   * Enables logs.
   */
  static async enableLogs() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.enableLogs();
  }

  /**
   * Disable logs.
   */
  static async disableLogs() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.disableLogs();
  }

  /**
   * Enables statistics.
   */
  static async enableStatistics() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.enableStatistics();
  }

  /**
   * Disables statistics.
   */
  static async disableStatistics() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.disableStatistics();
  }

  /**
   * Returns the platform name the library is loaded on.
   */
  static async getPlatform() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getPlatform();
  }

  /**
   * Writes the given file to a pipe.
   *
   * @param inputPath input file path
   * @param pipePath pipe path
   * @returns zero on success, non-zero on error
   */
  static async writeToPipe(inputPath, pipePath) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.writeToPipe(inputPath, pipePath);
  }

  /**
   * <p>Displays the native file dialog to select a file in read mode. If a file is selected then this
   * method returns the Structured Access Framework Uri for that file.
   *
   * <p>Note that this method is Android only. It will fail if called on other platforms.
   *
   * @param type specifies a mime type for the file dialog
   * @param extraTypes additional mime types
   * @returns Structured Access Framework Uri (<code>"content:…"</code>) of the file selected or undefined
   * if no files are selected
   */
  static async selectDocumentForRead(type, extraTypes) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.selectDocument(false, undefined, type, extraTypes);
  }

  /**
   * <p>Displays the native file dialog to select a file in write mode. If a file is selected then this
   * method returns the Structured Access Framework Uri for that file.
   *
   * <p>Note that this method is Android only. It will fail if called on other platforms.
   *
   * @param title file name
   * @param type specifies a mime type for the file dialog
   * @param extraTypes additional mime types
   * @returns Structured Access Framework Uri (<code>"content:…"</code>) of the file selected or undefined
   * if no files are selected
   */
  static async selectDocumentForWrite(title, type, extraTypes) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.selectDocument(true, title, type, extraTypes);
  }

}

class FFmpegKitFactory {

  static #ffmpegSessionCompleteCallback = undefined;
  static #ffprobeSessionCompleteCallback = undefined;
  static #mediaInformationSessionCompleteCallback = undefined;
  static #logCallback = undefined;
  static #statisticsCallback = undefined;
  static #activeLogLevel = undefined;

  static mapToStatistics(statisticsMap) {
    if (statisticsMap !== undefined) {
      return new Statistics(statisticsMap.sessionId, statisticsMap.videoFrameNumber, statisticsMap.videoFps, statisticsMap.videoQuality, statisticsMap.size, statisticsMap.time, statisticsMap.bitrate, statisticsMap.speed);
    } else {
      return undefined;
    }
  }

  static mapToLog(logMap) {
    if (logMap !== undefined) {
      return new Log(logMap.sessionId, logMap.level, logMap.message)
    } else {
      return undefined;
    }
  }

  static mapToSession(sessionMap) {
    if (sessionMap !== undefined) {
      switch (sessionMap.type) {
        case 2:
          return AbstractSession.createFFprobeSessionFromMap(sessionMap);
        case 3:
          return AbstractSession.createMediaInformationSessionFromMap(sessionMap);
        case 1:
        default:
          return AbstractSession.createFFmpegSessionFromMap(sessionMap);
      }
    } else {
      return undefined;
    }
  }

  static getVersion() {
    return "6.0.2";
  }

  static getLogRedirectionStrategy(sessionId) {
    return logRedirectionStrategyMap.get(sessionId);
  }

  static setLogRedirectionStrategy(sessionId, logRedirectionStrategy) {
    logRedirectionStrategyMap.set(sessionId, logRedirectionStrategy);
  }

  static getLogCallback(sessionId) {
    return logCallbackMap.get(sessionId);
  }

  static setLogCallback(sessionId, logCallback) {
    if (logCallback !== undefined) {
      logCallbackMap.set(sessionId, logCallback);
    }
  }

  static getGlobalLogCallback() {
    return this.#logCallback;
  }

  static setGlobalLogCallback(logCallback) {
    this.#logCallback = logCallback;
  }

  static getStatisticsCallback(sessionId) {
    return statisticsCallbackMap.get(sessionId);
  }

  static setStatisticsCallback(sessionId, statisticsCallback) {
    if (statisticsCallback !== undefined) {
      statisticsCallbackMap.set(sessionId, statisticsCallback);
    }
  }

  static getGlobalStatisticsCallback() {
    return this.#statisticsCallback;
  }

  static setGlobalStatisticsCallback(statisticsCallback) {
    this.#statisticsCallback = statisticsCallback;
  }

  static getFFmpegSessionCompleteCallback(sessionId) {
    return ffmpegSessionCompleteCallbackMap.get(sessionId);
  }

  static setFFmpegSessionCompleteCallback(sessionId, completeCallback) {
    if (completeCallback !== undefined) {
      ffmpegSessionCompleteCallbackMap.set(sessionId, completeCallback);
    }
  }

  static getGlobalFFmpegSessionCompleteCallback() {
    return this.#ffmpegSessionCompleteCallback;
  }

  static setGlobalFFmpegSessionCompleteCallback(completeCallback) {
    this.#ffmpegSessionCompleteCallback = completeCallback;
  }

  static getFFprobeSessionCompleteCallback(sessionId) {
    return ffprobeSessionCompleteCallbackMap.get(sessionId);
  }

  static setFFprobeSessionCompleteCallback(sessionId, completeCallback) {
    if (completeCallback !== undefined) {
      ffprobeSessionCompleteCallbackMap.set(sessionId, completeCallback);
    }
  }

  static getGlobalFFprobeSessionCompleteCallback() {
    return this.#ffprobeSessionCompleteCallback;
  }

  static setGlobalFFprobeSessionCompleteCallback(completeCallback) {
    this.#ffprobeSessionCompleteCallback = completeCallback;
  }

  static getMediaInformationSessionCompleteCallback(sessionId) {
    return mediaInformationSessionCompleteCallbackMap.get(sessionId);
  }

  static setMediaInformationSessionCompleteCallback(sessionId, completeCallback) {
    if (completeCallback !== undefined) {
      mediaInformationSessionCompleteCallbackMap.set(sessionId, completeCallback);
    }
  }

  static getGlobalMediaInformationSessionCompleteCallback() {
    return this.#mediaInformationSessionCompleteCallback;
  }

  static setGlobalMediaInformationSessionCompleteCallback(completeCallback) {
    this.#mediaInformationSessionCompleteCallback = completeCallback;
  }

  static setLogLevel(logLevel) {
    this.#activeLogLevel = logLevel;
  }

  static getLogLevel() {
    return this.#activeLogLevel;
  }

  static optionalNumericParameter(value) {
    return value ?? -1;
  }

  static validDate(time) {
    if (time === undefined || time === null || time <= 0) {
      return undefined;
    } else {
      return new Date(time);
    }
  }

}

class FFmpegKitInitializer {
  static #initialized = false;
  static #eventEmitter = new FFmpegKitReactNativeEventEmitter();

  static processLogCallbackEvent(event) {
    const log = FFmpegKitFactory.mapToLog(event)
    const sessionId = event.sessionId;
    const level = event.level;
    const text = event.message;
    const activeLogLevel = FFmpegKitConfig.getLogLevel();
    let globalCallbackDefined = false;
    let sessionCallbackDefined = false;
    let activeLogRedirectionStrategy = FFmpegKitConfig.getLogRedirectionStrategy();

    // AV_LOG_STDERR logs are always redirected
    if ((activeLogLevel === Level.AV_LOG_QUIET && level !== Level.AV_LOG_STDERR) || level > activeLogLevel) {
      // LOG NEITHER PRINTED NOR FORWARDED
      return;
    }

    if (FFmpegKitFactory.getLogRedirectionStrategy(sessionId) !== undefined) {
      activeLogRedirectionStrategy = FFmpegKitFactory.getLogRedirectionStrategy(sessionId);
    }
    let activeLogCallback = FFmpegKitFactory.getLogCallback(sessionId);
    if (activeLogCallback !== undefined) {
      sessionCallbackDefined = true;

      try {
        // NOTIFY SESSION CALLBACK DEFINED
        activeLogCallback(log);
      } catch (err) {
        console.log("Exception thrown inside session log callback.", err.stack);
      }
    }

    let globalLogCallbackFunction = FFmpegKitFactory.getGlobalLogCallback();
    if (globalLogCallbackFunction !== undefined) {
      globalCallbackDefined = true;

      try {
        // NOTIFY GLOBAL CALLBACK DEFINED
        globalLogCallbackFunction(log);
      } catch (err) {
        console.log("Exception thrown inside global log callback.", err.stack);
      }
    }

    // EXECUTE THE LOG STRATEGY
    switch (activeLogRedirectionStrategy) {
      case LogRedirectionStrategy.NEVER_PRINT_LOGS: {
        return;
      }
      case LogRedirectionStrategy.PRINT_LOGS_WHEN_GLOBAL_CALLBACK_NOT_DEFINED: {
        if (globalCallbackDefined) {
          return;
        }
      }
        break;
      case LogRedirectionStrategy.PRINT_LOGS_WHEN_SESSION_CALLBACK_NOT_DEFINED: {
        if (sessionCallbackDefined) {
          return;
        }
      }
        break;
      case LogRedirectionStrategy.PRINT_LOGS_WHEN_NO_CALLBACKS_DEFINED: {
        if (globalCallbackDefined || sessionCallbackDefined) {
          return;
        }
      }
        break;
      case LogRedirectionStrategy.ALWAYS_PRINT_LOGS: {
      }
        break;
    }

    // PRINT LOGS
    switch (level) {
      case Level.AV_LOG_QUIET: {
        // PRINT NO OUTPUT
      }
        break;
      default: {
        console.log(text);
      }
    }
  }

  static processStatisticsCallbackEvent(event) {
    let statistics = FFmpegKitFactory.mapToStatistics(event);
    let sessionId = event.sessionId;

    let activeStatisticsCallback = FFmpegKitFactory.getStatisticsCallback(sessionId);
    if (activeStatisticsCallback !== undefined) {
      try {
        // NOTIFY SESSION CALLBACK DEFINED
        activeStatisticsCallback(statistics);
      } catch (err) {
        console.log("Exception thrown inside session statistics callback.", err.stack);
      }
    }

    let globalStatisticsCallbackFunction = FFmpegKitFactory.getGlobalStatisticsCallback();
    if (globalStatisticsCallbackFunction !== undefined) {
      try {
        // NOTIFY GLOBAL CALLBACK DEFINED
        globalStatisticsCallbackFunction(statistics);
      } catch (err) {
        console.log("Exception thrown inside global statistics callback.", err.stack);
      }
    }
  }

  static processCompleteCallbackEvent(event) {
    if (event !== undefined) {
      let sessionId = event.sessionId;

      FFmpegKitConfig.getSession(sessionId).then(session => {
        if (session !== undefined) {
          if (session.getCompleteCallback() !== undefined) {
            try {
              // NOTIFY SESSION CALLBACK DEFINED
              session.getCompleteCallback()(session);
            } catch (err) {
              console.log("Exception thrown inside session complete callback.", err.stack);
            }
          }

          if (session.isFFmpeg()) {
            let globalFFmpegSessionCompleteCallback = FFmpegKitFactory.getGlobalFFmpegSessionCompleteCallback();
            if (globalFFmpegSessionCompleteCallback !== undefined) {
              try {
                // NOTIFY GLOBAL CALLBACK DEFINED
                globalFFmpegSessionCompleteCallback(session);
              } catch (err) {
                console.log("Exception thrown inside global complete callback.", err.stack);
              }
            }
          } else if (session.isFFprobe()) {
            let globalFFprobeSessionCompleteCallback = FFmpegKitFactory.getGlobalFFprobeSessionCompleteCallback();
            if (globalFFprobeSessionCompleteCallback !== undefined) {
              try {
                // NOTIFY GLOBAL CALLBACK DEFINED
                globalFFprobeSessionCompleteCallback(session);
              } catch (err) {
                console.log("Exception thrown inside global complete callback.", err.stack);
              }
            }
          } else if (session.isMediaInformation()) {
            let globalMediaInformationSessionCompleteCallback = FFmpegKitFactory.getGlobalMediaInformationSessionCompleteCallback();
            if (globalMediaInformationSessionCompleteCallback !== undefined) {
              try {
                // NOTIFY GLOBAL CALLBACK DEFINED
                globalMediaInformationSessionCompleteCallback(session);
              } catch (err) {
                console.log("Exception thrown inside global complete callback.", err.stack);
              }
            }
          }
        }
      });
    }
  }

  static async initialize() {
    if (this.#initialized) {
      return;
    } else {
      this.#initialized = true;
    }

    console.log("Loading ffmpeg-kit-react-native.");

    this.#eventEmitter.addListener(eventLogCallbackEvent, FFmpegKitInitializer.processLogCallbackEvent);
    this.#eventEmitter.addListener(eventStatisticsCallbackEvent, FFmpegKitInitializer.processStatisticsCallbackEvent);
    this.#eventEmitter.addListener(eventCompleteCallbackEvent, FFmpegKitInitializer.processCompleteCallbackEvent);

    FFmpegKitFactory.setLogLevel(await FFmpegKitReactNativeModule.getLogLevel());
    const version = FFmpegKitFactory.getVersion();
    const platform = await FFmpegKitConfig.getPlatform();
    const arch = await ArchDetect.getArch();
    const packageName = await Packages.getPackageName();
    await FFmpegKitConfig.enableRedirection();
    const isLTSPostfix = (await FFmpegKitConfig.isLTSBuild()) ? "-lts" : "";

    console.log(`Loaded ffmpeg-kit-react-native-${platform}-${packageName}-${arch}-${version}${isLTSPostfix}.`);
  }

}

/**
 * <p>An FFmpeg session.
 */
export class FFmpegSession extends AbstractSession {

  /**
   * Creates a new FFmpeg session.
   *
   * @param argumentsArray FFmpeg command arguments
   * @param completeCallback callback that will be called when the execution has completed
   * @param logCallback callback that will receive logs
   * @param statisticsCallback callback that will receive statistics
   * @param logRedirectionStrategy defines how logs will be redirected
   * @returns FFmpeg session created
   */
  static async create(argumentsArray, completeCallback, logCallback, statisticsCallback, logRedirectionStrategy) {
    const session = await AbstractSession.createFFmpegSession(argumentsArray, logRedirectionStrategy);
    const sessionId = session.getSessionId();

    FFmpegKitFactory.setFFmpegSessionCompleteCallback(sessionId, completeCallback);
    FFmpegKitFactory.setLogCallback(sessionId, logCallback);
    FFmpegKitFactory.setStatisticsCallback(sessionId, statisticsCallback);

    return session;
  }

  /**
   * Returns the session specific statistics callback.
   *
   * @return session specific statistics callback
   */
  getStatisticsCallback() {
    return FFmpegKitFactory.getStatisticsCallback(this.getSessionId());
  }

  /**
   * Returns the session specific complete callback.
   *
   * @return session specific complete callback
   */
  getCompleteCallback() {
    return FFmpegKitFactory.getFFmpegSessionCompleteCallback(this.getSessionId());
  }

  /**
   * Returns all statistics entries generated for this session. If there are asynchronous
   * messages that are not delivered yet, this method waits for them until the given timeout.
   *
   * @param waitTimeout wait timeout for asynchronous messages in milliseconds
   * @return list of statistics entries generated for this session
   */
  async getAllStatistics(waitTimeout) {
    await FFmpegKitConfig.init();

    const allStatistics = await FFmpegKitReactNativeModule.ffmpegSessionGetAllStatistics(this.getSessionId(), FFmpegKitFactory.optionalNumericParameter(waitTimeout));
    return allStatistics.map(FFmpegKitFactory.mapToStatistics);
  }

  /**
   * Returns all statistics entries delivered for this session. Note that if there are
   * asynchronous messages that are not delivered yet, this method will not wait for
   * them and will return immediately.
   *
   * @return list of statistics entries received for this session
   */
  async getStatistics() {
    await FFmpegKitConfig.init();

    const statistics = await FFmpegKitReactNativeModule.ffmpegSessionGetStatistics(this.getSessionId());
    return statistics.map(FFmpegKitFactory.mapToStatistics);
  }

  /**
   * Returns the last received statistics entry.
   *
   * @return the last received statistics entry or undefined if there are not any statistics entries
   * received
   */
  async getLastReceivedStatistics() {
    let statistics = await this.getStatistics();

    if (statistics.length > 0) {
      return statistics[statistics.length - 1];
    } else {
      return undefined;
    }
  }

  isFFmpeg() {
    return true;
  }

  isFFprobe() {
    return false;
  }

  isMediaInformation() {
    return false;
  }

}

/**
 * <p>Main class to run <code>FFprobe</code> commands.
 */
export class FFprobeKit {

  /**
   * <p>Synchronously executes FFprobe command provided. Space character is used to split the command
   * into arguments. You can use single or double quote characters to specify arguments inside your command.
   *
   * @param command FFprobe command
   * @return FFprobe session created for this execution
   */
  static async execute(command) {
    return FFprobeKit.executeWithArguments(FFmpegKitConfig.parseArguments(command));
  }

  /**
   * <p>Synchronously executes FFprobe with arguments provided.
   *
   * @param commandArguments FFprobe command options/arguments as string array
   * @return FFprobe session created for this execution
   */
  static async executeWithArguments(commandArguments) {
    let session = await FFprobeSession.create(commandArguments, undefined, undefined);

    await FFmpegKitConfig.ffprobeExecute(session);

    return session;
  }

  /**
   * <p>Starts an asynchronous FFprobe execution for the given command. Space character is used to split the command
   * into arguments. You can use single or double quote characters to specify arguments inside your command.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * FFprobeSessionCompleteCallback if you want to be notified about the result.
   *
   * @param command FFprobe command
   * @param completeCallback callback that will be called when the execution has completed
   * @param logCallback callback that will receive logs
   * @return FFprobe session created for this execution
   */
  static async executeAsync(command, completeCallback, logCallback) {
    return FFprobeKit.executeWithArgumentsAsync(FFmpegKitConfig.parseArguments(command), completeCallback, logCallback);
  }

  /**
   * <p>Starts an asynchronous FFprobe execution with arguments provided.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * FFprobeSessionCompleteCallback if you want to be notified about the result.
   *
   * @param commandArguments FFprobe command options/arguments as string array
   * @param completeCallback callback that will be called when the execution has completed
   * @param logCallback callback that will receive logs
   * @return FFprobe session created for this execution
   */
  static async executeWithArgumentsAsync(commandArguments, completeCallback, logCallback) {
    let session = await FFprobeSession.create(commandArguments, completeCallback, logCallback);

    await FFmpegKitConfig.asyncFFprobeExecute(session);

    return session;
  }

  /**
   * <p>Extracts media information for the file specified with path.
   *
   * @param path            path or uri of a media file
   * @param waitTimeout     max time to wait until media information is transmitted
   * @return media information session created for this execution
   */
  static async getMediaInformation(path, waitTimeout) {
    const commandArguments = ["-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-show_chapters", "-i", path];
    return FFprobeKit.getMediaInformationFromCommandArguments(commandArguments, waitTimeout);
  }

  /**
   * <p>Extracts media information using the command provided. The command passed to
   * this method must generate the output in JSON format in order to successfully extract media information from it.
   *
   * @param command         FFprobe command that prints media information for a file in JSON format
   * @param waitTimeout     max time to wait until media information is transmitted
   * @return media information session created for this execution
   */
  static async getMediaInformationFromCommand(command, waitTimeout) {
    return FFprobeKit.getMediaInformationFromCommandArguments(FFmpegKitConfig.parseArguments(command), waitTimeout);
  }

  /**
   * <p>Extracts media information using the command arguments provided. The command
   * passed to this method must generate the output in JSON format in order to successfully extract media information
   * from it.
   *
   * @param commandArguments FFprobe command arguments that prints media information for a file in JSON format
   * @param waitTimeout     max time to wait until media information is transmitted
   * @return media information session created for this execution
   */
  static async getMediaInformationFromCommandArguments(commandArguments, waitTimeout) {
    let session = await MediaInformationSession.create(commandArguments, undefined, undefined);

    await FFmpegKitConfig.getMediaInformationExecute(session, waitTimeout);

    const mediaInformation = await FFmpegKitReactNativeModule.getMediaInformation(session.getSessionId());
    if (mediaInformation !== undefined && mediaInformation !== null) {
      session.setMediaInformation(new MediaInformation(mediaInformation));
    }

    return session;
  }

  /**
   * <p>Starts an asynchronous FFprobe execution to extract the media information for the specified file.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * MediaInformationSessionCompleteCallback if you want to be notified about the result.
   *
   * @param path            path or uri of a media file
   * @param completeCallback callback that will be notified when execution has completed
   * @param logCallback     callback that will receive logs
   * @param waitTimeout     max time to wait until media information is transmitted
   * @return media information session created for this execution
   */
  static async getMediaInformationAsync(path, completeCallback, logCallback, waitTimeout) {
    const commandArguments = ["-v", "error", "-hide_banner", "-print_format", "json", "-show_format", "-show_streams", "-show_chapters", "-i", path];
    return FFprobeKit.getMediaInformationFromCommandArgumentsAsync(commandArguments, completeCallback, logCallback, waitTimeout);
  }

  /**
   * <p>Starts an asynchronous FFprobe execution to extract media information using a command. The command passed to
   * this method must generate the output in JSON format in order to successfully extract media information from it.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * MediaInformationSessionCompleteCallback if you want to be notified about the result.
   *
   * @param command         FFprobe command that prints media information for a file in JSON format
   * @param completeCallback callback that will be notified when execution has completed
   * @param logCallback     callback that will receive logs
   * @param waitTimeout     max time to wait until media information is transmitted
   * @return media information session created for this execution
   */
  static async getMediaInformationFromCommandAsync(command, completeCallback, logCallback, waitTimeout) {
    return FFprobeKit.getMediaInformationFromCommandArgumentsAsync(FFmpegKitConfig.parseArguments(command), completeCallback, logCallback, waitTimeout);
  }

  /**
   * <p>Starts an asynchronous FFprobe execution to extract media information using command arguments. The command
   * passed to this method must generate the output in JSON format in order to successfully extract media information
   * from it.
   *
   * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
   * MediaInformationSessionCompleteCallback if you want to be notified about the result.
   *
   * @param commandArguments FFprobe command arguments that prints media information for a file in JSON format
   * @param completeCallback callback that will be notified when execution has completed
   * @param logCallback     callback that will receive logs
   * @param waitTimeout     max time to wait until media information is transmitted
   * @return media information session created for this execution
   */
  static async getMediaInformationFromCommandArgumentsAsync(commandArguments, completeCallback, logCallback, waitTimeout) {
    let session = await MediaInformationSession.create(commandArguments, completeCallback, logCallback);

    await FFmpegKitConfig.asyncGetMediaInformationExecute(session, waitTimeout);

    const mediaInformation = await FFmpegKitReactNativeModule.getMediaInformation(session.getSessionId());
    if (mediaInformation !== undefined && mediaInformation !== null) {
      session.setMediaInformation(new MediaInformation(mediaInformation));
    }

    return session;
  }

  /**
   * <p>Lists all FFprobe sessions in the session history.
   *
   * @return all FFprobe sessions in the session history
   */
  static async listFFprobeSessions() {
    await FFmpegKitConfig.init();

    const sessionArray = await FFmpegKitReactNativeModule.getFFprobeSessions();
    return sessionArray.map(FFmpegKitFactory.mapToSession);
  }

  /**
   * <p>Lists all MediaInformation sessions in the session history.
   *
   * @return all MediaInformation sessions in the session history
   */
  static async listMediaInformationSessions() {
    await FFmpegKitConfig.init();

    const sessionArray = await FFmpegKitReactNativeModule.getMediaInformationSessions();
    return sessionArray.map(FFmpegKitFactory.mapToSession);
  }

}

/**
 * <p>An FFprobe session.
 */
export class FFprobeSession extends AbstractSession {

  /**
   * Creates a new FFprobe session.
   *
   * @param argumentsArray FFprobe command arguments
   * @param completeCallback callback that will be called when the execution has completed
   * @param logCallback callback that will receive logs
   * @param logRedirectionStrategy defines how logs will be redirected
   * @returns FFprobe session created
   */
  static async create(argumentsArray, completeCallback, logCallback, logRedirectionStrategy) {
    const session = await AbstractSession.createFFprobeSession(argumentsArray, logRedirectionStrategy);
    const sessionId = session.getSessionId();

    FFmpegKitFactory.setFFprobeSessionCompleteCallback(sessionId, completeCallback);
    FFmpegKitFactory.setLogCallback(sessionId, logCallback);

    return session;
  }

  /**
   * Returns the session specific complete callback.
   *
   * @return session specific complete callback
   */
  getCompleteCallback() {
    return FFmpegKitFactory.getFFprobeSessionCompleteCallback(this.getSessionId());
  }

  isFFmpeg() {
    return false;
  }

  isFFprobe() {
    return true;
  }

  isMediaInformation() {
    return false;
  }

}

/**
 * <p>Defines log levels.
 */
export class Level {

  /**
   * This log level is used to specify logs printed to stderr by ffmpeg.
   * Logs that has this level are not filtered and always redirected.
   */
  static AV_LOG_STDERR = -16;

  /**
   * Print no output.
   */
  static AV_LOG_QUIET = -8;

  /**
   * Something went really wrong and we will crash now.
   */
  static AV_LOG_PANIC = 0;

  /**
   * Something went wrong and recovery is not possible.
   * For example, no header was found for a format which depends
   * on headers or an illegal combination of parameters is used.
   */
  static AV_LOG_FATAL = 8;

  /**
   * Something went wrong and cannot losslessly be recovered.
   * However, not all future data is affected.
   */
  static AV_LOG_ERROR = 16;

  /**
   * Something somehow does not look correct. This may or may not
   * lead to problems. An example would be the use of '-vstrict -2'.
   */
  static AV_LOG_WARNING = 24;

  /**
   * Standard information.
   */
  static AV_LOG_INFO = 32;

  /**
   * Detailed information.
   */
  static AV_LOG_VERBOSE = 40;

  /**
   * Stuff which is only useful for libav* developers.
   */
  static AV_LOG_DEBUG = 48;

  /**
   * Extremely verbose debugging, useful for libav* development.
   */
  static AV_LOG_TRACE = 56;

  /**
   * Returns log level string.
   *
   * @param level log level integer
   * @returns log level string
   */
  static levelToString(level) {
    switch (level) {
      case Level.AV_LOG_TRACE:
        return "TRACE";
      case Level.AV_LOG_DEBUG:
        return "DEBUG";
      case Level.AV_LOG_VERBOSE:
        return "VERBOSE";
      case Level.AV_LOG_INFO:
        return "INFO";
      case Level.AV_LOG_WARNING:
        return "WARNING";
      case Level.AV_LOG_ERROR:
        return "ERROR";
      case Level.AV_LOG_FATAL:
        return "FATAL";
      case Level.AV_LOG_PANIC:
        return "PANIC";
      case Level.AV_LOG_STDERR:
        return "STDERR";
      case Level.AV_LOG_QUIET:
      default:
        return "";
    }
  }

}

/**
 * <p>Log entry for an <code>FFmpegKit</code> session.
 */
export class Log {
  #sessionId;
  #level;
  #message;

  constructor(sessionId, level, message) {
    this.#sessionId = sessionId;
    this.#level = level;
    this.#message = message;
  }

  getSessionId() {
    return this.#sessionId;
  }

  getLevel() {
    return this.#level;
  }

  getMessage() {
    return this.#message;
  }

}

/**
 * Media information class.
 */
export class MediaInformation {

  static KEY_FORMAT_PROPERTIES = "format";
  static KEY_FILENAME = "filename";
  static KEY_FORMAT = "format_name";
  static KEY_FORMAT_LONG = "format_long_name";
  static KEY_START_TIME = "start_time";
  static KEY_DURATION = "duration";
  static KEY_SIZE = "size";
  static KEY_BIT_RATE = "bit_rate";
  static KEY_TAGS = "tags";

  #allProperties;

  constructor(properties) {
    this.#allProperties = properties;
  }

  /**
   * Returns file name.
   *
   * @return media file name
   */
  getFilename() {
    return this.getStringFormatProperty(MediaInformation.KEY_FILENAME);
  }

  /**
   * Returns format.
   *
   * @return media format
   */
  getFormat() {
    return this.getStringFormatProperty(MediaInformation.KEY_FORMAT);
  }

  /**
   * Returns long format.
   *
   * @return media long format
   */
  getLongFormat() {
    return this.getStringFormatProperty(MediaInformation.KEY_FORMAT_LONG);
  }

  /**
   * Returns duration.
   *
   * @return media duration in "seconds.microseconds" format
   */
  getDuration() {
    return this.getStringFormatProperty(MediaInformation.KEY_DURATION);
  }

  /**
   * Returns start time.
   *
   * @return media start time in milliseconds
   */
  getStartTime() {
    return this.getStringFormatProperty(MediaInformation.KEY_START_TIME);
  }

  /**
   * Returns size.
   *
   * @return media size in bytes
   */
  getSize() {
    return this.getStringFormatProperty(MediaInformation.KEY_SIZE);
  }

  /**
   * Returns bitrate.
   *
   * @return media bitrate in kb/s
   */
  getBitrate() {
    return this.getStringFormatProperty(MediaInformation.KEY_BIT_RATE);
  }

  /**
   * Returns all tags.
   *
   * @return tags dictionary
   */
  getTags() {
    return this.getFormatProperty(MediaInformation.KEY_TAGS);
  }

  /**
   * Returns the streams found as array.
   *
   * @returns StreamInformation array
   */
  getStreams() {
    let list = [];
    let streamList;

    if (this.#allProperties !== undefined) {
      streamList = this.#allProperties.streams;
    }

    if (streamList !== undefined) {
      streamList.forEach((stream) => {
        list.push(new StreamInformation(stream));
      });
    }

    return list;
  }

  /**
   * Returns the chapters found as array.
   *
   * @returns Chapter array
   */
  getChapters() {
    let list = [];
    let chapterList;

    if (this.#allProperties !== undefined) {
      chapterList = this.#allProperties.chapters;
    }

    if (chapterList !== undefined) {
      chapterList.forEach((chapter) => {
        list.push(new Chapter(chapter));
      });
    }

    return list;
  }

  /**
   * Returns the property associated with the key.
   *
   * @param key property key
   * @return property as string or undefined if the key is not found
   */
  getStringProperty(key) {
    let allProperties = this.getAllProperties();
    if (allProperties !== undefined) {
      return allProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns the property associated with the key.
   *
   * @param key property key
   * @return property as number or undefined if the key is not found
   */
  getNumberProperty(key) {
    let allProperties = this.getAllProperties();
    if (allProperties !== undefined) {
      return allProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns the property associated with the key.
   *
   * @param key property key
   * @return property as an object or undefined if the key is not found
   */
  getProperty(key) {
    let allProperties = this.getAllProperties();
    if (allProperties !== undefined) {
      return allProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns the format property associated with the key.
   *
   * @param key property key
   * @return format property as string or undefined if the key is not found
   */
  getStringFormatProperty(key) {
    let formatProperties = this.getFormatProperties();
    if (formatProperties !== undefined) {
      return formatProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns the format property associated with the key.
   *
   * @param key property key
   * @return format property as number or undefined if the key is not found
   */
  getNumberFormatProperty(key) {
    let formatProperties = this.getFormatProperties();
    if (formatProperties !== undefined) {
      return formatProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns the format property associated with the key.
   *
   * @param key property key
   * @return format property as an object or undefined if the key is not found
   */
  getFormatProperty(key) {
    let formatProperties = this.getFormatProperties();
    if (formatProperties !== undefined) {
      return formatProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns all format properties defined.
   *
   * @returns an object where format properties can be accessed by property names
   */
  getFormatProperties() {
    if (this.#allProperties !== undefined) {
      return this.#allProperties[MediaInformation.KEY_FORMAT_PROPERTIES];
    } else {
      return undefined;
    }
  }

  /**
   * Returns all properties found, including stream properties.
   *
   * @returns an object in which properties can be accessed by property names
   */
  getAllProperties() {
    return this.#allProperties;
  }
}

/**
 * A parser that constructs {@link MediaInformation} from FFprobe's json output.
 */
export class MediaInformationJsonParser {

  /**
   * Extracts <code>MediaInformation</code> from the given FFprobe json output. Note that this
   * method does not fail as {@link #fromWithError(String)} does and returns undefined on error.
   *
   * @param ffprobeJsonOutput FFprobe json output
   * @return created {@link MediaInformation} instance of undefined if a parsing error occurs
   */
  static async from(ffprobeJsonOutput) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.mediaInformationJsonParserFrom(ffprobeJsonOutput).map(properties => new MediaInformation(properties));
  }

  /**
   * Extracts MediaInformation from the given FFprobe json output.
   *
   * @param ffprobeJsonOutput ffprobe json output
   * @return created {@link MediaInformation} instance
   */
  static async fromWithError(ffprobeJsonOutput) {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.mediaInformationJsonParserFrom(ffprobeJsonOutput).map(properties => new MediaInformation(properties));
  }

}

/**
 * <p>A custom FFprobe session, which produces a <code>MediaInformation</code> object using the
 * FFprobe output.
 */
export class MediaInformationSession extends AbstractSession {
  #mediaInformation;

  /**
   * Creates a new MediaInformationSession session.
   *
   * @param argumentsArray FFprobe command arguments
   * @param completeCallback callback that will be called when the execution has completed
   * @param logCallback callback that will receive logs
   * @returns MediaInformationSession session created
   */
  static async create(argumentsArray, completeCallback, logCallback) {
    const session = await AbstractSession.createMediaInformationSession(argumentsArray);
    const sessionId = session.getSessionId();

    FFmpegKitFactory.setMediaInformationSessionCompleteCallback(sessionId, completeCallback);
    FFmpegKitFactory.setLogCallback(sessionId, logCallback);

    return session;
  }

  /**
   * Returns the media information extracted in this session.
   *
   * @return media information extracted or undefined if the command failed or the output can not be
   * parsed
   */
  getMediaInformation() {
    return this.#mediaInformation;
  }

  /**
   * Sets the media information extracted in this session.
   *
   * @param mediaInformation media information extracted
   */
  setMediaInformation(mediaInformation) {
    this.#mediaInformation = mediaInformation;
  }

  /**
   * Returns the session specific complete callback.
   *
   * @return session specific complete callback
   */
  getCompleteCallback() {
    return FFmpegKitFactory.getMediaInformationSessionCompleteCallback(this.getSessionId());
  }

  isFFmpeg() {
    return false;
  }

  isFFprobe() {
    return false;
  }

  isMediaInformation() {
    return true;
  }

}

/**
 * <p>Helper class to extract binary package information.
 */
export class Packages {

  /**
   * Returns the FFmpegKit ReactNative binary package name.
   *
   * @return predicted FFmpegKit ReactNative binary package name
   */
  static async getPackageName() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getPackageName();
  }

  /**
   * Returns enabled external libraries by FFmpeg.
   *
   * @return enabled external libraries
   */
  static async getExternalLibraries() {
    await FFmpegKitConfig.init();

    return FFmpegKitReactNativeModule.getExternalLibraries();
  }

}

export class ReturnCode {

  static SUCCESS = 0;

  static CANCEL = 255;

  #value;

  constructor(value) {
    this.#value = value;
  }

  static isSuccess(returnCode) {
    return (returnCode !== undefined && returnCode.getValue() === ReturnCode.SUCCESS);
  }

  static isCancel(returnCode) {
    return (returnCode !== undefined && returnCode.getValue() === ReturnCode.CANCEL);
  }

  getValue() {
    return this.#value;
  }

  isValueSuccess() {
    return (this.#value === ReturnCode.SUCCESS);
  }

  isValueError() {
    return ((this.#value !== ReturnCode.SUCCESS) && (this.#value !== ReturnCode.CANCEL));
  }

  isValueCancel() {
    return (this.#value === ReturnCode.CANCEL);
  }

  toString() {
    return this.#value;
  }

}

/**
 * <p>Statistics entry for an FFmpeg execute session.
 */
export class Statistics {
  #sessionId;
  #videoFrameNumber;
  #videoFps;
  #videoQuality;
  #size;
  #time;
  #bitrate;
  #speed;

  constructor(sessionId, videoFrameNumber, videoFps, videoQuality, size, time, bitrate, speed) {
    this.#sessionId = sessionId;
    this.#videoFrameNumber = videoFrameNumber;
    this.#videoFps = videoFps;
    this.#videoQuality = videoQuality;
    this.#size = size;
    this.#time = time;
    this.#bitrate = bitrate;
    this.#speed = speed;
  }

  getSessionId() {
    return this.#sessionId;
  }

  setSessionId(sessionId) {
    this.#sessionId = sessionId;
  }

  getVideoFrameNumber() {
    return this.#videoFrameNumber;
  }

  setVideoFrameNumber(videoFrameNumber) {
    this.#videoFrameNumber = videoFrameNumber;
  }

  getVideoFps() {
    return this.#videoFps;
  }

  setVideoFps(videoFps) {
    this.#videoFps = videoFps;
  }

  getVideoQuality() {
    return this.#videoQuality;
  }

  setVideoQuality(videoQuality) {
    this.#videoQuality = videoQuality;
  }

  getSize() {
    return this.#size;
  }

  setSize(size) {
    this.#size = size;
  }

  getTime() {
    return this.#time;
  }

  setTime(time) {
    this.#time = time;
  }

  getBitrate() {
    return this.#bitrate;
  }

  setBitrate(bitrate) {
    this.#bitrate = bitrate;
  }

  getSpeed() {
    return this.#speed;
  }

  setSpeed(speed) {
    this.#speed = speed;
  }

}

/**
 * Stream information class.
 */
export class StreamInformation {

  static KEY_INDEX = "index";
  static KEY_TYPE = "codec_type";
  static KEY_CODEC = "codec_name";
  static KEY_CODEC_LONG = "codec_long_name";
  static KEY_FORMAT = "pix_fmt";
  static KEY_WIDTH = "width";
  static KEY_HEIGHT = "height";
  static KEY_BIT_RATE = "bit_rate";
  static KEY_SAMPLE_RATE = "sample_rate";
  static KEY_SAMPLE_FORMAT = "sample_fmt";
  static KEY_CHANNEL_LAYOUT = "channel_layout";
  static KEY_SAMPLE_ASPECT_RATIO = "sample_aspect_ratio";
  static KEY_DISPLAY_ASPECT_RATIO = "display_aspect_ratio";
  static KEY_AVERAGE_FRAME_RATE = "avg_frame_rate";
  static KEY_REAL_FRAME_RATE = "r_frame_rate";
  static KEY_TIME_BASE = "time_base";
  static KEY_CODEC_TIME_BASE = "codec_time_base";
  static KEY_TAGS = "tags";

  #allProperties;

  constructor(properties) {
    this.#allProperties = properties;
  }

  /**
   * Returns stream index.
   *
   * @return stream index, starting from zero
   */
  getIndex() {
    return this.getNumberProperty(StreamInformation.KEY_INDEX);
  }

  /**
   * Returns stream type.
   *
   * @return stream type; audio or video
   */
  getType() {
    return this.getStringProperty(StreamInformation.KEY_TYPE);
  }

  /**
   * Returns stream codec.
   *
   * @return stream codec
   */
  getCodec() {
    return this.getStringProperty(StreamInformation.KEY_CODEC);
  }

  /**
   * Returns stream codec in long format.
   *
   * @return stream codec with additional profile and mode information
   */
  getCodecLong() {
    return this.getStringProperty(StreamInformation.KEY_CODEC_LONG);
  }

  /**
   * Returns stream format.
   *
   * @return stream format
   */
  getFormat() {
    return this.getStringProperty(StreamInformation.KEY_FORMAT);
  }

  /**
   * Returns width.
   *
   * @return width in pixels
   */
  getWidth() {
    return this.getNumberProperty(StreamInformation.KEY_WIDTH);
  }

  /**
   * Returns height.
   *
   * @return height in pixels
   */
  getHeight() {
    return this.getNumberProperty(StreamInformation.KEY_HEIGHT);
  }

  /**
   * Returns bitrate.
   *
   * @return bitrate in kb/s
   */
  getBitrate() {
    return this.getStringProperty(StreamInformation.KEY_BIT_RATE);
  }

  /**
   * Returns sample rate.
   *
   * @return sample rate in hz
   */
  getSampleRate() {
    return this.getStringProperty(StreamInformation.KEY_SAMPLE_RATE);
  }

  /**
   * Returns sample format.
   *
   * @return sample format
   */
  getSampleFormat() {
    return this.getStringProperty(StreamInformation.KEY_SAMPLE_FORMAT);
  }

  /**
   * Returns channel layout.
   *
   * @return channel layout
   */
  getChannelLayout() {
    return this.getStringProperty(StreamInformation.KEY_CHANNEL_LAYOUT);
  }

  /**
   * Returns sample aspect ratio.
   *
   * @return sample aspect ratio
   */
  getSampleAspectRatio() {
    return this.getStringProperty(StreamInformation.KEY_SAMPLE_ASPECT_RATIO);
  }

  /**
   * Returns display aspect ratio.
   *
   * @return display aspect ratio
   */
  getDisplayAspectRatio() {
    return this.getStringProperty(StreamInformation.KEY_DISPLAY_ASPECT_RATIO);
  }

  /**
   * Returns display aspect ratio.
   *
   * @return average frame rate in fps
   */
  getAverageFrameRate() {
    return this.getStringProperty(StreamInformation.KEY_AVERAGE_FRAME_RATE);
  }

  /**
   * Returns real frame rate.
   *
   * @return real frame rate in tbr
   */
  getRealFrameRate() {
    return this.getStringProperty(StreamInformation.KEY_REAL_FRAME_RATE);
  }

  /**
   * Returns time base.
   *
   * @return time base in tbn
   */
  getTimeBase() {
    return this.getStringProperty(StreamInformation.KEY_TIME_BASE);
  }

  /**
   * Returns codec time base.
   *
   * @return codec time base in tbc
   */
  getCodecTimeBase() {
    return this.getStringProperty(StreamInformation.KEY_CODEC_TIME_BASE);
  }

  /**
   * Returns all tags.
   *
   * @return tags object
   */
  getTags() {
    return this.getProperty(StreamInformation.KEY_TAGS);
  }

  /**
   * Returns the stream property associated with the key.
   *
   * @param key property key
   * @return stream property as string or undefined if the key is not found
   */
  getStringProperty(key) {
    if (this.#allProperties !== undefined) {
      return this.#allProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns the stream property associated with the key.
   *
   * @param key property key
   * @return stream property as number or undefined if the key is not found
   */
  getNumberProperty(key) {
    if (this.#allProperties !== undefined) {
      return this.#allProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns the stream property associated with the key.
   *
   * @param key property key
   * @return stream property as an object or undefined if the key is not found
   */
  getProperty(key) {
    if (this.#allProperties !== undefined) {
      return this.#allProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns all properties found.
   *
   * @returns an object in which properties can be accessed by property names
   */
  getAllProperties() {
    return this.#allProperties;
  }
}

/**
 * Chapter class.
 */
export class Chapter {

  static KEY_ID = "id";
  static KEY_TIME_BASE = "time_base";
  static KEY_START = "start";
  static KEY_START_TIME = "start_time";
  static KEY_END = "end";
  static KEY_END_TIME = "end_time";
  static KEY_TAGS = "tags";

  #allProperties;

  constructor(properties) {
    this.#allProperties = properties;
  }

  /**
   * Returns id.
   *
   * @return id
   */
  getId() {
    return this.getNumberProperty(Chapter.KEY_ID);
  }

  /**
   * Returns time base.
   *
   * @return time base
   */
  getTimeBase() {
    return this.getStringProperty(Chapter.KEY_TIME_BASE);
  }

  /**
   * Returns start.
   *
   * @return start
   */
  getStart() {
    return this.getNumberProperty(Chapter.KEY_START);
  }

  /**
   * Returns start time.
   *
   * @return start time
   */
  getStartTime() {
    return this.getStringProperty(Chapter.KEY_START_TIME);
  }

  /**
   * Returns end.
   *
   * @return end
   */
  getEnd() {
    return this.getNumberProperty(Chapter.KEY_END);
  }

  /**
   * Returns end time.
   *
   * @return end time
   */
  getEndTime() {
    return this.getStringProperty(Chapter.KEY_END_TIME);
  }

  /**
   * Returns all tags.
   *
   * @return tags object
   */
  getTags() {
    return this.getProperty(StreamInformation.KEY_TAGS);
  }

  /**
   * Returns the chapter property associated with the key.
   *
   * @param key property key
   * @return chapter property as string or undefined if the key is not found
   */
  getStringProperty(key) {
    if (this.#allProperties !== undefined) {
      return this.#allProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns the chapter property associated with the key.
   *
   * @param key property key
   * @return chapter property as number or undefined if the key is not found
   */
  getNumberProperty(key) {
    if (this.#allProperties !== undefined) {
      return this.#allProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns the chapter property associated with the key.
   *
   * @param key property key
   * @return chapter property as an object or undefined if the key is not found
   */
  getProperty(key) {
    if (this.#allProperties !== undefined) {
      return this.#allProperties[key];
    } else {
      return undefined;
    }
  }

  /**
   * Returns all properties found.
   *
   * @returns an object in which properties can be accessed by property names
   */
  getAllProperties() {
    return this.#allProperties;
  }
}
