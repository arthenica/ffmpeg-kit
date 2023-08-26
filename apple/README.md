# FFmpegKit for iOS, macOS and tvOS

### 1. Features
#### 1.1 iOS
- Supports `iOS SDK 12.1+` on Main releases and `iOS SDK 10+` on LTS releases
- Includes `armv7`, `armv7s`, `arm64`, `arm64-simulator`, `arm64e`, `i386`, `x86_64`, `x86_64-mac-catalyst` and 
  `arm64-mac-catalyst` architectures
- Objective-C API
- Camera access
- `ARC` enabled library
- Can be built with `-fembed-bitcode` flag
- Creates shared `frameworks` and `xcframeworks`

#### 1.2 macOS
- Supports `macOS SDK 10.15+` on Main releases and `macOS SDK 10.12+` on LTS releases
- Includes `arm64` and `x86_64` architectures
- Objective-C API
- Camera access
- `ARC` enabled library
- Creates shared `frameworks` and `xcframeworks`

#### 1.3 tvOS
- Supports `tvOS SDK 11.0+` on Main releases and `tvOS SDK 10.0+` on LTS releases
- Includes `arm64`, `arm64-simulator` and `x86_64` architectures
- Objective-C API
- `ARC` enabled library
- Can be built with `-fembed-bitcode` flag
- Creates shared `frameworks` and `xcframeworks`

### 2. Building

Run `ios.sh`/`macos.sh`/`tvos.sh` inside the project root to build `ffmpeg-kit` and `ffmpeg` shared libraries
for a platform.

Optionally, use `apple.sh` to combine bundles created by these three scripts in a single bundle.

Please note that `FFmpegKit` project repository includes the source code of `FFmpegKit` only. `ios.sh`, `macos.sh` and 
`tvos.sh` need network connectivity and internet access to `github.com` in order to download the source code of
`FFmpeg` and external libraries enabled.

#### 2.1 Prerequisites

`ios.sh`, `macos.sh` and `tvos.sh` require the following tools and packages.

##### 2.1.1 iOS

- **Xcode 8.0** or later
- **iOS SDK 10** or later
- **Command Line Tools**

##### 2.1.2 macOS

- **Xcode 8.0** or later
- **macOS SDK 10.12** or later
- **Command Line Tools**

##### 2.1.3 tvOS

- **Xcode 8.0** or later
- **tvOS SDK 10.0** or later
- **Command Line Tools**

##### 2.1.4 Packages

Use your package manager (brew, etc.) to install the following packages.

```
autoconf automake libtool pkg-config curl git doxygen nasm cmake gcc gperf texinfo yasm bison autogen wget gettext meson ninja ragel groff gtk-doc-tools libtasn1
```

#### 2.2 Options

Use `--enable-<library name>` flag to support additional external or system libraries and
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
- `macOS` `frameworks` for `Main` builds are located under the `bundle-apple-framework-macos` folder.
- `macOS` `frameworks` for `LTS` builds are located under the `bundle-apple-framework-macos-lts` folder.
- `tvOS` `frameworks` for `Main` builds are located under the `bundle-apple-framework-tvos` folder.
- `tvOS` `frameworks` for `LTS` builds are located under the `bundle-apple-framework-tvos-lts` folder.

### 3. Using

#### 3.1 Objective API

1. Add `FFmpegKit` dependency to your `Podfile` in `ffmpeg-kit-<platform>-<package name>` pattern. Use one of the 
   `FFmpegKit` package names given in the project [README](https://github.com/arthenica/ffmpeg-kit).

    - iOS
    ```yaml
    pod 'ffmpeg-kit-ios-full', '~> 6.0'
    ```

    - macOS
    ```yaml
    pod 'ffmpeg-kit-macos-full', '~> 6.0'
    ```

    - tvOS
    ```yaml
    pod 'ffmpeg-kit-tvos-full', '~> 6.0'
    ```

2. Execute synchronous `FFmpeg` commands.

    ```objectivec
    #include <ffmpegkit/FFmpegKit.h>

    FFmpegSession *session = [FFmpegKit execute:@"-i file1.mp4 -c:v mpeg4 file2.mp4"];
    ReturnCode *returnCode = [session getReturnCode];
    if ([ReturnCode isSuccess:returnCode]) {

        // SUCCESS

    } else if ([ReturnCode isCancel:returnCode]) {

        // CANCEL

    } else {

        // FAILURE
        NSLog(@"Command failed with state %@ and rc %@.%@", [FFmpegKitConfig sessionStateToString:[session getState]], returnCode, [session getFailStackTrace]);

    }
    ```

3. Each `execute` call (sync or async) creates a new session. Access every detail about your execution from the
   session created.

    ```objectivec
    FFmpegSession *session = [FFmpegKit execute:@"-i file1.mp4 -c:v mpeg4 file2.mp4"];

    // Unique session id created for this execution
    long sessionId = [session getSessionId];

    // Command arguments as a single string
    NSString *command = [session getCommand];

    // Command arguments
    NSArray *arguments = [session getArguments];
   
    // State of the execution. Shows whether it is still running or completed
    SessionState state = [session getState];

    // Return code for completed sessions. Will be null if session is still running or ends with a failure
    ReturnCode *returnCode = [session getReturnCode];

    NSDate *startTime =[session getStartTime];
    NSDate *endTime =[session getEndTime];
    long duration =[session getDuration];

    // Console output generated for this execution
    NSString *output = [session getOutput];

    // The stack trace if FFmpegKit fails to run a command
    NSString *failStackTrace = [session getFailStackTrace];

    // The list of logs generated for this execution
    NSArray *logs = [session getLogs];

    // The list of statistics generated for this execution
    NSArray *statistics = [session getStatistics];
    ```

4. Execute asynchronous `FFmpeg` commands by providing session specific `execute`/`log`/`session` callbacks.

    ```objectivec
    FFmpegSession* session = [FFmpegKit executeAsync:@"-i file1.mp4 -c:v mpeg4 file2.mp4" withCompleteCallback:^(FFmpegSession* session){
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

5. Execute `FFprobe` commands.

    - Synchronous

    ```objectivec
    FFprobeSession *session = [FFprobeKit execute:ffprobeCommand];

    if ([ReturnCode isSuccess:[session getReturnCode]]) {
        NSLog(@"Command failed. Please check output for the details.");
    }
    ```

   - Asynchronous

    ```objectivec
    [FFprobeKit executeAsync:ffmpegCommand withCompleteCallback:^(FFprobeSession* session) {

        CALLED WHEN SESSION IS EXECUTED

    }];
    ```

6. Get media information for a file.

    ```objectivec
    MediaInformationSession *mediaInformation = [FFprobeKit getMediaInformation:"<file path or uri>"];
    MediaInformation *mediaInformation =[mediaInformation getMediaInformation];
    ```

7. Stop ongoing `FFmpeg` operations.

   - Stop all executions
       ```objectivec
       [FFmpegKit cancel];
       ```
   - Stop a specific session
       ```objectivec
       [FFmpegKit cancel:sessionId];
       ```

8. Get previous `FFmpeg` and `FFprobe` sessions from session history.

    ```objectivec
    NSArray* sessions = [FFmpegKitConfig getSessions];
    for (int i = 0; i < [sessions count]; i++) {
        id<Session> session = [sessions objectAtIndex:i];
        NSLog(@"Session %d = id: %ld, startTime: %@, duration: %ld, state:%@, returnCode:%@.\n",
            i,
            [session getSessionId],
            [session getStartTime],
            [session getDuration],
            [FFmpegKitConfig sessionStateToString:[session getState]],
            [session getReturnCode]);
    }
    ```

9. Enable global callbacks.

    - Session type specific Complete Callbacks, called when an async session has been completed

        ```objectivec
        [FFmpegKitConfig enableFFmpegSessionCompleteCallback:^(FFmpegSession* session) {
            ...
        }];

        [FFmpegKitConfig enableFFprobeSessionCompleteCallback:^(FFprobeSession* session) {
            ...
        }];

        [FFmpegKitConfig enableMediaInformationSessionCompleteCallback:^(MediaInformationSession* session) {
            ...
        }];
        ```

    - Log Callback, called when a session generates logs

        ```objectivec
        [FFmpegKitConfig enableLogCallback:^(Log *log) {
            ...
        }];
        ```

    - Statistics Callback, called when a session generates statistics

        ```objectivec
        [FFmpegKitConfig enableStatisticsCallback:^(Statistics *statistics) {
            ...
        }];
        ```

10. Ignore the handling of a signal. Required by `Mono` and frameworks that use `Mono`, e.g. `Unity` and `Xamarin`.

    ```objectivec
    [FFmpegKitConfig ignoreSignal:SIGXCPU];
    ```

11. Register system fonts and custom font directories.

    ```objectivec
    [FFmpegKitConfig setFontDirectoryList:[NSArray arrayWithObjects:@"/System/Library/Fonts", @"<folder with fonts>", nil] with:nil];
    ```

### 4. Test Application

You can see how `FFmpegKit` is used inside an application by running `iOS`, `macOS` and `tvOS` test applications 
developed under the [FFmpegKit Test](https://github.com/arthenica/ffmpeg-kit-test) project.
