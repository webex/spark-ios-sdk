
import Foundation

class AuthenticationStrategyProxy: AuthenticationStrategy {
    private var delegate: AuthenticationStrategy?
    func setDelegateStrategy(_ delegate: AuthenticationStrategy?) {
        self.delegate = delegate
    }
    
    var authorized: Bool {
        get {
            if let delegate = delegate {
                return delegate.authorized
            } else {
                return false
            }
        }
    }
    
    func deauthorize() {
        if let delegate = delegate {
            return delegate.deauthorize()
        }
    }
    
    func accessToken(completionHandler: @escaping (String?) -> Void) {
        if let delegate = delegate {
            return delegate.accessToken(completionHandler: completionHandler)
        } else {
            completionHandler(nil)
        }
    }
}
