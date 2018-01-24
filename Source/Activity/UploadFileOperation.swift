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


/// The struct of a UploadFileOperation on Cisco Spark.
///
/// - since: 1.4.0
public enum FileUploadState : String{
    case Initiated
    case Uploading
    case UploadSuccess
    case UploadFialure
}
class UploadFileOperation: Operation {
    
    let token: String
    private var spaceUrl : String
    private var fileModel : FileObjectModel
    private var hasThumbNail: Bool = false
    private var progress : Double = 0.0
    private var thumNaliProgress: Double = 0.0
    private var progressHandler : ((Double) -> Void)?
    private var completionHandler : ((FileObjectModel,Error?) -> Void)
    private var uploadState : FileUploadState = FileUploadState.Initiated
    private var bodyUploadFinish: Bool = false
    private var thumbNailUploadFinish: Bool = false
    private var keyMatiarial: String
    init(token: String,
         spaceUrl: String,
         fileModel: FileObjectModel,
         keyMatiarial: String,
         progressHandler: ((Double) -> Void)? = nil,
         completionHandler: @escaping ((FileObjectModel,Error?) -> Void))
    {
        self.token = token
        self.fileModel = fileModel
        self.spaceUrl = spaceUrl
        self.keyMatiarial = keyMatiarial
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        super.init()
    }
    
    override func main() {
        self.shareOperation()
    }
    
    private func shareOperation(){
        if let _ = self.fileModel.image{
            self.hasThumbNail = true
            self.uploadThumbNail(token: token)
        }
        self.uploadFile(token: token)
    }
    
    private func uploadFile(token: String){
        let header : [String: String]  = ["Authorization" : "Bearer " + token]
        let uploadSessionUrl = URL(string: self.spaceUrl+"/upload_sessions")
        var fileSize: UInt64 = 0
        do{
            SDKLogger.shared.info("Begin To Upload File Data ......")
            self.uploadState = .Uploading
            let fileUrl = self.fileModel.localFileUrl?.replacingOccurrences(of: "file://", with: "")
            let fileAttr = try FileManager.default.attributesOfItem(atPath: fileUrl!)
            fileSize = fileAttr[FileAttributeKey.size] as! UInt64
            let nsInputStream = InputStream(fileAtPath: fileUrl!)
            let fileScr = try SecureContentReference(error: ())
            let secureInputStream = try SecureInputStream(stream: nsInputStream, scr: fileScr)
            let parameters : Parameters = ["fileSize": fileSize]
            Alamofire.request(uploadSessionUrl!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { response in
                switch response.result{
                case .success(let value):
                    if let dict = value as? [String : Any]{
                        let uploadUrl = URL(string: dict["uploadUrl"] as! String)
                        let finishUrl = URL(string: dict["finishUploadUrl"] as! String)
                        
                        let uploadheadHeader: HTTPHeaders = ["Content-Length": String(fileSize)]
                        
                        Alamofire.upload(secureInputStream, to: uploadUrl!, method: .put, headers: uploadheadHeader).uploadProgress(closure: { (progress) in
                            self.uploadProgress(progress.fractionCompleted)
                        }).responseString(completionHandler: { (response) in
                            let finishHead: HTTPHeaders = [ "Authorization" : "Bearer " + token,
                                                            "Content-Type": "application/json;charset=UTF-8"]
                            let pramDict = ["size":fileSize]
                            do{
                                var request = try Alamofire.URLRequest(url: finishUrl!, method: .post, headers: finishHead)
                                let pramData = try JSONSerialization.data(withJSONObject: pramDict, options: .prettyPrinted)
                                request.httpBody = pramData
                                Alamofire.request(request).responseJSON(completionHandler: { (response) in
                                    switch response.result{
                                    case .success(let value):
                                        if let dict = value as? [String : Any]{
                                            let downLoadUrl = dict["downloadUrl"] as! String
                                            self.fileModel.fileSize = fileSize
                                            self.fileModel.url = downLoadUrl
                                            do{
                                                fileScr.loc = URL(string: downLoadUrl)!
                                                let chiperfileSrc = try fileScr.encryptedSecureContentReference(withKey: self.keyMatiarial)
                                                self.fileModel.scr = chiperfileSrc
                                            }catch{}
                                            self.finishUploadFileBody(fileScr: fileScr)
                                        }
                                        break
                                    case .failure:
                                        break
                                    }
                                })
                            } catch{}
                        })
                    }
                    break
                case .failure(let error):
                    self.finishUploadWithError(error)
                    break
                }
            })
        }catch let error as NSError{
            self.finishUploadWithError(error)
        }
    }
    
    
    private func uploadThumbNail(token: String){
        let header : [String: String]  = ["Authorization" : "Bearer " + token]
        let uploadSessionUrl = URL(string: self.spaceUrl+"/upload_sessions")
        var fileSize: UInt64 = 0
        do{
            SDKLogger.shared.info("Begin To Uploading Thumbnail Data ......")
            let fileAttr = try FileManager.default.attributesOfItem(atPath: (self.fileModel.image?.localFileUrl!)!)
            fileSize = fileAttr[FileAttributeKey.size] as! UInt64
            let nsInputStream = InputStream(fileAtPath: (self.fileModel.image?.localFileUrl!)!)
            let fileScr = try SecureContentReference(error: ())
            let secureInputStream = try SecureInputStream(stream: nsInputStream, scr: fileScr)
            let parameters : Parameters = [ "fileSize": fileSize ]
            Alamofire.request(uploadSessionUrl!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { response in
                switch response.result{
                case .success(let value):
                    if let dict = value as? [String : Any]{
                        let uploadUrl = URL(string: dict["uploadUrl"] as! String)
                        let finishUrl = URL(string: dict["finishUploadUrl"] as! String)
                        
                        let uploadheadHeader: HTTPHeaders = ["Content-Length": String(fileSize)]
                        Alamofire.upload(secureInputStream, to: uploadUrl!, method: .put, headers: uploadheadHeader).uploadProgress(closure: { (progress) in
                            self.uploadThumbNailProgress(progress.fractionCompleted)
                        }).responseString(completionHandler: { (response) in
                            let finishHead: HTTPHeaders = [ "Authorization" : "Bearer " + token,
                                                            "Content-Type": "application/json;charset=UTF-8"]
                            let pramDict = ["size":fileSize]
                            do{
                                var request = try Alamofire.URLRequest(url: finishUrl!, method: .post, headers: finishHead)
                                let pramData = try JSONSerialization.data(withJSONObject: pramDict, options: .prettyPrinted)
                                request.httpBody = pramData
                                Alamofire.request(request).responseJSON(completionHandler: { (response) in
                                    switch response.result{
                                    case .success(let value):
                                        if let dict = value as? [String : Any]{
                                            let downLoadUrl = dict["downloadUrl"] as! String
                                            self.fileModel.image?.url = downLoadUrl
                                            do{
                                                fileScr.loc = URL(string: downLoadUrl)!
                                                let chiperfileSrc = try fileScr.encryptedSecureContentReference(withKey: self.keyMatiarial)
                                                self.fileModel.image?.scr = chiperfileSrc
                                            }catch{}
                                            self.finishUpLoadThumbNail(fileScr: fileScr)
                                        }
                                        break
                                    case .failure:
                                        break
                                    }
                                })
                            } catch{}
                        })
                    }
                    break
                case .failure(let error):
                    self.finishUploadWithError(error)
                    break
                }
            })
        }catch let error as NSError{
            self.finishUploadWithError(error)
        }
    }
    
    private func uploadProgress(_ progress: Double){
        self.progress = progress
        if self.hasThumbNail{
            self.progress = progress
            if let progressHandler = self.progressHandler{
                progressHandler((self.progress+self.thumNaliProgress)/2)
            }
        }else{
            self.progress = progress
            if let progressHandler = self.progressHandler{
                progressHandler(self.progress)
            }
        }
    }
    private func uploadThumbNailProgress(_ progress: Double){
        self.thumNaliProgress = progress
        if let progressHandler = self.progressHandler{
            progressHandler((self.progress+self.thumNaliProgress)/2)
        }
    }
    
    private func finishUploadFileBody(fileScr: SecureContentReference?=nil){
        self.bodyUploadFinish = true
        if(!self.hasThumbNail){
            self.completionHandler(self.fileModel, nil)
        }else if(self.hasThumbNail && self.thumbNailUploadFinish){
            self.completionHandler(self.fileModel, nil)
        }
    }
    private func finishUpLoadThumbNail(fileScr: SecureContentReference?=nil, error: Error?=nil){
        self.thumbNailUploadFinish = true
        if(self.bodyUploadFinish){
            self.completionHandler(self.fileModel, nil)
        }
    }
    
    private func finishUploadWithError(_ error : Error){
        self.cancel()
        self.completionHandler(self.fileModel, error)
    }
}
