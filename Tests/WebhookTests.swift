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
            Utils.wait(Config.TestcaseInterval)
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
                    try Spark.webhooks.update(webhookId: webhookId, name: "myWebhook1", targetUrl: "https://example.com/myWebhook1")
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