//
//  CreateGroupView.swift
//  Wancer
//
//  Created by Kenny Lin on 4/1/24.
//

import SwiftUI
import SwiftData

struct CreateGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @Query private var users: [User] = []
    @Query private var groups: [Group] = []
    @State private var userManager = UserManager.shared
    @State private var groupName = ""
    @State private var groupMembers: [User] = []
    
    var bluetoothManager: BluetoothManager
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self.bluetoothManager = gBluetoothManager
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter Group Chat Name", text: $groupName)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(groupMembers.dropFirst(), id: \.id) { member in
                            Text("\(member.firstName) \(member.lastName)")
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .onTapGesture {
                                    removeMember(member)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                List(users.sorted { user1, user2 in
                    if user1.lastName == user2.lastName {
                        return user1.firstName < user2.firstName
                    } else {
                        return user1.lastName < user2.lastName
                    }
                }) { user in
                    Button(action: {
                        toggleMember(user)
                    }) {
                        HStack {
                            Text("\(user.firstName) \(user.lastName)")
                            Spacer()
                            if groupMembers.contains(where: { $0.id == user.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .navigationBarTitle("Create Group", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                createGroup()
            }) {
                Text("Create")
                    .foregroundColor(.blue)
            })
        }
        .onAppear {
            if let currentUser = userManager.retrieveUser() {
                groupMembers.append(currentUser)
            }
        }
    }
    
    private func toggleMember(_ user: User) {
        if let index = groupMembers.firstIndex(where: { $0.id == user.id }) {
            groupMembers.remove(at: index)
        } else {
            groupMembers.append(user)
        }
    }
    
    private func removeMember(_ user: User) {
        groupMembers.removeAll(where: { $0.id == user.id })
    }
    
    private func createGroup() {
        let groupId = groupMembers
            .sorted { $0.id < $1.id }
            .map { String($0.id % 10_000) }
            .joined()
        
        if groups.contains(where: {$0.id == groupId}) {
            print("Group already exists")
            return
        }
        
        let newGroup = Group(id: groupId, name: groupName, users: [], acceptedAt: Date(), messages: [])
        
        for member in groupMembers {
            member.addGroup(newGroup)
        }
        
        if let currentUser = userManager.retrieveUser() {
            if let invitationSignal = newGroup.buildString(String(currentUser.id)) {
                bluetoothManager.write(value: invitationSignal, characteristic: bluetoothManager.characteristics[0])
            }
        }
        
        isPresented = false
    }
}
