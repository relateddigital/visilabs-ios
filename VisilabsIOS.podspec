Pod::Spec.new do |s|
  s.name             = 'VisilabsIOS'
  s.module_name      = 'VisilabsIOS'
  s.version          = '0.0.1'
  s.summary          = 'VisilabsIOS TEST KULLANMAYIN'
  s.description      = 'VisilabsIOS TEST KULLANMAYIN'
  s.homepage         = 'https://www.relateddigital.com'
  s.license          = 'MIT'
  
  s.swift_version    = '5.0'
  s.author           = { 'Related Digital' => 'developer@relateddigital.com' }
  s.source           = { git: 'https://github.com/relateddigital/visilabs-ios.git', tag: s.version.to_s }
  s.platform     = :ios
  
  s.ios.deployment_target = '10.0'
  s.ios.source_files  = ['Sources/**/*.swift']
  s.ios.resources    = ['Sources/**/*.{html,js,png,xib}']
  s.ios.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.relateddigital.visilabs', 'DEFINES_MODULE' => 'YES' }
  s.requires_arc     = true
  #s.ios.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.relateddigital.visilabs', 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) IOS'  }
  #s.ios.pod_target_xcconfig = { }

  #TODO: Euromsg Extension'ları için supspec yapılabilir.

end
