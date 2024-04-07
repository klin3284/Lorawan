//
//  Emergency.swift
//  Wancer
//
//  Created by Kenny Lin on 4/6/24.
//

import SwiftUI

class Emergency: Identifiable {
    var id: Int64
    var type: EmergencyType
    var name: String
    var senderNumber: String
    var createdAt: Date
    var latitude: Double
    var longitude: Double
    var text: String
    
    init(id: Int64, type: EmergencyType, name: String, senderNumber: String, createdAt: Date, latitude: Double, longitude: Double, text: String) {
        self.id = id
        self.type = type
        self.name = name
        self.senderNumber = senderNumber
        self.createdAt = createdAt
        self.latitude = latitude
        self.longitude = longitude
        self.text = text
    }
    
    func buildString() -> String {
        let createdAtToString = DateFormatter.standard.string(from: createdAt)
        
        return signalStringBuilder(prefix: SignalType.SOS_TYPE, fields: [(type.code, 5), (name, 30), (senderNumber, 10), (createdAtToString, 20), (String(latitude), 8), (String(longitude), 8), ("", 4), (text, 165)])
    }
}
