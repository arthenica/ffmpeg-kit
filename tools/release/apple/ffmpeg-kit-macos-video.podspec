Pod::Spec.new do |s|  
    s.name              = "ffmpeg-kit-macos-video"
    s.version           = "VERSION"
    s.summary           = "FFmpeg Kit macOS Video Static Framework"
    s.description       = <<-DESC
    DESCRIPTION
    DESC

    s.homepage          = "https://github.com/tanersener/ffmpeg-kit"

    s.author            = { "Taner Sener" => "tanersener@gmail.com" }
    s.license           = { :type => "LGPL-3.0", :file => "ffmpegkit.framework/LICENSE" }

    s.platform          = :osx
    s.requires_arc      = true
    s.libraries         = 'z', 'bz2', 'c++', 'iconv'

    s.source            = { :http => "https://github.com/tanersener/ffmpeg-kit/releases/download/vVERSION/ffmpeg-kit-video-VERSION-macos-framework.zip" }

    s.osx.deployment_target = '10.11'
    s.osx.frameworks    = 'AudioToolbox','AVFoundation','CoreAudio','CoreImage','CoreMedia','OpenCL','OpenGL','VideoToolbox'
    s.osx.vendored_frameworks = 'ffmpegkit.framework', 'libavcodec.framework', 'libavdevice.framework', 'libavfilter.framework', 'libavformat.framework', 'libavutil.framework', 'libswresample.framework', 'libswscale.framework', 'dav1d.framework', 'expat.framework', 'fontconfig.framework', 'freetype.framework', 'fribidi.framework', 'giflib.framework', 'harfbuzz.framework', 'jpeg.framework', 'kvazaar.framework', 'libass.framework', 'libogg.framework', 'libpng.framework', 'libtheora.framework', 'libtheoradec.framework', 'libtheoraenc.framework', 'libvorbis.framework', 'libvorbisenc.framework', 'libvorbisfile.framework', 'libvpx.framework', 'libwebp.framework', 'libwebpmux.framework', 'libwebpdemux.framework', 'snappy.framework', 'tiff.framework'

end  
