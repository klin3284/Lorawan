//
//  Message.swift
//  wancer-swift
//
//  Created by Ethan Liu on 3/17/24.
//

import Foundation
import SwiftData

@Model
class Message: Identifiable {
    var id: Int
    var text: String
    var createdAt: Date
    var author: Int
    var seen: Bool
    
    init(id: Int, text: String, createdAt: Date, author: Int, seen: Bool) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.author = author
        self.seen = seen
    }
}
