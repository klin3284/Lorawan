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
            ChatView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }
    init() {
        do {
            container = try ModelContainer(for: User.self, Group.self, Message.self)
        }
        catch {
            fatalError("failed to create model container")
        }
    }

}
