//
//  MainView.swift
//  Wancer
//
//  Created by Kenny Lin on 4/1/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTabIndex = 1
    @Query private var groups: [Group]
    @Query private var users: [User]
    @Query private var messages: [Message]
    var bluetoothManager: BluetoothManager
    
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.MessageReceived)) { _ in
            print("notified of signal")
            if let messageSignal = bluetoothManager.messageQueue.dequeue() {
                switch(messageSignal) {
                case let signal as MessageSignal:
                    print("messaged")
                    print(signal.groupId)
                    print(signal.senderNumber)
                    print(signal.text)
                    if let userId = Int(signal.senderNumber) {
                        if  let group = fetchGroupFromId(signal.groupId.trimmingCharacters(in: .whitespaces)),
                            let user = fetchUserFromId(userId) {
                            print("parsing")
                            let newMsg = Message(id: Int(signal.messageId) ?? 9999, text: signal.text, createdAt: Date(), author: user, seen: false, group: nil)
                            group.addMessage(newMsg)
                        }
                    }
                    break;
                case let signal as InvitationSignal:
                    print("Invite")
                    print(signal.senderNumber)
                    print(signal.groupId)
                    print(signal.memberNumbers.count)
                    if let senderId = Int(signal.senderNumber) {
                        if fetchGroupFromId(signal.groupId) == nil &&
                            fetchUserFromId(senderId) != nil {
                            var groupMember: [User] = []
                            if let senderFound = fetchUserFromId(senderId) {
                                print("sender added")
                                groupMember.append(senderFound)
                            }
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
                            let newGroup = Group(id: signal.groupId, name: "", users: [], messages: [])
                            for member in groupMember {
                                member.addGroup(newGroup)
                            }
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


#Preview {
    MainView()
}
