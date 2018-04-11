Pod::Spec.new do |s|
  s.name = "SparkBroadcastExtensionKit"
  s.version = "1.4.0"
  s.summary = "Spark iOS SDK"
  s.homepage = "https://developer.ciscospark.com"
  s.license = "MIT"
  s.author = { "Spark SDK team" => "spark-sdk-crdc@cisco.com" }
  s.source = { :git => "https://github.com/ciscospark/spark-ios-sdk.git", :tag => s.version }
  s.source_files = "SparkBroadcastExtensionKit/**/*.{h,m,swift}"
  s.requires_arc = true
  s.ios.deployment_target = "11.2"
  s.preserve_paths = 'Vendors/*.framework'
  s.xcconfig = {'FRAMEWORK_SEARCH_PATHS' => '$(PODS_ROOT)/SparkSDK/Vendors',
                'ENABLE_BITCODE' => 'NO',
                }
  s.vendored_frameworks = "Vendors/*.framework"
end
