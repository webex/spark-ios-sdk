# SparkSDK

Spark IOS SDK written in swift.

## Setup
Here are the steps to integrate SparkSDK into your Xcode project using [CocoaPods](http://cocoapods.org):

1. Install CocoaPods:
    ```bash
    gem install cocoapods
    ```

1. Setup Cocoapods:
    ```bash
    pod setup
    ```

1. Create a new file "Podfile" with following content in your project directory::

    ```ruby
      platform :ios, '8.0'
      use_frameworks!

      pod 'SparkSDK'
    ```

1. Install SparkSDK from your project directory:

    ```bash
    pod install
    ```

## Example:
Below is code of a demo of the SDK usage

1. Setup SDK with Spark access Token 
   ```swift
   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let sparkAccessToken = "Yjc5ZTYyMDEt..."
        Spark.setupWithSparkAccessToken(sparkAccessToken)
        return true
    }
   ```
1. Setup SDK with Guest access Token
   ```swift
   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let guestAccessToken = "Yjc5ZTYyMDEt..."
        Spark.setupWithGuestAccessToken(guestAccessToken)
        return true
    }
   ```
1. Setup SDK with App Info
   ```swift
   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let clientID = "C1dc0c47e..."
        let clientSecret = "c086fc9c..."
        let scope = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write"
        let redirectURI = "SparkSDKDemo://response"
        
        Spark.setupWithAppKey(clientID,
            clientSecret: clientSecret,
            scope: scope,
            redirectURI: redirectURI)
        return true
    }
    ```
1. OAuth authorize to Spark platform
   ```swift
   @IBAction func loginWithSpark(sender: AnyObject) {
        Spark.authorizeFromController(self)
    }
   ```
   A webview will be presented for SSO login. Observe the notification of authentication status.
  ```swift
   NSNotificationCenter.defaultCenter().addObserver(
        
        self,
        selector: "handleAuth",
        name: Spark.notificationSucceedAuthentication,
        object: nil
    )
   ```
   A convinience method to check if authorized.
   ```swift
   Spark.authorized()
   ```
1. Use Spark service with Spark SDK
   ```swift
func example() {
        // List the rooms that I'm in
        if let rooms = Spark.rooms.list() {
            for room in rooms {
                print("\(room.title!), created \(room.created!): \(room.id!)")
            }
        }
        
        // Create a new room
        if let room = Spark.rooms.create(title: "Hello World") {
            print("\(room.title!), created \(room.created!): \(room.id!)")
            
            // Add a coworker to the room
            Spark.memberships.create(roomId: room.id!, personEmail: "coworker@acm.com")
            
            // List the members of the room
            if let memberships = Spark.memberships.list(roomId: room.id!) {
                for membership in memberships {
                    print("\(membership.personEmail!)")
                }
            }
            
            // Post a text message to the room
            Spark.messages.create(roomId: room.id!, text: "Hello World")
            
            // Share a file with the room
            Spark.messages.create(roomId: room.id!, files: "http://example.com/hello_world.jpg")
        }
    }
    ```
    
## SparkSDKDemo
A demo app for the Spark SDK. Here are the steps to build it: 

1. Install SparkSDK from app directory ./example: (assume Cocoapods setup is already done.)

    ```bash
    pod install
    ```
1. Open ./example/SparkSDKDemo.xcworkspace with xcode.

1. Build target "SparkSDKDemo" in xcode. Make sure your iphone is connected to your computer, and select your device for build, because call functionality only works with device.
