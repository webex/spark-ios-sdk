[![Travis CI](https://travis-ci.org/ciscospark/spark-ios-sdk.svg?branch=master)](https://travis-ci.org/ciscospark/spark-ios-sdk)

# Cisco Spark iOS SDK

Want to have secure and convenient audio and video interactions integrated into your iOS application? **Cisco Spark iOS SDK** is designed to ease the developer experience and accelerate the integration of pervasive into mobile applications. This guide will help you to get up running quickly with **Cisco Spark iOS SDK** in your iOS application.
 
Cisco Spark iOS SDK is written in [Swift](https://developer.apple.com/swift) and requires **iOS 9.0** or above.

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
   let clientId = "Def123456..."
   let clientSecret = "fed456..."
   let scope = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write"
   let redirectUri = "MyCustomApplication://response"
   let oauthStrategy = OAuthStrategy(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri)
   let spark = Spark(authenticationStrategy: oauthStrategy)
   // ...
   if !oauthStrategy.authorized {
       oauthStrategy.authorize(parentViewController: self) { success in
           if !success {
               print("User not authorized")
           }
       }
   }
   ```
 
2. Create the Spark SDK with Guess ID authentication ([JWT](https://jwt.io/) based).
 
   ```swift
   let jwtAuthStrategy = JWTAuthStrategy()
   let spark = Spark(authenticationStrategy: jwtAuthStrategy)
   // ...
   if !jwtAuthStrategy.authorized {
       // obtain JWT through some application-specific mechanism  
       jwtAuthStrategy.authorizedWith(jwt: myJwt)
   }
   ```
 
3. Register the device to send and receive calls.
 
   ```swift
   spark.phone.register() { success in
       if success {
           // Successfully registered device
       } else {
           // Device was not registered, and no calls can be sent or received
       }
   }
   ```
            
4. Use Spark service
    
   ```swift
   spark.rooms.create(title: "My Room") { serviceResponse in
       switch serviceResponse.result {
       case .success(let room):
           // Room was created
       case .failure(let error):
           // Room creation failed
       }
   }
 
   // ... 
 
   if let roomId = room.id {
       spark.memberships.create(roomId: roomId, personId: coworkerId) { serviceResponse in
           // ...
       }
 
       spark.messages.post(roomId: roomId, text: "Hello friend!") { serviceResponse in
           // ...
       }
   }
   ```
    
5. Make an outgoing call.
 
   ```swift
   let address = "coworker@example.com"
   spark.phone.requestMediaAccess(Phone.MediaAccessType.audioVideo) { granted in
       if granted {
           // Prepare view for an outgoing call, including ensuring MediaRenderViews
           // are created if making a video call
           let localVideoView = MediaRenderView()
           let remoteVideoView = MediaRenderView()
           let mediaOption = MediaOption.audioVideo(local: localVideoView, remote: remoteVideoView)
           let call = spark.phone.dial(address, option: mediaOption) { success in
               if success {
                   // Call will be soon be ringing on the remote user's phone
               } else {
                   // A service call may have failed, the user may have rejected the
                   // codec license, or the address could have been incorrect
               }
           }
       } else {
           // User denied access to use the camera or microphone
       }
   }
   ```
 
6. Receive a call.
 
   ```swift
   class MyCallObserver: CallObserver {
       func callIncoming(_ call: Call) {
           // Show incoming call view
           let userAcceptedCall: Bool = // ... from user action
           if userAcceptedCall {
               let mediaOption = // ... set up a media option similarly to dialing
               call.answer(option: mediaOption) { success in
               }
           } else {
               // If the user chose to reject the call then reject it
               call.reject() { success in
               }
           }
       }
   }
   ```
