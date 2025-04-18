Pod::Spec.new do |s|
  s.name             = 'ffmpeg_kit_flutter'
  s.version          = '6.0.5'
  s.summary          = 'FFmpeg Kit for Flutter'
  s.description      = 'A Flutter plugin for running FFmpeg and FFprobe commands.'
  s.homepage         = 'https://github.com/SungjunApp/ffmpeg-kit'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Sungjun' => 'sungjun.app@vocalhong.com' }

  s.platform            = :ios
  s.ios.deployment_target = '12.1'
  s.requires_arc        = true
  s.static_framework    = true

  s.source_files        = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.dependency          'Flutter'

  s.source              = { :path => '.' }

  s.vendored_frameworks = [
    'bundle-apple-xcframework-ios/ffmpegkit.xcframework',
    'bundle-apple-xcframework-ios/libavcodec.xcframework',
    'bundle-apple-xcframework-ios/libavdevice.xcframework',
    'bundle-apple-xcframework-ios/libavfilter.xcframework',
    'bundle-apple-xcframework-ios/libavformat.xcframework',
    'bundle-apple-xcframework-ios/libavutil.xcframework',
    'bundle-apple-xcframework-ios/libswresample.xcframework',
    'bundle-apple-xcframework-ios/libswscale.xcframework'
  ]

  s.preserve_paths = 'bundle-apple-xcframework-ios/**'

  s.frameworks = [
    "AudioToolbox",
    "AVFoundation",
    "CoreMedia",
    "VideoToolbox"
  ]
end
