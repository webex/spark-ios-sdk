source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

def shared_pods
	pod 'Alamofire', :git => 'https://github.com/asynchrony/Alamofire.git', :branch => 'swift3'
	pod 'ObjectMapper', :git => 'https://github.com/asynchrony/ObjectMapper.git', :branch => 'swift-3'
	pod 'AlamofireObjectMapper', :git => 'https://github.com/asynchrony/AlamofireObjectMapper.git', :branch => 'swift-3'
	pod 'SwiftyJSON', :git => 'https://github.com/asynchrony/SwiftyJSON.git', :branch => 'swift3'
	pod 'Starscream', :git => 'https://github.com/asynchrony/Starscream.git', :branch => 'swift3'
	pod 'KeychainAccess', :git => 'https://github.com/asynchrony/KeychainAccess.git', :branch => 'swift-3.0'
	pod 'CocoaLumberjack/Swift', :git => 'https://github.com/asynchrony/CocoaLumberjack.git', :branch => 'swift3'
end

target 'SparkSDK' do
	shared_pods
end

target 'SparkSDKTests' do
	shared_pods
	#pod 'Quick', '0.9.2' #no swift3 branch
	#pod 'Nimble', '4.1.0' #no swift3 branch
end
