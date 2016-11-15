Pod::Spec.new do |s|
  s.name         = "ZIMInputToolbar"
  s.version      = "0.8.2"
  s.platform = :ios , "8.0"
  s.ios.deployment_target = "8.0"
  s.summary      = "Messages style input toolbar for iOS."
  s.homepage     = "https://github.com/vkovtash/inputtoolbar"
  s.license      = 'MIT'
  s.author       = { "Vlad Kovtash" => "v.kovtash@gmail.com" }
  s.source       = { :git => "https://github.com/vkovtash/inputtoolbar.git", :tag => s.version.to_s }
  s.source_files = "ZIMInputToolbar/Classes/*.{h,m}"
  s.resources = "ZIMInputToolbar/Resources/*.png"
  s.requires_arc = true
end
