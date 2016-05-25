// Copyright 2016 Cisco Systems Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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