Pod::Spec.new do |s|
  s.name = "SparkSDK"
  s.version = "1.4.0"
  s.summary = "Spark iOS SDK"
  s.homepage = "https://developer.ciscospark.com"
  s.license = "MIT"
  s.author = { "Spark SDK team" => "spark-sdk-crdc@cisco.com" }
  s.source = { :git => "https://github.com/ciscospark/spark-ios-sdk.git", :tag => s.version }
  s.source_files = "Source/**/*.{h,m,swift}"
  s.requires_arc = true
  s.ios.deployment_target = "10.0"
  s.preserve_paths = 'Frameworks/*.framework'
  s.xcconfig = {'FRAMEWORK_SEARCH_PATHS' => '$(PODS_ROOT)/SparkSDK/Frameworks',
                'ENABLE_BITCODE' => 'NO',
                }
  s.vendored_frameworks = "Frameworks/*.framework"
  s.dependency 'Alamofire', '~> 4.7.1'
  s.dependency 'ObjectMapper', '~> 3.1'
  s.dependency 'AlamofireObjectMapper', '~> 5.0'
  s.dependency 'SwiftyJSON', '~> 4.0'
  s.dependency 'Starscream', '~> 3.0.5'
  s.dependency 'KeychainAccess', '~> 3.1'
end
