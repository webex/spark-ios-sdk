source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def shared_pods
	platform :ios, '9.0'
	pod 'Alamofire', '~> 4.0'
	pod 'ObjectMapper', '~> 2.0'
	pod 'AlamofireObjectMapper', '~> 4.0'
	pod 'SwiftyJSON', '~> 3.1'
	pod 'Starscream', '~> 2.0'
	pod 'KeychainAccess', '~> 3.0'
end

target 'SparkSDK' do
	shared_pods
end

target 'SparkSDKTests' do
	shared_pods
end

target 'SparkBroadcastExtensionKit' do
	platform :ios, '11.0'
	shared_pods
end

target 'SparkBroadcastExtensionKitTests' do
	shared_pods
end