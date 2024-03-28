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
    var id: Int
    
    var name: String
    
    @Relationship(deleteRule: .nullify)
    var users: [User]?
    @Relationship(deleteRule: .cascade, inverse: \Message.group)
    var messages: [Message]
    
    init(id: Int, name: String, users: [User], messages: [Message]) {
        self.id = id
        self.name = name
        self.users = users
        self.messages = messages
    }
    
    func addUser(_ user: User) {
        users?.append(user)
    }
    
    func addMessage(_ message: Message) {
        messages.append(message)
    }
    
    func removeUser(_ user: User) {
        if let index = users?.firstIndex(where: { $0.id == user.id }) {
            users?.remove(at: index)
        }
    }
}

