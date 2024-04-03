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
    @Attribute(.unique)
    var id: Int
    
    var text: String
    
    var createdAt: Date
    
    var author: User?
    
    var seen: Bool
    
    var group: Group?
    
    init(id: Int, text: String, createdAt: Date, author: User?, seen: Bool, group: Group?) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.author = author
        self.seen = seen
        self.group = group
    }
    
    func buildString() -> String? {
        if let groupFound = group,
           let userFound = author {
            return signalStringBuilder(prefix: Constants.MESSAGE_TYPE, fields: [(String(groupFound.id), 20), (String(id), 20), (String(userFound.id), 10), (text, 200)])
        }
        return nil
    }
}
