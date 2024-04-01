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
    
    @State private var groupName = ""
    @State private var groupMembers: [User] = []
    
    var body: some View {
        VStack {
            TextField("Enter Group Chat Name", text: $groupName)
            
            HStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(groupMembers, id: \.id) { member in
                            Text("\(member.firstName) \(member.lastName)")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .onTapGesture {
                                    removeMember(member)
                                }
                        }
                    }
                }
            }
            .frame(height: 30)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            
            List(users, id: \.id) { user in
                Button(action: {
                    toggleMember(user)
                }) {
                    HStack {
                        Text("\(user.firstName) \(user.lastName)")
                        Spacer()
                        if groupMembers.contains(where: {$0.id == user.id}) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button("Done") {
                createGroup()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
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
        let groupIdString = groupMembers.map { String($0.id % 10_000) }.joined()
        if let groupId = Int(groupIdString) {
            let newGroup = Group(id: groupId, name: groupName, users: [], messages: [])
            for member in groupMembers {
                member.addGroup(newGroup)
            }
            isPresented = false
        }
    }
}

