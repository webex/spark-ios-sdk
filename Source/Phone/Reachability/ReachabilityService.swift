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
import ObjectMapper

class ReachabilityService {
    
    typealias ReachabilityHandler = (String?) -> Void
    static let sharedInstance = ReachabilityService()
    var feedback: MediaEngineReachabilityFeedback?
    
    private var hostAddresses: [InterfaceAddress.Item]?
    private var lastFetchData: NSDate?
    private let MaxAge = NSTimeInterval(7200) // 7200 sec = 2 hours

    func fetch() {
        let isAddressChanged = isHostAddressChanged()
        let isMaxAgeReached = isLastFetchLongEnough()
        
        if isAddressChanged || isMaxAgeReached {
            Logger.info("Fetch scheduled, isAddressChanged = \(isAddressChanged), isMaxAgeReached = \(isMaxAgeReached)")
            performReachabilityCheck() {
                if let value = $0 {
                    self.feedback = Mapper<MediaEngineReachabilityFeedback>().map(value)

                    // update only when getting success feedback
                    self.updateHostAddresses()
                    self.updateFetchDate()
                    
                    Logger.info("Fetch done, result = \(value)")
                } else {
                    Logger.error("Fetch failed, get nil from Media Engine")
                }
            }
        } else {
            Logger.info("Fetch skipped, isAddressChanged = \(isAddressChanged), isMaxAgeReached = \(isMaxAgeReached)")
        }
    }
    
    func clear() {
        hostAddresses = nil
        lastFetchData = nil
        clearReachabilityData()
    }
    
    private func isHostAddressChanged() -> Bool {
        if hostAddresses == nil {
            return true
        }
        
        let newHostAddresses = InterfaceAddress.getSortedAddresses()
        if InterfaceAddress.isSameSortedAddresses(oldAddrs: hostAddresses!, newAddrs: newHostAddresses) {
            return false
        }
        
        return true
    }
    
    private func isLastFetchLongEnough() -> Bool {
        if lastFetchData == nil {
            return true
        }
        
        if lastFetchData!.timeIntervalSinceNow > MaxAge {
            return true
        }
        
        return false
    }
    
    private func updateHostAddresses() {
        hostAddresses = InterfaceAddress.getSortedAddresses()
    }
    
    private func updateFetchDate() {
        lastFetchData = NSDate()
    }
    
    private func performReachabilityCheck(completionHandler: ReachabilityCheckHandler) {
        var clusterInfo: MediaCluster? = nil
        MediaClusterClient().get() {
            (response: ServiceResponse<MediaCluster>) in
            switch response.result {
            case .Success(let value):
                clusterInfo = value
                if let group = clusterInfo?.group {
                    MediaEngineWrapper.sharedInstance.performReachabilityCheck(group) {
                        completionHandler($0)
                    }
                }
            case .Failure(let error):
                Logger.error("Failure: \(error.localizedFailureReason)")
            }
        }
    }
    
    private func clearReachabilityData() {
        MediaEngineWrapper.sharedInstance.clearReachabilityData()
    }
}