//
//  Emergency.swift
//  Wancer
//
//  Created by Kenny Lin on 4/6/24.
//

import SwiftUI

class Emergency {
    var id: Int64
    var name: String
    var senderNumber: String
    var createdAt: Date
    var location: String
    var text: String
    
    init(id: Int64, name: String, senderNumber: String, createdAt: Date, location: String, text: String) {
        self.id = id
        self.name = name
        self.senderNumber = senderNumber
        self.createdAt = createdAt
        self.location = location
        self.text = text
    }
    
    func buildString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdAtToString = dateFormatter.string(from: createdAt)
        
        return signalStringBuilder(prefix: Constants.SOS_TYPE, fields: [(name, 30), (senderNumber, 10), (createdAtToString, 20), (location, 20), (text, 170)])
    }
}
