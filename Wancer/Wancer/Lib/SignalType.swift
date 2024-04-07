//
//  Constants.swift
//  Wancer
//
//  Created by Kenny Lin on 3/22/24.
//

import SwiftUI

struct SignalType {
    static let MESSAGE_TYPE = "11111"
    static let INVITATION_TYPE = "22222"
    static let ACCEPTATION_TYPE = "33333"
    static let DELIVERED_TYPE = "44444"
    static let NAVIGATION_TYPE = "55555"
    static let SOS_TYPE = "66666"
}

public enum EmergencyType {
    case STRANDED
    case MEDICAL
    case FIRE
    case MARINE
    case WILDLIFE
    case OTHER
    
    init?(rawValue: String) {
        switch rawValue {
        case "11111":
            self = .STRANDED
        case "22222":
            self = .MEDICAL
        case "33333":
            self = .FIRE
        case "44444":
            self = .MARINE
        case "55555":
            self = .WILDLIFE
        case "66666":
            self = .OTHER
        default:
            return nil
        }
    }
    
    var code: String {
        switch self {
        case .STRANDED:
            return "11111"
        case .MEDICAL:
            return "22222"
        case .FIRE:
            return "33333"
        case .MARINE:
            return "44444"
        case .WILDLIFE:
            return "55555"
        case .OTHER:
            return "66666"
        }
    }
}

