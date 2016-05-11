
public protocol Address {
    var address: String { get }
}

public class EmailAddress: Address {
    var emailAddress: String
    
    public init(_ address: String) {
        emailAddress = address
    }
    
    public var address: String {
        return emailAddress
    }
}

public class RoomIdAddress: Address {
    var roomIdAddress: String
    
    public init(_ address: String) {
        roomIdAddress = address
    }
    
    public var address: String {
        return roomIdAddress
    }
}

public class SipAddress: Address {
    var sipAddress: String
    
    public init(_ address: String) {
        sipAddress = address
    }
    
    public var address: String {
        return sipAddress
    }
}