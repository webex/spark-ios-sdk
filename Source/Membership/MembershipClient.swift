
import Alamofire

public class MembershipClient: CompletionHandlerType<Membership> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("memberships")
    }
    
    public func list(roomId roomId: String? = nil, personId: String? = nil, personEmail: String? = nil, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        
        let query = HttpParameters([
            "roomId": roomId,
            "personId": personId,
            "personEmail": personEmail,
            "max": max])
        
        let request = requestBuilder()
            .method(.GET)
            .query(query)
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    public func createWithPersonId(roomId roomId: String, personId: String? = nil, isModerator: Bool? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = HttpParameters([
            "roomId": roomId,
            "personId": personId,
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.POST)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func createWithPersonEmail(roomId roomId: String, personEmail: String? = nil, isModerator: Bool? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = HttpParameters([
            "roomId": roomId,
            "personEmail": personEmail,
            "isModerator": isModerator])
        
        let request = requestBuilder()
            .method(.POST)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func get(membershipId membershipId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func update(membershipId membershipId: String, isModerator: Bool, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .body(HttpParameters(["isModerator": isModerator]))
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func delete(membershipId membershipId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(membershipId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}