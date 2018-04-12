Pod::Spec.new do |s|
s.name         = "JKBadgeKit"
s.version      = "0.0.1"
s.summary      = "Little red dot scheme"
s.homepage     = "https://github.com/JekinChou/JKBadgeKit"
s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
s.author             = { "zhangjie" => "454200568@qq.com" }
s.source       = { :git => "https://github.com/JekinChou/JKBadgeKit.git", :tag => "#{s.version}" }
s.platform = :ios, '8.0'
s.requires_arc = true
s.ios.deployment_target = '8.0'
s.source_files = 'JKBadgeKit/JKBadgeKit/JKBadgeFramework/**/*'
s.public_header_files = 'JKBadgeKit/JKBadgeKit/JKBadgeFramework/**/*.{h}'
end
