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
    var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
}

