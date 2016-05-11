
import Alamofire

public class MessageClient: CompletionHandlerType<Message> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("messages")
    }
    
    public func list(roomId roomId: String, before: String? = nil, beforeMessage: String? = nil, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let query = HttpParameters([
            "roomId": roomId,
            "before": before,
            "beforeMessage": beforeMessage,
            "max": max])
        
        let request = requestBuilder()
            .method(.GET)
            .query(query)
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    public func create(roomId roomId: String? = nil, text: String? = nil, files: String? = nil, toPersonId: String? = nil, toPersonEmail: String? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = HttpParameters([
            "roomId": roomId,
            "text": text,
            "files": files,
            "toPersonId": toPersonId,
            "toPersonEmail": toPersonEmail])
        
        let request = requestBuilder()
            .method(.POST)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func get(messageId messageId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler){
        let request = requestBuilder()
            .method(.GET)
            .path(messageId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func delete(messageId messageId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(messageId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}