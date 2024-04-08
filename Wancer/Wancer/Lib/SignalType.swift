//
//  Constants.swift
//  Wancer
//
//  Created by Kenny Lin on 3/22/24.
//

import SwiftUI

struct SignalType {
    static let MESSAGE_TYPE = "1111"
    static let INVITATION_TYPE = "2222"
    static let ACCEPTATION_TYPE = "3333"
    static let DELIVERED_TYPE = "4444"
    static let NAVIGATION_TYPE = "5555"
    static let SOS_TYPE = "6666"
}

enum EmergencyType: String, CaseIterable {
    case STRANDED = "11111"
    case MEDICAL = "22222"
    case FIRE = "33333"
    case MARINE = "44444"
    case WILDLIFE = "55555"
    case OTHER = "66666"
    
    var code: String {
        return self.rawValue
    }
    
    var stringValue: String {
        switch self {
        case .STRANDED:
            return "Stranded"
        case .MEDICAL:
            return "Medical"
        case .FIRE:
            return "Fire"
        case .MARINE:
            return "Marine"
        case .WILDLIFE:
            return "Wildlife"
        case .OTHER:
            return "Other"
        }
    }
}
