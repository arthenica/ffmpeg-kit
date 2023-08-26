# FFmpegKit for Linux

### 1. Features
- Provides a `C++` API with `c++11`
- Includes `x86_64` architecture
- Builds shared native libraries (.so)
- Prebuilt binaries not published

### 2. Building

Run `linux.sh` at project root directory to build `ffmpeg-kit` and `ffmpeg` shared libraries. 

Please note that `FFmpegKit` project repository includes the source code of `FFmpegKit` only. `linux.sh` needs 
network connectivity and internet access to `github.com` in order to download the source code of `FFmpeg` and 
external libraries enabled.

#### 2.1 Prerequisites

`linux.sh` requires the following packages.

##### 2.1.1 Packages

Use your package manager (apt, yum, dnf, etc.) to install the following packages.

Note that the names of the Linux packages vary from distribution to distribution. The names given below are
valid for Debian/Ubuntu. Some packages may have a different name if you are on another distribution.

- The following packages are required by the build scripts.

  ```
  clang llvm lld libclang-14-dev libstdc++6 nasm autoconf automake libtool pkg-config curl git doxygen rapidjson-dev
  ```

- These optional packages should be installed only if you want to build corresponding external libraries.
  
  ```
  cmake libasound2-dev libass-dev libfontconfig1-dev libfreetype-dev libfribidi-dev libgmp-dev libgnutls28-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev librubberband-dev libsdl2-dev libshine-dev libsnappy-dev libsoxr-dev libspeex-dev libtesseract-dev libtheora-dev libtwolame-dev libva-dev libvidstab-dev libvorbis-dev libvo-amrwbenc-dev libvpx-dev libv4l-dev libwebp-dev libxml2-dev libxvidcore-dev libx265-dev meson ocl-icd-opencl-dev opencl-headers tcl zlib1g-dev groff gtk-doc-tools libtasn1
  ```

#### 2.2 Options

Use `--enable-<library name>` flag to support additional external or system libraries.

```
./linux.sh --enable-fontconfig
```

Run `--help` to see all available build options.

#### 2.3 Build Output

All libraries created by `linux.sh` can be found under the `prebuilt` directory.

- Headers and libraries created for the `Main` builds are located under the `bundle-linux` folder.

### 3. Using

#### 3.1 C++ API

`FFmpegKit` doesn't publish any prebuilt `Linux` libraries, as it does for other platforms. Therefore, you need to
manually build and import `FFmpegKit` libraries into your projects. 

Then, you can use the following API methods to execute `FFmpeg` and `FFprobe` commands inside your application.

1. Execute synchronous `FFmpeg` commands.

    ```C++
    #include <FFmpegKit.h>
    #include <FFmpegKitConfig.h>

    using namespace ffmpegkit;

    auto session = FFmpegKit::execute("-i file1.mp4 -c:v mpeg4 file2.mp4");
    if (ReturnCode::isSuccess(session->getReturnCode())) {

        // SUCCESS

    } else if (ReturnCode::isCancel(session->getReturnCode())) {

        // CANCEL

    } else {

        // FAILURE
        std::cout << "Command failed with state " << FFmpegKitConfig::sessionStateToString(session->getState()) << " and rc " << session->getReturnCode() << "." << session->getFailStackTrace() << std::endl;

    }
    ```

2. Each `execute` call (sync or async) creates a new session. Access every detail about your execution from the 
   session created.

    ```C++
    #include <FFmpegKit.h>
    #include <FFmpegKitConfig.h>

    using namespace ffmpegkit;
   
    auto session = FFmpegKit::execute("-i file1.mp4 -c:v mpeg4 file2.mp4");

    // Unique session id created for this execution
    long sessionId = session->getSessionId();

    // Command arguments as a single string
    auto command = session->getCommand();

    // Command arguments
    auto arguments = session->getArguments();

    // State of the execution. Shows whether it is still running or completed
    SessionState state = session->getState();

    // Return code for completed sessions. Will be null if session is still running or ends with a failure
    auto returnCode = session->getReturnCode();

    auto startTime = session->getStartTime();
    auto endTime = session->getEndTime();
    long duration = session->getDuration();

    // Console output generated for this execution
    auto output = session->getOutput();

    // The stack trace if FFmpegKit fails to run a command
    auto failStackTrace = session->getFailStackTrace();

    // The list of logs generated for this execution
    auto logs = session->getLogs();

    // The list of statistics generated for this execution
    auto statistics = session->getStatistics();
    ```

3. Execute asynchronous `FFmpeg` commands by providing session specific `execute`/`log`/`session` callbacks.

    ```C++
    #include <FFmpegKit.h>
    #include <FFmpegKitConfig.h>

    using namespace ffmpegkit;
   
    FFmpegKit::executeAsync("-i file1.mp4 -c:v mpeg4 file2.mp4", [](auto session) {
        const auto state = session->getState();
        auto returnCode = session->getReturnCode();
   
        // CALLED WHEN SESSION IS EXECUTED

        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(state) << " and rc " << returnCode << "." << session->getFailStackTrace() << std::endl;
    }, [](auto log) {

        // CALLED WHEN SESSION PRINTS LOGS
   
    }, [](auto statistics) {
   
        // CALLED WHEN SESSION GENERATES STATISTICS

    });
    ```

4. Execute `FFprobe` commands.

    - Synchronous

    ```C++
    #include <FFprobeKit.h>
    #include <FFmpegKitConfig.h>

    using namespace ffmpegkit;

    auto session = FFprobeKit::execute(ffprobeCommand);

    if (!ReturnCode::isSuccess(session->getReturnCode())) {
        std::cout << "Command failed. Please check output for the details." << std::endl;
    }
    ```

    - Asynchronous

    ```C++
    #include <FFprobeKit.h>
    #include <FFmpegKitConfig.h>

    using namespace ffmpegkit;

    FFprobeKit::executeAsync(ffprobeCommand, [](auto session) {
   
        // CALLED WHEN SESSION IS EXECUTED

    });
    ```

5. Get media information for a file.

    ```C++
    #include <FFprobeKit.h>

    using namespace ffmpegkit;

    auto mediaInformation = FFprobeKit::getMediaInformation("<file path or uri>");
    mediaInformation->getMediaInformation();
    ```

6. Stop ongoing `FFmpeg` operations.

    - Stop all executions
        ```C++
        FFmpegKit::cancel();
        ```
    - Stop a specific session
        ```C++
        FFmpegKit::cancel(sessionId);
        ```

7. Get previous `FFmpeg` and `FFprobe` sessions from session history.

    ```C++
    #include <FFmpegKitConfig.h>

    using namespace ffmpegkit;

    auto sessions = FFmpegKitConfig::getSessions();
    int i = 0;
    std::for_each(sessions->begin(), sessions->end(), [](const auto session) {
        std::cout << "Session " << i++ << " = id:" << session->getSessionId() << ", startTime:" << session->getStartTime() << ", duration:" << session-> getDuration() << ", state:" << FFmpegKitConfig::sessionStateToString(session->getState()) << ", returnCode:" << session->getReturnCode() << "." << std::endl;
    });
    ```
8. Enable global callbacks.

    - Session type specific Complete Callbacks, called when an async session has been completed

        ```C++
        #include <FFmpegKitConfig.h>

        using namespace ffmpegkit;

        FFmpegKitConfig::enableFFmpegSessionCompleteCallback([](auto session) {

        });

        FFmpegKitConfig::enableFFprobeSessionCompleteCallback([](auto session) {

        });

        FFmpegKitConfig::enableMediaInformationSessionCompleteCallback([](auto session) {
      
        });
        ```

    - Log Callback, called when a session generates logs

        ```C++
        #include <FFmpegKitConfig.h>

        using namespace ffmpegkit;

        FFmpegKitConfig::enableLogCallback([](auto log) {
            ...
        });
        ```

    - Statistics Callback, called when a session generates statistics

        ```C++
        #include <FFmpegKitConfig.h>

        using namespace ffmpegkit;

        FFmpegKitConfig::enableStatisticsCallback([](auto statistics) {
            ...
        });
        ```

9. Register system fonts and custom font directories.

    ```C++
    #include <FFmpegKitConfig.h>

    using namespace ffmpegkit;

    FFmpegKitConfig::setFontDirectoryList(std::list<std::string>{"/usr/share/fonts"}, std::map<std::string,std::string>()));
    ```

### 4. Test Application

You can see how `FFmpegKit` is used inside an application by running `Linux` test applications developed under the
[FFmpegKit Test](https://github.com/arthenica/ffmpeg-kit-test) project.
