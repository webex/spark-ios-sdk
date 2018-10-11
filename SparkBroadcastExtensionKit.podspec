Pod::Spec.new do |s|
  s.name = "SparkBroadcastExtensionKit"
  s.version = "1.4.1"
  s.summary = "iOS Broadcast Extension Kit for Spark iOS SDK"
  s.homepage = "https://developer.webex.com"
  s.license = "MIT"
  s.author = { "Spark SDK team" => "spark-sdk-crdc@cisco.com" }
  s.source = { :git => "https://github.com/webex/spark-ios-sdk.git", :tag => s.version }
  s.ios.deployment_target = "11.2"  
  s.source_files = "Exts/BroadcastExtensionKit/SparkBroadcastExtensionKit/**/*.{h,m,swift}"
  s.preserve_paths = 'Frameworks/*.framework'
  s.xcconfig = {'FRAMEWORK_SEARCH_PATHS' => '$(PODS_ROOT)/SparkBroadcastExtensionKit/Frameworks',
                'ENABLE_BITCODE' => 'NO',
                }               
end
