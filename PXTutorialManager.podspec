Pod::Spec.new do |s|
  s.name             = "PXTutorialManager"
  s.version          = "0.1.3"
  s.summary          = "A tutorial with an image carousel."
  s.description      = <<-DESC
                       Loads a JSON description for a tutorial and displays images and descriptions in a neat carousel.
                       DESC
  s.homepage         = "https://github.com/pixio/PXTutorialManager/"
  s.license          = 'MIT'
  s.author           = { "Daniel Blakemore" => "DanBlakemore@gmail.com" }
  s.source = {
   :git => "https://github.com/pixio/PXTutorialManager.git",
   :tag => s.version.to_s
  }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PXTutorialManager' => ['Pod/Assets/PXTutorialManager/*.{png,json}']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'UIColor-MoreColors'
  s.dependency 'PXButton'
  s.dependency 'PXUtilities'
  s.dependency 'PXImageView'
  s.dependency 'iCarousel', '~> 1.8'
end
