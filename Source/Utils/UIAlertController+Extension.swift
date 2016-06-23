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

extension UIAlertController {
    
    // Present the alert on top of the visible UIViewController.
    func present(animated: Bool, completion: (() -> Void)?) {
        // Get new UIWindow at the top of the window hierarchy
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = UIViewController()
        window.backgroundColor = UIColor.clearColor()
        window.windowLevel = UIWindowLevelAlert
        
        if let rootVC = window.rootViewController {
            window.makeKeyAndVisible()
            rootVC.presentViewController(self, animated: animated, completion: completion)
        }
    }
}