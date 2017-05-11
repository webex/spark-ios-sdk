[![Travis CI](https://travis-ci.org/ciscospark/spark-ios-sdk.svg?branch=master)](https://travis-ci.org/ciscospark/spark-ios-sdk)

# Cisco Spark iOS SDK

Want to have secure and convenient audio and video interactions integrated into your iOS application? **Cisco Spark iOS SDK** is designed to ease the developer experience and accelerate the integration of pervasive into mobile applications. This guide will help you to get up running quickly with **Cisco Spark iOS SDK** in your iOS application.
 
Cisco Spark iOS SDK is written in [Swift 3](https://developer.apple.com/swift) and requires **iOS 9.0** or above.

## Setup
Assuming you already have your Xcode project, e.g., MySparkApp, for your iOS applicaiton. Here are the steps to integrate SparkSDK into your Xcode project using [CocoaPods](http://cocoapods.org):

1. Install CocoaPods:
 
    ```
    gem install cocoapods
    ```

2. Setup Cocoapods:
 
    ```
    pod setup
    ```

3. Create a new file "Podfile" with following content in your MySparkApp project directory:

    ```bash
    source 'https://github.com/CocoaPods/Specs.git'
    
    platform :ios, '9.0'
    use_frameworks!
    
    target 'MySparkApp' do
        pod 'SparkSDK'
    end
    ```

4. Install SparkSDK from your MySparkApp project directory:

    ```bash
    pod install
    ```


## Example
Below is code of a demo of the SDK usage:

1. Create the Spark SDK with Spark ID authentication ([OAuth](https://oauth.net/) based).
   
    ```swift
    let clientId = "..."
    let clientSecret = "..."
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
 
2. Create the Spark SDK with Guess ID authentication ([JWT](https://jwt.io/) based).
 
    ```swift
    let authenticator = JWTAuthenticator()
    let spark = Spark(authenticator: authenticator)

    if !authenticator.authorized {
      authenticator.authorizedWith(jwt: myJwt)
    }
    ```
 
3. Register the device to send and receive calls.
   
    ```swift
    spark.phone.register() { error in
      if let error = error {
        ... // Device was not registered, and no calls can be sent or received
      } else {
        ... // Successfully registered device
      }
    }
    ```
            
4. Use Spark service
    
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
    
5. Make an outgoing call.
 
    ```swift
    spark.phone.dial("coworker@acm.com", option: MediaOption.audioVideo(local: ..., remote: ...)) { ret in
      switch ret {
      case .success(let call):
        call.onConnected = { 

        } 
        call.onDisconnected = { reason in

        }
      case .failure(let error):
        // failure
      }
    }
    ```
 
6. Receive a call.
   
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
