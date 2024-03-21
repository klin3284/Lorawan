//
//  User.swift
//  wancer-swift
//
//  Created by Ethan Liu on 3/16/24.
//

import Foundation
import SwiftData

@Model
class User: Identifiable, ObservableObject {
    @Attribute(.unique)
    var id: Int
    var firstName: String
    var lastName: String
    @Relationship(inverse: \Group.users)
    var groups: [Group]
    
    init(id: Int, firstName: String, lastName: String, groups: [Group]) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.groups = groups
    }
}


