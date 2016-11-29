
import Foundation

class SimpleAuthStrategy: AuthenticationStrategy {
    private var accessToken: String?
    
    var authorized: Bool {
        get {
            return accessToken != nil
        }
    }
    
    init(accessToken: String?) {
        self.accessToken = accessToken
    }
    
    func deauthorize() {
        accessToken = nil
    }
    
    func accessToken(completionHandler: @escaping (String?) -> Void) {
        completionHandler(accessToken)
    }
}
