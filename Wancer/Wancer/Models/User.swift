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
    var id: Int
    var firstName: String
    var lastName: String
    
    init(id: Int, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
    
}


