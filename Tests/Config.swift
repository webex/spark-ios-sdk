// Copyright 2016-2017 Cisco Systems Inc
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
import SparkSDK


struct Config {
    static let TestcaseInterval = 1.0
    static let TestcaseRetryCount = 3
    static let TestcasePendingCheckTimeout = 20.0
    static let TestcasePendingCheckPollInterval = 0.2
    static let TestcasePendingMediaInit = 3.0
    
    static let InvalidId = "abc"
    static let InvalidEmail = EmailAddress.fromString("abc@a.aa")!
    static let FakeRoomId = "Y2lzY29zcGFyazovL3VzL1JPT00vYWNmNjg3MDAtY2FhZC0xMWU3LTg1Y2EtMjUzNjhiNjY3YjQz"
    static let FakeSelfDeviceUrl = "https://wdmServer.com/self"
    static let FakeOtherDeviceUrl = "https://wdmServer.com/other"
    static let FakeWebSocketUrl = "https://WebSocketServer.com/"
    static let FakeLocusServiceUrl = "https://locusServer.com/"
    static let FakeConversationServiceUrl = "https://conversationServiceUrl.com/"
    static let FakeCalliopeDiscoveryServiceUrl = "https://calliopeDiscoveryServiceUrl.com/"
    static let FakeMetricsServiceUrl = "https://metricsServiceUrl.com/"
    
}



