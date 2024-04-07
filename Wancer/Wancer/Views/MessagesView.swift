//
//  GroupsListView.swift
//  Wancer
//
//  Created by Kenny Lin on 3/29/24.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @State private var isCreatingGroup = false
    @State private var isAcceptingGroup = false
    
    private var sortedGroups: [Group] {
        databaseManager.groups.sorted { group1, group2 in
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
                        let rowDeleted = databaseManager.deleteGroup(group.id)
                        print(rowDeleted == 1)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .navigationBarTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        ZStack {
                            Button(action: {
                                self.isAcceptingGroup = true
                            }) {
                                Image(systemName: "envelope")
                            }
                            
                            let inviteCount = databaseManager.groups.filter{$0.acceptedAt == nil}.count
                            if inviteCount > 0 {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 14, height: 14)
                                    Text("\(inviteCount)")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 15, y: 10)
                            }
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
