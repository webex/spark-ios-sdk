// Copyright 2016 Cisco Systems Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import ObjectMapper

class ReachabilityService {
    
    typealias ReachabilityHandler = (String?) -> Void
    static let sharedInstance = ReachabilityService()
    var feedback: MediaEngineReachabilityFeedback?
    
    private var hostAddresses: [InterfaceAddress.Item]?
    private var lastFetchData: Date?
    private let MaxAge = TimeInterval(7200) // 7200 sec = 2 hours

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
        lastFetchData = Date()
    }
    
    private func performReachabilityCheck(_ completionHandler: @escaping ReachabilityCheckHandler) {
        var clusterInfo: MediaCluster? = nil
        MediaClusterClient().get() {
            (response: ServiceResponse<MediaCluster>) in
            switch response.result {
            case .success(let value):
                clusterInfo = value
                if let group = clusterInfo?.group {
                    MediaEngineWrapper.sharedInstance.performReachabilityCheck(group) {
                        completionHandler($0)
                    }
                }
            case .failure(let error):
                Logger.error("Failure", error: error)
            }
        }
    }
    
    private func clearReachabilityData() {
        MediaEngineWrapper.sharedInstance.clearReachabilityData()
    }
}
