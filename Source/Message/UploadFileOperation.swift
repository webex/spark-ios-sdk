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

class UploadFileOperations {
    
    private let queue = SerialQueue()
    
    private var operations: [UploadFileOperation]
    
    init(key: EncryptionKey, files: [LocalFile]) {
        self.operations = files.map { file in
            return UploadFileOperation(key: key, local: file)
        }
    }
    
    func run(client: MessageClientImpl, completionHandler: @escaping (Result<[RemoteFile]>) -> Void) {
        var sucess = [RemoteFile]()
        self.operations.forEach { operation in
            if !operation.done {
                self.queue.sync {
                    operation.run(client: client) { [weak self] result in
                        if let file = result.data {
                            sucess.append(file)
                        }
                        self?.queue.yield()
                    }
                }
            }
        }
        self.queue.sync {
            completionHandler(Result.success(sucess))
        }
    }
}

class UploadFileOperation {
    
    let local: LocalFile
    private let key: EncryptionKey
    private(set) var done: Bool = false
    
    init(key: EncryptionKey, local: LocalFile) {
        self.local = local
        self.key = key
    }
    
    func run(client: MessageClientImpl, completionHandler: @escaping (Result<RemoteFile>) -> Void) {
        if !FileManager.default.fileExists(atPath: self.local.path) || !FileManager.default.isReadableFile(atPath: self.local.path) {
            self.uploadError(completionHandler: completionHandler)
            return
        }
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: self.local.path), let size = attrs[FileAttributeKey.size] as? UInt64 else {
            self.uploadError(completionHandler: completionHandler)
            return
        }
        client.authenticator.accessToken { token in
            guard let token = token else {
                self.uploadError(completionHandler: completionHandler)
                return
            }
            self.key.spaceUrl(authenticator: client.authenticator) { result in
                if let url = result.data {
                    let headers: HTTPHeaders  = ["Authorization": "Bearer " + token]
                    let parameters: Parameters = ["fileSize": size]
                    Alamofire.request(url + "/upload_sessions", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response: DataResponse<Any>) in
                        if let dict = response.result.value as? [String : Any],
                            let uploadUrl = dict["uploadUrl"] as? String,
                            let finishUrl = dict["finishUploadUrl"] as? String,
                            let scr = try? SecureContentReference(error: ()),
                            let inputStream = try? SecureInputStream(stream: InputStream(fileAtPath: self.local.path), scr: scr) {
                            let uploadHeaders: HTTPHeaders = ["Content-Length": String(size)]
                            Alamofire.upload(inputStream, to: uploadUrl, method: .put, headers: uploadHeaders).uploadProgress(closure: { (progress) in
                                self.local.progressHandler?(progress.fractionCompleted)
                            }).responseString { response in
                                if let _ = response.result.value {
                                    let finishHeaders: HTTPHeaders = ["Authorization": "Bearer " + token, "Content-Type": "application/json;charset=UTF-8"]
                                    let finishParameters: Parameters = ["size": size]
                                    Alamofire.request(finishUrl, method: .post, parameters: finishParameters, encoding: JSONEncoding.default, headers: finishHeaders).responseJSON { response in
                                        if let dict = response.result.value as? [String : Any], let downLoadUrl = dict["downloadUrl"] as? String, let url = URL(string: downLoadUrl) {
                                            scr.loc = url
                                            var file = RemoteFile(local: self.local, downloadUrl: downLoadUrl, size: size)
                                            self.key.material(client: client) { material in
                                                file.encrypt(key: material.data, scr: scr)
                                                self.done = true
                                                completionHandler(Result.success(file))
                                            }
                                        }
                                        else {
                                            self.uploadError(response.error, completionHandler: completionHandler)
                                        }
                                    }
                                }
                                else {
                                    self.uploadError(response.error, completionHandler: completionHandler)
                                }
                            }
                        }
                        else {
                            self.uploadError(response.error, completionHandler: completionHandler)
                        }
                    }
                }
                else {
                    self.uploadError(result.error, completionHandler: completionHandler)
                }
            }
        }
    }
    
    private func uploadError(_ error: Error? = nil, completionHandler: @escaping (Result<RemoteFile>) -> Void) {
        SDKLogger.shared.info("File Uoload Fail...")
        self.done = true
        completionHandler(Result.failure(error ?? SparkError.serviceFailed(code: -7000, reason: "upload error")))
    }
    
}
