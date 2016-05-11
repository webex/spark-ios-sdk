
import Alamofire

public class WebhookClient: CompletionHandlerType<Webhook> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("webhooks")
    }
    
    public func list(max max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(HttpParameters(["max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    public func create(name name: String, targetUrl: String, resource: String, event: String, filter: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let body = HttpParameters([
            "name": name,
            "targetUrl": targetUrl,
            "resource": resource,
            "event": event,
            "filter": filter])
        
        let request = requestBuilder()
            .method(.POST)
            .body(body)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func get(webhookId webhookId: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func update(webhookId webhookId: String, name: String, targetUrl: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .body(HttpParameters(["name": name, "targetUrl": targetUrl]))
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func delete(webhookId webhookId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(webhookId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}