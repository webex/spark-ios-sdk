source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

def shared_pods
	pod 'Alamofire', '~> 4.0.0'
	pod 'ObjectMapper', '~> 2.0.0'
	pod 'AlamofireObjectMapper', '~> 4.0.0'
	pod 'SwiftyJSON', :git => 'https://github.com/asynchrony/SwiftyJSON.git', :branch => 'swift3'
	pod 'Starscream', '~> 2.0.0'
	pod 'KeychainAccess', '~> 3.0.0'
	pod 'CocoaLumberjack/Swift', :git => 'https://github.com/asynchrony/CocoaLumberjack.git', :branch => 'swift3'
end

target 'SparkSDK' do
	shared_pods
end

target 'SparkSDKTests' do
	shared_pods
	pod 'Quick', :git => 'https://github.com/Quick/Quick.git', :branch => 'swift-3.0'
	pod 'Nimble', :git => 'https://github.com/Quick/Nimble.git', :branch => 'master' 
end
