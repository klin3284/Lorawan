//
//  WancerApp.swift
//  Wancer
//
//  Created by Kenny Lin on 3/18/24.
//

import SwiftUI
import SwiftData

@main
struct WancerApp: App {
    
    let container: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
    
    init() {
        do {
            container = try ModelContainer(for: User.self, Group.self, Message.self)
            print("Created model container")
        }
        catch {
            fatalError("Failed to create model container")
        }
    }
}
