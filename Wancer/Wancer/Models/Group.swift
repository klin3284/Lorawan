//
//  Group.swift
//  wancer-swift
//
//  Created by Ethan Liu on 3/18/24.
//


import Foundation
import SwiftData

struct Group: Identifiable {
    let id: Int64
    var name: String
    var acceptedAt: Date?
    let secret: String
    var messages: [Message]
    
    init(id: Int64, name: String, acceptedAt: Date?, secret: String, messages: [Message]) {
        self.id = id
        self.name = name
        self.acceptedAt = acceptedAt
        self.secret = secret
        self.messages = messages
    }
    
    func buildString(_ senderNumber: String, _ recipientNumbers: [String]) -> String? {
        if recipientNumbers.count > 1 {
            return signalStringBuilder(prefix: Constants.INVITATION_TYPE, fields: [(secret, 20), (recipientNumbers.joined(separator: ""), 100), (senderNumber, 10)])
        }
        return nil
    }
}

