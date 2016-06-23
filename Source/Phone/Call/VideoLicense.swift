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

class VideoLicense {
    
    static let sharedInstance = VideoLicense()
    
    private let userDefaults = UserDefaults.sharedInstance
    
    func checkActivation(completion: (isActivated: Bool) -> Void) {
        guard needActivation() else {
            completion(isActivated: true)
            return
        }
        
        promptForActivation(completion)
    }
    
    func disableActivation() {
        userDefaults.isVideoLicenseActivationDisabled = true
    }
    
    // It's used for development only, to reset video license settings.
    func resetActivation() {
        userDefaults.removeVideoLicenseSetting()
    }
    
    private func promptForActivation(completion: (isActivated: Bool) -> Void) {
        let AlertTitle = "Activate License"
        let AlertMessage = "To enable video calls, activate a free video license (H.264 AVC) from Cisco. By selecting 'Activate', you accept the Cisco End User License Agreement and Notices."
        
        let alertController = UIAlertController(title: AlertTitle, message: AlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Activate", style: UIAlertActionStyle.Default) { _ in
            self.activateLicense()
            completion(isActivated: true)
            })
        alertController.addAction(UIAlertAction(title: "View License", style: UIAlertActionStyle.Default) { _ in
            completion(isActivated: false)
            self.viewLicense()
            })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { _ in
            completion(isActivated: false)
            })
        
        alertController.present(true, completion: nil)
    }
    
    private func needActivation() -> Bool {
        if userDefaults.isVideoLicenseActivated || userDefaults.isVideoLicenseActivationDisabled {
            return false
        }
        
        return true
    }
    
    private func activateLicense() {
        userDefaults.isVideoLicenseActivated = true
        CallMetrics.sharedInstance.reportVideoLicenseActivation()
    }
    
    private func viewLicense() {
        guard let url = NSURL(string: "http://www.openh264.org/BINARY_LICENSE.txt") else {
            return
        }
        
        UIApplication.sharedApplication().openURL(url)
    }
}