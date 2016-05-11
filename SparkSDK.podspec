Pod::Spec.new do |s|
  s.name         = "SparkSDK"
  s.version      = "1.0.0"
  s.summary      = "Spark IOS SDK"
  s.homepage     = "https://sqbu-github.cisco.com/Sparkguest/"
  s.license      = "MIT"
  s.author       = { "Spark guest team" => "spark-guest-crdc@cisco.com" }
  s.source    = { :git => "https://sqbu-github.cisco.com/Sparkguest/SparkKit.git", :tag => s.version }
  s.source_files = "Source/**/*.{h,m,swift}"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.vendored_frameworks = "mediaEngine/Wme.framework"
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(SRCROOT)/../mediaEngine','ENABLE_BITCODE' => 'NO'}
  s.dependency 'Alamofire', '~> 3.3.1'
  s.dependency 'ObjectMapper', '~> 1.2.0'
  s.dependency 'AlamofireObjectMapper', '~> 3.0.0'
  s.dependency 'SwiftyJSON', '~> 2.3.2'
  s.dependency 'Starscream', '~> 1.1.3'
  s.dependency 'KeychainAccess'
end

