Pod::Spec.new do |s|
	s.name = "BitmovinRNPlayer"
	s.version = "0.4.29"
	s.platform = :tvos, :ios
	s.swift_versions = ['5.1']
	s.summary = "ZappPlugins"
	s.description = "Zapp Plugins store Protocol and Managers that relevan for Applicaster Zapp Plugin System"
	s.homepage = "https://applicaster.com"
	s.license = ''
	s.author = "Applicaster LTD."
	s.source = {
		 :git => 'git@github.com:applicaster-plugins/TelevisionAcademyPlayerPlugin.git',
		 :tag => s.version.to_s
  }
	s.dependency 'React'
	s.dependency 'ZappCore'
    s.dependency 'BitmovinPlayer','~> 2.42.0'
    s.dependency 'BitmovinAnalyticsCollector/BitmovinPlayer','~> 1.12.0'
    s.dependency 'BitmovinAnalyticsCollector/Core','~> 1.12.0'
	s.xcconfig = {
		 'ENABLE_BITCODE' => 'YES',
		 'ENABLE_TESTABILITY' => 'YES',
		 'OTHER_CFLAGS'  => '-fembed-bitcode',
		 'SWIFT_VERSION' => '5.1'
		}

	 s.tvos.deployment_target = "10.0"
	 s.ios.deployment_target = "10.0"

	 s.source_files  = [
	    'ReactNative/*.{m,swift}',
	    'ReactNative/Analytics/*.{m,swift}'
	 ]
	 s.exclude_files = [

	 ]

end
