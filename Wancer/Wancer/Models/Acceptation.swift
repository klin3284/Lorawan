//
//  Acceptation.swift
//  Wancer
//
//  Created by Kenny Lin on 4/1/24.
//

import SwiftUI
import SwiftData

class Acceptation : Signal, Identifiable {
    var acceptedAt: Date
    
    var author: User?
    
    var group: Group?
    
    init(acceptedAt: Date, author: User? = nil, group: Group? = nil) {
        self.acceptedAt = acceptedAt
        self.author = author
        self.group = group
    }
}
