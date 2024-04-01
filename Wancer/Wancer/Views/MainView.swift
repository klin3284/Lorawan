//
//  MainView.swift
//  Wancer
//
//  Created by Kenny Lin on 4/1/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTabIndex = 1
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            ContactsView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Contacts")
                }
                .tag(0)
            
            MessagesView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Messages")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .onAppear {
            selectedTabIndex = 1
        }
    }
}


#Preview {
    MainView()
}
