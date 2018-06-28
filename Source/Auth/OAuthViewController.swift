// Copyright 2016-2018 Cisco Systems Inc
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


class OAuthViewController: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private var cancelButton: UIBarButtonItem?

    private let completionHandler: (_ oauthCode: String?) -> Void
    private let url: URL
    private let redirectUri: String
    
    init(authorizationUrl: URL, redirectUri: String, completionHandler: @escaping (_ oauthCode: String?) -> Void) {
        self.url = authorizationUrl
        self.redirectUri = redirectUri
        self.completionHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Not implemented")
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Link to Spark"
        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(OAuthViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !webView.canGoBack {
            load(url: url)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let url = navigationAction.request.url, OAuthUrlUtil.url(url, matchesRedirectUri: redirectUri) {
            decisionHandler(.cancel)

            // XXX Determine under what circumstances OAuth will return errors in the redirect url, and if that means we should allow the webview to
            // remain, with the expectation that the user can continue to try to log in, or if we should force a cancel or other similar action
            // because it is no longer possible to log in successfully
            let code = OAuthUrlUtil.oauthCodeFor(redirectUrl: url)
            dismiss()
            completionHandler(code)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    @objc private func cancel(_ sender: Any?) {
        dismiss()
        completionHandler(nil)
    }
    
    private func dismiss() {
        webView.stopLoading()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
