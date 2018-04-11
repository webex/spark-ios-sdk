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
import Alamofire
import MobileCoreServices.UTCoreTypes
import MobileCoreServices.UTType

class ListMessageOperation: Operation {
    var roomId: String
    var listRequest: ServiceRequest
    var completionHandler : (ServiceResponse<[MessageModel]>) -> Void
    var response: ServiceResponse<[MessageModel]>?
    var keyMaterial : String?
    init(roomId : String,
         listRequest: ServiceRequest,
         keyMaterial: String?=nil,
         queue:DispatchQueue? = nil,
         completionHandler: @escaping (ServiceResponse<[MessageModel]>) -> Void)
    {
        self.roomId = roomId
        self.listRequest = listRequest
        self.completionHandler = completionHandler
        self.keyMaterial = keyMaterial
        super.init()
    }
    
    override func main() {
        self.listRequest.responseArray {(response: ServiceResponse<[MessageModel]>) in
            self.response = response
            switch response.result{
            case .success(let list):
                self.decryptList(list)
                break
            case .failure(_):
                self.completionHandler(response)
                break
            }
        }
    }
    
    private func decryptList(_ messageList: [MessageModel]){
        guard let acitivityKeyMaterial = self.keyMaterial else{
            return
        }
        let filterList = messageList.filter({$0.messageAction == MessageAction.post || $0.messageAction == MessageAction.share})
        for message in filterList{
            do {
                if message.text == nil{
                    message.text = ""
                }
                guard let chiperText = message.text
                    else{
                        return;
                }
                if(chiperText != ""){
                    let plainTextData = try CjoseWrapper.content(fromCiphertext: chiperText, key: acitivityKeyMaterial)
                    let clearText = NSString(data:plainTextData ,encoding: String.Encoding.utf8.rawValue)
                    message.text = clearText! as String
                }
                if let files = message.files{
                    for file in files{
                        if let displayname = file.displayName,let scr = file.scr{
                            let nameData = try CjoseWrapper.content(fromCiphertext: displayname, key: acitivityKeyMaterial)
                            let clearName = NSString(data:nameData ,encoding: String.Encoding.utf8.rawValue)! as String
                            let srcData = try CjoseWrapper.content(fromCiphertext: scr, key: acitivityKeyMaterial)
                            let clearSrc = NSString(data:srcData ,encoding: String.Encoding.utf8.rawValue)! as String
                            if let image = file.thumb{
                                let imageSrcData = try CjoseWrapper.content(fromCiphertext: image.scr, key: acitivityKeyMaterial)
                                let imageClearSrc = NSString(data:imageSrcData ,encoding: String.Encoding.utf8.rawValue)! as String
                                image.scr = imageClearSrc
                            }
                            file.displayName = clearName
                            file.scr = clearSrc
                        }
                    }
                    message.files = files
                }
            }catch{}
        }
        let result = Result<[MessageModel]>.success(filterList)
        let serviceResponse = ServiceResponse(self.response?.response, result)
        self.completionHandler(serviceResponse)
    }
}
