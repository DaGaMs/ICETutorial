Pod::Spec.new do |s|
  s.name = 'ICETutorial'
  s.version = '1.0.3'
  s.summary = 'An implementation of the in-app tutorial as seen e.g. in Path 3'
  s.homepage = 'http://icepat.github.io/ICETutorial'
  s.license = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  s.author = 'Patrick Trillsam, Benjamin Schuster-Boeckler'
  s.source = {
    :git => 'https://github.com/DaGaMs/ICETutorial.git',
    :tag => '1.0.2'
  }
  s.platform = :ios, '6.0'
  s.source_files = 'ICETutorial/Libraries'
  s.public_header_files = 'ICETutorial/Libraries'
  s.frameworks = 'UIKit', 'CoreGraphics'
  s.requires_arc = true
  s.resources = ['Resources/*.png', 'ICETutorial/en.lproj/*.xib']
end