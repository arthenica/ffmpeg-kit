# FFmpegKit

## Notice
FFmpegKit has been officially retired. There will be no further `ffmpeg-kit` releases. All previously released `ffmpeg-kit` binaries will be removed according to the following schedule. Thank you for your support and interest in this project.

Thank you for your support and contributions over the course of this project.

| FFmpegKit Version |  Available Until   |
|:-----------------:|:------------------:|
|   Less than 6.0   | February 1st, 2025 |
|        6.0        |  April 1st, 2025   |

<img src="https://github.com/arthenica/ffmpeg-kit/raw/main/docs/assets/ffmpeg-kit-icon-v9.png" width="180">

`FFmpegKit` is a collection of tools to use `FFmpeg` in `Android`, `iOS`, `Linux`, `macOS`, `tvOS`, `Flutter` and `React Native` applications.

It includes scripts to build `FFmpeg` native libraries, a wrapper library to run `FFmpeg`/`FFprobe` commands in
applications and 8 prebuilt binary packages available at [Github](https://github.com/arthenica/ffmpeg-kit/releases),
[Maven Central](https://search.maven.org), [CocoaPods](https://cocoapods.org), [pub](https://pub.dev) and [npm](https://www.npmjs.com).

### 1. Features
- Scripts to build FFmpeg native libraries
- `FFmpegKit` wrapper library to run `FFmpeg`/`FFprobe` commands in applications
- Supports native platforms: Android, iOS, Linux, macOS and tvOS
- Supports hybrid platforms: Flutter, React Native
- Based on FFmpeg `v4.5-dev` or later with optional system and external libraries
- 8 prebuilt binary packages available at [Github](https://github.com/arthenica/ffmpeg-kit/releases), [Maven Central](https://search.maven.org), [CocoaPods](https://cocoapods.org), [pub](https://pub.dev) and [npm](https://www.npmjs.com)
- Licensed under `LGPL 3.0` by default, some packages licensed by `GPL v3.0` effectively

### 2. Android

See [Android](https://github.com/arthenica/ffmpeg-kit/tree/development/android) to learn more about `FFmpegKit` for
`Android`.

### 3. iOS, macOS, tvOS

See [Apple](https://github.com/arthenica/ffmpeg-kit/tree/development/apple) to use `FFmpegKit` on `Apple` platforms
(`iOS`, `macOS`, `tvOS`).

### 4. Flutter

See [Flutter](https://github.com/arthenica/ffmpeg-kit/tree/main/flutter/flutter) to learn more about `FFmpegKit` for
`Flutter`.

### 5. Linux

See [Linux](https://github.com/arthenica/ffmpeg-kit/tree/main/linux) to learn more about `FFmpegKit` for
`Linux`.

### 6. React Native

See [React Native](https://github.com/arthenica/ffmpeg-kit/tree/main/react-native) to learn more about `FFmpegKit` for
`React Native`.

### 7. Build Scripts

Use `android.sh`, `ios.sh`, `linux.sh`, `macos.sh` and `tvos.sh` to build `FFmpegKit` for each native platform.

All scripts support additional options to enable optional libraries and disable platform architectures. See
[Building](https://github.com/arthenica/ffmpeg-kit/wiki/Building) wiki page for the details.

### 8. FFmpegKit Library

`FFmpegKit` is a wrapper library that allows you to easily run `FFmpeg`/`FFprobe` commands in applications. It
provides additional features on top of `FFmpeg` to enable platform specific resources, control how commands are
executed and how the results are handled.

`Android` library of `FFmpegKit` has a `Java` API, `Apple` libraries (`iOS`, `macOS`, `tvOS`) have an `Objective-C`
API, `Flutter` library comes with a `Dart` API, `Linux` library has a `C++` API and `React Native` library provides
a `JavaScript` API with `Typescript` definitions, which are identical in terms of features and capabilities.

### 9. Packages

There are eight different `ffmpeg-kit` packages distributed on
[Github](https://github.com/arthenica/ffmpeg-kit/releases),
[Maven Central](https://search.maven.org), [CocoaPods](https://cocoapods.org), [pub](https://pub.dev) and
[npm](https://www.npmjs.com).
Below you can see which system libraries and external libraries are enabled in each one of them.

Please remember that some parts of `FFmpeg` are licensed under the `GPL` and only `GPL` licensed `ffmpeg-kit` packages
include them.

<table>
<thead>
<tr>
<th align="center"></th>
<th align="center"><sup>min</sup></th>
<th align="center"><sup>min-gpl</sup></th>
<th align="center"><sup>https</sup></th>
<th align="center"><sup>https-gpl</sup></th>
<th align="center"><sup>audio</sup></th>
<th align="center"><sup>video</sup></th>
<th align="center"><sup>full</sup></th>
<th align="center"><sup>full-gpl</sup></th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><sup>external libraries</sup></td>
<td align="center">-</td>
<td align="center"><sup>vid.stab</sup><br><sup>x264</sup><br><sup>x265</sup><br><sup>xvidcore</sup></td>
<td align="center"><sup>gmp</sup><br><sup>gnutls</sup></td>
<td align="center"><sup>gmp</sup><br><sup>gnutls</sup><br><sup>vid.stab</sup><br><sup>x264</sup><br><sup>x265</sup><br><sup>xvidcore</sup></td>
<td align="center"><sup>lame</sup><br><sup>libilbc</sup><br><sup>libvorbis</sup><br><sup>opencore-amr</sup><br><sup>opus</sup><br><sup>shine</sup><br><sup>soxr</sup><br><sup>speex</sup><br><sup>twolame</sup><br><sup>vo-amrwbenc</sup></td>
<td align="center"><sup>dav1d</sup><br><sup>fontconfig</sup><br><sup>freetype</sup><br><sup>fribidi</sup><br><sup>kvazaar</sup><br><sup>libass</sup><br><sup>libiconv</sup><br><sup>libtheora</sup><br><sup>libvpx</sup><br><sup>libwebp</sup><br><sup>snappy</sup><br><sup>zimg</sup></td>
<td align="center"><sup>dav1d</sup><br><sup>fontconfig</sup><br><sup>freetype</sup><br><sup>fribidi</sup><br><sup>gmp</sup><br><sup>gnutls</sup><br><sup>kvazaar</sup><br><sup>lame</sup><br><sup>libass</sup><br><sup>libiconv</sup><br><sup>libilbc</sup><br><sup>libtheora</sup><br><sup>libvorbis</sup><br><sup>libvpx</sup><br><sup>libwebp</sup><br><sup>libxml2</sup><br><sup>opencore-amr</sup><br><sup>opus</sup><br><sup>shine</sup><br><sup>snappy</sup><br><sup>soxr</sup><br><sup>speex</sup><br><sup>twolame</sup><br><sup>vo-amrwbenc</sup><br><sup>zimg</sup></td>
<td align="center"><sup>dav1d</sup><br><sup>fontconfig</sup><br><sup>freetype</sup><br><sup>fribidi</sup><br><sup>gmp</sup><br><sup>gnutls</sup><br><sup>kvazaar</sup><br><sup>lame</sup><br><sup>libass</sup><br><sup>libiconv</sup><br><sup>libilbc</sup><br><sup>libtheora</sup><br><sup>libvorbis</sup><br><sup>libvpx</sup><br><sup>libwebp</sup><br><sup>libxml2</sup><br><sup>opencore-amr</sup><br><sup>opus</sup><br><sup>shine</sup><br><sup>snappy</sup><br><sup>soxr</sup><br><sup>speex</sup><br><sup>twolame</sup><br><sup>vid.stab</sup><br><sup>vo-amrwbenc</sup><br><sup>x264</sup><br><sup>x265</sup><br><sup>xvidcore</sup><br><sup>zimg</sup></td>
</tr>
</tbody>
</table>

- `AVFoundation` is not available on `tvOS`
- `VideoToolbox` is not available on LTS releases of `iOS` and `tvOS`
- `zimg` is supported since `v4.5.1`

### 10. Versions

`FFmpegKit` binaries generated use the same major and minor version numbers as the upstream `FFmpeg` project. The
third and last number in the version string, if exists, is specific to `FFmpegKit`. It shows different releases from
the same `FFmpeg` release branch.

`dev` part in the version string indicates that `FFmpeg` source code is cloned from the `FFmpeg` `master` branch and
the exact version number of `FFmpeg` is obtained using the `git describe --tags` command.

|    Platforms     |                                  FFmpegKit Version                                  | FFmpeg Version | Release Date |
|:----------------:|:-----------------------------------------------------------------------------------:|:--------------:|:------------:|
|     Flutter      |   [6.0.3](https://github.com/arthenica/ffmpeg-kit/releases/tag/flutter.v6.0.3)    |      6.0       | Sep 19, 2023 |
|   React Native   | [6.0.2](https://github.com/arthenica/ffmpeg-kit/releases/tag/react.native.v6.0.2) |      6.0       | Sep 19, 2023 |
|     Flutter      |   [6.0.2](https://github.com/arthenica/ffmpeg-kit/releases/tag/flutter.v6.0.2)    |      6.0       | Sep 03, 2023 |
|   React Native   | [6.0.1](https://github.com/arthenica/ffmpeg-kit/releases/tag/react.native.v6.0.1) |      6.0       | Sep 03, 2023  |
|     Flutter      |   [6.0.1](https://github.com/arthenica/ffmpeg-kit/releases/tag/flutter.v6.0.1)    |      6.0       | Sep 03, 2023 |
|   React Native   | [6.0.0](https://github.com/arthenica/ffmpeg-kit/releases/tag/react.native.v6.0.0) |      6.0       | Aug 27, 2023 |
|     Flutter      |   [6.0.0](https://github.com/arthenica/ffmpeg-kit/releases/tag/flutter.v6.0.0)    |      6.0       | Aug 27, 2023 |
|      Android<br>Apple       |         [6.0](https://github.com/arthenica/ffmpeg-kit/releases/tag/v6.0)          |      6.0       | Aug 21, 2023 |
|   React Native   | [5.1.0](https://github.com/arthenica/ffmpeg-kit/releases/tag/react.native.v5.1.0) |     5.1.2      | Oct 02, 2022 |
|     Flutter      |   [5.1.0](https://github.com/arthenica/ffmpeg-kit/releases/tag/flutter.v5.1.0)    |     5.1.2      | Oct 02, 2022 |
|     Android<br>Apple      |         [5.1](https://github.com/arthenica/ffmpeg-kit/releases/tag/v5.1)          |     5.1.2      | Sep 29, 2022 |
|   React Native   | [4.5.2](https://github.com/arthenica/ffmpeg-kit/releases/tag/react.native.v4.5.2) |  4.5-dev-3393  | May 25, 2022 |
|     Flutter      |   [4.5.1](https://github.com/arthenica/ffmpeg-kit/releases/tag/flutter.v4.5.1)    |  4.5-dev-3393  | Jan 02, 2022 |
|   React Native   | [4.5.1](https://github.com/arthenica/ffmpeg-kit/releases/tag/react.native.v4.5.1) |  4.5-dev-3393  | Jan 02, 2022 |
|     Android      |       [4.5.1](https://github.com/arthenica/ffmpeg-kit/releases/tag/v4.5.1)        |  4.5-dev-3393  | Jan 01, 2022 |
|      Apple       |       [4.5.1](https://github.com/arthenica/ffmpeg-kit/releases/tag/v4.5.1)        |  4.5-dev-3393  | Dec 30, 2021 |
|     Flutter      |   [4.5.0](https://github.com/arthenica/ffmpeg-kit/releases/tag/flutter.v4.5.0)    |  4.5-dev-2008  | Oct 05, 2021 |
|   React Native   | [4.5.0](https://github.com/arthenica/ffmpeg-kit/releases/tag/react.native.v4.5.0) |  4.5-dev-2008  | Oct 01, 2021 |
| Android<br>Apple |         [4.5](https://github.com/arthenica/ffmpeg-kit/releases/tag/v4.5)          |  4.5-dev-2008  | Sep 18, 2021 |
| Android<br>Apple |         [4.4](https://github.com/arthenica/ffmpeg-kit/releases/tag/v4.4)          |  4.4-dev-3015  | Mar 03, 2021 |

### 11. LTS Releases

`FFmpegKit` binaries are published in two release variants: `Main Release` and `LTS Release`.

- Main releases include complete functionality of the library and support the latest SDK/API features.

- LTS releases are customized to support a wider range of devices. They are built using older API/SDK versions, so some features are not available on them.

This table shows the differences between two variants.

|        | Main Release |                        LTS Release                        |
| :----: | :----: |:---------------------------------------------------------:|
| Android API Level | 24 |                            16                             | 
| Android Camera Access | Yes |                             -                             |
| Android Architectures | arm-v7a-neon<br/>arm64-v8a<br/>x86<br/>x86-64 | arm-v7a<br/>arm-v7a-neon<br/>arm64-v8a<br/>x86<br/>x86-64 |
| iOS Min SDK | 12.1 |                            10                             |
| iOS VideoToolbox | Yes |                             -                             |
| iOS AVFoundation | Yes |                             -                             |
| iOS Architectures | arm64<br/>arm64-simulator<br/>arm64-mac-catalyst<br/>x86-64<br/>x86-64-mac-catalyst |            armv7<br/>arm64<br/>i386<br/>x86-64            |
| iOS Bundle Format | XCFrameworks |                        Frameworks                         |
| Mac Catalyst Min Version | 14.0 |                             -                             |
| macOS Min SDK | 10.15 |                           10.12                           |
| macOS AVFoundation | Yes |                             -                             |
| macOS Architectures | arm64<br/>x86-64 |                          x86-64                           |
| macOS Bundle Format | XCFrameworks |                        Frameworks                         |
| tvOS Min SDK | 11.0 |                           10.0                            |
| tvOS VideoToolbox | Yes |                             -                             |
| tvOS Architectures | arm64<br/>x86-64<br/>arm64-simulator |                     arm64<br/>x86-64                      |
| tvOS Bundle Format | XCFrameworks |                        Frameworks                         |

### 12. Documentation

A more detailed documentation is available under [Wiki](https://github.com/arthenica/ffmpeg-kit/wiki).

### 13. Test Applications

You can see how `FFmpegKit` is used inside an application by running test applications created under
[FFmpegKit Test](https://github.com/arthenica/ffmpeg-kit-test) project.

All applications are identical and supports command execution, video encoding, accessing https urls, encoding audio,
burning subtitles, video stabilisation, pipe operations and concurrent command execution.

### 14. License

`FFmpegKit` library alone is licensed under the `LGPL v3.0`.

`FFmpegKit` bundles (`.aar` archives, `frameworks`, `xcframeworks`), which include both  `FFmpegKit` and `FFmpeg`
libraries, are also licensed under the `LGPL v3.0`. However, if the source code is built using the optional
`--enable-gpl` flag or prebuilt binaries with `-gpl` postfix are used, then `FFmpegKit` bundles become subject to the
`GPL v3.0`. Because, `FFmpeg` is licensed under the `GPL v3.0` in those bundles. And that makes the whole bundle
effectively subject to the `GPL v3.0`.

`FFmpegKit` build scripts always configure `FFmpeg` with `--enable-version3` option. And never enable non-free
libraries. Thus, `FFmpeg` libraries created by `FFmpegKit` are licensed under the `LGPL v3.0` by default. Only when
`--enable-gpl` is provided they become subject to `GPL v3.0`. That is how prebuilt binaries with `-gpl` postfix are
compiled.

Refer to [Licenses](https://github.com/arthenica/ffmpeg-kit/wiki/Licenses) to see the licenses of all libraries.
[Trademark](https://github.com/arthenica/ffmpeg-kit/wiki/Trademark) lists the trademarks used in the `FFmpegKit`
documentation.

### 15. Patents

It is not clearly explained in their documentation, but it is believed that `FFmpeg`, `kvazaar`, `x264` and `x265`
include algorithms which are subject to software patents. If you live in a country where software algorithms are
patentable then you'll probably need to pay royalty fees to patent holders. We are not lawyers though, so we recommend
that you seek legal advice first. See [FFmpeg Patent Mini-FAQ](https://ffmpeg.org/legal.html).

`openh264` clearly states that it uses patented algorithms. Therefore, if you build `ffmpeg-kit` with `openh264` and
distribute that library, then you are subject to pay MPEG LA licensing fees. Refer to
[OpenH264 FAQ](https://www.openh264.org/faq.html) page for the details.

### 16. Contributing

See our [CONTRIBUTING](https://github.com/arthenica/ffmpeg-kit/blob/main/CONTRIBUTING.md) guide.

### 17. See Also

- [FFmpeg API Documentation](https://ffmpeg.org/doxygen/4.0/index.html)
- [FFmpeg Wiki](https://trac.ffmpeg.org/wiki/WikiStart)
- [FFmpeg External Library Licenses](https://www.ffmpeg.org/doxygen/4.0/md_LICENSE.html)
