Pod::Spec.new do |s|  
    s.name              = "ffmpeg-kit-tvos-https-gpl"
    s.version           = "VERSION"
    s.summary           = "FFmpeg Kit tvOS Https GPL Shared Framework"
    s.description       = <<-DESC
    DESCRIPTION
    DESC

    s.homepage          = "https://github.com/arthenica/ffmpeg-kit"

    s.author            = { "Taner Sener" => "tanersener@gmail.com" }
    s.license           = { :type => "GPL-3.0", :file => "ffmpegkit.framework/LICENSE" }

    s.platform          = :tvos
    s.requires_arc      = true
    s.libraries         = 'z', 'bz2', 'c++', 'iconv'

    s.source            = { :http => "https://github.com/arthenica/ffmpeg-kit/releases/download/vVERSION/ffmpeg-kit-https-gpl-VERSION-tvos-framework.zip" }

    s.tvos.deployment_target = '10.0'
    s.tvos.frameworks   = 'AudioToolbox','VideoToolbox','CoreMedia'
    s.tvos.vendored_frameworks = 'ffmpegkit.framework', 'libavcodec.framework', 'libavdevice.framework', 'libavfilter.framework', 'libavformat.framework', 'libavutil.framework', 'libswresample.framework', 'libswscale.framework'

end  
