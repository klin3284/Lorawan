//
//  Notifications.swift
//  Wancer
//
//  Created by Kenny Lin on 3/27/24.
//

import SwiftUI

extension NSNotification {
    static let MessageReceived = Notification.Name.init("MessageReceived")
    static let LostBleConnection = Notification.Name.init("LostBleConnection")
}
