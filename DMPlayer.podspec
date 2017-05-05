Pod::Spec.new do |s|
  s.name         = "DMPlayer"
  s.version      = "0.0.1"
  s.summary      = "具有弹幕功能的 ZFPlayer."
  s.homepage     = "https://github.com/Minlison/DMPlayer"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Minlison" => "yuanhang.1991@icloud.com", "unash" => "unash@exbye.com", "renzifeng" => "zifeng1300@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Minlison/DMPlayer.git", :tag => "#{s.version}" }
  s.source_files  = "DMPlayer", "DMPlayer/**/*.{h,m}"
  s.resource  = "DMPlayer/Thrid/ZFPlayer/ZFPlayer.xcassets"
  s.frameworks = "UIKit","MediaPlayer","CoreTelephony","Foundation","QuartzCore","CoreGraphics"
  s.requires_arc = true
  s.dependency "Masonry", "~> 1.0.2"
end
