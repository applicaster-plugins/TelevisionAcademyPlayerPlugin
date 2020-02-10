Pod::Spec.new do |s|
	s.name = "BitmovinRNPlayer"
	s.version = "0.0.2"
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
	s.dependency 'ZappPlugins'
    s.dependency 'BitmovinPlayer','~> 2.37.0'
	s.xcconfig = {
		 'ENABLE_BITCODE' => 'YES',
		 'ENABLE_TESTABILITY' => 'YES',
		 'OTHER_CFLAGS'  => '-fembed-bitcode',
		 'SWIFT_VERSION' => '5.1'
		}

	 s.tvos.deployment_target = "10.0"
	 s.ios.deployment_target = "10.0"

	 s.source_files  = [
	    'ReactNative/*.{m,swift}'
	 ]
	 s.exclude_files = [

	 ]

end
