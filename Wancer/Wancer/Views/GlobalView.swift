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
            HStack(spacing: 30) {
                Text(emergency.name)
                    .font(.headline)
                Text(emergency.senderNumber.toPhoneNumberFormat())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            HStack {
                Image(systemName: "location")
                Text(CLLocationCoordinate2D(latitude: emergency.latitude, longitude: emergency.longitude).formattedCoordinate)
            }
            HStack(spacing: 15) {
                Text("Emergency: \(emergency.type.stringValue)")
                    .font(.subheadline)
                
                Text(DateFormatter.standard.string(from: emergency.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(emergency.text)
                .font(.subheadline)
                .foregroundColor(.gray)

        }
    }
}
