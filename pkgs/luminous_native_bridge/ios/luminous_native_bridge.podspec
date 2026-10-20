#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint luminous_native_bridge.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'luminous_native_bridge'
  s.version          = '0.0.1'
  s.summary          = 'Luminous native bridge channel layer.'
  s.description      = <<-DESC
Luminous native bridge channel layer.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'luminous_native_bridge/Sources/luminous_native_bridge/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'luminous_native_bridge_privacy' => ['luminous_native_bridge/Sources/luminous_native_bridge/PrivacyInfo.xcprivacy']}
end
