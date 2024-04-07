//
//  CreateGroupView.swift
//  Wancer
//
//  Created by Kenny Lin on 4/1/24.
//

import SwiftUI

struct CreateGroupView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Binding var isPresented: Bool
    @State var currentUser = UserManager.shared.retrieveUser()!
    @State private var groupName = ""
    @State private var searchName = ""
    @State private var groupMembers: [User] = []
    @State private var invalidState = false
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField(invalidState ? "Cannot be Empty" : "Enter Group Chat Name", text: $groupName)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(invalidState ? Color.red : Color.clear, lineWidth: 1)
                    )
                    .onChange(of: groupName) {
                        invalidState = false
                    }
                
                HStack {
                    TextField("Search for...", text: $searchName)
                    Spacer()
                    Button(action: {searchName = ""}) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                }
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
                
                List(databaseManager.users
                    .filter {
                        (searchName == "" ||
                            $0.firstName.localizedCaseInsensitiveContains(searchName) ||
                            $0.lastName.localizedCaseInsensitiveContains(searchName)
                        ) && $0.id != currentUser.id
                    }

                    .sorted { user1, user2 in
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
            groupMembers.append(currentUser)
        }
    }
    
    private func toggleMember(_ user: User) {
        if let index = groupMembers.firstIndex(where: { $0.id == user.id }) {
            groupMembers.remove(at: index)
        } else {
            groupMembers.append(user)
            searchName = ""
        }
    }
    
    private func removeMember(_ user: User) {
        groupMembers.removeAll(where: { $0.id == user.id })
    }
    
    private func createGroup() {
        guard groupName != "" else {
            print("group name cannot be empty")
            self.invalidState = true
            return
        }
        
        let groupSecret = groupMembers
            .sorted { $0.phoneNumber < $1.phoneNumber }
            .map { String($0.phoneNumber.suffix(groupMembers.count <= 5 ? 4 : 2)) }
            .joined()
        
        if databaseManager.groups.contains(where: {$0.secret == groupSecret}) {
            print("Group already exists")
            return
        }
        
        if let groupId = databaseManager.insertGroup(groupName, groupSecret, Date()) {
            databaseManager.getAllGroups()
            
            for member in groupMembers {
                databaseManager.insertUserGroup(member.id, groupId)
            }
            
            if let invitationSignal = databaseManager.groups.first(where: {$0.id == groupId})?
                .buildString(currentUser.phoneNumber, groupMembers.map{$0.phoneNumber}) {
                bluetoothManager.write(value: invitationSignal, characteristic: bluetoothManager.characteristics[0])
            } else {
                print("Couldnt build string")
            }
            
            searchName = ""
            groupName = ""
        }
        
        isPresented = false
    }
}
