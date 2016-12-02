
import Foundation

class SimpleAuthStrategy: AuthenticationStrategy {
    static func neverAuthorized() -> AuthenticationStrategy {
        return SimpleAuthStrategy(possibleAccessToken: nil)
    }
    
    private var accessToken: String?
    
    var authorized: Bool {
        return accessToken != nil
    }
    
    private init(possibleAccessToken: String?) {
        self.accessToken = possibleAccessToken
    }
    
    convenience init(accessToken: String) {
        self.init(possibleAccessToken: accessToken)
    }
    
    func deauthorize() {
        accessToken = nil
    }
    
    func accessToken(completionHandler: @escaping (String?) -> Void) {
        completionHandler(accessToken)
    }
}
