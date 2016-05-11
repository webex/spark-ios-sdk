//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import WebKit

class ConnectController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    
    var onWillDismiss: ((didCancel: Bool) -> Void)?
    var tryParseAccessCodeFrom: ((url: NSURL) -> Bool)?
    
    var cancelButton: UIBarButtonItem?
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(URL: NSURL, parseAccessCodeFrom: ((url: NSURL) -> Bool)) {
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
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(ConnectController.cancel(_:)))
        self.navigationItem.rightBarButtonItem = self.cancelButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !webView.canGoBack {
            if nil != startURL {
                loadURL(startURL!)
            }
            else {
                webView.loadHTMLString("There is no `startURL`", baseURL: nil)
            }
        }
    }
    
    func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.URL, parseAccessCode = self.tryParseAccessCodeFrom {
                if parseAccessCode(url: url) {
                    self.dismiss(true)
                    return decisionHandler(.Cancel)
                }
            }
            return decisionHandler(.Allow)
    }
    
    var startURL: NSURL? {
        didSet(oldURL) {
            if nil != startURL && nil == oldURL && isViewLoaded() {
                loadURL(startURL!)
            }
        }
    }
    
    func loadURL(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func showHideBackButton(show: Bool) {
        navigationItem.leftBarButtonItem = show ? UIBarButtonItem(barButtonSystemItem: .Rewind, target: self, action: #selector(ConnectController.goBack(_:))) : nil
    }
    
    func goBack(sender: AnyObject?) {
        webView.goBack()
    }
    
    func cancel(sender: AnyObject?) {
        dismiss(true, animated: (sender != nil))
    }
    
    func dismiss(animated: Bool) {
        dismiss(false, animated: animated)
    }
    
    func dismiss(asCancel: Bool, animated: Bool) {
        webView.stopLoading()
        
        self.onWillDismiss?(didCancel: asCancel)
        presentingViewController?.dismissViewControllerAnimated(animated, completion: nil)
    }
    
}
