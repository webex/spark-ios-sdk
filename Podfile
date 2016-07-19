source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

def shared_pods
    pod 'Alamofire', '~> 3.3.1'
    pod 'ObjectMapper', '~> 1.2.0'
    pod 'AlamofireObjectMapper', '= 3.0.0'
    pod 'SwiftyJSON', '~> 2.3.2'
    pod 'Starscream', '~> 1.1.3'
    pod 'KeychainAccess', '~> 2.3.5'
    pod 'CocoaLumberjack/Swift', '~> 2.3.0'
end

target 'SparkSDK' do
    shared_pods
end

target 'SparkSDKTests' do
    shared_pods
    pod 'Quick', '0.9.2'
    pod 'Nimble', '4.1.0'
end
