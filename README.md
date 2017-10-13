# Cisco Spark iOS SDK

[![CocoaPods](https://img.shields.io/cocoapods/v/SparkSDK.svg)](https://cocoapods.org/pods/SparkSDK)
[![Travis CI](https://travis-ci.org/ciscospark/spark-ios-sdk.svg?branch=master)](https://travis-ci.org/ciscospark/spark-ios-sdk)
[![license](https://img.shields.io/github/license/ciscospark/spark-ios-sdk.svg)](https://github.com/ciscospark/spark-ios-sdk/blob/master/LICENSE)

The Cisco Spark iOS SDK makes it easy to integrate secure and convenient Cisco Spark messaging and calling features in your iOS apps.

This SDK is written in [Swift 3](https://developer.apple.com/swift) and requires **iOS 9** or later.

## Table of Contents

- [Install](#install)
- [Usage](#usage)
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

    platform :ios, '9.0'
    use_frameworks!

    target 'MySparkApp' do
      pod 'SparkSDK'
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

    // ...

    spark.messages.post(personEmail: email, text: "Hello there") { response in
        switch response.result {
        case .success(let message):
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

## License

&copy; 2016-2017 Cisco Systems, Inc. and/or its affiliates. All Rights Reserved.

See [LICENSE](https://github.com/ciscospark/spark-ios-sdk/blob/master/LICENSE) for details.
