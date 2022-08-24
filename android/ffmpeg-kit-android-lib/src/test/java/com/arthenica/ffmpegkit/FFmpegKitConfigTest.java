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

import static com.arthenica.ffmpegkit.FFmpegSessionTest.TEST_ARGUMENTS;

import org.junit.Assert;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * <p>Tests for {@link FFmpegKitConfig} class.
 */
public class FFmpegKitConfigTest {

    private static final String externalLibrariesCommandOutput = "   configuration:\n" +
            "                          --cross-prefix=i686-linux-android-\n" +
            "                          --sysroot=/Users/taner/Library/Android/sdk/ndk-bundle/toolchains/ffmpeg-kit-i686/sysroot\n" +
            "                          --prefix=/Users/taner/Projects/ffmpeg-kit/prebuilt/android-x86/ffmpeg\n" +
            "                          --pkg-config=/usr/local/bin/pkg-config --extra-cflags='-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32 -Wno-unused-function -fstrict-aliasing -fPIC -DANDROID -D__ANDROID__ -D__ANDROID_API__=21 -O2 -I/Users/taner/Library/Android/sdk/ndk-bundle/toolchains/ffmpeg-kit-i686/sysroot/usr/include -I/Users/taner/Library/Android/sdk/ndk-bundle/toolchains/ffmpeg-kit-i686/sysroot/usr/local/include'\n" +
            "                          --extra-cxxflags='-std=c++11 -fno-exceptions -fno-rtti'\n" +
            "                          --extra-ldflags='-march=i686 -Wl,--gc-sections,--icf=safe -lc -lm -ldl -llog -lc++_shared -L/Users/taner/Library/Android/sdk/ndk-bundle/toolchains/ffmpeg-kit-i686/i686-linux-android/lib -L/Users/taner/Library/Android/sdk/ndk-bundle/toolchains/ffmpeg-kit-i686/sysroot/usr/lib -L/Users/taner/Library/Android/sdk/ndk-bundle/toolchains/ffmpeg-kit-i686/lib -L/Users/taner/Library/Android/sdk/ndk-bundle/platforms/android-21/arch-x86/usr/lib'\n" +
            "                          --enable-version3\n" +
            "                          --arch=i686\n" +
            "                          --cpu=i686\n" +
            "                          --target-os=android\n" +
            "                          --disable-neon\n" +
            "                          --disable-asm\n" +
            "                          --disable-inline-asm\n" +
            "                          --enable-cross-compile\n" +
            "                          --enable-pic\n" +
            "                          --enable-jni\n" +
            "                          --enable-libvorbis\n" +
            "                          --enable-optimizations\n" +
            "                          --enable-swscale\n" +
            "                          --enable-shared\n" +
            "                          --enable-v4l2-m2m\n" +
            "                          --enable-small\n" +
            "                          --disable-openssl\n" +
            "                          --disable-xmm-clobber-test\n" +
            "                          --disable-debug\n" +
            "                          --disable-neon-clobber-test\n" +
            "                          --disable-programs\n" +
            "                          --disable-postproc\n" +
            "                          --disable-doc\n" +
            "                          --disable-htmlpages\n" +
            "                          --disable-manpages\n" +
            "                          --disable-podpages\n" +
            "                          --disable-txtpages\n" +
            "                          --disable-static\n" +
            "                          --disable-sndio\n" +
            "                          --disable-schannel\n" +
            "                          --disable-securetransport\n" +
            "                          --disable-xlib\n" +
            "                          --disable-cuda\n" +
            "                          --disable-cuvid\n" +
            "                          --disable-nvenc\n" +
            "                          --disable-vaapi\n" +
            "                          --disable-vdpau\n" +
            "                          --disable-videotoolbox\n" +
            "                          --disable-audiotoolbox\n" +
            "                          --disable-appkit\n" +
            "                          --disable-alsa\n" +
            "                          --disable-cuda\n" +
            "                          --disable-cuvid\n" +
            "                          --disable-nvenc\n" +
            "                          --disable-vaapi\n" +
            "                          --disable-vdpau\n" +
            "                          --disable-zlib\n";

    @Test
    public void getExternalLibraries() {

        final List<String> supportedExternalLibraries = new ArrayList<>();
        supportedExternalLibraries.add("chromaprint");
        supportedExternalLibraries.add("dav1d");
        supportedExternalLibraries.add("fontconfig");
        supportedExternalLibraries.add("freetype");
        supportedExternalLibraries.add("fribidi");
        supportedExternalLibraries.add("gmp");
        supportedExternalLibraries.add("gnutls");
        supportedExternalLibraries.add("kvazaar");
        supportedExternalLibraries.add("lame");
        supportedExternalLibraries.add("libaom");
        supportedExternalLibraries.add("libass");
        supportedExternalLibraries.add("libiconv");
        supportedExternalLibraries.add("libilbc");
        supportedExternalLibraries.add("libtheora");
        supportedExternalLibraries.add("libvidstab");
        supportedExternalLibraries.add("libvorbis");
        supportedExternalLibraries.add("libvpx");
        supportedExternalLibraries.add("libwebp");
        supportedExternalLibraries.add("libxml2");
        supportedExternalLibraries.add("opencore-amr");
        supportedExternalLibraries.add("opus");
        supportedExternalLibraries.add("shine");
        supportedExternalLibraries.add("sdl");
        supportedExternalLibraries.add("snappy");
        supportedExternalLibraries.add("soxr");
        supportedExternalLibraries.add("speex");
        supportedExternalLibraries.add("tesseract");
        supportedExternalLibraries.add("twolame");
        supportedExternalLibraries.add("x264");
        supportedExternalLibraries.add("x265");
        supportedExternalLibraries.add("xvidcore");
        supportedExternalLibraries.add("android-zlib");
        supportedExternalLibraries.add("android-media-codec");


        final List<String> enabledList = new ArrayList<>();
        for (String supportedExternalLibrary : supportedExternalLibraries) {
            if (externalLibrariesCommandOutput.contains("enable-" + supportedExternalLibrary) ||
                    externalLibrariesCommandOutput.contains("enable-lib" + supportedExternalLibrary)) {
                enabledList.add(supportedExternalLibrary);
            }
        }

        Collections.sort(enabledList);

        Assert.assertNotNull(enabledList);
        Assert.assertEquals(1, enabledList.size());
    }

    @Test
    public void getPackageName() {
        Assert.assertEquals("min", listToPackageName(Collections.singletonList("")));
        Assert.assertEquals("min-gpl", listToPackageName(Collections.singletonList("xvidcore")));
        Assert.assertEquals("full-gpl", listToPackageName(Arrays.asList("gnutls", "speex", "fribidi", "xvidcore")));
        Assert.assertEquals("full", listToPackageName(Arrays.asList("fribidi", "speex")));
        Assert.assertEquals("video", listToPackageName(Collections.singletonList("fribidi")));
        Assert.assertEquals("audio", listToPackageName(Collections.singletonList("speex")));
        Assert.assertEquals("https", listToPackageName(Collections.singletonList("gnutls")));
        Assert.assertEquals("https-gpl", listToPackageName(Arrays.asList("gnutls", "xvidcore")));
    }

    @Test
    public void extractExtensionFromSafDisplayName() {
        String extension = FFmpegKitConfig.extractExtensionFromSafDisplayName("video.mp4 (2)");
        Assert.assertEquals("mp4", extension);

        extension = FFmpegKitConfig.extractExtensionFromSafDisplayName("video file name.mp3 (2)");
        Assert.assertEquals("mp3", extension);

        extension = FFmpegKitConfig.extractExtensionFromSafDisplayName("file.mp4");
        Assert.assertEquals("mp4", extension);

        extension = FFmpegKitConfig.extractExtensionFromSafDisplayName("file name.mp4");
        Assert.assertEquals("mp4", extension);
    }

    @Test
    public void setSessionHistorySize() {
        int newSize = 15;
        FFmpegKitConfig.setSessionHistorySize(newSize);

        for (int i = 1; i <= (newSize + 5); i++) {
            FFmpegSession.create(TEST_ARGUMENTS);
            Assert.assertTrue(FFmpegKitConfig.getSessions().size() <= newSize);
        }

        newSize = 3;
        FFmpegKitConfig.setSessionHistorySize(newSize);
        for (int i = 1; i <= (newSize + 5); i++) {
            FFmpegSession.create(TEST_ARGUMENTS);
            Assert.assertTrue(FFmpegKitConfig.getSessions().size() <= newSize);
        }
    }

    private String listToPackageName(final List<String> externalLibraryList) {
        boolean speex = externalLibraryList.contains("speex");
        boolean fribidi = externalLibraryList.contains("fribidi");
        boolean gnutls = externalLibraryList.contains("gnutls");
        boolean xvidcore = externalLibraryList.contains("xvidcore");

        if (speex && fribidi) {
            if (xvidcore) {
                return "full-gpl";
            } else {
                return "full";
            }
        } else if (speex) {
            return "audio";
        } else if (fribidi) {
            return "video";
        } else if (xvidcore) {
            if (gnutls) {
                return "https-gpl";
            } else {
                return "min-gpl";
            }
        } else {
            if (gnutls) {
                return "https";
            } else {
                return "min";
            }
        }
    }

}
