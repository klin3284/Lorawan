//
//  WancerApp.swift
//  Wancer
//
//  Created by Kenny Lin on 3/18/24.
//

import SwiftUI

@main
struct WancerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: User.self)
                .modelContainer(for: Group.self)
                .modelContainer(for: Message.self)
        }
    }
}
