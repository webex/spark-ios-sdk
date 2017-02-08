source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

def shared_pods
	pod 'Alamofire', '~> 4.0.0'
	pod 'ObjectMapper', '~> 2.0.0'
	pod 'AlamofireObjectMapper', '~> 4.0.0'
	pod 'SwiftyJSON', '~> 3.1.0'
	pod 'Starscream', '~> 2.0.0'
	pod 'KeychainAccess', '~> 3.0.0'
	pod 'CocoaLumberjack/Swift', '~> 3.0.0'
end

target 'SparkSDK' do
	shared_pods
end

target 'SparkSDKTests' do
	shared_pods
end
