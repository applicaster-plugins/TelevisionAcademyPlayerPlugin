Pod::Spec.new do |s|

    s.name             = "TelevisionAcademyIOSPlayerPlugin"
    s.version          = '0.6.0'
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
    s.swift_version = '5.1'
    s.static_framework = true
    s.resources = ['ios/TelevisionAcademyIOSPlayerPlugin/SupportingFiles/*']
    s.source_files = 'ios/TelevisionAcademyIOSPlayerPlugin/PluginClasses/*.swift','ios/TelevisionAcademyIOSPlayerPlugin/PluginClasses/**/*.swift'
    s.dependency 'BitmovinPlayer','~> 2.42.0'
    s.dependency 'google-cast-sdk-no-bluetooth', '= 4.4.4'
    s.dependency 'BitmovinAnalyticsCollector/BitmovinPlayer','~> 1.12.0'
    s.dependency 'BitmovinAnalyticsCollector/Core','~> 1.12.0'
    s.dependency 'PlayerEvents'
    s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                    'ENABLE_BITCODE' => 'YES',
                    'SWIFT_VERSION' => '5.1'
                  }
  end