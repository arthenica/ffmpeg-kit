/*
 * Copyright (c) 2022 Taner Sener
 *
 * This file is part of FFmpegKit.
 *
 * FFmpegKit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FFmpegKit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General License for more details.
 *
 *  You should have received a copy of the GNU Lesser General License
 *  along with FFmpegKit.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef FFMPEG_KIT_ABSTRACT_SESSION_H
#define FFMPEG_KIT_ABSTRACT_SESSION_H

#include "Session.h"

namespace ffmpegkit {

    /**
     * Abstract session implementation which includes common features shared by <code>FFmpeg</code>,
     * <code>FFprobe</code> and <code>MediaInformation</code> sessions.
     */
    class AbstractSession : public Session, std::enable_shared_from_this<AbstractSession> {
        public:

            /**
             * Defines how long default "getAll" methods wait, in milliseconds.
             */
            static constexpr int DefaultTimeoutForAsynchronousMessagesInTransmit = 5000;

            /**
             * Creates a new abstract session.
             *
             * @param arguments              command arguments
             * @param logCallback            session specific log callback
             * @param logRedirectionStrategy session specific log redirection strategy
             */
            AbstractSession(const std::list<std::string>& arguments, const ffmpegkit::LogCallback logCallback, const LogRedirectionStrategy logRedirectionStrategy);

            /**
             * Waits for all asynchronous messages to be transmitted until the given timeout.
             *
             * @param timeout wait timeout in milliseconds
             */
            void waitForAsynchronousMessagesInTransmit(const int timeout) const;

            /**
             * Returns the session specific log callback.
             *
             * @return session specific log callback
             */
            ffmpegkit::LogCallback getLogCallback() const override;

            /**
             * Returns the session identifier.
             *
             * @return session identifier
             */
            long getSessionId() const override;

            /**
             * Returns session create time.
             *
             * @return session create time
             */
            std::chrono::time_point<std::chrono::system_clock> getCreateTime() const override;

            /**
             * Returns session start time.
             *
             * @return session start time
             */
            std::chrono::time_point<std::chrono::system_clock> getStartTime() const override;

            /**
             * Returns session end time.
             *
             * @return session end time
             */
            std::chrono::time_point<std::chrono::system_clock> getEndTime() const override;

            /**
             * Returns the time taken to execute this session.
             *
             * @return time taken to execute this session in milliseconds or zero (0) if the session is
             * not over yet
             */
            long getDuration() const override;

            /**
             * Returns command arguments as a list.
             *
             * @return command arguments as a list
             */
            std::shared_ptr<std::list<std::string>> getArguments() const override;

            /**
             * Returns command arguments as a concatenated string.
             *
             * @return command arguments as a concatenated string
             */
            std::string getCommand() const override;

            /**
             * Returns all log entries generated for this session. If there are asynchronous
             * messages that are not delivered yet, this method waits for them until the given timeout.
             *
             * @param waitTimeout wait timeout for asynchronous messages in milliseconds
             * @return list of log entries generated for this session
             */
            std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::Log>>> getAllLogsWithTimeout(const int waitTimeout) const override;

            /**
             * Returns all log entries generated for this session. If there are asynchronous
             * messages that are not delivered yet, this method waits for them.
             *
             * @return list of log entries generated for this session
             */
            std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::Log>>> getAllLogs() const override;

            /**
             * Returns all log entries delivered for this session. Note that if there are asynchronous
             * messages that are not delivered yet, this method will not wait for them and will return
             * immediately.
             *
             * @return list of log entries received for this session
             */
            std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::Log>>> getLogs() const override;

            /**
             * Returns all log entries generated for this session as a concatenated string. If there are
             * asynchronous messages that are not delivered yet, this method waits for them until
             * the given timeout.
             *
             * @param waitTimeout wait timeout for asynchronous messages in milliseconds
             * @return all log entries generated for this session as a concatenated string
             */
            std::string getAllLogsAsStringWithTimeout(const int waitTimeout) const override;

            /**
             * Returns all log entries generated for this session as a concatenated string. If there are
             * asynchronous messages that are not delivered yet, this method waits for them.
             *
             * @return all log entries generated for this session as a concatenated string
             */
            std::string getAllLogsAsString() const override;

            /**
             * Returns all log entries delivered for this session as a concatenated string. Note that if
             * there are asynchronous messages that are not delivered yet, this method will not wait
             * for them and will return immediately.
             *
             * @return list of log entries received for this session
             */
            std::string getLogsAsString() const override;

            /**
             * Returns the log output generated while running the session.
             *
             * @return log output generated
             */
            std::string getOutput() const override;

            /**
             * Returns the state of the session.
             *
             * @return state of the session
             */
            ffmpegkit::SessionState getState() const override;

            /**
             * Returns the return code for this session. Note that return code is only set for sessions
             * that end with SessionStateCompleted state. If a session is not started, still running or failed then
             * this method returns nullptr.
             *
             * @return the return code for this session if the session has completed, nullptr if session is
             * not started, still running or failed
             */
            std::shared_ptr<ffmpegkit::ReturnCode> getReturnCode() const override;

            /**
             * Returns the stack trace of the exception received while executing this session.
             * <p>
             * The stack trace is only set for sessions that end with SessionStateFailed state. For sessions that has
             * SessionStateCompleted state this method returns an empty string.
             *
             * @return stack trace of the exception received while executing this session, an empty string if session
             * is not started, still running or completed
             */
            std::string getFailStackTrace() const override;

            /**
             * Returns session specific log redirection strategy.
             *
             * @return session specific log redirection strategy
             */
            ffmpegkit::LogRedirectionStrategy getLogRedirectionStrategy() const override;

            /**
             * Returns whether there are still asynchronous messages being transmitted for this
             * session or not.
             *
             * @return true if there are still asynchronous messages being transmitted, false
             * otherwise
             */
            bool thereAreAsynchronousMessagesInTransmit() const override;

            /**
             * Adds a new log entry for this session.
             *
             * It is invoked internally by <code>FFmpegKit</code> library methods. Must not be used by user
             * applications.
             *
             * @param log log entry
             */
            void addLog(const std::shared_ptr<ffmpegkit::Log> log) override;

            /**
             * Starts running the session.
             */
            void startRunning() override;

            /**
             * Completes running the session with the provided return code.
             *
             * @param returnCode return code of the execution
             */
            void complete(const std::shared_ptr<ffmpegkit::ReturnCode> returnCode) override;

            /**
             * Ends running the session with a failure.
             *
             * @param error error received
             */
            void fail(const char* error) override;

            /**
             * Returns whether it is an <code>FFmpeg</code> session or not.
             *
             * @return true if it is an <code>FFmpeg</code> session, false otherwise
             */
            virtual bool isFFmpeg() const override;

            /**
             * Returns whether it is an <code>FFprobe</code> session or not.
             *
             * @return true if it is an <code>FFprobe</code> session, false otherwise
             */
            virtual bool isFFprobe() const override;

            /**
             * Returns whether it is a <code>MediaInformation</code> session or not.
             *
             * @return true if it is a <code>MediaInformation</code> session, false otherwise
             */
            virtual bool isMediaInformation() const override;

            /**
             * Cancels running the session.
             */
            void cancel() override;

        private:
            const long _sessionId;
            ffmpegkit::LogCallback _logCallback;
            std::chrono::time_point<std::chrono::system_clock> _createTime;
            std::chrono::time_point<std::chrono::system_clock> _startTime;
            std::chrono::time_point<std::chrono::system_clock> _endTime;
            std::shared_ptr<std::list<std::string>> _arguments;
            std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::Log>>> _logs;
            SessionState _state;
            std::shared_ptr<ffmpegkit::ReturnCode> _returnCode;
            std::string _failStackTrace;
            LogRedirectionStrategy _logRedirectionStrategy;
    };

}

#endif // FFMPEG_KIT_ABSTRACT_SESSION_H
