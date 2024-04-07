//
//  CreateSOSView.swift
//  Wancer
//
//  Created by Kenny Lin on 4/6/24.
//

import SwiftUI
import CoreLocation

struct CreateEmergencyView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Binding var isPresented: Bool
    @State private var selectedEmergencyType: EmergencyType = EmergencyType.STRANDED
    @State private var currentUser = UserManager.shared.retrieveUser()!
    @State private var text = ""
    @State private var showConfirmation = false
    @State private var currentLocation: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationView {
            Form {
                Text("This emergency will be shared with anyone nearby. Use only in emergencies.")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                
                Section(header: Text("Your Information")) {
                    Text("Name: \(currentUser.firstName) \(currentUser.lastName)")
                    Text("Phone Number: \(currentUser.phoneNumber.toPhoneNumberFormat())")
                }
                Section(header: Text("Location")) {
                    HStack {
                        Image(systemName: "location")
                        if let location = currentLocation {
                            Text(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude).formattedCoordinate)
                        }
                    }
                }
                
                Picker("Select Emergency Type", selection: $selectedEmergencyType) {
                    ForEach(EmergencyType.allCases, id: \.self) { option in
                        Text(option.stringValue)
                    }
                }
                
                Section(header: Text("Message")) {
                    TextField("Write SOS Message...", text: $text)
                        .padding(.bottom, 100)
                }
            }
            .navigationBarTitle("Create Emergency", displayMode: .inline)
            .navigationBarItems(trailing: Button("Send") {
                showConfirmation = true
            })
            .confirmationDialog("Confirm Emergency", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Send", role: .destructive) {
                    if let location = currentLocation {
                        let emergencyId = databaseManager.insertEmergency(type: selectedEmergencyType, name: "\(currentUser.firstName) \(currentUser.lastName)", phoneNumber: currentUser.phoneNumber, latitude: location.latitude, longitude: location.longitude, text: text)
                        databaseManager.getAllEmergencies()
                        
                        if let emergencySignal = databaseManager.emergencies.first(where: {$0.id == emergencyId})?
                            .buildString() {
                            bluetoothManager.write(value: emergencySignal, characteristic: bluetoothManager.characteristics[0])
                        } else {
                            print("Couldnt build string")
                        }
                        
                        isPresented = false
                    }
                }
            }
        }
        .onAppear() {
            currentLocation = self.locationManager.location
        }
    }
}

