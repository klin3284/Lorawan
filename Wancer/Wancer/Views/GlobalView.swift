//
//  SettingsView.swift
//  Wancer
//
//  Created by Kenny Lin on 4/1/24.
//

import SwiftUI
import CoreLocation

struct GlobalView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @State private var showCreateEmergency = false
    
    var body: some View {
        NavigationView {
            List(databaseManager.emergencies ) { emergency in
                EmergencyRow(emergency: emergency)
            }
            .navigationBarTitle("Emergencies")
            .navigationBarItems(trailing: Button(action: {
                showCreateEmergency = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showCreateEmergency) {
                CreateEmergencyView(isPresented: $showCreateEmergency)
            }
            .onAppear {
                databaseManager.getAllEmergencies()
            }
        }
    }
}

struct EmergencyRow: View {
    @State var emergency: Emergency
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(emergency.name)
                .font(.headline)
            Text(emergency.senderNumber)
            Text(String(emergency.latitude))
            Text(String(emergency.longitude))
            Text(emergency.text)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(DateFormatter.standard.string(from: emergency.createdAt))
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
