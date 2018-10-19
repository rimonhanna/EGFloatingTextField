Pod::Spec.new do |s|
  s.name             = "EGFloatingTextField"
  s.version          = "1.1.4"
  s.summary          = "Implementation of Google's 'Floating labels' of Material design."
  s.homepage         = "https://github.com/rimonhanna/EGFloatingTextField"
  s.license          = 'MIT'
  s.author           = { "Rimon Hanna" => "rimon.ragaie@gmail.com" }
  s.source           = { :git => "https://github.com/rimonhanna/EGFloatingTextField.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/rimon_hanna'
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.dependency 'PureLayout', '~>3.0.2'
  s.source_files = 'EGFloatingTextField/EGFloatingTextField/*.swift'
  s.resource = 'EGFloatingTextField/EGFloatingTextField/**/*.{lproj}'
end

