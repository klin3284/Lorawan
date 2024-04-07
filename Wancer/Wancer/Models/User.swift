//
//  User.swift
//  wancer-swift
//
//  Created by Ethan Liu on 3/16/24.
//

import Foundation

class User: Identifiable, Codable {
    let id: Int64
    var firstName: String
    var lastName: String
    var phoneNumber: String
    
    init(id: Int64, firstName: String, lastName: String, phoneNumber: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }
    
    // MARK: Codable
    enum CodingKeys: CodingKey {
        case id, firstName, lastName, phoneNumber
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        id = try container.decode(Int64.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(id, forKey: .id)
    }
    
    func changeFirstName(_ firstName: String) {
        self.firstName = firstName
    }
    
    func changeLastName(_ lastName: String) {
        self.lastName = lastName
    }
}


