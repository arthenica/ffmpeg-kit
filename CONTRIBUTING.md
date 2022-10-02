# How to contribute

Thanks for taking the time to contribute! :heart:

The following is a set of guidelines for contributing to `FFmpegKit`!

## Project Resources

* [Wiki](https://github.com/arthenica/ffmpeg-kit/wiki) includes most detailed documentation we have
* [FFmpegKit Feature Roadmap](https://github.com/orgs/arthenica/projects/1) shows our long term plans for the project
* [How To Get Help](https://github.com/arthenica/ffmpeg-kit/issues/215) details what you need to do if you need help
* [Discussions](https://github.com/arthenica/ffmpeg-kit/discussions) is where we expect you to ask questions
* [Issues](https://github.com/arthenica/ffmpeg-kit/issues) is for bugs and issues

## Reporting Bugs

Bugs are tracked as [GitHub issues](https://github.com/arthenica/ffmpeg-kit/issues). We have a `Bug report` issue 
template which includes all the fields we need to see to confirm a bug and work on it. Try to fill out all template
fields, especially the logs field and steps to reproduce the bug. Reproducing a bug is crucial to be able to fix it.

### FFmpeg Bugs

`FFmpegKit` does not modify the original `FFmpeg` source code. Therefore, if an `FFmpeg` feature or component is not 
working as expected, most probably that problem comes from `FFmpeg`. If you encounter those kind of errors, we expect 
you to install the desktop version of `FFmpeg` and test that feature or component there. If it fails on desktop too 
then it must be reported to [FFmpeg bug tracker](https://trac.ffmpeg.org/). If not, then it is an `FFmpegKit` bug. 
Create an issue and state that this bug doesn't exist on the `desktop` version of the same `FFmpeg` version.

## Feature Requests

Before creating a feature request, please check our long term plan for the project, which is visible under the
[FFmpegKit Feature Roadmap](https://github.com/orgs/arthenica/projects/1). Then create an issue and fill out the
`Feature request` issue template and provide as many details as possible.

### External Library Requests

`FFmpeg` supports a long list of `external` libraries. In `FFmpegKit` we did our best to support most of them. 
However, there are still many libraries that cannot be used within `FFmpegKit`.

Unfortunately, cross compilation is a challenging process. Because of that, we don't take new external library 
requests. Though, we are open to PRs. If someone wants to contribute we'll be happy to review their changes that
enables another external library in `FFmpeg`. 

## Pull Requests

Although it is not mandatory, our suggestion is to first discuss the change you wish to make via an issue or a 
discussion. `FFmpegKit` is a complex project. There are many things that must be considered when implementing a
feature.

`FFmpegKit` has a unified API, which means we provide the same functionality on all platforms. Therefore, we expect
the same from the pull requests as well. A feature must be implemented for all platforms unless it is a platform specific
feature.

Ensure that your changes rely on official documented methods and test your changes using the test applications we have
under the [ffmpeg-kit-test](https://github.com/arthenica/ffmpeg-kit-test) repository.

`main` branch of `FFmpegKit` includes only the latest released source code. Therefore, please open your pull requests
against the development branches (`development` for native platforms, `development-react-native` for
`react-native`, `development-flutter` for `flutter`). 

Note that PRs about styling and cosmetic changes will not be accepted.

Thanks!