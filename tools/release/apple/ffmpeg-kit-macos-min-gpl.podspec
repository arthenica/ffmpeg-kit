Pod::Spec.new do |s|  
    s.name              = "ffmpeg-kit-macos-min-gpl"
    s.version           = "VERSION"
    s.summary           = "FFmpeg Kit macOS Min GPL Shared Framework"
    s.description       = <<-DESC
    DESCRIPTION
    DESC

    s.homepage          = "https://github.com/tanersener/ffmpeg-kit"

    s.author            = { "Taner Sener" => "tanersener@gmail.com" }
    s.license           = { :type => "GPL-3.0", :file => "ffmpegkit.framework/LICENSE" }

    s.platform          = :osx
    s.requires_arc      = true
    s.libraries         = 'z', 'bz2', 'c++', 'iconv'

    s.source            = { :http => "https://github.com/tanersener/ffmpeg-kit/releases/download/vVERSION/ffmpeg-kit-min-gpl-VERSION-macos-framework.zip" }

    s.osx.deployment_target = '10.12'
    s.osx.frameworks    = 'AudioToolbox','AVFoundation','CoreAudio','CoreImage','CoreMedia','OpenCL','OpenGL','VideoToolbox'
    s.osx.vendored_frameworks = 'ffmpegkit.framework', 'libavcodec.framework', 'libavdevice.framework', 'libavfilter.framework', 'libavformat.framework', 'libavutil.framework', 'libswresample.framework', 'libswscale.framework'

end  
