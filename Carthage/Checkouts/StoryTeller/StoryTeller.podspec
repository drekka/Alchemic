
Pod::Spec.new do |s|

  s.homepage     = "https://github.com/drekka/StoryTeller"
  s.summary      = "A logging framework which bases logging on the data rather than severity."
  s.description  = "A logging framework which bases logging on the data rather than severity."
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Derek Clarkson" => "d4rkf1br3@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/drekka/StoryTeller.git", :tag => "v0.1" }
  s.source_files = "StoryTeller/**/*.{h,m}"
  s.public_header_files = "StoryTeller/**/*.h"
  s.requires_arc = true
  
end
