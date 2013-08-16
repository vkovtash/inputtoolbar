Pod::Spec.new do |s|
  s.name         = "InputToolbar"
  s.version      = "0.2"
  s.summary      = "Messages style input toolbar for iOS."
  s.homepage     = "https://github.com/vkovtash/inputtoolbar"
  s.license      = 'MIT'
  s.author       = { "Vlad Kovtash" => "vlad@kovtash.com" }
  s.source       = { :git => "https://github.com/vkovtash/inputtoolbar.git", :tag => "v#{s.version}"}
  s.platform     = :ios
  s.source_files = 'UIInputToolbarSample/Classes/UIInputToolbar'
  s.resources = "UIInputToolbarSample/Resources/*.png"
  s.requires_arc = true
end
