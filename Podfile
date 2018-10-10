source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def shared_pods
	platform :ios, '10.0'
    pod 'Alamofire', '= 4.7.1'
    pod 'ObjectMapper', '~> 3.1'
    pod 'AlamofireObjectMapper', '~> 5.0'
    pod 'SwiftyJSON', '~> 4.0'
    pod 'Starscream', '= 3.0.5'
    pod 'KeychainAccess', '~> 3.1'
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
