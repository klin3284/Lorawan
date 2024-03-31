//
//  User.swift
//  wancer-swift
//
//  Created by Ethan Liu on 3/16/24.
//

import Foundation
import SwiftData

@Model
class User: Identifiable {
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
    
    func addGroups(_ group: Group) {
        self.groups.append(group)
    }
    
    func changeFirstName(_ firstName: String) {
        self.firstName = firstName
    }
    
    func changeLastName(_ lastName: String) {
        self.lastName = lastName
    }
}


