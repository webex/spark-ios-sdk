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


private var SparkTempPath: String {
    get{
        do {
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! + "/SparkDownLoads/"
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            return path
        } catch _ as NSError {
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! + "/SparkDownLoads/"
            return path
        }
    }
}

/// The struct of a DownLoadType on Cisco Spark.
///
/// - since: 1.4.0
public enum DownLoadType : String{
    case BodyAndThumb
    case ThumbOnly
    case BodyOnly
}
/// The struct of a DownloadFileOperationState on Cisco Spark.
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
    private var downLoadType : DownLoadType
    init(token: String,
         uuid: String,
         fileModel: FileObjectModel,
         keyMatiarial: String,
         downLoadType: DownLoadType? = .BodyAndThumb,
         progressHandler: ((Double) -> Void)? = nil,
         completionHandler: @escaping ((FileObjectModel,FileDownLoadState) -> Void))
    {
        self.token = token
        self.fileModel = fileModel
        self.uuid = uuid
        self.keyMatiarial = keyMatiarial
        self.downLoadType = downLoadType!
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        super.init()
    }
    
    override func main() {
        self.downLoadOperation()
    }
    
    private func downLoadOperation(){
        switch self.downLoadType {
        case .BodyAndThumb:
            self.startThumbAndBodyDownLoad()
            break
        case .BodyOnly:
            self.startBodyOnlyDownLoad()
            break
        case .ThumbOnly:
            self.startThumbOnlyDownLoad()
            break
        }
    }
    
    private func startThumbAndBodyDownLoad(){
        let trackingID = "ITCLIENT_\(self.uuid)_0"
        let config = URLSessionConfiguration.default
        if let image = self.fileModel.image{
            self.hasThumbNail = true
            let urlSTR = image.url
            let urlString = URL(string: urlSTR!)
            self.thumbDownLoadSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
            self.thumbDownLoadPath = createFilePahtWithName("thumb_" + self.fileModel.displayName!)
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
        self.bodyDownLoadPath = createFilePahtWithName(self.fileModel.displayName!)
        var request = NSURLRequest(url: urlString!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 0) as URLRequest
        request.setValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
        request.setValue(trackingID, forHTTPHeaderField: "TrackingID")
        if let dataTask = self.bodyDownLoadSeesion?.dataTask(with: request){
            dataTask.resume()
        }
    }
    
    private func startThumbOnlyDownLoad(){
        let trackingID = "ITCLIENT_\(self.uuid)_0"
        let config = URLSessionConfiguration.default
        if let image = self.fileModel.image{
            self.hasThumbNail = true
            let urlSTR = image.url
            let urlString = URL(string: urlSTR!)
            self.thumbDownLoadSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
            self.thumbDownLoadPath = createFilePahtWithName("thumb_" + self.fileModel.displayName!)
            var request = NSURLRequest(url: urlString!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 0) as URLRequest
            request.setValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
            request.setValue(trackingID, forHTTPHeaderField: "TrackingID")
            if let dataTask = self.thumbDownLoadSession?.dataTask(with: request){
                dataTask.resume()
            }
        }else{
            self.downLoadError()
        }
    }
    
    private func startBodyOnlyDownLoad(){
        let trackingID = "ITCLIENT_\(self.uuid)_0"
        let config = URLSessionConfiguration.default
        let urlSTR = self.fileModel.url
        let urlString = URL(string: urlSTR!)
        self.bodyDownLoadSeesion = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        self.bodyDownLoadPath = createFilePahtWithName(self.fileModel.displayName!)
        var request = NSURLRequest(url: urlString!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 0) as URLRequest
        request.setValue("Bearer " + self.token, forHTTPHeaderField: "Authorization")
        request.setValue(trackingID, forHTTPHeaderField: "TrackingID")
        if let dataTask = self.bodyDownLoadSeesion?.dataTask(with: request){
            dataTask.resume()
        }
    }
    
    private func downLoadProgress(_ progress: Double){
        self.progress += progress
        if(self.downLoadType == .BodyAndThumb){
            if self.hasThumbNail{
                if let progressHandler = self.progressHandler{
                    progressHandler((self.progress+self.thumNaliProgress)/2)
                }
            }else{
                if let progressHandler = self.progressHandler{
                    progressHandler(self.progress)
                }
            }
        }else{
            if let progressHandler = self.progressHandler{
                progressHandler(self.progress)
            }
        }
    }
    private func downLoadThumbNailProgress(_ progress: Double){
        self.thumNaliProgress += progress
        if self.downLoadType == .ThumbOnly{
            if let progressHandler = self.progressHandler{
                progressHandler(self.thumNaliProgress)
            }
        }else{
            if let progressHandler = self.progressHandler{
                progressHandler((self.progress+self.thumNaliProgress)/2)
            }
        }
    }
    
    private func finishDownLoadFileBody(){
        self.bodyDownLoadFinish = true
        self.fileModel.localFileUrl = self.bodyDownLoadPath
        if(self.downLoadType == .BodyAndThumb){
            if(!self.hasThumbNail){
                self.cancel()
                self.completionHandler(self.fileModel, .DownloadSuccess)
            }else if(self.hasThumbNail && self.thumbNailDownLoadFinish){
                self.cancel()
                self.completionHandler(self.fileModel, .DownloadSuccess)
            }
        }else if(self.downLoadType == .BodyOnly){
            self.cancel()
            self.completionHandler(self.fileModel, .DownloadSuccess)
        }
    }
    private func finishDownLoadThumbNail(){
        self.thumbNailDownLoadFinish = true
        self.fileModel.image?.localFileUrl = self.thumbDownLoadPath
        if(self.downLoadType == .ThumbOnly){
            self.cancel()
            self.completionHandler(self.fileModel, .DownloadSuccess)
        }else{
            if(self.bodyDownLoadFinish){
                self.cancel()
                self.completionHandler(self.fileModel, .DownloadSuccess)
            }
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
                var outputStream = OutputStream(toFileAtPath: self.bodyDownLoadPath!, append: true)
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
        if(session == self.bodyDownLoadSeesion){
            if (error != nil) {
                self.downLoadError()
            }
            SDKLogger.shared.info("File DownLoad Finished")
            self.bodyOutPutStream?.close()
            self.finishDownLoadFileBody()
        }else{
            if (error != nil) {
                self.downLoadError()
            }
            
            SDKLogger.shared.info("ThumbNail DownLoad Finished")
            self.thumbOutPutStream?.close()
            self.finishDownLoadThumbNail()
        }
    }
    
    private func createFilePahtWithName(_ name: String) -> String{
        let date : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMddyyyy:hhmmSSS"
        let todaysDate = dateFormatter.string(from: date)
        return SparkTempPath + todaysDate + "-" + name
    }
    
    private func downLoadError(){
        self.cancel()
        self.completionHandler(self.fileModel, .DownloadFialure)
    }
}

