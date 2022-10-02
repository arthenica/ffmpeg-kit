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

#include "Packages.h"
#include "config.h"
#include <memory>
#include <algorithm>

std::string ffmpegkit::Packages::getPackageName() {
    std::shared_ptr<std::set<std::string>> enabledLibrarySet = getExternalLibraries();
    #define contains_ext_lib(element) enabledLibrarySet->find(element) != enabledLibrarySet->end()
    bool speex = contains_ext_lib("speex");
    bool fribidi = contains_ext_lib("fribidi");
    bool gnutls = contains_ext_lib("gnutls");
    bool xvid = contains_ext_lib("xvid");

    bool min = false;
    bool minGpl = false;
    bool https = false;
    bool httpsGpl = false;
    bool audio = false;
    bool video = false;
    bool full = false;
    bool fullGpl = false;

    if (speex && fribidi) {
        if (xvid) {
            fullGpl = true;
        } else {
            full = true;
        }
    } else if (speex) {
        audio = true;
    } else if (fribidi) {
        video = true;
    } else if (xvid) {
        if (gnutls) {
            httpsGpl = true;
        } else {
            minGpl = true;
        }
    } else {
        if (gnutls) {
            https = true;
        } else {
            min = true;
        }
    }

    if (fullGpl) {
        if (contains_ext_lib("dav1d") &&
            contains_ext_lib("fontconfig") &&
            contains_ext_lib("freetype") &&
            contains_ext_lib("fribidi") &&
            contains_ext_lib("gmp") &&
            contains_ext_lib("gnutls") &&
            contains_ext_lib("kvazaar") &&
            contains_ext_lib("mp3lame") &&
            contains_ext_lib("libass") &&
            contains_ext_lib("iconv") &&
            contains_ext_lib("libilbc") &&
            contains_ext_lib("libtheora") &&
            contains_ext_lib("libvidstab") &&
            contains_ext_lib("libvorbis") &&
            contains_ext_lib("libvpx") &&
            contains_ext_lib("libwebp") &&
            contains_ext_lib("libxml2") &&
            contains_ext_lib("opencore-amr") &&
            contains_ext_lib("opus") &&
            contains_ext_lib("shine") &&
            contains_ext_lib("snappy") &&
            contains_ext_lib("soxr") &&
            contains_ext_lib("speex") &&
            contains_ext_lib("twolame") &&
            contains_ext_lib("x264") &&
            contains_ext_lib("x265") &&
            contains_ext_lib("xvid")) {
            return "full-gpl";
        } else {
            return "custom";
        }
    }

    if (full) {
        if (contains_ext_lib("dav1d") &&
            contains_ext_lib("fontconfig") &&
            contains_ext_lib("freetype") &&
            contains_ext_lib("fribidi") &&
            contains_ext_lib("gmp") &&
            contains_ext_lib("gnutls") &&
            contains_ext_lib("kvazaar") &&
            contains_ext_lib("mp3lame") &&
            contains_ext_lib("libass") &&
            contains_ext_lib("iconv") &&
            contains_ext_lib("libilbc") &&
            contains_ext_lib("libtheora") &&
            contains_ext_lib("libvorbis") &&
            contains_ext_lib("libvpx") &&
            contains_ext_lib("libwebp") &&
            contains_ext_lib("libxml2") &&
            contains_ext_lib("opencore-amr") &&
            contains_ext_lib("opus") &&
            contains_ext_lib("shine") &&
            contains_ext_lib("snappy") &&
            contains_ext_lib("soxr") &&
            contains_ext_lib("speex") &&
            contains_ext_lib("twolame")) {
            return "full";
        } else {
            return "custom";
        }
    }

    if (video) {
        if (contains_ext_lib("dav1d") &&
            contains_ext_lib("fontconfig") &&
            contains_ext_lib("freetype") &&
            contains_ext_lib("fribidi") &&
            contains_ext_lib("kvazaar") &&
            contains_ext_lib("libass") &&
            contains_ext_lib("iconv") &&
            contains_ext_lib("libtheora") &&
            contains_ext_lib("libvpx") &&
            contains_ext_lib("libwebp") &&
            contains_ext_lib("snappy")) {
            return "video";
        } else {
            return "custom";
        }
    }

    if (audio) {
        if (contains_ext_lib("mp3lame") &&
            contains_ext_lib("libilbc") &&
            contains_ext_lib("libvorbis") &&
            contains_ext_lib("opencore-amr") &&
            contains_ext_lib("opus") &&
            contains_ext_lib("shine") &&
            contains_ext_lib("soxr") &&
            contains_ext_lib("speex") &&
            contains_ext_lib("twolame")) {
            return "audio";
        } else {
            return "custom";
        }
    }

    if (httpsGpl) {
        if (contains_ext_lib("gmp") &&
            contains_ext_lib("gnutls") &&
            contains_ext_lib("libvidstab") &&
            contains_ext_lib("x264") &&
            contains_ext_lib("x265") &&
            contains_ext_lib("xvid")) {
            return "https-gpl";
        } else {
            return "custom";
        }
    }

    if (https) {
        if (contains_ext_lib("gmp") &&
            contains_ext_lib("gnutls")) {
            return "https";
        } else {
            return "custom";
        }
    }

    if (minGpl) {
        if (contains_ext_lib("libvidstab") &&
            contains_ext_lib("x264") &&
            contains_ext_lib("x265") &&
            contains_ext_lib("xvid")) {
            return "min-gpl";
        } else {
            return "custom";
        }
    }

    return "min";
}

std::shared_ptr<std::set<std::string>> ffmpegkit::Packages::getExternalLibraries() {
    const std::set<const char*> supportedExternalLibraries{
        "dav1d",
        "fontconfig",
        "freetype",
        "fribidi",
        "gmp",
        "gnutls",
        "kvazaar",
        "mp3lame",
        "libaom",
        "libass",
        "iconv",
        "libilbc",
        "libtheora",
        "libvidstab",
        "libvorbis",
        "libvpx",
        "libwebp",
        "libxml2",
        "opencore-amr",
        "openh264",
        "opus",
        "rubberband",
        "sdl2",
        "shine",
        "snappy",
        "soxr",
        "speex",
        "tesseract",
        "twolame",
        "x264",
        "x265",
        "xvid"};
    std::string buildConfiguration(FFMPEG_CONFIGURATION);
    char libraryName1[50];
    char libraryName2[50];
    std::shared_ptr<std::set<std::string>> enabledLibrarySet = std::make_shared<std::set<std::string>>();

    std::for_each(supportedExternalLibraries.cbegin(), supportedExternalLibraries.cend(), [&](const char* supportedExternalLibrary) {
        sprintf(libraryName1, "enable-%s", supportedExternalLibrary);
        sprintf(libraryName2, "enable-lib%s", supportedExternalLibrary);

        if (buildConfiguration.find(libraryName1) != std::string::npos || buildConfiguration.find(libraryName2) != std::string::npos) {
            enabledLibrarySet->insert(supportedExternalLibrary);
        }
    });

    return enabledLibrarySet;
}
