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

import UIKit
import ObjectMapper

/// The struct of a TypingStatus on Cisco Spark.
///
/// - since: 1.4.0
public enum TypingAction : String{
    case StartTyping = "status.start_typing"
    case StopTyping = "status.stop_typing"
}

public class TypingMessage {
    
    public var action: TypingAction?{
        return TypingAction(rawValue: self.messageModel.eventType!)!
    }
    public var actor: MessageActorModel?{
        return self.messageModel.actor
    }
    public var conversationId: String?{
        return self.messageModel.conversationId
    }
    private var messageModel: MessageModel
    init(activitModel: MessageModel) {
        self.messageModel = activitModel
    }
    public required convenience init?(map: Map){
        let acivitiModel = Mapper<MessageModel>().map(JSON: map.JSON)
        self.init(activitModel: acivitiModel!)
    }
    public func mapping(map: Map) {
        self.messageModel <- map
    }
}

