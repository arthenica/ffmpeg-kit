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

#ifndef FFMPEG_KIT_H
#define FFMPEG_KIT_H

#include <string.h>
#include <stdlib.h>
#include "LogCallback.h"
#include "FFmpegSession.h"
#include "StatisticsCallback.h"

namespace ffmpegkit {

    /**
     * <p>Main class to run <code>FFmpeg</code> commands. Supports executing commands both synchronously and
     * asynchronously.
     * <pre>
     * auto session = FFmpegKit::execute:("-i file1.mp4 -c:v libxvid file1.avi");
     *
     * auto asyncSession = FFmpegKit::executeAsync:("-i file1.mp4 -c:v libxvid file1.avi", [](auto session){ ... });
     * </pre>
     * <p>Provides overloaded <code>execute</code> methods to define session specific callbacks.
     * <pre>
     * auto asyncSession = FFmpegKit::executeAsync:("-i file1.mp4 -c:v libxvid file1.avi, [](auto session){ ... }, [](auto log){ ... }, [](auto statistics){ ... });
     * </pre>
     */
    class FFmpegKit {
        public:

            /**
             * <p>Synchronously executes FFmpeg with arguments provided.
             *
             * @param arguments FFmpeg command options/arguments as string list
             * @return FFmpeg session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFmpegSession> executeWithArguments(const std::list<std::string>& arguments);

            /**
             * <p>Starts an asynchronous FFmpeg execution with arguments provided.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete.
             * You must use an FFmpegSessionCompleteCallback if you want to be notified about the result.
             *
             * @param arguments        FFmpeg command options/arguments as string list
             * @param completeCallback callback that will be called when the execution has completed
             * @return FFmpeg session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFmpegSession> executeWithArgumentsAsync(const std::list<std::string>& arguments, FFmpegSessionCompleteCallback completeCallback);

            /**
             * <p>Starts an asynchronous FFmpeg execution with arguments provided.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete.
             * You must use an FFmpegSessionCompleteCallback if you want to be notified about the result.
             *
             * @param arguments           FFmpeg command options/arguments as string list
             * @param completeCallback    callback that will be called when the execution has completed
             * @param logCallback         callback that will receive logs
             * @param statisticsCallback  callback that will receive statistics
             * @return FFmpeg session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFmpegSession> executeWithArgumentsAsync(const std::list<std::string>& arguments, FFmpegSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, ffmpegkit::StatisticsCallback statisticsCallback);

            /**
             * <p>Synchronously executes FFmpeg command provided. Space character is used to split command
             * into arguments. You can use single or double quote characters to specify arguments inside
             * your command.
             *
             * @param command FFmpeg command
             * @return FFmpeg session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFmpegSession> execute(const std::string command);

            /**
             * <p>Starts an asynchronous FFmpeg execution for the given command. Space character is used to split the command
             * into arguments. You can use single or double quote characters to specify arguments inside your command.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
             * FFmpegSessionCompleteCallback if you want to be notified about the result.
             *
             * @param command          FFmpeg command
             * @param completeCallback callback that will be called when the execution has completed
             * @return FFmpeg session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFmpegSession> executeAsync(const std::string command, FFmpegSessionCompleteCallback completeCallback);

            /**
             * <p>Starts an asynchronous FFmpeg execution for the given command. Space character is used to split the command
             * into arguments. You can use single or double quote characters to specify arguments inside your command.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
             * FFmpegSessionCompleteCallback if you want to be notified about the result.
             *
             * @param command             FFmpeg command
             * @param completeCallback    callback that will be called when the execution has completed
             * @param logCallback         callback that will receive logs
             * @param statisticsCallback  callback that will receive statistics
             * @return FFmpeg session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFmpegSession> executeAsync(const std::string command, FFmpegSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, ffmpegkit::StatisticsCallback statisticsCallback);

            /**
             * <p>Cancels all running sessions.
             *
             * <p>This method does not wait for termination to complete and returns immediately.
             */
            static void cancel();

            /**
             * <p>Cancels the session specified with <code>sessionId</code>.
             *
             * <p>This method does not wait for termination to complete and returns immediately.
             *
             * @param sessionId id of the session that will be cancelled
             */
            static void cancel(const long sessionId);

            /**
             * <p>Lists all FFmpeg sessions in the session history.
             *
             * @return all FFmpeg sessions in the session history
             */
            static std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::FFmpegSession>>> listSessions();

    };

}

#endif // FFMPEG_KIT_H
