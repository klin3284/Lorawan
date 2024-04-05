//
//  Group.swift
//  wancer-swift
//
//  Created by Ethan Liu on 3/18/24.
//


import Foundation
import SwiftData

@Model
class Group: Identifiable {
    @Attribute(.unique)
    var id: String
    
    var name: String
    
    var acceptedAt: Date?
    
    @Relationship(deleteRule: .nullify)
    var users: [User]?
    
    @Relationship(deleteRule: .cascade, inverse: \Message.group)
    var messages: [Message]
    
    init(id: String, name: String, users: [User], messages: [Message]) {
        self.id = id
        self.name = name
        self.acceptedAt = nil
        self.users = users
        self.messages = messages
    }
    
    init(id: String, name: String, users: [User], acceptedAt: Date, messages: [Message]) {
        self.id = id
        self.name = name
        self.acceptedAt = acceptedAt
        self.users = users
        self.messages = messages
    }
    
    func setName(_ name: String) {
        self.name = name
    }
    
    func addUser(_ user: User) {
        users = (users ?? []) + [user]
    }
    
    func addMessage(_ message: Message) {
        messages.append(message)
    }
    
    func removeUser(_ user: User) {
        if var users = users, let index = users.firstIndex(where: { $0.id == user.id }) {
            users.remove(at: index)
            self.users = users
        }
    }
    
    func acceptInvitation() {
        if self.acceptedAt == nil {
            self.acceptedAt = Date.now
        }
    }
    
    func buildString(_ senderNumber: String) -> String? {
        if let usersFound = users {
            if usersFound.count > 1 {
                return signalStringBuilder(prefix: Constants.INVITATION_TYPE, fields: [(id, 20), (usersFound.map { String($0.id) }.joined(separator: ""), 100), (senderNumber, 10)])
            }
        }
        return nil
    }
}

