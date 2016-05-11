//
//  UserAgent.swift
//  Pods
//
//  Created by bxu3 on 4/26/16.
//
//

import Foundation


class UserAgent {
    // TODO: need to check the id
    static let sharedInstance = UserAgent(identity: "spark_ios_sdk")
    
    var userAgentString: String!
    
    init(identity: String) {
        let buildVersion = Spark.version
        let currentDevice = UIDevice .currentDevice()
        let systemName = currentDevice.systemName
        let systemVersion = currentDevice.systemVersion
        let platform = self.platform()
        
        userAgentString = "\(identity)/\(buildVersion) (\(systemName) \(systemVersion); \(platform))"
    }
    
    private func platform() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return NSString(bytes: &sysinfo.machine, length: Int(_SYS_NAMELEN), encoding: NSASCIIStringEncoding)! as String
    }
}