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


/// An Single sign-on [SSO](https://help.webex.com/docs/DOC-9143#reference_E9B2CEDE975E4CD311C56D9B0EF2476C)
/// based authentication strategy used to authenticate a user on Cisco Spark.
///
/// - see: [Cisco Spark Integration](https://developer.ciscospark.com/authentication.html)
/// - since: 1.2.0
import Foundation

public class SSOAuthenticator: OAuthAuthenticator {
    
    /// The base uri of the identity provider, which should conform to SAML 2.0 specifications.
    private let identityProviderUri: String
    
    /// A collection of additional query params.
    private let additionalQueryItems: [URLQueryItem]
    
    /// Creates a new SSO authentication strategy
    ///
    /// - parameter clientId: the OAuth client id
    /// - parameter clientSecret: the OAuth client secret
    /// - parameter scope: space-separated string representing which permissions the application needs
    /// - parameter redirectUri: the redirect URI that will be called when completing the authentication. This must match the redirect URI registered to your clientId.
    /// - parameter identityProviderUri: the URI that will handle authentication claims with spark service on behalf of the hosting application.
    /// - parameter additionalQueryItems: a collection of additional *URLQueryItem* to be appended to the identityProviderUri.
    ///
    /// - see: [Cisco Spark Integration](https://developer.ciscospark.com/authentication.html)
    /// - since: 1.2.0
    public init(clientId: String, clientSecret: String, scope: String, redirectUri: String, identityProviderUri: String,
         queryItems: [URLQueryItem] = []) {
        self.identityProviderUri = identityProviderUri
        self.additionalQueryItems = queryItems
        super.init(clientId: clientId, clientSecret: clientSecret, scope: scope, redirectUri: redirectUri,
                   storage: OAuthKeychainStorage(), oauthClient: OAuthClient(), oauthLauncher: OAuthLauncher(), clock: Clock())
    }
    
    
    /// Overrides the authorizationUrl by taking the original url and redirecting the request through the
    /// provided identity provider uri. Once the identity provider has validated the claim with Cisco Services it will
    /// redirect back to continue a slimmed down version of oAuth authentication flow which has prefilled the user spark
    /// id.
    ///
    /// This flow only interacts with the user if they need to explicitly need to provide permissions to allow spark to
    /// use their account.
    override func authorizationUrl() -> URL? {
        /// Construct the request uri to the identity provider by appending any provided parameters.
        if let authorizationUrl = super.authorizationUrl(), let components = NSURLComponents(string: identityProviderUri) {
            var queryItems = [URLQueryItem(name: "returnTo", value: authorizationUrl.absoluteString)]
            queryItems.append(contentsOf: additionalQueryItems)
            
            components.queryItems = queryItems
            
            return components.url
        }
        
        return nil
    }
}
