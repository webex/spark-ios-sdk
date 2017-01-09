//
//  BackgroundCallNotifications.swift
//  SparkSDK
//
//  Created by Rik van den Brule on 29/11/2016.
//  Copyright © 2016 Cisco. All rights reserved.
//

import Foundation

/// Defines notifications to notify SparkSDK of calls when the application is in the background.
/// 
/// These notifications can be posted to `NSNotificationCenter` to let SparkSDK handle background calls.
@objc public class SparkBackgroundCallNotifications: NSObject {

    /// Notify SparkSDK that a call is incoming while the app is in the background.
    public static let SparkCallIncomingInBackground = Notification(name:
        Notification.Name(rawValue: "com.ciscospark.SparkCallIncomingInBackground"), object: nil)

    /// Notify SparkSDK that an incoming background call was declined while the app was in the background.
    public static let SparkCallDeclinedInBackground = Notification(name:
        Notification.Name(rawValue: "com.ciscospark.SparkCallDeclinedInBackground"), object: nil)
}
