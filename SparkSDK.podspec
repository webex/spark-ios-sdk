Pod::Spec.new do |s|
  s.name = "SparkSDK"
  s.version = "1.3.0"
  s.summary = "Spark iOS SDK"
  s.homepage = "https://developer.ciscospark.com"
  s.license = "MIT"
  s.author = { "Spark SDK team" => "spark-sdk-crdc@cisco.com" }
  s.source = { :git => "https://github.com/ciscospark/spark-ios-sdk.git", :tag => s.version }
  s.source_files = "Source/**/*.{h,m,swift}"
  s.requires_arc = true
  s.ios.deployment_target = "9.0"
  s.preserve_paths = 'Vendors/*.framework'
  s.xcconfig = {'FRAMEWORK_SEARCH_PATHS' => '$(PODS_ROOT)/SparkSDK/MediaEngine',
                'ENABLE_BITCODE' => 'NO',
                'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/SparkSDK/Vendors/cjose/include' '$(PODS_ROOT)/SparkSDK/Vendors/json-c/include' '$(PODS_ROOT)/SparkSDK/Vendors/openssl/include',
                'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/SparkSDK/Vendors/cjose/lib' '$(PODS_ROOT)/SparkSDK/Vendors/openssl/lib' '$(PODS_ROOT)/SparkSDK/Vendors/json-c/lib',
                }
  s.vendored_frameworks = "MediaEngine/*"
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'ObjectMapper', '~> 2.0'
  s.dependency 'AlamofireObjectMapper', '~> 4.0'
  s.dependency 'SwiftyJSON', '~> 3.0'
  s.dependency 'Starscream', '~> 2.0'
  s.dependency 'KeychainAccess', '~> 3.0'
end
