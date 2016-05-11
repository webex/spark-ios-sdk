//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation

/// Room HTTP client
public class RoomClient: CompletionHandlerType<Room> {
    
    private func requestBuilder() -> ServiceRequest.Builder {
        return ServiceRequest.Builder().path("rooms")
    }

    public func list(showSipAddress showSipAddress: Bool? = nil, max: Int? = nil, queue: dispatch_queue_t? = nil, completionHandler: ArrayHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(HttpParameters(["showSipAddress": showSipAddress, "max": max]))
            .keyPath("items")
            .queue(queue)
            .build()
        
        request.responseArray(completionHandler)
    }
    
    public func create(title title: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.POST)
            .body(HttpParameters(["title": title]))
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func get(roomId roomId: String, showSipAddress: Bool? = nil, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.GET)
            .query(HttpParameters(["showSipAddress": showSipAddress]))
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func update(roomId roomId: String, title: String, queue: dispatch_queue_t? = nil, completionHandler: ObjectHandler) {
        let request = requestBuilder()
            .method(.PUT)
            .body(HttpParameters(["title": title]))
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseObject(completionHandler)
    }
    
    public func delete(roomId roomId: String, queue: dispatch_queue_t? = nil, completionHandler: AnyObjectHandler) {
        let request = requestBuilder()
            .method(.DELETE)
            .path(roomId)
            .queue(queue)
            .build()
        
        request.responseJSON(completionHandler)
    }
}