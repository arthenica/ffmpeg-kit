declare module 'ffmpeg-kit-react-native' {

  export abstract class AbstractSession implements Session {

    static createFFmpegSession(argumentsArray: Array<string>, logRedirectionStrategy?: LogRedirectionStrategy): Promise<FFmpegSession>;

    static createFFmpegSessionFromMap(sessionMap: { [key: string]: any }): FFmpegSession;

    static createFFprobeSession(argumentsArray: Array<string>, logRedirectionStrategy?: LogRedirectionStrategy): Promise<FFprobeSession>;

    static createFFprobeSessionFromMap(sessionMap: { [key: string]: any }): FFprobeSession;

    static createMediaInformationSession(argumentsArray: Array<string>): Promise<MediaInformationSession>;

    static createMediaInformationSessionFromMap(sessionMap: { [key: string]: any }): MediaInformationSession;

    getLogCallback(): LogCallback;

    getSessionId(): number;

    getCreateTime(): Date;

    getStartTime(): Date;

    getEndTime(): Promise<Date>;

    getDuration(): Promise<number>;

    getArguments(): Array<string>;

    getCommand(): string;

    getAllLogs(waitTimeout ?: number): Promise<Array<Log>>;

    getLogs(): Promise<Array<Log>>;

    getAllLogsAsString(waitTimeout?: number): Promise<string>;

    getLogsAsString(): Promise<string>;

    getOutput(): Promise<string>;

    getState(): Promise<SessionState>;

    getReturnCode(): Promise<ReturnCode>;

    getFailStackTrace(): Promise<string>;

    getLogRedirectionStrategy(): LogRedirectionStrategy;

    thereAreAsynchronousMessagesInTransmit(): Promise<boolean>;

    isFFmpeg(): boolean;

    isFFprobe(): boolean;

    isMediaInformation(): boolean;

    cancel(): Promise<void>;

  }

  export class ArchDetect {

    static getArch(): Promise<string>;

  }

  export type FFmpegSessionCompleteCallback = (session: FFmpegSession) => void;
  export type FFprobeSessionCompleteCallback = (session: FFprobeSession) => void;
  export type MediaInformationSessionCompleteCallback = (session: MediaInformationSession) => void;

  export class FFmpegKit {

    static execute(command: string): Promise<FFmpegSession>;

    static executeWithArguments(commandArguments: string[]): Promise<FFmpegSession>;

    static executeAsync(command: string, completeCallback?: FFmpegSessionCompleteCallback, logCallback?: LogCallback, statisticsCallback?: StatisticsCallback): Promise<FFmpegSession>;

    static executeWithArgumentsAsync(commandArguments: string[], completeCallback?: FFmpegSessionCompleteCallback, logCallback?: LogCallback, statisticsCallback?: StatisticsCallback): Promise<FFmpegSession>;

    static cancel(sessionId?: number): Promise<void>;

    static listSessions(): Promise<FFmpegSession[]>;

  }

  export class FFmpegKitConfig {

    static init(): Promise<void>;

    static uninit(): Promise<void>;

    static enableRedirection(): Promise<void>;

    static disableRedirection(): Promise<void>;

    static setFontconfigConfigurationPath(path: string): Promise<void>;

    static setFontDirectory(path: string, mapping?: { [key: string]: string }): Promise<void>;

    static setFontDirectoryList(fontDirectoryList: string[], mapping?: { [key: string]: string }): Promise<void>;

    static registerNewFFmpegPipe(): Promise<string>;

    static closeFFmpegPipe(ffmpegPipePath: string): Promise<void>;

    static getFFmpegVersion(): Promise<string>;

    static getVersion(): Promise<string>;

    static isLTSBuild(): Promise<boolean>;

    static getBuildDate(): Promise<string>;

    static setEnvironmentVariable(name: string, value: string): Promise<void>;

    static ignoreSignal(signal: Signal): Promise<void>;

    static ffmpegExecute(session: FFmpegSession): Promise<void>;

    static ffprobeExecute(session: FFprobeSession): Promise<void>;

    static getMediaInformationExecute(session: MediaInformationSession, waitTimeout?: number): Promise<void>;

    static asyncFFmpegExecute(session: FFmpegSession): Promise<void>;

    static asyncFFprobeExecute(session: FFprobeSession): Promise<void>;

    static asyncGetMediaInformationExecute(session: MediaInformationSession, waitTimeout?: number): Promise<void>;

    static enableLogCallback(logCallback: LogCallback): void;

    static enableStatisticsCallback(statisticsCallback: StatisticsCallback): void;

    static enableFFmpegSessionCompleteCallback(completeCallback: FFmpegSessionCompleteCallback): void;

    static getFFmpegSessionCompleteCallback(): FFmpegSessionCompleteCallback;

    static enableFFprobeSessionCompleteCallback(completeCallback: FFprobeSessionCompleteCallback): void;

    static getFFprobeSessionCompleteCallback(): FFprobeSessionCompleteCallback;

    static enableMediaInformationSessionCompleteCallback(completeCallback: MediaInformationSessionCompleteCallback): void;

    static getMediaInformationSessionCompleteCallback(): MediaInformationSessionCompleteCallback;

    static getLogLevel(): Level;

    static setLogLevel(level: Level): Promise<void>;

    static getSafParameterForRead(uriString: String): Promise<string>;

    static getSafParameterForWrite(uriString: String): Promise<string>;

    static getSafParameter(uriString: String, openMode: String): Promise<string>;

    static getSessionHistorySize(): Promise<number>;

    static setSessionHistorySize(sessionHistorySize: number): Promise<void>;

    static getSession(sessionId: number): Promise<Session>;

    static getLastSession(): Promise<Session>;

    static getLastCompletedSession(): Promise<Session>;

    static getSessions(): Promise<Session[]>;

    static clearSessions(): Promise<void>;

    static getFFmpegSessions(): Promise<FFmpegSession[]>;

    static getFFprobeSessions(): Promise<FFprobeSession[]>;

    static getMediaInformationSessions(): Promise<MediaInformationSession[]>;

    static getSessionsByState(state): Promise<Session[]>;

    static getLogRedirectionStrategy(): LogRedirectionStrategy;

    static setLogRedirectionStrategy(logRedirectionStrategy: LogRedirectionStrategy);

    static messagesInTransmit(sessionId: number): Promise<number>;

    static sessionStateToString(state): string;

    static parseArguments(command: string): string[];

    static argumentsToString(commandArguments: string[]): string;

    static enableLogs(): Promise<void>;

    static disableLogs(): Promise<void>;

    static enableStatistics(): Promise<void>;

    static disableStatistics(): Promise<void>;

    static getPlatform(): Promise<string>;

    static writeToPipe(inputPath: string, pipePath: string): Promise<number>;

    static selectDocumentForRead(type?: string, extraTypes?: string[]): Promise<string>;

    static selectDocumentForWrite(title?: string, type?: string, extraTypes?: string[]): Promise<string>;

  }

  export class FFmpegSession extends AbstractSession implements Session {

    static create(argumentsArray: Array<string>, completeCallback?: FFmpegSessionCompleteCallback, logCallback?: LogCallback, statisticsCallback?: StatisticsCallback, logRedirectionStrategy?: LogRedirectionStrategy): Promise<FFmpegSession>;

    getStatisticsCallback(): StatisticsCallback;

    getCompleteCallback(): FFmpegSessionCompleteCallback;

    getAllStatistics(waitTimeout?: number): Promise<Array<Statistics>>;

    getStatistics(): Promise<Array<Statistics>>;

    getLastReceivedStatistics(): Promise<Statistics>;

    isFFmpeg(): boolean;

    isFFprobe(): boolean;

    isMediaInformation(): boolean;

  }

  export class FFprobeKit {

    static execute(command: string): Promise<FFprobeSession>;

    static executeWithArguments(commandArguments: string[]): Promise<FFprobeSession>;

    static executeAsync(command: string, completeCallback?: FFprobeSessionCompleteCallback, logCallback?: LogCallback): Promise<FFprobeSession>;

    static executeWithArgumentsAsync(commandArguments: string[], completeCallback?: FFprobeSessionCompleteCallback, logCallback?: LogCallback): Promise<FFprobeSession>;

    static getMediaInformation(path: string, waitTimeout?: number): Promise<MediaInformationSession>;

    static getMediaInformationFromCommand(command: string, waitTimeout?: number): Promise<MediaInformationSession>;

    static getMediaInformationFromCommandArguments(commandArguments: string[], waitTimeout?: number): Promise<MediaInformationSession>;

    static getMediaInformationAsync(path: string, completeCallback?: FFprobeSessionCompleteCallback, logCallback?: LogCallback, waitTimeout?: number): Promise<MediaInformationSession>;

    static getMediaInformationFromCommandAsync(command: string, completeCallback?: FFprobeSessionCompleteCallback, logCallback?: LogCallback, waitTimeout?: number): Promise<MediaInformationSession>;

    static getMediaInformationFromCommandArgumentsAsync(commandArguments: string[], completeCallback?: FFprobeSessionCompleteCallback, logCallback?: LogCallback, waitTimeout?: number): Promise<MediaInformationSession>;

    static listFFprobeSessions(): Promise<FFprobeSession[]>;

    static listMediaInformationSessions(): Promise<MediaInformationSession[]>;

  }

  export class FFprobeSession extends AbstractSession implements Session {

    static create(argumentsArray: Array<string>, completeCallback?: FFprobeSessionCompleteCallback, logCallback?: LogCallback, logRedirectionStrategy?: LogRedirectionStrategy): Promise<FFprobeSession>;

    getCompleteCallback(): FFprobeSessionCompleteCallback;

    isFFmpeg(): boolean;

    isFFprobe(): boolean;

    isMediaInformation(): boolean;

  }

  export class Level {
    static readonly AV_LOG_STDERR: number;
    static readonly AV_LOG_QUIET: number;
    static readonly AV_LOG_PANIC: number;
    static readonly AV_LOG_FATAL: number;
    static readonly AV_LOG_ERROR: number;
    static readonly AV_LOG_WARNING: number;
    static readonly AV_LOG_INFO: number;
    static readonly AV_LOG_VERBOSE: number;
    static readonly AV_LOG_DEBUG: number;
    static readonly AV_LOG_TRACE: number;

    static levelToString(number: number): string;
  }

  export class Log {

    constructor(sessionId: number, level: number, message: String);

    getSessionId(): number;

    getLevel(): number;

    getMessage(): String;

  }

  export type LogCallback = (log: Log) => void;

  export enum LogRedirectionStrategy {
    ALWAYS_PRINT_LOGS = 0,
    PRINT_LOGS_WHEN_NO_CALLBACKS_DEFINED = 1,
    PRINT_LOGS_WHEN_GLOBAL_CALLBACK_NOT_DEFINED = 2,
    PRINT_LOGS_WHEN_SESSION_CALLBACK_NOT_DEFINED = 3,
    NEVER_PRINT_LOGS = 4
  }

  export class MediaInformation {

    static readonly KEY_FORMAT_PROPERTIES: string;
    static readonly KEY_FILENAME: string;
    static readonly KEY_FORMAT: string;
    static readonly KEY_FORMAT_LONG: string;
    static readonly KEY_START_TIME: string;
    static readonly KEY_DURATION: string;
    static readonly KEY_SIZE: string;
    static readonly KEY_BIT_RATE: string;
    static readonly KEY_TAGS: string;

    constructor(properties: Record<string, any>);

    getFilename(): string;

    getFormat(): string;

    getLongFormat(): string;

    getDuration(): number;

    getStartTime(): string;

    getSize(): string;

    getBitrate(): string;

    getTags(): Record<string, any>;

    getStreams(): Array<StreamInformation>;

    getChapters(): Array<Chapter>;

    getStringProperty(key: string): string;

    getNumberProperty(key: string): number;

    getProperty(key: string): any;

    getStringFormatProperty(key: string): string;

    getNumberFormatProperty(key: string): number;

    getFormatProperty(key: string): any;

    getFormatProperties(): Record<string, any>;

    getAllProperties(): Record<string, any>;

  }

  export class MediaInformationJsonParser {

    static from(ffprobeJsonOutput: string): Promise<MediaInformation>;

    static fromWithError(ffprobeJsonOutput: string): Promise<MediaInformation>;

  }

  export class MediaInformationSession extends AbstractSession implements Session {

    static create(argumentsArray: Array<string>, completeCallback?: MediaInformationSessionCompleteCallback, logCallback?: LogCallback): Promise<MediaInformationSession>;

    getMediaInformation(): MediaInformation;

    setMediaInformation(mediaInformation: MediaInformation): void;

    getCompleteCallback(): MediaInformationSessionCompleteCallback;

    isFFmpeg(): boolean;

    isFFprobe(): boolean;

    isMediaInformation(): boolean;

  }

  export class Packages {

    static getPackageName(): Promise<string>;

    static getExternalLibraries(): Promise<string[]>;

  }

  export class ReturnCode {

    static readonly SUCCESS: number;

    static readonly CANCEL: number;

    constructor(value: number);

    static isSuccess(returnCode: ReturnCode): boolean;

    static isCancel(returnCode: ReturnCode): boolean;

    getValue(): number;

    isValueSuccess(): boolean;

    isValueError(): boolean;

    isValueCancel(): boolean;

  }

  export interface Session {

    getLogCallback(): LogCallback;

    getSessionId(): number;

    getCreateTime(): Date;

    getStartTime(): Date;

    getEndTime(): Promise<Date>;

    getDuration(): Promise<number>;

    getArguments(): Array<String>;

    getCommand(): String;

    getAllLogs(waitTimeout ?: number): Promise<Array<Log>>;

    getLogs(): Promise<Array<Log>>;

    getAllLogsAsString(waitTimeout?: number): Promise<string>;

    getLogsAsString(): Promise<string>;

    getOutput(): Promise<string>;

    getState(): Promise<SessionState>;

    getReturnCode(): Promise<ReturnCode>;

    getFailStackTrace(): Promise<string>;

    getLogRedirectionStrategy(): LogRedirectionStrategy;

    thereAreAsynchronousMessagesInTransmit(): Promise<boolean>;

    isFFmpeg(): boolean;

    isFFprobe(): boolean;

    isMediaInformation(): boolean;

    cancel(): Promise<void>;

  }

  export enum SessionState {
    CREATED = 0,
    RUNNING = 1,
    FAILED = 2,
    COMPLETED = 3
  }

  export enum Signal {
    SIGINT = 2,
    SIGQUIT = 3,
    SIGPIPE = 13,
    SIGTERM = 15,
    SIGXCPU = 24
  }

  export class Statistics {

    constructor(sessionId: number, videoFrameNumber: number, videoFps: number, videoQuality: number, size: number, time: number, bitrate: number, speed: number);

    getSessionId(): number;

    setSessionId(sessionId: number): void;

    getVideoFrameNumber(): number;

    setVideoFrameNumber(videoFrameNumber: number): void;

    getVideoFps(): number;

    setVideoFps(videoFps: number): void;

    getVideoQuality(): number;

    setVideoQuality(videoQuality: number): void;

    getSize(): number;

    setSize(size: number): void;

    getTime(): number;

    setTime(time: number): void;

    getBitrate(): number;

    setBitrate(bitrate: number): void;

    getSpeed(): number;

    setSpeed(speed: number): void;

  }

  export type StatisticsCallback = (statistics: Statistics) => void;

  export class StreamInformation {

    static readonly KEY_INDEX: string;
    static readonly KEY_TYPE: string;
    static readonly KEY_CODEC: string;
    static readonly KEY_CODEC_LONG: string;
    static readonly KEY_FORMAT: string;
    static readonly KEY_WIDTH: string;
    static readonly KEY_HEIGHT: string;
    static readonly KEY_BIT_RATE: string;
    static readonly KEY_SAMPLE_RATE: string;
    static readonly KEY_SAMPLE_FORMAT: string;
    static readonly KEY_CHANNEL_LAYOUT: string;
    static readonly KEY_SAMPLE_ASPECT_RATIO: string;
    static readonly KEY_DISPLAY_ASPECT_RATIO: string;
    static readonly KEY_AVERAGE_FRAME_RATE: string;
    static readonly KEY_REAL_FRAME_RATE: string;
    static readonly KEY_TIME_BASE: string;
    static readonly KEY_CODEC_TIME_BASE: string;
    static readonly KEY_TAGS: string;

    constructor(properties: Record<string, any>);

    getIndex(): number;

    getType(): string;

    getCodec(): string;

    getCodecLong(): string;

    getFormat(): string;

    getWidth(): number;

    getHeight(): number;

    getBitrate(): string;

    getSampleRate(): string;

    getSampleFormat(): string;

    getChannelLayout(): string;

    getSampleAspectRatio(): string;

    getDisplayAspectRatio(): string;

    getAverageFrameRate(): string;

    getRealFrameRate(): string;

    getTimeBase(): string;

    getCodecTimeBase(): string;

    getTags(): Record<string, any>;

    getStringProperty(key): string;

    getNumberProperty(key): number;

    getProperty(key): any;

    getAllProperties(): Record<string, any>;

  }

  export class Chapter {

    static readonly KEY_ID: string;
    static readonly KEY_TIME_BASE: string;
    static readonly KEY_START: string;
    static readonly KEY_START_TIME: string;
    static readonly KEY_END: string;
    static readonly KEY_END_TIME: string;
    static readonly KEY_TAGS: string;

    constructor(properties: Record<string, any>);

    getId(): number;

    getTimeBase(): string;

    getStart(): number;

    getStartTime(): string;

    getEnd(): number;

    getEndTime(): string;

    getTags(): Record<string, any>;

    getStringProperty(key): string;

    getNumberProperty(key): number;

    getProperty(key): any;

    getAllProperties(): Record<string, any>;

  }

}
