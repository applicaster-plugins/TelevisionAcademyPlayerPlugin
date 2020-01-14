Pod::Spec.new do |s|

    s.name             = "TelevisionAcademyIOSPlayerPlugin"
    s.version          = '0.1.0'
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
    s.resources = ['ios/TelevisionAcademyIOSPlayerPlugin/Resources/Images/*.png', 'ios/TelevisionAcademyIOSPlayerPlugin/PluginClasses/*.{xib,nib,storyboard}']
    s.source_files = 'ios/TelevisionAcademyIOSPlayerPlugin/PluginClasses/**/*.{swift,h,m}'
    s.dependency 'ZappPlugins'
    s.dependency 'BitmovinPlayer', '2.27.0'
    s.dependency 'PlayerEvents'
    s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                    'ENABLE_BITCODE' => 'YES',
                    'SWIFT_VERSION' => '5.0'
                  }
  end