//
//  BleConnectionView.swift
//  Wancer
//
//  Created by Kenny Lin on 3/29/24.
//

import SwiftUI
import SwiftData

let gBluetoothManager = BluetoothManager()

struct BleConnectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    var bluetoothManager: BluetoothManager
    @State private var isShowingMeContactView = false
    @State private var showingAlert = false
    @Query private var users: [User]
    @Query private var groups: [Group]
    
    init() {
        self.bluetoothManager = gBluetoothManager
    }
    
    func fetchUserFromId(_ userId: Int) -> User? {
        return users.first(where: {$0.id == userId})
    }
    
    func fetchGroupFromId(_ groupId: String) -> Group? {
        return  groups.first(where: {$0.id == groupId})
    }
    
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.MessageReceived)) { _ in
                if let messageSignal = bluetoothManager.messageQueue.dequeue() {
                    switch(messageSignal) {
                    case let signal as MessageSignal:
                        if let userId = Int(signal.senderNumber) {
                            if  let group = fetchGroupFromId(signal.groupId),
                                let user = fetchUserFromId(userId) {
                                modelContext.insert(Message(id: Int(signal.messageId) ?? 9999, text: signal.text, createdAt: Date(), author: user, seen: false, group: group))
                            }
                        }
                        break;
                    case let signal as InvitationSignal:
                        if let senderId = Int(signal.senderNumber) {
                            if fetchGroupFromId(signal.groupId) == nil &&
                                fetchUserFromId(senderId) != nil {
                                var groupMember: [User] = []
                                for userIdString in signal.memberNumbers {
                                    if let userId = Int(userIdString) {
                                        if let userFound = fetchUserFromId(userId) {
                                            groupMember.append(userFound)
                                        } else {
                                            let newContact = User(id: userId, firstName: "Unknown", lastName: "Contact", groups: [])
                                            modelContext.insert(newContact)
                                            groupMember.append(newContact)
                                        }
                                    }
                                }
                                modelContext.insert(Group(id: signal.groupId, name: "", users: groupMember, messages: []))
                            }
                        }
                    default:
                        print("Signal Type Not Supported")
                        break;
                    }
                }
            }
        }
    }
}
