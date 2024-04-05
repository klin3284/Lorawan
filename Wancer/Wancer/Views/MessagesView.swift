//
//  GroupsListView.swift
//  Wancer
//
//  Created by Kenny Lin on 3/29/24.
//

import SwiftUI
import SwiftData

struct MessagesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var groups: [Group]
    @State private var isCreatingGroup = false
    @State private var isAcceptingGroup = false
    
    private var sortedGroups: [Group] {
        groups.sorted { group1, group2 in
            guard let lastMessage1 = group1.messages.last,
                  let lastMessage2 = group2.messages.last else {
                return false
            }
            return lastMessage1.createdAt > lastMessage2.createdAt
        }
    }
    
    var body: some View {
        NavigationView {
            List(sortedGroups.filter { $0.acceptedAt != nil }) { group in
                NavigationLink(destination: ChatView(group: group)
                ) {
                    GroupRowView(group: group)
                }
                .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive, action: {
                            deleteGroup(group)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .navigationBarTitle("Messages", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            self.isAcceptingGroup = true
                        }) {
                            Image(systemName: "envelope")
                        }
                        Button(action: {
                            self.isCreatingGroup = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isCreatingGroup) {
                CreateGroupView(isPresented: $isCreatingGroup)
            }
            .sheet(isPresented: $isAcceptingGroup) {
                PendingGroupView(isPresented: $isAcceptingGroup)
                
            }
        }
    }
    
    private func deleteGroup(_ group: Group) {
        guard UserManager.shared.retrieveUser() != nil else {
            print("Current user not found")
            return
        }
        
        modelContext.delete(group)
    }
}

struct PendingGroupView: View {
    @Binding var isPresented: Bool
    @Query private var groups: [Group]
    @State private var showAssignGroupName = false
    @State private var groupName = ""
    @State private var selectedGroup: Group?
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            Text("Pending Groups")
                .font(.headline)
                .padding()
            
            List(groups.filter{ $0.acceptedAt == nil }) { group in
                HStack {
                    Text(group.users?.map{ $0.firstName }.joined(separator: " ") ?? "Unknown Members")
                    Spacer()
                    Button(action: {
                        selectedGroup = group
                        showAssignGroupName = true
                    }) {
                        Image(systemName: "checkmark.circle")
                    }
                }
            }
            .padding()
            
            Button("Close") {
                self.isPresented = false
            }
            .padding()
        }
        .alert("Give This Group Chat a Name", isPresented: $showAssignGroupName) {
            TextField("Group Name", text: $groupName)
            Button("Cancel") {
                showAssignGroupName.toggle()
            }
            Button("OK") {
                if let selectedGroup = selectedGroup {
                    selectedGroup.acceptInvitation()
                    selectedGroup.setName(groupName)
                    isPresented = false
                }
            }.disabled(groupName.count == 0)
        }
    }
}

struct GroupRowView: View {
    let group: Group
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(group.name)
                    .font(.headline)
                if let lastMessage = group.messages.last {
                    Text(lastMessage.text)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if let lastMessage = group.messages.last {
                Text(lastMessage.createdAt, style: .relative)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
