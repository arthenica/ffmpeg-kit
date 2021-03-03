# FFmpegKit for iOS, macOS and tvOS

### 1. Features
#### 1.1 iOS
- Builds `armv7`, `armv7s`, `arm64`, `arm64-simulator`, `arm64e`, `i386`, `x86_64`, `x86_64-mac-catalyst` and 
  `arm64-mac-catalyst` architectures
- Supports `bzip2`, `iconv`, `libuuid`, `zlib` system libraries and `AudioToolbox`, `AVFoundation`, `VideoToolbox` system frameworks
- Objective-C API
- Camera access
- `ARC` enabled library
- Built with `-fembed-bitcode` flag
- Creates static `frameworks`, static `xcframeworks` and static `universal (fat)` libraries (.a)
- Supports `iOS SDK 9.3` or later

#### 1.2 macOS
- Builds `arm64` and `x86_64` architectures
- Supports `bzip2`, `iconv`, `libuuid`, `zlib` system libraries and `AudioToolbox`, `AVFoundation`, `CoreImage`, 
  `OpenCL`, `OpenGL`, `VideoToolbox` system frameworks
- Objective-C API
- Camera access
- `ARC` enabled library
- Built with `-fembed-bitcode` flag
- Creates static `frameworks`, static `xcframeworks` and static `universal (fat)` libraries (.a)
- Supports `macOS SDK 10.11` or later

#### 1.3 tvOS
- Builds `arm64`, `arm64-simulator` and `x86_64` architectures
- Supports `bzip2`, `iconv`, `libuuid`, `zlib` system libraries and `AudioToolbox`, `VideoToolbox` system frameworks
- Objective-C API
- `ARC` enabled library
- Built with `-fembed-bitcode` flag
- Creates static `frameworks`, static `xcframeworks` and static `universal (fat)` libraries (.a)
- Supports `tvOS SDK 9.2` or later

### 2. Building

Run `ios.sh`/`macos.sh`/`tvos.sh` at project root directory to build `ffmpeg-kit` and `ffmpeg` shared libraries for a 
platform.

Optionally, use `apple.sh` to combine bundles created by these three scripts in a single bundle.

#### 2.1 Prerequisites

`ios.sh`/`macos.sh`/`tvos.sh` requires the following packages and tools.

1. Use your package manager (brew, etc.) to install the following packages.

    ```
    autoconf automake libtool pkg-config curl cmake gcc gperf texinfo yasm nasm bison autogen git wget autopoint meson ninja
    ```

2. `ios.sh`/`macos.sh`/`tvos.sh` needs network connectivity and internet access to `github.com` in order to download
   the source code of all libraries except `ffmpeg-kit`.

3. Install the tools necessary listed below in `2.1.x`.

##### 2.1.1 iOS

- **Xcode 7.3.1** or later
- **iOS SDK 9.3** or later
- **Command Line Tools**

##### 2.1.2 macOS

- **Xcode 7.3.1** or later
- **macOS SDK 10.11** or later
- **Command Line Tools**

##### 2.1.3 tvOS

- **Xcode 7.3.1** or later
- **tvOS SDK 9.2** or later
- **Command Line Tools**

#### 2.2 Options

Use `--enable-<library name>` flags to support additional external or system libraries and
`--disable-<architecture name>` to disable architectures you don't want to build.

```
./ios.sh --enable-fontconfig --disable-armv7
./macos.sh --enable-freetype --enable-macos-avfoundation --disable-arm64
./tv.sh --enable-dav1d --enable-libvpx --disable-arm64-simulator
```

Run `--help` to see all available build options.

#### 2.3 LTS Binaries

Use `--lts` option to build lts binaries for each architecture.

#### 2.4 Build Output

All libraries created can be found under the `prebuilt` directory.

- `iOS` `xcframeworks` for `Main` builds are located under the `bundle-apple-xcframework-ios` folder.
- `macOS` `xcframeworks` for `Main` builds are located under the `bundle-apple-xcframework-macos` folder.
- `tvOS` `xcframeworks` for `Main` builds are located under the `bundle-apple-xcframework-tvos` folder.
- `iOS` `frameworks` for `Main` builds are located under the `bundle-apple-framework-ios` folder.
- `iOS` `frameworks` for `LTS` builds are located under the `bundle-apple-framework-ios-lts` folder.
- `iOS` `universal (fat) libraries (.a)` for `LTS` builds are located under the `bundle-apple-universal-ios-lts` folder.
- `macOS` `frameworks` for `Main` builds are located under the `bundle-apple-framework-macos` folder.
- `macOS` `frameworks` for `LTS` builds are located under the `bundle-apple-framework-macos-lts` folder.
- `macOS` `universal (fat) libraries (.a)` for `LTS` builds are located under the `bundle-apple-universal-macos-lts` folder.
- `tvOS` `frameworks` for `Main` builds are located under the `bundle-apple-framework-tvos` folder.
- `tvOS` `frameworks` for `LTS` builds are located under the `bundle-apple-framework-tvos-lts` folder.
- `tvOS` `universal (fat) libraries (.a)` for `LTS` builds are located under the `bundle-apple-universal-tvos-lts` folder.

### 3. Using

#### 3.1 Objective API

1. add `FFmpegKit` dependency to your `Podfile` in `ffmpeg-kit-<platform>-<package name>` pattern. Use one of the 
   `FFmpegKit` package names given in the project [README](https://github.com/tanersener/ffmpeg-kit).

    - iOS
    ```
    pod 'ffmpeg-kit-ios-full', '~> 4.4.LTS'
    ```

    - macOS
    ```
    pod 'ffmpeg-kit-macos-full', '~> 4.4.LTS'
    ```

    - tvOS
    ```
    pod 'ffmpeg-kit-tvos-full', '~> 4.4.LTS'
    ```

2. Execute synchronous FFmpeg commands.

    ```
    #include <ffmpegkit/FFmpegKit.h>

    FFmpegSession* session = [FFmpegKit execute:@"-i file1.mp4 -c:v mpeg4 file2.mp4"];
    ReturnCode* returnCode = [session getReturnCode];
    if ([ReturnCode isSuccess:returnCode]) {
        // SUCCESS
    } else if ([ReturnCode isCancel:returnCode]) {
        // CANCEL
    } else {
        // FAILURE
        NSLog(@"Command failed with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], returnCode, [session getFailStackTrace]);
    }
    ```

3. Execute asynchronous FFmpeg commands by providing session specific execute/log/session callbacks.

    ```
    id<Session> session = [FFmpegKit executeAsync:@"-i file1.mp4 -c:v mpeg4 file2.mp4" withExecuteCallback:^(id<Session> session){
        SessionState state = [session getState];
        ReturnCode *returnCode = [session getReturnCode];

        // CALLED WHEN SESSION IS EXECUTED

        NSLog(@"FFmpeg process exited with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:state], returnCode, [session getFailStackTrace]);

    } withLogCallback:^(Log *log) {

        // CALLED WHEN SESSION PRINTS LOGS

    } withStatisticsCallback:^(Statistics *statistics) {

        // CALLED WHEN SESSION GENERATES STATISTICS

    }];
    ```

4. Execute synchronous FFprobe commands.

    ```
    FFprobeSession *session = [FFprobeKit execute:ffprobeCommand];
    if ([ReturnCode isSuccess:[session getReturnCode]]) {
        NSLog(@"Command failed. Please check output for the details.");
    }
    ```

5. Get session output.

    ```
    FFmpegSession session = FFmpegKit.execute("-i file1.mp4 -c:v mpeg4 file2.mp4");
    NSLog([session getOutput]);
    ```

6. Stop ongoing FFmpeg operations.

   - Stop all executions
       ```
       [FFmpegKit cancel];
       ```
   - Stop a specific session
       ```
       [FFmpegKit cancel:sessionId];
       ```

7. Get media information for a file.

    ```
    MediaInformationSession *mediaInformation = [FFprobeKit getMediaInformation:"<file path or uri>"];
    MediaInformation *mediaInformation =[mediaInformation getMediaInformation];
    ```

8. List previous FFmpeg sessions.

   ```
    NSArray* ffmpegSessions = [FFmpegKit listSessions];
    for (int i = 0; i < [ffmpegSessions count]; i++) {
        FFmpegSession* session = [ffmpegSessions objectAtIndex:i];
        NSLog(@"Session %d = id: %ld, startTime: %@, duration: %ld, state:%@, returnCode:%@.\n",
            i,
            [session getSessionId],
            [session getStartTime],
            [session getDuration],
            [FFmpegKitConfig sessionStateToString:[session getState]],
            [session getReturnCode]);
    }
   ```

### 4. Test Application

You can see how `FFmpegKit` is used inside an application by running test applications developed under the
[FFmpegKit Test](https://github.com/tanersener/ffmpeg-kit-test) project.
