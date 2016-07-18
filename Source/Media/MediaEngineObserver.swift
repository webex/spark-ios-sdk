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

class MediaEngineObserver: NotificationObserver {
    override func getNotificationHandlerMap() -> [String: String] {
        return [MediaEngineDidEncounterErrorNotification: "onMediaEngineDidEncounterError:"]
    }
    
    @objc private func onMediaEngineDidEncounterError(notification: NSNotification) {
        // TODO: handle engine errors
        Logger.info(notification.description)
    }
}