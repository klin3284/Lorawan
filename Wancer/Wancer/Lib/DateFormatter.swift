//
//  DateFormatter.swift
//  Wancer
//
//  Created by Kenny Lin on 4/6/24.
//

import SwiftUI

extension DateFormatter {
    static var standard: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
