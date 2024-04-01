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
    
    @Query private var users: [User]
    @Query private var groups: [Group]
    @Query private var messages: [Message]

    var body: some View {
       BleConnectionView()
    }
}

