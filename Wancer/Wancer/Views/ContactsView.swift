//
//  Contacts.swift
//  Wancer
//
//  Created by Ankit Amonkar on 3/20/24.
//

import SwiftUI
import ContactsUI
import Foundation
import Contacts

// Define a separate button component to handle each user
struct ContactButton: View {
    let user: User
    @State private var isShowingTooltip = false // Separate state for each button
    
    var body: some View {
        Button(action: {
            self.isShowingTooltip = true // Toggle tooltip visibility
        }) {
            Text("\(user.firstName) \(user.lastName)")
        }
        .alert(isPresented: $isShowingTooltip) {
            Alert(title: Text("\(user.firstName) \(user.lastName)\n\(user.phoneNumber.toPhoneNumberFormat())"),
                  dismissButton: .default(Text("OK")))
        }
    }
}


struct ContactsView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @State private var currentUser = UserManager.shared.retrieveUser()!
    @State private var contactsManager = ContactsManager.shared
    @State private var isContactsFetched = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            if isLoading {
                VStack(spacing: 25) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2.0)
                    Text("Loading contacts...")
                }
            } else {
                VStack {
                    List(databaseManager.users.sorted { user1, user2 in
                        if user1.lastName == user2.lastName {
                            return user1.firstName < user2.firstName
                        } else {
                            return user1.lastName < user2.lastName
                        }
                    })  { user in
                        ContactButton(user: user)
                    }
                }
                .navigationBarTitle("Contacts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        ZStack {
                            ContactButton(user: currentUser)
                                .hidden()
                            Image(systemName: "person.circle.fill")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isLoading = true
                            contactsManager.fetchAllContactsAndInsertIntoDatabase {
                                isLoading = false
                            }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                }
            }
        }
    }
}
