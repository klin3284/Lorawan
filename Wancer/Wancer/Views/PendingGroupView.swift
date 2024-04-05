//
//  PendingGroupView.swift
//  Wancer
//
//  Created by Kenny Lin on 4/5/24.
//

import SwiftUI
import SwiftData

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
            Text("Invitations")
                .font(.headline)
                .padding()
            
            List(groups.filter{ $0.acceptedAt == nil }) { group in
                HStack {
                    Text("Pending Response to Join Groupchat").bold()
                    Text(group.users?.map{ $0.firstName }.joined(separator: ", ") ?? "Unknown Members")
                    Spacer()
                    Button(action: {
                        selectedGroup = group
                        showAssignGroupName = true
                    }) {
                        Image(systemName: "checkmark")
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
