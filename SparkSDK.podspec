Pod::Spec.new do |s|
  s.name = "SparkSDK"
  s.version = "0.9.142"
  s.summary = "Spark iOS SDK"
  s.homepage = "https://developer.ciscospark.com"
  s.license = "MIT"
  s.author = { "Spark SDK team" => "spark-sdk-crdc@cisco.com" }
  s.source = { :git => "https://github.com/ciscospark/spark-ios-sdk.git", :tag => s.version }
  s.source_files = "Source/**/*.{h,m,swift}"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.resource = 'MediaEngine/Wme.framework'
  s.preserve_paths = 'MediaEngine/Wme.framework'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/SparkSDK/MediaEngine"', 'ENABLE_BITCODE' => 'NO'}
  s.vendored_frameworks = "MediaEngine/Wme.framework"
  s.dependency 'Alamofire', '~> 3.3.1'
  s.dependency 'ObjectMapper', '~> 1.2.0'
  s.dependency 'AlamofireObjectMapper', '~> 3.0.0'
  s.dependency 'SwiftyJSON', '~> 2.3.2'
  s.dependency 'Starscream', '~> 1.1.3'
  s.dependency 'KeychainAccess'
end

