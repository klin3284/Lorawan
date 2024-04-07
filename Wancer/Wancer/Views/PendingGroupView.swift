//
//  PendingGroupView.swift
//  Wancer
//
//  Created by Kenny Lin on 4/5/24.
//

import SwiftUI

struct PendingGroupView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @Binding var isPresented: Bool
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
            
            List(databaseManager.groups.filter{ $0.acceptedAt == nil }) { group in
                HStack {
                    VStack {
                        Text(databaseManager.getUsersByGroupId(group.id).map{ $0.firstName }.joined(separator: ", "))
                    }
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
                    databaseManager.updateGroupAccepted(selectedGroup.id, Date())
                    databaseManager.updateGroupName(selectedGroup.id, groupName)
                    databaseManager.getAllGroups()
                    isPresented = false
                }
            }.disabled(groupName.count == 0)
        }
    }
}
