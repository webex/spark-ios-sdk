source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def shared_pods
	platform :ios, '10.0'
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
	platform :ios, '11.2'
end

target 'SparkBroadcastExtensionKitTests' do
	platform :ios, '11.2'
end