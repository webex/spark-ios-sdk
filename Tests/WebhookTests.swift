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
import Quick
import Nimble
@testable import SparkSDK

class WebhookSpec: QuickSpec {
    
    private var room: TestRoom?
    private var roomId: String {
        return room!.id!
    }
    
    override func spec() {
        beforeSuite {
            Spark.initWith(accessToken: Config.selfUser.token!)
            self.room = TestRoom()
        }
        
        afterSuite {
            Utils.wait(interval: Config.TestcaseInterval)
        }
        
        describe("Webhook API") {
            var webhookId: String = ""
            
            it("Create webhook") {
                do {
                    let filter = "roomId=" + self.roomId
                    let webhook = try Spark.webhooks.create(name: "myWebhook", targetUrl: "https://example.com/myWebhook", resource: "messages", event: "created", filter: filter)
                    expect(webhook.id).notTo(beNil())
                    
                    webhookId = webhook.id!
                    
                } catch let error as NSError {
                    fail("Failed to create webhook, \(error.localizedFailureReason)")
                }
            }
            
            it("List webhook") {
                do {
                    let webhooks = try Spark.webhooks.list()
                    expect(webhooks.count).to(equal(1))
                    
                } catch let error as NSError {
                    fail("Failed to list webhook, \(error.localizedFailureReason)")
                }
            }
            
            it("Get webhook") {
                do {
                    let webhookFromGet = try Spark.webhooks.get(webhookId: webhookId)
                    expect(webhookFromGet.id).to(equal(webhookId))
                    
                } catch let error as NSError {
                    fail("Failed to get webhook, \(error.localizedFailureReason)")
                }
            }
            
            it("Update webhook") {
                do {
                    _ = try Spark.webhooks.update(webhookId: webhookId, name: "myWebhook1", targetUrl: "https://example.com/myWebhook1")
                } catch let error as NSError {
                    fail("Failed to update webhook, \(error.localizedFailureReason)")
                }
            }
            
            it("Delete webhook") {
                expect{try Spark.webhooks.delete(webhookId: webhookId)}.notTo(throwError())
            }
        }
    }
}
