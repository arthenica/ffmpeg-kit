require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = package["name"]
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platform          = :ios
  s.requires_arc      = true
  s.static_framework  = true

  s.source       = { :git => "https://github.com/arthenica/ffmpeg-kit.git", :tag => "react.native.v#{s.version}" }

  s.default_subspec   = 'https'

  s.dependency "React-Core"

  s.subspec 'min' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-min', "6.0"
      ss.ios.deployment_target = '12.1'
  end

  s.subspec 'min-lts' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-min', "6.0.LTS"
      ss.ios.deployment_target = '10'
  end

  s.subspec 'min-gpl' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-min-gpl', "6.0"
      ss.ios.deployment_target = '12.1'
  end

  s.subspec 'min-gpl-lts' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-min-gpl', "6.0.LTS"
      ss.ios.deployment_target = '10'
  end

  s.subspec 'https' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-https', "6.0"
      ss.ios.deployment_target = '12.1'
  end

  s.subspec 'https-lts' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-https', "6.0.LTS"
      ss.ios.deployment_target = '10'
  end

  s.subspec 'https-gpl' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-https-gpl', "6.0"
      ss.ios.deployment_target = '12.1'
  end

  s.subspec 'https-gpl-lts' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-https-gpl', "6.0.LTS"
      ss.ios.deployment_target = '10'
  end

  s.subspec 'audio' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-audio', "6.0"
      ss.ios.deployment_target = '12.1'
  end

  s.subspec 'audio-lts' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-audio', "6.0.LTS"
      ss.ios.deployment_target = '10'
  end

  s.subspec 'video' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-video', "6.0"
      ss.ios.deployment_target = '12.1'
  end

  s.subspec 'video-lts' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-video', "6.0.LTS"
      ss.ios.deployment_target = '10'
  end

  s.subspec 'full' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-full', "6.0"
      ss.ios.deployment_target = '12.1'
  end

  s.subspec 'full-lts' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-full', "6.0.LTS"
      ss.ios.deployment_target = '10'
  end

  s.subspec 'full-gpl' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-full-gpl', "6.0"
      ss.ios.deployment_target = '12.1'
  end

  s.subspec 'full-gpl-lts' do |ss|
      ss.source_files      = '**/FFmpegKitReactNativeModule.m',
                             '**/FFmpegKitReactNativeModule.h'
      ss.dependency 'ffmpeg-kit-ios-full-gpl', "6.0.LTS"
      ss.ios.deployment_target = '10'
  end

end
