
import Foundation

class OAuthLauncher {
    func launchOAuthViewController(parentViewController: UIViewController, authorizationUrl: URL,
                                   redirectUri: String, completionHandler: @escaping (_ oauthCode: String?) -> Void) {
        let viewController = OAuthViewController(authorizationUrl: authorizationUrl, redirectUri: redirectUri, completionHandler: completionHandler)
        let navigationController = UINavigationController(rootViewController: viewController)
        parentViewController.present(navigationController, animated: true, completion: nil)
    }
}
