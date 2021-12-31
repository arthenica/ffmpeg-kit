Pod::Spec.new do |s|  
    s.name              = "ffmpeg-kit-ios-video"
    s.version           = "VERSION"
    s.summary           = "FFmpeg Kit iOS Video Shared Framework"
    s.description       = <<-DESC
    DESCRIPTION
    DESC

    s.homepage          = "https://github.com/tanersener/ffmpeg-kit"

    s.author            = { "Taner Sener" => "tanersener@gmail.com" }
    s.license           = { :type => "LGPL-3.0", :file => "ffmpegkit.framework/LICENSE" }

    s.platform          = :ios
    s.requires_arc      = true
    s.libraries         = 'z', 'bz2', 'c++', 'iconv'

    s.source            = { :http => "https://github.com/tanersener/ffmpeg-kit/releases/download/vVERSION/ffmpeg-kit-video-VERSION-ios-framework.zip" }

    s.ios.deployment_target = '10'
    s.ios.frameworks    = 'AudioToolbox','AVFoundation','CoreMedia','VideoToolbox'
    s.ios.vendored_frameworks = 'ffmpegkit.framework', 'libavcodec.framework', 'libavdevice.framework', 'libavfilter.framework', 'libavformat.framework', 'libavutil.framework', 'libswresample.framework', 'libswscale.framework'

end  
