//  Copyright © 2016 Cisco Systems, Inc. All rights reserved.

import Foundation
import ObjectMapper

// Room type.
public enum RoomType: String {
    /// 1-to-1 room
    case Direct
    /// Group room
    case Group
}

/// Room contents.
public struct Room: Mappable {
    public var id: String?
    public var title: String?
    public var type: RoomType?
    public var isLocked: Bool?
    public var lastActivity: String?
    public var created: String?

    /// Room constructor.
    /// - Note: for internal use only.
    public init?(_ map: Map){
    }
    
    /// Room mapping from JSON.
    /// - Note: for internal use only.
    public mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        type <- (map["type"], RoomTypeTransform())
        isLocked <- map["isLocked"]
        lastActivity <- map["lastActivity"]
        created <- map["created"]
    }
    
    private class RoomTypeTransform: TransformType {
        typealias Object = RoomType
        typealias JSON = String
        
        func transformFromJSON(value: AnyObject?) -> Object? {
            guard let state = value as? String else {
                return nil
            }
            return RoomType(rawValue: state)
        }
        
        func transformToJSON(value: Object?) -> JSON? {
            return nil
        }
    }
}