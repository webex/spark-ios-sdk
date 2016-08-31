// Copyright 2016 Cisco Systems Inc
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

import WebKit

class ConnectController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    
    var onWillDismiss: ((_ didCancel: Bool) -> Void)?
    var tryParseAccessCodeFrom: ((_ url: URL) -> Bool)?
    
    var cancelButton: UIBarButtonItem?
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(URL: URL, parseAccessCodeFrom: ((_ url: URL) -> Bool)) {
        super.init(nibName: nil, bundle: nil)
        self.startURL = URL
        self.tryParseAccessCodeFrom = parseAccessCodeFrom
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Link to Spark"
        self.webView = WKWebView(frame: self.view.bounds)
        self.view.addSubview(self.webView)
        
        self.webView.navigationDelegate = self
        
        self.view.backgroundColor = .white
        
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ConnectController.cancel(_:)))
        self.navigationItem.rightBarButtonItem = self.cancelButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !webView.canGoBack {
            if nil != startURL {
				load(url: startURL!)
            }
            else {
                webView.loadHTMLString("There is no `startURL`", baseURL: nil)
            }
        }
    }
    
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
		if let url = navigationAction.request.url, let parseAccessCode = self.tryParseAccessCodeFrom {
			if parseAccessCode(url) {
				self.dismiss(animated: true)
				return decisionHandler(.cancel)
			}
		}
		return decisionHandler(.allow)
	}
    
    var startURL: URL? {
        didSet(oldURL) {
            if nil != startURL && nil == oldURL && isViewLoaded {
				load(url: startURL!)
            }
        }
    }
    
    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    func showHideBackButton(_ show: Bool) {
        navigationItem.leftBarButtonItem = show ? UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(ConnectController.goBack(_:))) : nil
    }
    
    func goBack(_ sender: Any?) {
        webView.goBack()
    }
    
    func cancel(_ sender: Any?) {
		dismiss(asCancel: true, animated: (sender != nil))
    }
    
    func dismiss(animated: Bool) {
		dismiss(asCancel: false, animated: animated)
    }
    
    func dismiss(asCancel: Bool, animated: Bool) {
        webView.stopLoading()
        
        self.onWillDismiss?(asCancel)
        presentingViewController?.dismiss(animated: animated, completion: nil)
    }
    
}
