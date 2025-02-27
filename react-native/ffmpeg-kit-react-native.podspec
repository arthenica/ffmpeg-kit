require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = package["name"]
  s.version      = package["version"]
  s.summary      = package["description"] + " (Android only)"
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platform          = :ios
  s.source            = { :git => "https://github.com/arthenica/ffmpeg-kit.git", :tag => "react.native.v#{s.version}" }
  s.source_files      = "ios/*.{h,m}"
  s.requires_arc      = true

  s.dependency "React-Core"

  # This is a placeholder podspec that doesn't include any actual FFmpeg dependencies
  # iOS support has been removed from this fork
  s.ios.deployment_target = '12.1'
end
