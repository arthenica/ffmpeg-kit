Pod::Spec.new do |s|
    s.name             = 'ffmpeg-kit-ios-min'
    s.version          = '6.0.0'  # 与编译版本严格对应
    s.summary          = 'Minimal FFmpegKit build for iOS'
    s.description      = <<-DESC
                          Custom minimal build of FFmpegKit for iOS arm64 architecture.
                          Contains core ffmpeg libraries without external dependencies.
                         DESC
    s.homepage         = 'https://github.com/ZhuYilin10/ffmpeg-kit'
    s.license          = { 
      :type => 'LGPL-3.0', 
      :file => 'ffmpeg-kit-ios-min/ffmpegkit.xcframework/ios-arm64/ffmpegkit.framework/LICENSE'  # 确保LICENSE文件存在于此路径
    }
    s.author           = { 'zhuyl' => 'zhuyl.cn' }
  
    # 平台配置
    s.platform         = :ios
    s.ios.deployment_target = '12.1'  # 与你的编译目标一致
    s.requires_arc     = true
  
    # 源码配置
    s.source           = { 
      :git => 'https://github.com/ZhuYilin10/ffmpeg-kit.git', 
      :tag => s.version.to_s 
    }
  
    # 框架配置
    s.vendored_frameworks = [
      'ffmpeg-kit-ios-min/ffmpegkit.xcframework'  # 指向xcframework根目录
    ]
  end