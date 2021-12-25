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

package com.arthenica.ffmpegkit;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * <p>Helper class to extract binary package information.
 */
public class Packages {

    private static final List<String> supportedExternalLibraries;

    static {
        supportedExternalLibraries = new ArrayList<>();
        supportedExternalLibraries.add("dav1d");
        supportedExternalLibraries.add("fontconfig");
        supportedExternalLibraries.add("freetype");
        supportedExternalLibraries.add("fribidi");
        supportedExternalLibraries.add("gmp");
        supportedExternalLibraries.add("gnutls");
        supportedExternalLibraries.add("kvazaar");
        supportedExternalLibraries.add("mp3lame");
        supportedExternalLibraries.add("libass");
        supportedExternalLibraries.add("iconv");
        supportedExternalLibraries.add("libilbc");
        supportedExternalLibraries.add("libtheora");
        supportedExternalLibraries.add("libvidstab");
        supportedExternalLibraries.add("libvorbis");
        supportedExternalLibraries.add("libvpx");
        supportedExternalLibraries.add("libwebp");
        supportedExternalLibraries.add("libxml2");
        supportedExternalLibraries.add("opencore-amr");
        supportedExternalLibraries.add("openh264");
        supportedExternalLibraries.add("openssl");
        supportedExternalLibraries.add("opus");
        supportedExternalLibraries.add("rubberband");
        supportedExternalLibraries.add("sdl2");
        supportedExternalLibraries.add("shine");
        supportedExternalLibraries.add("snappy");
        supportedExternalLibraries.add("soxr");
        supportedExternalLibraries.add("speex");
        supportedExternalLibraries.add("srt");
        supportedExternalLibraries.add("tesseract");
        supportedExternalLibraries.add("twolame");
        supportedExternalLibraries.add("x264");
        supportedExternalLibraries.add("x265");
        supportedExternalLibraries.add("xvid");
        supportedExternalLibraries.add("zimg");
    }

    /**
     * Returns the FFmpegKit binary package name.
     *
     * @return predicted FFmpegKit binary package name
     */
    public static String getPackageName() {
        final List<String> externalLibraryList = getExternalLibraries();
        final boolean speex = externalLibraryList.contains("speex");
        final boolean fribidi = externalLibraryList.contains("fribidi");
        final boolean gnutls = externalLibraryList.contains("gnutls");
        final boolean xvid = externalLibraryList.contains("xvid");

        boolean minGpl = false;
        boolean https = false;
        boolean httpsGpl = false;
        boolean audio = false;
        boolean video = false;
        boolean full = false;
        boolean fullGpl = false;

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
            }
        }

        if (fullGpl) {
            if (externalLibraryList.contains("dav1d") &&
                    externalLibraryList.contains("fontconfig") &&
                    externalLibraryList.contains("freetype") &&
                    externalLibraryList.contains("fribidi") &&
                    externalLibraryList.contains("gmp") &&
                    externalLibraryList.contains("gnutls") &&
                    externalLibraryList.contains("kvazaar") &&
                    externalLibraryList.contains("mp3lame") &&
                    externalLibraryList.contains("libass") &&
                    externalLibraryList.contains("iconv") &&
                    externalLibraryList.contains("libilbc") &&
                    externalLibraryList.contains("libtheora") &&
                    externalLibraryList.contains("libvidstab") &&
                    externalLibraryList.contains("libvorbis") &&
                    externalLibraryList.contains("libvpx") &&
                    externalLibraryList.contains("libwebp") &&
                    externalLibraryList.contains("libxml2") &&
                    externalLibraryList.contains("opencore-amr") &&
                    externalLibraryList.contains("opus") &&
                    externalLibraryList.contains("shine") &&
                    externalLibraryList.contains("snappy") &&
                    externalLibraryList.contains("soxr") &&
                    externalLibraryList.contains("speex") &&
                    externalLibraryList.contains("twolame") &&
                    externalLibraryList.contains("x264") &&
                    externalLibraryList.contains("x265") &&
                    externalLibraryList.contains("xvid") &&
                    externalLibraryList.contains("zimg")) {
                return "full-gpl";
            } else {
                return "custom";
            }
        }

        if (full) {
            if (externalLibraryList.contains("dav1d") &&
                    externalLibraryList.contains("fontconfig") &&
                    externalLibraryList.contains("freetype") &&
                    externalLibraryList.contains("fribidi") &&
                    externalLibraryList.contains("gmp") &&
                    externalLibraryList.contains("gnutls") &&
                    externalLibraryList.contains("kvazaar") &&
                    externalLibraryList.contains("mp3lame") &&
                    externalLibraryList.contains("libass") &&
                    externalLibraryList.contains("iconv") &&
                    externalLibraryList.contains("libilbc") &&
                    externalLibraryList.contains("libtheora") &&
                    externalLibraryList.contains("libvorbis") &&
                    externalLibraryList.contains("libvpx") &&
                    externalLibraryList.contains("libwebp") &&
                    externalLibraryList.contains("libxml2") &&
                    externalLibraryList.contains("opencore-amr") &&
                    externalLibraryList.contains("opus") &&
                    externalLibraryList.contains("shine") &&
                    externalLibraryList.contains("snappy") &&
                    externalLibraryList.contains("soxr") &&
                    externalLibraryList.contains("speex") &&
                    externalLibraryList.contains("twolame") &&
                    externalLibraryList.contains("zimg")) {
                return "full";
            } else {
                return "custom";
            }
        }

        if (video) {
            if (externalLibraryList.contains("dav1d") &&
                    externalLibraryList.contains("fontconfig") &&
                    externalLibraryList.contains("freetype") &&
                    externalLibraryList.contains("fribidi") &&
                    externalLibraryList.contains("kvazaar") &&
                    externalLibraryList.contains("libass") &&
                    externalLibraryList.contains("iconv") &&
                    externalLibraryList.contains("libtheora") &&
                    externalLibraryList.contains("libvpx") &&
                    externalLibraryList.contains("libwebp") &&
                    externalLibraryList.contains("snappy") &&
                    externalLibraryList.contains("zimg")) {
                return "video";
            } else {
                return "custom";
            }
        }

        if (audio) {
            if (externalLibraryList.contains("mp3lame") &&
                    externalLibraryList.contains("libilbc") &&
                    externalLibraryList.contains("libvorbis") &&
                    externalLibraryList.contains("opencore-amr") &&
                    externalLibraryList.contains("opus") &&
                    externalLibraryList.contains("shine") &&
                    externalLibraryList.contains("soxr") &&
                    externalLibraryList.contains("speex") &&
                    externalLibraryList.contains("twolame")) {
                return "audio";
            } else {
                return "custom";
            }
        }

        if (httpsGpl) {
            if (externalLibraryList.contains("gmp") &&
                    externalLibraryList.contains("gnutls") &&
                    externalLibraryList.contains("libvidstab") &&
                    externalLibraryList.contains("x264") &&
                    externalLibraryList.contains("x265") &&
                    externalLibraryList.contains("xvid")) {
                return "https-gpl";
            } else {
                return "custom";
            }
        }

        if (https) {
            if (externalLibraryList.contains("gmp") &&
                    externalLibraryList.contains("gnutls")) {
                return "https";
            } else {
                return "custom";
            }
        }

        if (minGpl) {
            if (externalLibraryList.contains("libvidstab") &&
                    externalLibraryList.contains("x264") &&
                    externalLibraryList.contains("x265") &&
                    externalLibraryList.contains("xvid")) {
                return "min-gpl";
            } else {
                return "custom";
            }
        }

        if (externalLibraryList.size() == 0) {
            return "min";
        } else {
            return "custom";
        }
    }

    /**
     * Returns enabled external libraries by FFmpeg.
     *
     * @return enabled external libraries
     */
    public static List<String> getExternalLibraries() {
        final String buildConfiguration = AbiDetect.getNativeBuildConf();

        final List<String> enabledLibraryList = new ArrayList<>();
        for (String supportedExternalLibrary : supportedExternalLibraries) {
            if (buildConfiguration.contains("enable-" + supportedExternalLibrary) ||
                    buildConfiguration.contains("enable-lib" + supportedExternalLibrary)) {
                enabledLibraryList.add(supportedExternalLibrary);
            }
        }

        Collections.sort(enabledLibraryList);

        return enabledLibraryList;
    }

}
