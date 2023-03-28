Pod::Spec.new do |s|
  s.name             = 'VisilabsIOS'
  s.module_name      = 'VisilabsIOS'
  s.version          = '3.9.0'
  s.summary          = 'VisilabsIOS IOS SDK'
  s.description      = 'VisilabsIOS IOS SDK for analytics and recommendation'
  s.homepage         = 'https://www.relateddigital.com'
  s.license          = 'Apache License, Version 2.0'
  s.swift_version    = '5.0'
  s.author           = { 'Related Digital' => 'developer@relateddigital.com' }
  s.source           = { git: 'https://github.com/relateddigital/visilabs-ios.git', tag: s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files  = ['Sources/**/*.{swift,h,m,xib}']
  s.resources    = ['Sources/Assets/**/*.{html,js,png}']
  s.ios.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.relateddigital.visilabs'}
  s.requires_arc     = true
end
