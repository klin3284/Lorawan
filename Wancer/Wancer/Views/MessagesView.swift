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
            List(sortedGroups) { group in
                NavigationLink(destination: ChatView(group: group)
                ) {
                    GroupRowView(group: group)
                }
            }
            .navigationBarTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isCreatingGroup = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreatingGroup) {
                CreateGroupView(isPresented: $isCreatingGroup)
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
