
import Foundation

class SparkInstance {
    private static var actualSharedInstance: SparkInstance?
    
    static var sharedInstance: SparkInstance {
        get {
            if actualSharedInstance == nil {
                actualSharedInstance = SparkInstance()
            }
            return actualSharedInstance!
        }
    }
    
    let authenticationStrategy: AuthenticationStrategyProxy
    let callMetrics: CallMetrics
    let reachabilityService: ReachabilityService
    let deviceService: DeviceService
    let phone: Phone
    
    init() {
        authenticationStrategy = AuthenticationStrategyProxy()
        callMetrics = CallMetrics(authenticationStrategy: authenticationStrategy)
        reachabilityService = ReachabilityService(authenticationStrategy: authenticationStrategy)
        let callManager = CallManager(authenticationStrategy: authenticationStrategy)
        let webSocketService = WebSocketService(authenticationStrategy: authenticationStrategy, callManager: callManager)
        let applicationLifecycleObserver = ApplicationLifecycleObserver(webSocketService: webSocketService, callManager: callManager)
        deviceService = DeviceService(authenticationStrategy: authenticationStrategy)
        phone = Phone(authenticationStrategy: authenticationStrategy, applicationLifecycleObserver: applicationLifecycleObserver, webSocketService: webSocketService, callManager: callManager)
    }
    
    func set(authenticationStrategy: AuthenticationStrategy) {
        self.authenticationStrategy.setDelegateStrategy(authenticationStrategy)
    }
}
