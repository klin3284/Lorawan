//
//  MainView.swift
//  Wancer
//
//  Created by Kenny Lin on 4/1/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTabIndex = 1
    @State private var showPopup = false
    @State private var navigateToBleView = false

    var body: some View {
        NavigationView {
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.LostBleConnection)) { _ in
                showPopup = true
            }
            .alert(isPresented: $showPopup) {
                Alert(title: Text("Lost Bluetooth Connection"),
                      message: Text("Your device has lost connection to the Bluetooth device."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}


#Preview {
    MainView()
}
