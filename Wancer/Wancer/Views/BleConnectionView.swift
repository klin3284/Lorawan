//
//  BleConnectionView.swift
//  Wancer
//
//  Created by Kenny Lin on 3/29/24.
//

import SwiftUI

struct BleConnectionView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var isShowingMeContactView = false
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Bluetooth is \(bluetoothManager.isBluetoothEnabled ? "enabled" : "disabled")")
                    .padding()
                
                if let connectedPeripheral = bluetoothManager.connectedPeripheral {
                    VStack{
                        Button(action: {
                            bluetoothManager.disconnect(peripheral: connectedPeripheral)
                        }) {
                            Text("\(connectedPeripheral.name ?? "Device") Connected")
                        }
                    }
                } else {
                    Text("Discovered Devices")
                        .padding()
                    
                    List(bluetoothManager.discoveredPeripherals.filter { $0.name != nil }, id: \.identifier) { peripheral in
                        Button(action: {
                            bluetoothManager.connect(peripheral: peripheral) { success in
                                if success {
                                    print("Successfully connected to peripheral.")
                                    isShowingMeContactView = true
                                } else {
                                    showingAlert = true
                                    print("Failed to connect to peripheral.")
                                }
                            }
                        }) {
                            Text(peripheral.name ?? "Unknown")
                        }
                    }
                    .refreshable {
                        bluetoothManager.discoveredPeripherals.removeAll()
                        bluetoothManager.startScan()
                    }
                    
                    Text("Not Connected")
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Connection Failed"), message: Text("This device is not supported."), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $isShowingMeContactView) {
                MeContactView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
