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

#ifndef FFMPEG_KIT_PACKAGES_H
#define FFMPEG_KIT_PACKAGES_H

#include <set>
#include <iostream>
#include <memory>
#include <string>

namespace ffmpegkit {

    /**
     * <p>Helper class to extract binary package information.
     */
    class Packages {
        public:

            /**
             * Returns the FFmpegKit binary package name.
             *
             * @return predicted FFmpegKit binary package name
             */
            static std::string getPackageName();

            /**
             * Returns enabled external libraries by FFmpeg.
             *
             * @return enabled external libraries
             */
            static std::shared_ptr<std::set<std::string>> getExternalLibraries();
    };

}

#endif // FFMPEG_KIT_PACKAGES_H
