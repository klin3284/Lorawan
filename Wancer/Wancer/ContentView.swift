//
//  ContentView.swift
//  Wancer
//
//  Created by Kenny Lin on 3/18/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var bluetoothManager = BluetoothManager()
    
    @Query private var users: [User]
    @Query private var groups: [Group]
    @Query private var messages: [Message]
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .padding()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: User.self)
        .modelContainer(for: Group.self)
        .modelContainer(for: Message.self)
}
