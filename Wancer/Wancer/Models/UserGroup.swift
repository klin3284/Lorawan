//
//  UserGroup.swift
//  wancer-swift
//
//  Created by Ethan Liu on 3/17/24.
//

import Foundation
import SwiftData

@Model
class UserGroup: Identifiable {
    var id: Int
    var name: String
    var users: [User]
    
    init(id: Int, name: String, users: [User] = []) {
        self.id = id
        self.name = name
        self.users = users
    }
    
    func addUser(_ user: User) {
        users.append(user)
    }
    
    func removeUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users.remove(at: index)
        }
    }
}




