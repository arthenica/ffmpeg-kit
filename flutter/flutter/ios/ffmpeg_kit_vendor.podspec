Pod::Spec.new do |s|
    s.name             = 'ffmpeg_kit_vendor'
    s.version          = '6.0'
    s.summary          = 'FFmpegKit for iOS with full-gpl configuration'
    s.description      = 'FFmpegKit prebuilt xcframework for iOS, full-gpl version.'
    s.homepage         = 'https://github.com/ente-io/ffmpeg-kit-forked'
    s.license          = { :type => 'GPL', :file => 'LICENSE' }
    s.author           = { 'Prateek' => 'prtksunal@gmail.com' }
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
    s.platform     = :ios, '12.1'
    s.swift_version = '5.0'
  end