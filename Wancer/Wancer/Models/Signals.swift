//
//  Signals.swift
//  Wancer
//
//  Created by Kenny Lin on 3/22/24.
//

import SwiftUI

class Signal {
    func buildString() -> String {
        return ""
    }
}

class CommunicationSignal: Signal {
    var groupId : String
    var messageId : String
    var senderNumber : String
    
    init(groupId: String, messageId: String, senderNumber: String) {
        self.groupId = groupId
        self.messageId = messageId
        self.senderNumber = senderNumber
    }
}

class InvitationSignal: CommunicationSignal {
    var memberNumbers : [String]
    
    init(groupId: String, memberNumbers : [String], senderNumber: String) {
        self.memberNumbers = memberNumbers
        super.init(groupId: groupId, messageId: "", senderNumber: senderNumber)
    }
    
    override func buildString() -> String {
        return signalStringBuilder(prefix: Constants.INVITATION_TYPE, fields: [(groupId, 20), (memberNumbers.joined(separator: ""), 100), (senderNumber, 10)])
    }
    
}

class AcceptationSignal: CommunicationSignal {
    init(groupId: String, senderNumber: String) {
        super.init(groupId: groupId, messageId: "", senderNumber: senderNumber)
    }
    
    override func buildString() -> String {
        return signalStringBuilder(prefix: Constants.ACCEPTATION_TYPE, fields: [(groupId, 20), (senderNumber, 10)])
    }
}

class MessageSignal: CommunicationSignal {
    var text : String
    
    init(groupId: String, messageId: String, senderNumber: String, text: String) {
        self.text = text
        super.init(groupId: groupId, messageId: messageId, senderNumber: senderNumber)
    }
    
    func createSignal() -> Message {
        print("GroupID:\(groupId) SenderId: \(senderNumber) MessageId: \(messageId)")
        return Message(id: Int(messageId) ?? 9999, text: text, createdAt: Date(), author: nil, seen: false, group: nil)
    }
    
    override func buildString() -> String {
        return signalStringBuilder(prefix: Constants.MESSAGE_TYPE, fields: [(groupId, 20), (messageId, 20), (senderNumber, 10), (text, 200)])
    }
}

class NavigationSignal: CommunicationSignal {
    var location: String
    
    init(groupId: String, messageId: String, senderNumber: String, location: String) {
        self.location = location
        super.init(groupId: groupId, messageId: messageId, senderNumber: senderNumber)
    }
    
    override func buildString() -> String {
        return signalStringBuilder(prefix: Constants.NAVIGATION_TYPE, fields: [(groupId, 20), (messageId, 20), (senderNumber, 10), (location, 20)])
    }
}

class DeliveredSignal: CommunicationSignal {
    override func buildString() -> String {
        return signalStringBuilder(prefix: Constants.DELIVERED_TYPE, fields: [(groupId, 20), (messageId, 20), (senderNumber, 10)])
    }
}

class SosSignal: Signal {
    var name: String
    var senderNumber: String
    var createdAt: Date
    var location: String
    var text: String
    
    init(name: String, senderNumber: String, createdAt: Date, location: String, text: String) {
        self.name = name
        self.senderNumber = senderNumber
        self.createdAt = createdAt
        self.location = location
        self.text = text
    }
    
    override func buildString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdAtToString = dateFormatter.string(from: createdAt)
        
        return signalStringBuilder(prefix: Constants.SOS_TYPE, fields: [(name, 30), (senderNumber, 10), (createdAtToString, 20), (location, 20), (text, 170)])
    }
}

public func signalStringBuilder(prefix: String, fields: [(field: String, maxLength: Int)]) -> String {
    var message = prefix
    var rangeMinBound = 0
    
    for (field, maxLength) in fields {
        message += field.padding(toLength: maxLength, withPad: " ", startingAt: 0)
        rangeMinBound += maxLength
    }
    
    message = message.padding(toLength: 255, withPad: " ", startingAt: 0)
    
    return message
}
