//
//  BleConnectionView.swift
//  Wancer
//
//  Created by Kenny Lin on 3/29/24.
//

import SwiftUI
import SwiftData

struct BleConnectionView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var bluetoothManager = BluetoothManager()
    @Query private var users: [User]
    @Query private var groups: [Group]
    @Query private var messages: [Message]
    
    func fetchUserFromId(_ userId: Int) -> User? {
        return users.first(where: {$0.id == userId})
    }
    
    func fetchGroupFromId(_ groupId: Int) -> Group? {
        return  groups.first(where: {$0.id == groupId})
    }
    
    var body: some View {
        NavigationView{
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
                        List(messages) { message in
                            Text("Text Message: \(message.text) Field: \(message.id) \(String(describing: message.group)) \(String(describing: message.author))")
                        }
                    }
                } else {
                    Text("Discovered Devices")
                        .padding()
                    
                    List(bluetoothManager.discoveredPeripherals.filter { $0.name != nil }, id: \.identifier) { peripheral in
                        Button(action: {
                            bluetoothManager.connect(peripheral: peripheral)
                        }) {
                            Text(peripheral.name ?? "Unknown")
                        }
                    }

                    Text("Not Connected")
                }
                
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.MessageReceived)) { _ in
                if let messageSignal = bluetoothManager.messageQueue.dequeue() {
                    switch(messageSignal) {
                    case let signal as MessageSignal:
                        if  let group = fetchGroupFromId(Int(signal.groupId) ?? 9999),
                            let user = fetchUserFromId(Int(signal.senderNumber)  ?? 9999)
                        {
                            modelContext.insert(Message(id: Int(signal.messageId) ?? 9999, text: signal.text, createdAt: Date(), author: user, seen: false, group: group))
                        }
                        break;
                    default:
                        print("Signal Type Not Supported")
                        break;
                    }
                }
            }
        }
    }
}

#Preview {
    BleConnectionView()
}
