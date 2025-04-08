Pod::Spec.new do |s|
  s.name             = 'ffmpeg_kit_flutter'
  s.version          = '6.0.3'
  s.summary          = 'FFmpeg Kit for Flutter'
  s.description      = 'A Flutter plugin for running FFmpeg and FFprobe commands.'
  s.homepage         = 'https://github.com/ente-io/ffmpeg-kit-forked'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ARTHENICA' => 'open-source@arthenica.com' }

  s.platform            = :ios, '12.1'
  s.requires_arc        = true
  s.static_framework    = true
w
  s.dependency          'Flutter'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.source           = {
    :http => 'https://github.com/ente-io/ffmpeg-kit-forked/releases/download/v6.0/ffmpegkit.xcframework.zip'
  }
  s.vendored_frameworks = [
    'ffmpegkit.framework',
    'libavcodec.framework',
    'libavdevice.framework',
    'libavfilter.framework',
    'libavformat.framework',
    'libavutil.framework',
    'libswresample.framework',
    'libswscale.framework'
  ]
end
