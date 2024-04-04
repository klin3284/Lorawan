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
    @State private var userManager = UserManager.shared
    @State private var groupName = ""
    @State private var groupMembers: [User] = []
    @State private var currentUser: User?
    @Query private var groups: [Group]
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
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
                                    if member != currentUser {
                                        removeMember(member)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                List(users, id: \.id) { user in
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
                self.currentUser = currentUser
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
        
        let newGroup = Group(id: groupId, name: groupName, users: [], messages: [])
        for member in groupMembers {
            member.addGroup(newGroup)
        }
        isPresented = false
    }
}
