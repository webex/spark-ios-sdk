import Foundation

@objc
public class KmsClusterInfo: NSObject {
    public let kmsCluster: String
    public let kmsPublicKey: String
    
    public init(kmsCluster: String, kmsPublicKey: String) {
        self.kmsCluster = kmsCluster
        self.kmsPublicKey = kmsPublicKey
    }
}
