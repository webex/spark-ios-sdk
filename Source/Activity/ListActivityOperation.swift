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

class ListActivityOperation: Operation {
    var conversationId: String
    var listRequest: ServiceRequest
    var completionHandler : (ServiceResponse<[MessageActivity]>) -> Void
    var response: ServiceResponse<[MessageActivity]>?
    var keyMaterial : String?
    init(conversationId : String,
         listRequest: ServiceRequest,
         keyMaterial: String?=nil,
         queue:DispatchQueue? = nil,
         completionHandler: @escaping (ServiceResponse<[MessageActivity]>) -> Void)
    {
        self.conversationId = conversationId
        self.listRequest = listRequest
        self.completionHandler = completionHandler
        self.keyMaterial = keyMaterial
        super.init()
    }
    
    override func main() {
        self.listRequest.responseArray {(response: ServiceResponse<[MessageActivity]>) in
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
    
    private func decryptList(_ activityList: [MessageActivity]){
        guard let acitivityKeyMaterial = self.keyMaterial else{
            return
        }
        for messageActivity in activityList{
            do {
                guard let chiperText = messageActivity.plainText
                    else{
                        return;
                }
                if(chiperText != ""){
                    let plainTextData = try CjoseWrapper.content(fromCiphertext: chiperText, key: acitivityKeyMaterial)
                    let clearText = NSString(data:plainTextData ,encoding: String.Encoding.utf8.rawValue)
                    messageActivity.plainText = clearText! as String
                    messageActivity.markDownString()
                }
                if let files = messageActivity.files{
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
                    messageActivity.files = files
                }
            }catch{}
        }
        self.completionHandler(self.response!)
    }
}
