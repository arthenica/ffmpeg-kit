/*
 * Copyright (c) 2022 Taner Sener
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

#ifndef FFMPEG_KIT_CONFIG_H
#define FFMPEG_KIT_CONFIG_H

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include "FFmpegSession.h"
#include "FFprobeSession.h"
#include "Level.h"
#include "LogCallback.h"
#include "MediaInformationSession.h"
#include "Signal.h"
#include "StatisticsCallback.h"
#include <map>

namespace ffmpegkit {

    /**
     * <p>Configuration class of <code>FFmpegKit</code> library. Allows customizing the global library
     * options. Provides helper methods to support additional resources.
     */
    class FFmpegKitConfig {
        public:

            /** Global library version */
            static constexpr const char* FFmpegKitVersion = "6.0";

            /**
             * Prefix of named pipes created by ffmpeg-kit.
             */
            static constexpr const char* FFmpegKitNamedPipePrefix = "fk_pipe_";

            /**
             * <p>Enables log and statistics redirection.
             *
             * <p>When redirection is enabled FFmpeg/FFprobe sessions collect log and statistics entries for the
             * executions. It is possible to define global or session specific log/statistics callbacks as well.
             *
             * <p>Note that redirection is enabled by default. If you do not want to use its functionality
             * please use disableRedirection method to disable it.
             */
            static void enableRedirection();

            /**
             * <p>Disables log and statistics redirection.
             *
             * <p>When redirection is disabled logs are printed to stderr, all logs and statistics
             * callbacks are disabled and <code>FFprobe</code>'s <code>getMediaInformation</code> methods
             * do not work.
             */
            static void disableRedirection();

            /**
             * <p>Sets and overrides <code>fontconfig</code> configuration directory.
             *
             * @param path directory that contains fontconfig configuration (fonts.conf)
             * @return zero on success, non-zero on error
             */
            static int setFontconfigConfigurationPath(const std::string& path);

            /**
             * <p>Registers the fonts inside the given path, so they become available to use in FFmpeg
             * filters.
             *
             * <p>Note that you need to build <code>FFmpegKit</code> with <code>fontconfig</code>
             * enabled or use a prebuilt package with <code>fontconfig</code> inside to be able to use
             * fonts in <code>FFmpeg</code>.
             *
             * @param fontDirectoryPath directory that contains fonts (.ttf and .otf files)
             * @param fontNameMapping   custom font name mappings, useful to access your fonts with more
             *                          friendly names
             */
            static void setFontDirectory(const std::string& fontDirectoryPath, const std::map<std::string,std::string>& fontNameMapping);

            /**
             * <p>Registers the fonts inside the given list of font directories, so they become available
             * to use in FFmpeg filters.
             *
             * <p>Note that you need to build <code>FFmpegKit</code> with <code>fontconfig</code>
             * enabled or use a prebuilt package with <code>fontconfig</code> inside to be able to use
             * fonts in <code>FFmpeg</code>.
             *
             * @param fontDirectoryList list of directories that contain fonts (.ttf and .otf files)
             * @param fontNameMapping   custom font name mappings, useful to access your fonts with more
             *                          friendly names
             */
            static void setFontDirectoryList(const std::list<std::string>& fontDirectoryList, const std::map<std::string,std::string>& fontNameMapping);

            /**
             * <p>Creates a new named pipe to use in <code>FFmpeg</code> operations.
             *
             * <p>Please note that creator is responsible of closing created pipes.
             *
             * @return the full path of the named pipe
             */
            static std::shared_ptr<std::string> registerNewFFmpegPipe();

            /**
             * <p>Closes a previously created <code>FFmpeg</code> pipe.
             *
             * @param ffmpegPipePath full path of the FFmpeg pipe
             */
            static void closeFFmpegPipe(const std::string& ffmpegPipePath);

            /**
             * <p>Returns the version of FFmpeg bundled within <code>FFmpegKit</code> library.
             *
             * @return the version of FFmpeg
             */
            static std::string getFFmpegVersion();

            /**
             * Returns FFmpegKit library version.
             *
             * @return FFmpegKit version
             */
            static std::string getVersion();

            /**
             * <p>Returns whether FFmpegKit release is a Long Term Release or not.
             *
             * @return true/yes or false/no
             */
            static bool isLTSBuild();

            /**
             * Returns FFmpegKit library build date.
             *
             * @return FFmpegKit library build date
             */
            static std::string getBuildDate();

            /**
             * <p>Sets an environment variable.
             *
             * @param variableName  environment variable name
             * @param variableValue environment variable value
             * @return zero on success, non-zero on error
             */
            static int setEnvironmentVariable(const std::string& variableName, const std::string& variableValue);

            /**
             * <p>Registers a new ignored signal. Ignored signals are not handled by <code>FFmpegKit</code>
             * library.
             *
             * @param signal signal to be ignored
             */
            static void ignoreSignal(const ffmpegkit::Signal signal);

            /**
             * <p>Synchronously executes the FFmpeg session provided.
             *
             * @param ffmpegSession FFmpeg session which includes command options/arguments
             */
            static void ffmpegExecute(const std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegSession);

            /**
             * <p>Synchronously executes the FFprobe session provided.
             *
             * @param ffprobeSession FFprobe session which includes command options/arguments
             */
            static void ffprobeExecute(const std::shared_ptr<ffmpegkit::FFprobeSession> ffprobeSession);

            /**
             * <p>Synchronously executes the media information session provided.
             *
             * @param mediaInformationSession media information session which includes command options/arguments
             * @param waitTimeout             max time to wait until media information is transmitted
             */
            static void getMediaInformationExecute(const std::shared_ptr<ffmpegkit::MediaInformationSession> mediaInformationSession, const int waitTimeout);

            /**
             * <p>Starts an asynchronous FFmpeg execution for the given session.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete.
             * You must use an FFmpegSessionCompleteCallback if you want to be notified about the result.
             *
             * @param ffmpegSession FFmpeg session which includes command options/arguments
             */
            static void asyncFFmpegExecute(const std::shared_ptr<ffmpegkit::FFmpegSession> ffmpegSession);

            /**
             * <p>Starts an asynchronous FFprobe execution for the given session.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete.
             * You must use an FFprobeSessionCompleteCallback if you want to be notified about the result.
             *
             * @param ffprobeSession FFprobe session which includes command options/arguments
             */
            static void asyncFFprobeExecute(const std::shared_ptr<ffmpegkit::FFprobeSession> ffprobeSession);

            /**
             * <p>Starts an asynchronous FFprobe execution for the given media information session.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete.
             * You must use an MediaInformationSessionCompleteCallback if you want to be notified about the result.
             *
             * @param mediaInformationSession media information session which includes command options/arguments
             * @param waitTimeout             max time to wait until media information is transmitted
             */
            static void asyncGetMediaInformationExecute(const std::shared_ptr<ffmpegkit::MediaInformationSession> mediaInformationSession, int waitTimeout);

            /**
             * <p>Sets a global log callback to redirect FFmpeg/FFprobe logs.
             *
             * @param logCallback log callback or nullptr to disable a previously defined log callback
             */
            static void enableLogCallback(const ffmpegkit::LogCallback logCallback);

            /**
             * <p>Sets a global statistics callback to redirect FFmpeg statistics.
             *
             * @param statisticsCallback statistics callback or nullptr to disable a previously defined statistics callback
             */
            static void enableStatisticsCallback(const ffmpegkit::StatisticsCallback statisticsCallback);

            /**
             * <p>Sets a global FFmpegSessionCompleteCallback to receive execution results for FFmpeg sessions.
             *
             * @param ffmpegSessionCompleteCallback complete callback or nullptr to disable a previously defined callback
             */
            static void enableFFmpegSessionCompleteCallback(const FFmpegSessionCompleteCallback ffmpegSessionCompleteCallback);

            /**
             * <p>Returns the global FFmpegSessionCompleteCallback set.
             *
             * @return global FFmpegSessionCompleteCallback or nullptr if it is not set
             */
            static FFmpegSessionCompleteCallback getFFmpegSessionCompleteCallback();

            /**
             * <p>Sets a global FFprobeSessionCompleteCallback to receive execution results for FFprobe sessions.
             *
             * @param ffprobeSessionCompleteCallback complete callback or nullptr to disable a previously defined callback
             */
            static void enableFFprobeSessionCompleteCallback(const FFprobeSessionCompleteCallback ffprobeSessionCompleteCallback);

            /**
             * <p>Returns the global FFprobeSessionCompleteCallback set.
             *
             * @return global FFprobeSessionCompleteCallback or nullptr if it is not set
             */
            static FFprobeSessionCompleteCallback getFFprobeSessionCompleteCallback();

            /**
             * <p>Sets a global MediaInformationSessionCompleteCallback to receive execution results for MediaInformation sessions.
             *
             * @param mediaInformationSessionCompleteCallback complete callback or nullptr to disable a previously defined
             * callback
             */
            static void enableMediaInformationSessionCompleteCallback(const MediaInformationSessionCompleteCallback mediaInformationSessionCompleteCallback);

            /**
             * <p>Returns the global MediaInformationSessionCompleteCallback set.
             *
             * @return global MediaInformationSessionCompleteCallback or nullptr if it is not set
             */
            static MediaInformationSessionCompleteCallback getMediaInformationSessionCompleteCallback();

            /**
             * Returns the current log level.
             *
             * @return current log level
             */
            static ffmpegkit::Level getLogLevel();

            /**
             * Sets the log level.
             *
             * @param level new log level
             */
            static void setLogLevel(const ffmpegkit::Level level);

            /**
             * Converts log level to string.
             *
             * @param level value
             * @return string value
             */
            static std::string logLevelToString(const ffmpegkit::Level level);

            /**
             * Returns the session history size.
             *
             * @return session history size
             */
            static int getSessionHistorySize();

            /**
             * Sets the session history size.
             *
             * @param sessionHistorySize session history size, should be smaller than 1000
             */
            static void setSessionHistorySize(const int sessionHistorySize);

            /**
             * Returns the session specified with <code>sessionId</code> from the session history.
             *
             * @param sessionId session identifier
             * @return session specified with sessionId or nullptr if it is not found in the history
             */
            static std::shared_ptr<ffmpegkit::Session> getSession(const long sessionId);

            /**
             * Returns the last session created from the session history.
             *
             * @return the last session created or nullptr if session history is empty
             */
            static std::shared_ptr<ffmpegkit::Session> getLastSession();

            /**
             * Returns the last session completed from the session history.
             *
             * @return the last session completed. If there are no completed sessions in the history this
             * method will return nullptr
             */
            static std::shared_ptr<ffmpegkit::Session> getLastCompletedSession();

            /**
             * <p>Returns all sessions in the session history.
             *
             * @return all sessions in the session history
             */
            static std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::Session>>> getSessions();

            /**
             * <p>Clears all, including ongoing, sessions in the session history.
             * <p>Note that callbacks cannot be triggered for deleted sessions.
             */
            static void clearSessions();

            /**
             * <p>Returns all FFmpeg sessions in the session history.
             *
             * @return all FFmpeg sessions in the session history
             */
            static std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::FFmpegSession>>> getFFmpegSessions();

            /**
             * <p>Returns all FFprobe sessions in the session history.
             *
             * @return all FFprobe sessions in the session history
             */
            static std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::FFprobeSession>>> getFFprobeSessions();

            /**
             * <p>Returns all MediaInformation sessions in the session history.
             *
             * @return all MediaInformation sessions in the session history
             */
            static std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::MediaInformationSession>>> getMediaInformationSessions();

            /**
             * <p>Returns sessions that have the given state.
             *
             * @return sessions that have the given state from the session history
             */
            static std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::Session>>> getSessionsByState(const SessionState state);

            /**
             * Returns the active log redirection strategy.
             *
             * @return log redirection strategy
             */
            static LogRedirectionStrategy getLogRedirectionStrategy();

            /**
             * <p>Sets the log redirection strategy
             *
             * @param logRedirectionStrategy log redirection strategy
             */
            static void setLogRedirectionStrategy(const LogRedirectionStrategy logRedirectionStrategy);

            /**
             * <p>Returns the number of async messages that are not transmitted to the callbacks for
             * this session.
             *
             * @param sessionId id of the session
             * @return number of async messages that are not transmitted to the callbacks for this session
             */
            static int messagesInTransmit(const long sessionId);

            /**
             * Converts session state to string.
             *
             * @param state session state
             * @return string value
             */
            static std::string sessionStateToString(SessionState state);

            /**
             * <p>Parses the given command into arguments. Uses space character to split the arguments.
             * Supports single and double quote characters.
             *
             * @param command string command
             * @return list of arguments
             */
            static std::list<std::string> parseArguments(const std::string& command);

            /**
             * <p>Concatenates arguments into a string adding a space character between two arguments.
             *
             * @param arguments arguments
             * @return concatenated string containing all arguments
             */
            static std::string argumentsToString(std::shared_ptr<std::list<std::string>> arguments);

    };

}

#endif // FFMPEG_KIT_CONFIG_H
