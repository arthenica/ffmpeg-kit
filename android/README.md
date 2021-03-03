# FFmpegKit for Android

### 1. Features
- Supports
  - `API Level 16+`
  - `arm-v7a`, `arm-v7a-neon`, `arm64-v8a`, `x86` and `x86_64` architectures
  - `zlib` and `MediaCodec` system libraries
- Can handle Storage Access Framework (SAF) uris
- Camera access on [supported devices](https://developer.android.com/ndk/guides/stable_apis#camera)
- Builds shared native libraries (.so)
- Creates Android archive with .aar extension

### 2. Building

Run `android.sh` at project root directory to build `ffmpeg-kit` and `ffmpeg` shared libraries. 

#### 2.1 Prerequisites

`android.sh` requires the following packages and tools. 

1. Install Android tools listed below.
    - **Android SDK Build Tools**
    - **Android NDK r21e** or later with LLDB and CMake

2. Use your package manager (apt, yum, dnf, brew, etc.) to install the following packages.

    ```
    autoconf automake libtool pkg-config curl cmake gcc gperf texinfo yasm nasm bison autogen git wget autopoint meson ninja
    ```

3. Set `ANDROID_SDK_ROOT` and `ANDROID_NDK_ROOT` environment variables.
    ```
    export ANDROID_SDK_ROOT=<Android SDK Path>
    export ANDROID_NDK_ROOT=<Android NDK Path>
    ```

4. `android.sh` needs network connectivity and internet access to `github.com` in order to download the source code 
   of all libraries except `ffmpeg-kit`.

#### 2.2 Options

Use `--enable-<library name>` flags to support additional external or system libraries and
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
   project [README](https://github.com/tanersener/ffmpeg-kit).

    ```
    repositories {
        mavenCentral()
    }

    dependencies {
        implementation 'com.arthenica:ffmpeg-kit-full:4.4.LTS'
    }
    ```

2. Execute synchronous FFmpeg commands.

    ```
    import com.arthenica.ffmpegkit.FFmpegKit;
    import com.arthenica.ffmpegkit.ReturnCode;

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

3. Execute asynchronous FFmpeg commands by providing session specific execute/log/session callbacks.

    ```
    FFmpegKit.executeAsync("-i file1.mp4 -c:v mpeg4 file2.mp4", new ExecuteCallback() {

        @Override
        public void apply(Session session) {
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

4. Execute synchronous FFprobe commands.

    ```
    FFprobeSession session = FFprobeKit.execute(ffprobeCommand);

    if (!ReturnCode.isSuccess(session.getReturnCode())) {
        Log.d(TAG, "Command failed. Please check output for the details.");
    }
    ```

5. Get session output.

    ```
    Session session = FFmpegKit.execute("-i file1.mp4 -c:v mpeg4 file2.mp4");
    Log.d(TAG, session.getOutput());
    ```

6. Stop ongoing FFmpeg operations.

    - Stop all executions
        ```
        FFmpegKit.cancel();
        ```
    - Stop a specific session
        ```
        FFmpegKit.cancel(sessionId);
        ```

7. Get media information for a file.

    ```
    MediaInformationSession mediaInformation = FFprobeKit.getMediaInformation("<file path or uri>");
    mediaInformation.getMediaInformation();
    ```

8. List previous FFmpeg sessions.

   ```
   List<FFmpegSession> ffmpegSessions = FFmpegKit.listSessions();
   for (int i = 0; i < ffmpegSessions.size(); i++) {
      FFmpegSession session = ffmpegSessions.get(i);
      Log.d(TAG, String.format("Session %d = id:%d, startTime:%s, duration:%s, state:%s, returnCode:%s.",
              i,
              session.getSessionId(),
              session.getStartTime(),
              session.getDuration(),
              session.getState(),
              session.getReturnCode()));
   }
   ```

### 4. Test Application

You can see how `FFmpegKit` is used inside an application by running test applications developed under the
[FFmpegKit Test](https://github.com/tanersener/ffmpeg-kit-test) project.
