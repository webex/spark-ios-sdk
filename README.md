# SparkSDK

Spark iOS SDK written in swift.

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

1. Create a new file "Podfile" with following content in your project directory:

    ```ruby
    source 'https://github.com/CocoaPods/Specs.git'
    source 'https://github.com/ciscospark/CocoaPodSpecs.git'
    
    platform :ios, '8.0'
    use_frameworks!
    
    pod 'SparkSDK'
    ```

1. Install SparkSDK from your project directory:

    ```bash
    pod install
    ```

## Example
Below is code of a demo of the SDK usage

1. Setup SDK with Spark access token 
   ```swift
   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let sparkAccessToken = "Yjc5ZTYyMDEt..."
        Spark.initWith(accessToken: sparkAccessToken)
        return true
    }
   ```
1. Setup SDK with app infomation, and authorize access to Spark service
   ```swift
   class LoginViewController: UIViewController {
    
        @IBAction func loginWithSpark(sender: AnyObject) {
            let clientId = "C90f769..."
            let clientSecret = "64e252..."
            let scope = "spark:people_read spark:rooms_read spark:rooms_write spark:memberships_read spark:memberships_write spark:messages_read spark:messages_write"
            let redirectUri = "SparkSDKDemo://response"
            
            Spark.initWith(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri, controller: self)
        }
    }
    ```

1. Register device
    ```swift
    Spark.phone.register() { success in
        if !success {
            print("Failed to register device.")
        }
    }
    ```
            
1. Use Spark service
    
   ```swift
   // IM example
    do {
        // Create a new room
        let room = try Spark.rooms.create(title: "Hello World")
        print("\(room.title!), created \(room.created!): \(room.id!)")
        
        // Add a coworker to the room
        try Spark.memberships.createWithPersonEmail(roomId: room.id!, personEmail: "coworker@acm.com")

        // List the members of the room
        let memberships = try Spark.memberships.list(roomId: room.id!)
        for membership in memberships {
            print("\(membership.personEmail!)")
        }

        // Post a text message to the room
        try Spark.messages.create(roomId: room.id!, text: "Hello World")

        // Share a file with the room
        try Spark.messages.create(roomId: room.id!, files: "http://example.com/hello_world.jpg")
        
    } catch let error as NSError {
        print("Error: \(error.localizedFailureReason)")
    }
    
    // Calling example
    // Make a call
    var outgoingCall: Call?
    Spark.phone.dial("coworker@acm.com", renderView: RenderView(...)) { call in
        outgoingCall = call
    }
    
    // Recive a call
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showCallToastView(_:)), name: Notifications.Phone.Incoming, ...)
    @objc func showCallToastView(notification: NSNotification) {
        var incomingCall = notification.call
    }
    ```
