# FFmpegKit for Android

### 1. Features
- Supports `API Level 24+` on Main releases and `API Level 16+` on LTS releases
- Includes `arm-v7a`, `arm-v7a-neon`, `arm64-v8a`, `x86` and `x86_64` architectures
- Can handle Storage Access Framework (SAF) Uris
- Camera access on [supported devices](https://developer.android.com/ndk/guides/stable_apis#camera)
- Builds shared native libraries (.so)
- Creates Android archive with .aar extension

### 2. Building

Run `android.sh` at project root directory to build `ffmpeg-kit` and `ffmpeg` shared libraries. 

Please note that `FFmpegKit` project repository includes the source code of `FFmpegKit` only. `android.sh` needs 
network connectivity and internet access to `github.com` in order to download the source code of `FFmpeg` and 
external libraries enabled.

#### 2.1 Prerequisites

`android.sh` requires the following tools and packages.

##### 2.1.1 Android Tools
   - Android SDK Build Tools
   - Android NDK r22b or later with LLDB and CMake (See [#292](https://github.com/arthenica/ffmpeg-kit/issues/292) if you want to use NDK r23b or later)

##### 2.1.2 Packages

Use your package manager (apt, yum, dnf, brew, etc.) to install the following packages.

```
autoconf automake libtool pkg-config curl git doxygen nasm cmake gcc gperf texinfo yasm bison autogen wget autopoint meson ninja ragel groff gtk-doc-tools libtasn1
```

##### 2.1.3 Environment Variables 

Set `ANDROID_SDK_ROOT` and `ANDROID_NDK_ROOT` environment variables before running `android.sh`.

```
export ANDROID_SDK_ROOT=<Android SDK Path>
export ANDROID_NDK_ROOT=<Android NDK Path>
```

#### 2.2 Options

Use `--enable-<library name>` flag to support additional external or system libraries and
`--disable-<architecture name>` to disable architectures you don't want to build.

```
./android.sh --enable-fontconfig --disable-arm-v7a-neon
```

Run `--help` to see all available build options.

#### 2.3 LTS Binaries

Use `--lts` option to build lts binaries for each architecture.

#### 2.4 Build Output

All libraries created by `android.sh` can be found under the `prebuilt` directory.

- `Android` archive (.aar file) for `Main` builds is located under the `bundle-android-aar` folder.
- `Android` archive (.aar file) for `LTS` builds is located under the `bundle-android-aar-lts` folder.

### 3. Using

#### 3.1 Android API

1. Declare `mavenCentral` repository and add `FFmpegKit` dependency to your `build.gradle` in 
   `ffmpeg-kit-<package name>` pattern. Use one of the `FFmpegKit` package names given in the 
   project [README](https://github.com/arthenica/ffmpeg-kit).

    ```yaml
    repositories {
        mavenCentral()
    }

    dependencies {
        implementation 'com.arthenica:ffmpeg-kit-full:6.0-2'
    }
    ```

2. Execute synchronous `FFmpeg` commands.

    ```java
    import com.arthenica.ffmpegkit.FFmpegKit;

    FFmpegSession session = FFmpegKit.execute("-i file1.mp4 -c:v mpeg4 file2.mp4");
    if (ReturnCode.isSuccess(session.getReturnCode())) {

        // SUCCESS

    } else if (ReturnCode.isCancel(session.getReturnCode())) {

        // CANCEL

    } else {

        // FAILURE
        Log.d(TAG, String.format("Command failed with state %s and rc %s.%s", session.getState(), session.getReturnCode(), session.getFailStackTrace()));

    }
    ```

3. Each `execute` call (sync or async) creates a new session. Access every detail about your execution from the 
   session created.

    ```java
    FFmpegSession session = FFmpegKit.execute("-i file1.mp4 -c:v mpeg4 file2.mp4");

    // Unique session id created for this execution
    long sessionId = session.getSessionId();

    // Command arguments as a single string
    String command = session.getCommand();

    // Command arguments
    String[] arguments = session.getArguments();

    // State of the execution. Shows whether it is still running or completed
    SessionState state = session.getState();

    // Return code for completed sessions. Will be null if session is still running or ends with a failure
    ReturnCode returnCode = session.getReturnCode();

    Date startTime = session.getStartTime();
    Date endTime = session.getEndTime();
    long duration = session.getDuration();

    // Console output generated for this execution
    String output = session.getOutput();

    // The stack trace if FFmpegKit fails to run a command
    String failStackTrace = session.getFailStackTrace();

    // The list of logs generated for this execution
    List<com.arthenica.ffmpegkit.Log> logs = session.getLogs();

    // The list of statistics generated for this execution
    List<Statistics> statistics = session.getStatistics();
    ```

4. Execute asynchronous `FFmpeg` commands by providing session specific `execute`/`log`/`session` callbacks.

    ```java
    FFmpegKit.executeAsync("-i file1.mp4 -c:v mpeg4 file2.mp4", new FFmpegSessionCompleteCallback() {

        @Override
        public void apply(FFmpegSession session) {
            SessionState state = session.getState();
            ReturnCode returnCode = session.getReturnCode();

            // CALLED WHEN SESSION IS EXECUTED

            Log.d(TAG, String.format("FFmpeg process exited with state %s and rc %s.%s", state, returnCode, session.getFailStackTrace()));
        }
    }, new LogCallback() {

        @Override
        public void apply(com.arthenica.ffmpegkit.Log log) {

            // CALLED WHEN SESSION PRINTS LOGS

        }
    }, new StatisticsCallback() {

        @Override
        public void apply(Statistics statistics) {

            // CALLED WHEN SESSION GENERATES STATISTICS

        }
    });
    ```

5. Execute `FFprobe` commands.

    - Synchronous

    ```java
    FFprobeSession session = FFprobeKit.execute(ffprobeCommand);

    if (!ReturnCode.isSuccess(session.getReturnCode())) {
        Log.d(TAG, "Command failed. Please check output for the details.");
    }
    ```

    - Asynchronous

    ```java
    FFprobeKit.executeAsync(ffprobeCommand, new FFprobeSessionCompleteCallback() {
   
        @Override
        public void apply(FFprobeSession session) {

            CALLED WHEN SESSION IS EXECUTED

        }
    });
    ```

6. Get media information for a file.

    ```java
    MediaInformationSession mediaInformation = FFprobeKit.getMediaInformation("<file path or uri>");
    mediaInformation.getMediaInformation();
    ```

7. Stop ongoing `FFmpeg` operations.

    - Stop all executions
        ```java
        FFmpegKit.cancel();
        ```
    - Stop a specific session
        ```java
        FFmpegKit.cancel(sessionId);
        ```

8. Convert Storage Access Framework (SAF) Uris into paths that can be read or written by `FFmpegKit`.
   - Reading a file:
  
        ```java
        Uri safUri = intent.getData();
        String inputVideoPath = FFmpegKitConfig.getSafParameterForRead(requireContext(), safUri);
        FFmpegKit.execute("-i " + inputVideoPath + " -c:v mpeg4 file2.mp4");
        ```
    
    - Writing to a file:
  
        ```java
        Uri safUri = intent.getData();
        String outputVideoPath = FFmpegKitConfig.getSafParameterForWrite(requireContext(), safUri);
        FFmpegKit.execute("-i file1.mp4 -c:v mpeg4 " + outputVideoPath);
        ```

   - Writing to a file in a custom mode.

       ```java
       Uri safUri = intent.getData();
       String path = FFmpegKitConfig.getSafParameter(requireContext(), safUri, "rw");
       FFmpegKit.execute("-i file1.mp4 -c:v mpeg4 " + path);
       ```

9. Get previous `FFmpeg` and `FFprobe` sessions from session history.

    ```java
    List<Session> sessions = FFmpegKitConfig.getSessions();
    for (int i = 0; i < sessions.size(); i++) {
        Session session = sessions.get(i);
        Log.d(TAG, String.format("Session %d = id:%d, startTime:%s, duration:%s, state:%s, returnCode:%s.",
              i,
              session.getSessionId(),
              session.getStartTime(),
              session.getDuration(),
              session.getState(),
              session.getReturnCode()));
    }
    ```

10. Enable global callbacks.

    - Session type specific Complete Callbacks, called when an async session has been completed

        ```java
        FFmpegKitConfig.enableFFmpegSessionCompleteCallback(new FFmpegSessionCompleteCallback() {

            @Override
            public void apply(FFmpegSession session) {

            }
        });

        FFmpegKitConfig.enableFFprobeSessionCompleteCallback(new FFprobeSessionCompleteCallback() {

            @Override
            public void apply(FFprobeSession session) {

            }
        });

        FFmpegKitConfig.enableMediaInformationSessionCompleteCallback(new MediaInformationSessionCompleteCallback() {

            @Override
            public void apply(MediaInformationSession session) {

            }
        });
        ```

    - Log Callback, called when a session generates logs

        ```java
        FFmpegKitConfig.enableLogCallback(new LogCallback() {
    
            @Override
            public void apply(final com.arthenica.ffmpegkit.Log log) {
                ...
            }
        });
        ```

    - Statistics Callback, called when a session generates statistics

        ```java
        FFmpegKitConfig.enableStatisticsCallback(new StatisticsCallback() {

            @Override
            public void apply(final Statistics newStatistics) {
                ...
            }
        });
        ```

11. Ignore the handling of a signal. Required by `Mono` and frameworks that use `Mono`, e.g. `Unity` and `Xamarin`.

    ```java
    FFmpegKitConfig.ignoreSignal(Signal.SIGXCPU);
    ```

12. Register system fonts and custom font directories.

    ```java
    FFmpegKitConfig.setFontDirectoryList(context, Arrays.asList("/system/fonts", "<folder with fonts>"), Collections.EMPTY_MAP);
    ```

### 4. Test Application

You can see how `FFmpegKit` is used inside an application by running `Android` test applications developed under the
[FFmpegKit Test](https://github.com/arthenica/ffmpeg-kit-test) project.
