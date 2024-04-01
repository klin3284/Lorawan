//
//  User.swift
//  wancer-swift
//
//  Created by Ethan Liu on 3/16/24.
//

import Foundation
import SwiftData

@Model
class User: Identifiable, Codable {
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
    
    // MARK: Codable
    enum CodingKeys: CodingKey {
        case id, firstName, lastName, groups
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        id = try container.decode(Int.self, forKey: .id)
        groups = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(id, forKey: .id)
    }
    
    func addGroup(_ group: Group) {
        self.groups.append(group)
    }
    
    func changeFirstName(_ firstName: String) {
        self.firstName = firstName
    }
    
    func changeLastName(_ lastName: String) {
        self.lastName = lastName
    }
}


