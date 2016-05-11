
import Alamofire

public class PersonClient: CompletionHandlerType<Person> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("people")
    }
    
    public func list(email email: String? = nil, displayName: String? = nil, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(HttpParameters(["email": email, "displayName": displayName, "max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    public func get(personId personId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler){
        let request = requestBuilder()
            .method(.GET)
            .path(personId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func getMe(queue queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler){
        let request = requestBuilder()
            .method(.GET)
            .path("me")
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
}
