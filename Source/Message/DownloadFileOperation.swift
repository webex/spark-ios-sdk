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

class DownloadFileOperation {
    
    private let authenticator: Authenticator
    private let uuid: String
    private let source: String
    private let secureContentRef: String?
    private let target: URL
    private let queue: DispatchQueue?
    private let progressHandler: ((Double) -> Void)?
    private let completionHandler : ((Result<URL>) -> Void)
    
    init(authenticator: Authenticator, uuid: String, source: String, secureContentRef: String?, thnumnail: Bool, target: URL?, queue: DispatchQueue?, progressHandler: ((Double) -> Void)?, completionHandler: @escaping ((Result<URL>) -> Void)) {
        self.authenticator = authenticator
        self.source = source
        self.secureContentRef = secureContentRef
        self.uuid = uuid
        self.queue = queue
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        if let target = target {
            self.target = target
        }
        else {
            let path = FileManager.default.temporaryDirectory.appendingPathComponent("com.ciscospark.sdk.download", isDirectory: true)
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            var name = URL(string: source)?.lastPathComponent ?? UUID().uuidString
            if (thnumnail) {
                name = "thumb-" + name
            }
            self.target = path.appendingPathComponent(name, isDirectory: false)
        }
    }
    
    func run() {
        guard let url = URL(string: self.source) else {
            self.downloadError()
            return
        }
        self.authenticator.accessToken { token in
            guard let token = token else {
                self.downloadError()
                return
            }
            let headers: HTTPHeaders = ["Authorization": "Bearer " + token, "TrackingID": "SPARKSDK_\(self.uuid)_0"]
            Alamofire.download(url, headers: headers) { (_, _) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                return (self.target, [.removePreviousFile, .createIntermediateDirectories])
                }.downloadProgress { progress in
                    (self.queue ?? DispatchQueue.main).async {
                        self.progressHandler?(progress.fractionCompleted)
                    }
                }.responseData { response in
                    switch response.result {
                    case .success(let data):
                        var output = OutputStream(url: self.target, append: true)
                        if let refString = self.secureContentRef, let ref = try? SecureContentReference(json: refString) {
                            output = try? SecureOutputStream(stream: output, scr: ref)
                        }
                        if let output = output {
                            output.open()
                            _ = output.write(data: data)
                            output.close()
                            if let error = output.streamError {
                                self.downloadError(error)
                            }
                            else {
                                (self.queue ?? DispatchQueue.main).async {
                                    self.completionHandler(Result.success(url))
                                }
                            }
                        }
                        else {
                            self.downloadError()
                        }
                        
                    case .failure(let error):
                        self.downloadError(error)
                    }
            }
        }
    }
    
    private func downloadError(_ error: Error? = nil) {
        SDKLogger.shared.info("File DownLoad Fail...")
        (self.queue ?? DispatchQueue.main).async {
            self.completionHandler(Result.failure(error ?? SparkError.serviceFailed(code: -7000, reason: "download error")))
        }
    }
}

extension OutputStream {
    func write(data: Data) -> Int {
        return data.withUnsafeBytes { self.write($0, maxLength: data.count) }
    }
}

