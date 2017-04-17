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
    var feedback: MediaEngineReachabilityFeedback?
    
    private var hostAddresses: [InterfaceAddress.Item]?
    private var lastFetchDate: Date?
    private let MaxAge = TimeInterval(7200) // 7200 sec = 2 hours
    private let authenticator: Authenticator
    private let deviceService: DeviceService
    
    init(authenticator: Authenticator, deviceService: DeviceService) {
        self.authenticator = authenticator
        self.deviceService = deviceService
    }
    
    func fetch() {
        let isAddressChanged = isHostAddressChanged()
        let isMaxAgeReached = isDataOutOfDate()
        
        if isAddressChanged || isMaxAgeReached {
            SDKLogger.info("Fetch scheduled, isAddressChanged = \(isAddressChanged), isMaxAgeReached = \(isMaxAgeReached)")
            performReachabilityCheck() {
                if let value = $0 {
                    self.feedback = Mapper<MediaEngineReachabilityFeedback>().map(JSONString: value)

                    // update only when getting success feedback
                    self.updateHostAddresses()
                    self.updateFetchDate()
                    
                    SDKLogger.info("Fetch done, result = \(value)")
                } else {
                    SDKLogger.error("Fetch failed, get nil from Media Engine")
                }
            }
        } else {
            SDKLogger.info("Fetch skipped, isAddressChanged = \(isAddressChanged), isMaxAgeReached = \(isMaxAgeReached)")
        }
    }
    
    func clear() {
        hostAddresses = nil
        lastFetchDate = nil
        clearReachabilityData()
    }
    
    private func isHostAddressChanged() -> Bool {
        if let hostAddresses = hostAddresses {
            let newHostAddresses = InterfaceAddress.getSortedAddresses()
            return !InterfaceAddress.isSameSortedAddresses(oldAddrs: hostAddresses, newAddrs: newHostAddresses)
        } else {
            return true
        }
    }
    
    private func isDataOutOfDate() -> Bool {
        if let lastFetchDate = lastFetchDate {
            return lastFetchDate.timeIntervalSinceNow > MaxAge
        } else {
            return true
        }
    }
    
    private func updateHostAddresses() {
        hostAddresses = InterfaceAddress.getSortedAddresses()
    }
    
    private func updateFetchDate() {
        lastFetchDate = Date()
    }
    
    private func performReachabilityCheck(_ completionHandler: @escaping ReachabilityCheckHandler) {
        var clusterInfo: MediaCluster? = nil
        MediaClusterClient(authenticator: authenticator, deviceService: deviceService).get() {
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
                SDKLogger.error("Failure", error: error)
            }
        }
    }
    
    private func clearReachabilityData() {
        MediaEngineWrapper.sharedInstance.clearReachabilityData()
    }
}
