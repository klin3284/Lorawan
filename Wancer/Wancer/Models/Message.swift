//
//  Message.swift
//  wancer-swift
//
//  Created by Ethan Liu on 3/17/24.
//

import Foundation
import SwiftData

struct Message: Identifiable {
    let id: Int64
    let groupId: Int64
    let userId: Int64
    let text: String
    let createdAt: Date
    let secret: String
    let signalStrength: String?
    
    init(id: Int64, groupId: Int64, userId: Int64, text: String, createdAt: Date, secret: String, signalStrength: String?) {
        self.id = id
        self.groupId = groupId
        self.userId = userId
        self.text = text
        self.createdAt = createdAt
        self.secret = secret
        self.signalStrength = signalStrength
    }
    
    func buildString(_ groupSecret: String, _ authorPhoneNumber: String) -> String {
        return signalStringBuilder(prefix: SignalType.MESSAGE_TYPE, fields: [(groupSecret, 20), (secret, 20), (authorPhoneNumber,  10), (text, 200)])
    }
}
