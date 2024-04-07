//
//  WancerApp.swift
//  Wancer
//
//  Created by Kenny Lin on 3/18/24.
//

import SwiftUI

@main
struct WancerApp: App {
    @StateObject private var databaseManager = DatabaseManager.shared
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(databaseManager)
                .environmentObject(bluetoothManager)
                .environmentObject(locationManager)
        }
    }
}
