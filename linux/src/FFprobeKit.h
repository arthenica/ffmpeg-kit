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

#ifndef FFPROBE_KIT_H
#define FFPROBE_KIT_H

#include <string.h>
#include <stdlib.h>
#include "FFprobeSession.h"
#include "MediaInformationJsonParser.h"
#include "MediaInformationSession.h"

namespace ffmpegkit {

    /**
     * <p>Main class to run <code>FFprobe</code> commands. Supports executing commands both synchronously and
     * asynchronously.
     * <pre>
     * auto session = FFprobeKit::execute("-hide_banner -v error -show_entries format=size -of default=noprint_wrappers=1 file1.mp4");
     *
     * auto asyncSession = FFprobeKit::executeAsync("-hide_banner -v error -show_entries format=size -of default=noprint_wrappers=1 file1.mp4", [](auto session){ ... });
     * </pre>
     * <p>Provides overloaded <code>execute</code> methods to define session specific callbacks.
     * <pre>
     * auto session = FFprobeKit::executeAsync("-hide_banner -v error -show_entries format=size -of default=noprint_wrappers=1 file1.mp4", [](auto session){ ... }, [](auto log){ ... }];
     * </pre>
     * <p>It can extract media information for a file or a url, using getMediaInformation method.
     * <pre>
     * auto session = FFprobeKit::getMediaInformation("file1.mp4");
     * </pre>
     */
    class FFprobeKit {
        public:

            /**
             * <p>Synchronously executes FFprobe with arguments provided.
             *
             * @param arguments FFprobe command options/arguments as string array
             * @return FFprobe session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> executeWithArguments(const std::list<std::string>& arguments);

            /**
             * <p>Starts an asynchronous FFprobe execution with arguments provided.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete.
             * You must use an FFprobeSessionCompleteCallback if you want to be notified about the result.
             *
             * @param arguments        FFprobe command options/arguments as string array
             * @param completeCallback callback that will be called when the execution has completed
             * @return FFprobe session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> executeWithArgumentsAsync(const std::list<std::string>& arguments, FFprobeSessionCompleteCallback completeCallback);

            /**
             * <p>Starts an asynchronous FFprobe execution with arguments provided.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete.
             * You must use an FFprobeSessionCompleteCallback if you want to be notified about the result.
             *
             * @param arguments        FFprobe command options/arguments as string array
             * @param completeCallback callback that will be notified when execution has completed
             * @param logCallback      callback that will receive logs
             * @return FFprobe session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> executeWithArgumentsAsync(const std::list<std::string>& arguments, FFprobeSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback);

            /**
             * <p>Synchronously executes FFprobe command provided. Space character is used to split command
             * into arguments. You can use single or double quote characters to specify arguments inside
             * your command.
             *
             * @param command FFprobe command
             * @return FFprobe session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> execute(const std::string command);

            /**
             * <p>Starts an asynchronous FFprobe execution for the given command. Space character is used to split the command
             * into arguments. You can use single or double quote characters to specify arguments inside your command.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
             * FFprobeSessionCompleteCallback if you want to be notified about the result.
             *
             * @param command          FFprobe command
             * @param completeCallback callback that will be called when the execution has completed
             * @return FFprobe session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> executeAsync(const std::string command, FFprobeSessionCompleteCallback completeCallback);

            /**
             * <p>Starts an asynchronous FFprobe execution for the given command. Space character is used to split the command
             * into arguments. You can use single or double quote characters to specify arguments inside your command.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
             * FFprobeSessionCompleteCallback if you want to be notified about the result.
             *
             * @param command          FFprobe command
             * @param completeCallback callback that will be notified when execution has completed
             * @param logCallback      callback that will receive logs
             * @return FFprobe session created for this execution
             */
            static std::shared_ptr<ffmpegkit::FFprobeSession> executeAsync(const std::string command, FFprobeSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback);

            /**
             * <p>Extracts media information for the file specified with path.
             *
             * @param path path or uri of a media file
             * @return media information session created for this execution
             */
            static std::shared_ptr<ffmpegkit::MediaInformationSession> getMediaInformation(const std::string path);

            /**
             * <p>Extracts media information for the file specified with path.
             *
             * @param path        path or uri of a media file
             * @param waitTimeout max time to wait until media information is transmitted
             * @return media information session created for this execution
             */
            static std::shared_ptr<ffmpegkit::MediaInformationSession> getMediaInformation(const std::string path, const int waitTimeout);

            /**
             * <p>Starts an asynchronous FFprobe execution to extract the media information for the specified file.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
             * MediaInformationSessionCompleteCallback if you want to be notified about the result.
             *
             * @param path             path or uri of a media file
             * @param completeCallback callback that will be called when the execution has completed
             * @return media information session created for this execution
             */
            static std::shared_ptr<ffmpegkit::MediaInformationSession> getMediaInformationAsync(const std::string path, MediaInformationSessionCompleteCallback completeCallback);

            /**
             * <p>Starts an asynchronous FFprobe execution to extract the media information for the specified file.
             *
             * <p>Note that this method returns immediately and does not wait the execution to complete. You must use an
             * MediaInformationSessionCompleteCallback if you want to be notified about the result.
             *
             * @param path             path or uri of a media file
             * @param completeCallback callback that will be notified when execution has completed
             * @param logCallback      callback that will receive logs
             * @param waitTimeout      max time to wait until media information is transmitted
             * @return media information session created for this execution
             */
            static std::shared_ptr<ffmpegkit::MediaInformationSession> getMediaInformationAsync(const std::string path, MediaInformationSessionCompleteCallback completeCallback, ffmpegkit::LogCallback logCallback, const int waitTimeout);

            /**
             * <p>Extracts media information using the command provided asynchronously.
             *
             * @param command FFprobe command that prints media information for a file in JSON format
             * @return media information session created for this execution
             */
            static std::shared_ptr<ffmpegkit::MediaInformationSession> getMediaInformationFromCommand(const std::string command);

            /**
             * <p>Lists all FFprobe sessions in the session history.
             *
             * @return all FFprobe sessions in the session history
             */
            static std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::FFprobeSession>>> listFFprobeSessions();

            /**
             * <p>Lists all MediaInformation sessions in the session history.
             *
             * @return all MediaInformation sessions in the session history
             */
            static std::shared_ptr<std::list<std::shared_ptr<ffmpegkit::MediaInformationSession>>> listMediaInformationSessions();

    };

}

#endif // FFPROBE_KIT_H
