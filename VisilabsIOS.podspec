#
# Be sure to run `pod lib lint VisilabsIOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#


Pod::Spec.new do |s|
  s.name             = 'VisilabsIOS'
  s.version          = '2.5.6'
  s.summary          = 'Visilabs IOS SDK'
  s.description      = 'Visilabs IOS SDK'
  s.homepage         = 'https://www.relateddigital.com'
  s.module_name      = 'VisilabsIOS'
  s.license          = 'Apache License, Version 2.0'
  s.swift_version    = '5.0'
  s.author           = { 'Related Digital' => 'developer@relateddigital.com' }
  s.source           = { :git => 'https://github.com/relateddigital/visilabs-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'VisilabsIOS/Classes/**/*'
  s.resources     = 'VisilabsIOS/Assets/**/*'
  #s.info_plist = { 'CFBundleIdentifier' => 'com.relateddigital.visilabs' }
  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.relateddigital.visilabs' }
end
