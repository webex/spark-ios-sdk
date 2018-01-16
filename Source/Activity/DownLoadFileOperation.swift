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

private let SparkTempPath = NSTemporaryDirectory()

/// The struct of a UploadFileOperation on Cisco Spark.
///
/// - since: 1.4.0
public enum FileDownLoadState : String{
    case Initiated
    case Downloading
    case DownloadSuccess
    case DownloadFialure
}
class DownLoadFileOperation: Operation , URLSessionDataDelegate {
    fileprivate var bodyDownLoadPath : String?
    fileprivate var thumbDownLoadPath : String?
    fileprivate var bodyOutPutStream : OutputStream?
    fileprivate var thumbOutPutStream : OutputStream?
    fileprivate var totalBodySize: UInt64?
    fileprivate var totalThumbSize: UInt64?
    fileprivate var bodyDownLoadSeesion: URLSession?
    fileprivate var thumbDownLoadSession: URLSession?
    
    let token: String
    private var uuid : String
    private var fileModel : FileObjectModel
    private var hasThumbNail: Bool = false
    private var progress : Double = 0.0
    private var thumNaliProgress: Double = 0.0
    private var progressHandler : ((Double) -> Void)?
    private var completionHandler : ((FileObjectModel,FileDownLoadState) -> Void)
    private var downLoadState : FileDownLoadState = FileDownLoadState.Initiated
    private var bodyDownLoadFinish: Bool = false
    private var thumbNailDownLoadFinish: Bool = false
    private var keyMatiarial: String
    init(token: String,
         uuid: String,
         fileModel: FileObjectModel,
         keyMatiarial: String,
         progressHandler: ((Double) -> Void)? = nil,
         completionHandler: @escaping ((FileObjectModel,FileDownLoadState) -> Void))
    {
        self.token = token
        self.fileModel = fileModel
        self.uuid = uuid
        self.keyMatiarial = keyMatiarial
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        super.init()
    }
    
    override func main() {
        self.downLoadOperation()
    }
    
    private func downLoadOperation(){
        let trackingID = "ITCLIENT_\(self.uuid)_0" + "_imi:true"
        let config = URLSessionConfiguration.default
        
        if let image = self.fileModel.image{
            self.hasThumbNail = true
            let urlSTR = image.url
            let urlString = URL(string: urlSTR!)
            self.thumbDownLoadSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
            self.thumbDownLoadPath = SparkTempPath + "thumb_" + self.fileModel.displayName!
            var request = NSURLRequest(url: urlString!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 0) as URLRequest
            request.setValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
            request.setValue(trackingID, forHTTPHeaderField: "TrackingID")
            if let dataTask = self.thumbDownLoadSession?.dataTask(with: request){
                dataTask.resume()
            }
        }
        let urlSTR = self.fileModel.url
        let urlString = URL(string: urlSTR!)
        self.bodyDownLoadSeesion = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        self.bodyDownLoadPath = SparkTempPath + self.fileModel.displayName!
        var request = NSURLRequest(url: urlString!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 0) as URLRequest
        request.setValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
        request.setValue(trackingID, forHTTPHeaderField: "TrackingID")
        if let dataTask = self.bodyDownLoadSeesion?.dataTask(with: request){
            dataTask.resume()
        }
        
    }
    
    private func downLoadProgress(_ progress: Double){
        print(progress)
        
        self.progress += progress
        if self.hasThumbNail{
            self.progress = progress
            if let progressHandler = self.progressHandler{
                progressHandler((self.progress+self.thumNaliProgress)/2)
            }
        }else{
            self.progress += progress
            if let progressHandler = self.progressHandler{
                progressHandler(self.progress)
            }
        }
    }
    private func downLoadThumbNailProgress(_ progress: Double){
        print("tumb Progress: \(progress)")
        self.thumNaliProgress += progress
        if let progressHandler = self.progressHandler{
            progressHandler((self.progress+self.thumNaliProgress)/2)
        }
    }
    
    private func finishDownLoadFileBody(){
        self.bodyDownLoadFinish = true
        self.fileModel.localFileUrl = self.bodyDownLoadPath
        if(!self.hasThumbNail){
            self.completionHandler(self.fileModel, .DownloadSuccess)
        }else if(self.hasThumbNail && self.thumbNailDownLoadFinish){
            self.completionHandler(self.fileModel, .DownloadSuccess)
        }
    }
    private func finishDownLoadThumbNail(){
        self.thumbNailDownLoadFinish = true
        self.fileModel.image?.localFileUrl = self.thumbDownLoadPath
        if(self.bodyDownLoadFinish){
            self.completionHandler(self.fileModel, .DownloadSuccess)
        }
    }
    
    
    
    /// download session delegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void){
        if(session == self.bodyDownLoadSeesion){
            let resp = response as! HTTPURLResponse
            let string = resp.allHeaderFields["Content-Length"] as! String
            let stri : String = string.components(separatedBy: "/").last!
            self.totalBodySize = UInt64(stri)!
            do{
                var outputStream = OutputStream(toMemory: ())
                let jsonstr =  self.fileModel.scr!
                let scr = try SecureContentReference(json: jsonstr)
                outputStream = try SecureOutputStream(stream: outputStream, scr: scr) as OutputStream
                self.bodyOutPutStream = outputStream
                self.bodyOutPutStream?.open()
                completionHandler(URLSession.ResponseDisposition.allow);
            }catch let error as NSError{
                SDKLogger.shared.info("DownLoadSession Create Error - \(error.description)")
            }
        }else{
            let resp = response as! HTTPURLResponse
            let string = resp.allHeaderFields["Content-Length"] as! String
            let stri : String = string.components(separatedBy: "/").last!
            self.totalThumbSize = UInt64(stri)!
            do{
                var outputStream = OutputStream(toFileAtPath: self.thumbDownLoadPath!, append: true)
                let jsonstr =  self.fileModel.image?.scr!
                let scr = try SecureContentReference(json: jsonstr)
                outputStream = try SecureOutputStream(stream: outputStream, scr: scr) as OutputStream
                self.thumbOutPutStream = outputStream
                self.thumbOutPutStream?.open()
                completionHandler(URLSession.ResponseDisposition.allow);
            }catch let error as NSError{
                SDKLogger.shared.info("ThumbNail DownLoadSession Create Error - \(error.description)")
            }
        }
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        if(session == self.bodyDownLoadSeesion){
            var buffer = [UInt8](repeating: 0, count: data.count)
            data.copyBytes(to: &buffer, count: data.count)
            self.bodyOutPutStream?.write(buffer, maxLength: data.count)
            self.downLoadProgress(Double(data.count)/Double(self.totalBodySize!))
        }else{
            var buffer = [UInt8](repeating: 0, count: data.count)
            data.copyBytes(to: &buffer, count: data.count)
            self.thumbOutPutStream?.write(buffer, maxLength: data.count)
            self.downLoadThumbNailProgress(Double(data.count)/Double(self.totalThumbSize!))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        //        if(session == self.bodyDownLoadSeesion){
        if (error == nil) {
            
        }else {
            print("DownLoad Error \(error.debugDescription)")
        }
        SDKLogger.shared.info("DownLoad Finished")
        //            self.bodyOutPutStream?.close()
        self.finishDownLoadFileBody()
        //        }else{
        //            if (error == nil) {
        //
        //            }else {
        //                SDKLogger.shared.info("ThumbNail DownLoad Error \(error.debugDescription)")
        //            }
        //            SDKLogger.shared.info("ThumbNail DownLoad Finished")
        ////            self.thumbOutPutStream?.close()
        ////            self.finishDownLoadThumbNail()
        //        }
        
    }
}

