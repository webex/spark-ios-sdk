# Cisco Spark iOS SDK

[![CocoaPods](https://img.shields.io/cocoapods/v/SparkSDK.svg)](https://cocoapods.org/pods/SparkSDK)
[![Travis CI](https://travis-ci.org/webex/spark-ios-sdk.svg?branch=master)](https://travis-ci.org/webex/spark-ios-sdk)
[![license](https://img.shields.io/github/license/webex/spark-ios-sdk.svg)](https://github.com/ciscospark/spark-ios-sdk/blob/master/LICENSE)

The Cisco Spark iOS SDK makes it easy to integrate secure and convenient Cisco Spark messaging and calling features in your iOS apps.

This SDK is written in [Swift 4](https://developer.apple.com/swift) and requires **iOS 10** or later.

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Upgrade 1.3.1 to 1.4.0](#upgrade-sdk-1.3.1-to-1.4.0-breaking-changes)
- [License](#license)

## Install

Assuming you already have an Xcode project, e.g. _MySparkApp_, for your iOS app, here are the steps to integrate the Spark iOS SDK into your Xcode project using [CocoaPods](http://cocoapods.org):

1. Install CocoaPods:

    ```bash
    gem install cocoapods
    ```

2. Setup CocoaPods:

    ```bash
    pod setup
    ```

3. Create a new file, `Podfile`, with following content in your _MySparkApp_ project directory:

    ```ruby
    source 'https://github.com/CocoaPods/Specs.git'
    
    use_frameworks!

    target 'MySparkApp' do
      platform :ios, '10.0'
      pod 'SparkSDK'
    end
    
    target 'MySparkAppBroadcastExtension' do
        platform :ios, '11.2'
        pod 'SparkBroadcastExtensionKit'
    end
    ```

4. Install the Spark iOS SDK from your _MySparkApp_ project directory:

    ```bash
    pod install
    ```

## Usage

To use the SDK, you will need Cisco Spark integration credentials. If you do not already have a Cisco Spark account, visit [Spark for Developers](https://developer.ciscospark.com/) to create your account and [register your integration](https://developer.ciscospark.com/authentication.html#registering-your-integration). Your app will need to authenticate users via an [OAuth](https://oauth.net/) grant flow for existing Cisco Spark users or a [JSON Web Token](https://jwt.io/) for guest users without a Cisco Spark account.

See the [iOS SDK area](https://developer.ciscospark.com/sdk-for-ios.html) of the Spark for Developers site for more information about this SDK.

### Example

Here are some examples of how to use the iOS SDK in your app.

1. Create the Spark instance using Spark ID authentication ([OAuth](https://oauth.net/)-based):

    ```swift
    let clientId = "$YOUR_CLIENT_ID"
    let clientSecret = "$YOUR_CLIENT_SECRET"
    let scope = "spark:all"
    let redirectUri = "Sparkdemoapp://response"

    let authenticator = OAuthAuthenticator(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
    let spark = Spark(authenticator: authenticator)

    if !authenticator.authorized {
        authenticator.authorize(parentViewController: self) { success in
            if !success {
                print("User not authorized")
            }
        }
    }
    ```

2. Create the Spark instance with Guest ID authentication ([JWT](https://jwt.io/)-based):

    ```swift
    let authenticator = JWTAuthenticator()
    let spark = Spark(authenticator: authenticator)

    if !authenticator.authorized {
        authenticator.authorizedWith(jwt: myJwt)
    }
    ```

3. Register the device to send and receive calls:

    ```swift
    spark.phone.register() { error in
        if let error = error {
            // Device not registered, and calls will not be sent or received
        } else {
            // Device registered
        }
    }
    ```

4. Use Spark service:

    ```swift
    spark.rooms.create(title: "Hello World") { response in
        switch response.result {
        case .success(let room):
            // ...
        case .failure(let error):
            // ...
        }
    }

    // ...

    spark.memberships.create(roomId: roomId, personEmail: email) { response in
        switch response.result {
        case .success(let membership):
            // ...
        case .failure(let error):
            // ...
        }
    }
    
    ```

5. Make an outgoing call:

    ```swift
    spark.phone.dial("coworker@acm.com", option: MediaOption.audioVideo(local: ..., remote: ...)) { ret in
        switch ret {
        case .success(let call):
            call.onConnected = {
                // ...
            }
            call.onDisconnected = { reason in
                // ...
            }
        case .failure(let error):
            // failure
        }
    }
    ```

6. Receive a call:

    ```swift
    spark.phone.onIncoming = { call in
        call.answer(option: MediaOption.audioVideo(local: ..., remote: ...)) { error in
        if let error = error {
            // success
        }
        else {
            // failure
        }
    }
    ```

7. Make an room call:

    ```swift
    spark.phone.dial(roomId, option: MediaOption.audioVideo(local: ..., remote: ...)) { ret in
        switch ret {
        case .success(let call):
            call.onConnected = {
                // ...
            }
            call.onDisconnected = { reason in
                // ...
            }
            call.onCallMembershipChanged = { changed in
                switch changed {
                case .joined(let membership):
                    //
                case .left(let membership):
                    //
                default:
                    //
                }                
            }            
        case .failure(let error):
            // failure
        }
    }
    ```
    
8. Screen share (view only):

    ```swift
    spark.phone.dial("coworker@acm.com", option: MediaOption.audioVideoScreenShare(video: (local: ..., remote: ...))) { ret in
        switch ret {
        case .success(let call):
            call.onConnected = {
                // ...
            }
            call.onDisconnected = { reason in
                // ...
            }
            call.onMediaChanged = { changed in
                switch changed {
                    ...
                case .remoteSendingScreenShare(let sending):
                    call.screenShareRenderView = sending ? view : nil
                }
            }
        case .failure(let error):
            // failure
        }
    }
    ```
9. Post a message:
    ```
    spark.messages.post(personEmail: email, text: "Hello there") { response in
        switch response.result {
        case .success(let message):
            // ...
        case .failure(let error):
            // ...
        }
    }
    ```
10. Receive a message:
    ```
    spark.messages.onEvent = { messageEvent in
        switch messageEvent{
        case .messageReceived(let message):
            // ...
            break
        case .messageDeleted(let messageId):
            // ...
            break
        }
    }
    ```
11. Screen share (sending):

    11.1 In your containing app:
    ```swift
    spark.phone.dial("coworker@acm.com", option: MediaOption.audioVideoScreenShare(video: ..., screenShare: ..., applicationGroupIdentifier: "group.your.application.group.identifier"))) { ret in
        switch ret {
        case .success(let call):
            call.oniOSBroadcastingChanged = {
                event in
                if #available(iOS 11.2, *) {
                    switch event {
                    case .extensionConnected :
                        call.startSharing() {
                            error in
                            // ...
                        }
                        break
                    case .extensionDisconnected:
                        call.stopSharing() {
                            error in
                            // ...
                        }
                        break
                    }
                }
            }
            }
        case .failure(let error):
            // failure
        }
    }
    ```
    11.2 In your broadcast upload extension sample handler:
    ```swift
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        SparkBroadcastExtension.sharedInstance.start(applicationGroupIdentifier: "group.your.application.group.identifier") {
            error in
            if let sparkError = error {
               // ...
            } else {
                SparkBroadcastExtension.sharedInstance.onError = {
                    error in
                    // ...
                }
                SparkBroadcastExtension.sharedInstance.onStateChange = {
                    state in
                    // state change
                }
            }
        }
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        SparkBroadcastExtension.sharedInstance.finish()
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
            case RPSampleBufferType.video:
                // Handle video sample buffer
                SparkBroadcastExtension.sharedInstance.handleVideoSampleBuffer(sampleBuffer: sampleBuffer)
                break
            case RPSampleBufferType.audioApp:
                // Handle audio sample buffer for app audio
                break
            case RPSampleBufferType.audioMic:
                // Handle audio sample buffer for mic audio
                break
        }
    }
    ```
    11.3 Get more technical details about the [Containing App & Broadcast upload extension](https://github.com/webex/spark-ios-sdk/wiki/Implementation-Broadcast-upload-extension) and [Set up an App Group](https://github.com/webex/spark-ios-sdk/wiki/Set-up-an-App-Group)

## Upgrade SDK 1.3.1 to 1.4.0 Breaking Changes
1. Minimum Deployment Target: ~~8.0~~ => 10.0
2. Support Swift Language Version: ~~3.0~~ => 4.0
3. If you were using 'MediaRenderView', need to add 'import SparkSDK". 
4. If you were using 'MediaRenderView' class in storyboard, need to set view's module to 'SparkSDK'.

## License

&copy; 2016-2018 Cisco Systems, Inc. and/or its affiliates. All Rights Reserved.

See [LICENSE](https://github.com/ciscospark/spark-ios-sdk/blob/master/LICENSE) for details.
