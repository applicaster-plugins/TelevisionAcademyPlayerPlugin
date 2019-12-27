Pod::Spec.new do |s|

    s.name             = "BitmovinPlayerPlugin"
    s.version          = '1.0.0'
    s.summary          = "BitmovinPlayer video player framework for Zapp iOS."
    s.description      = <<-DESC
                          BitmovinPlayer video player framework for Zapp iOS.
                         DESC
    s.homepage         = "https://github.com/applicaster-plugins/TelevisionAcademyPlayerPlugin"
    s.license          = 'MIT'
    s.author           = { "Anatolii Afanasiev" => "anatolii.afanasiev@corewillsoft.com" }
    s.source           = { :git => "https://github.com/applicaster-plugins/TelevisionAcademyPlayerPlugin.git", :tag => s.version.to_s }
  
    s.platform = :ios
    s.ios.deployment_target = "10.0"
    s.requires_arc = true
    s.swift_version = '5.0'
    s.static_framework = true
    s.resources = ['ios/Resources/Images/*.png', 'ios/PluginClasses/*.{xib,nib,storyboard}']
    s.source_files = 'ios/PluginClasses/**/*.{swift,h,m}'
    s.dependency 'ZappPlugins'
    s.dependency 'BitmovinPlayer'
    s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                    'ENABLE_BITCODE' => 'YES',
                    'SWIFT_VERSION' => '5.0'
                  }
    
  end