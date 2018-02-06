//
//  ListActivityOperation.swift
//  SparkSDK
//
//  Created by qucui on 2018/1/17.
//  Copyright © 2018年 Cisco. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices.UTCoreTypes
import MobileCoreServices.UTType

class ListMessageOperation: Operation {
    var roomId: String
    var listRequest: ServiceRequest
    var completionHandler : (ServiceResponse<[Message]>) -> Void
    var response: ServiceResponse<[Message]>?
    var keyMaterial : String?
    init(roomId : String,
         listRequest: ServiceRequest,
         keyMaterial: String?=nil,
         queue:DispatchQueue? = nil,
         completionHandler: @escaping (ServiceResponse<[Message]>) -> Void)
    {
        if let roomIdStr = (roomId.base64Decoded())!.split(separator: "/").last
        {
            self.roomId = String(roomIdStr)
        }else{
            self.roomId = ""
        }
        self.listRequest = listRequest
        self.completionHandler = completionHandler
        self.keyMaterial = keyMaterial
        super.init()
    }
    
    override func main() {
        self.listRequest.responseArray {(response: ServiceResponse<[Message]>) in
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
    
    private func decryptList(_ messageList: [Message]){
        guard let acitivityKeyMaterial = self.keyMaterial else{
            return
        }
        for message in messageList{
            do {
                if message.plainText == nil{
                    message.plainText = ""
                }
                guard let chiperText = message.plainText
                    else{
                        return;
                }
                if(chiperText != ""){
                    let plainTextData = try CjoseWrapper.content(fromCiphertext: chiperText, key: acitivityKeyMaterial)
                    let clearText = NSString(data:plainTextData ,encoding: String.Encoding.utf8.rawValue)
                    message.plainText = clearText! as String
                    message.markDownString()
                }
                if let files = message.files{
                    for file in files{
                        if let displayname = file.displayName,
                            let scr = file.scr
                        {
                            let nameData = try CjoseWrapper.content(fromCiphertext: displayname, key: acitivityKeyMaterial)
                            let clearName = NSString(data:nameData ,encoding: String.Encoding.utf8.rawValue)! as String
                            let srcData = try CjoseWrapper.content(fromCiphertext: scr, key: acitivityKeyMaterial)
                            let clearSrc = NSString(data:srcData ,encoding: String.Encoding.utf8.rawValue)! as String
                            if let image = file.image{
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
        self.completionHandler(self.response!)
    }
}
