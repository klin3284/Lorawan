//
//  Contacts.swift
//  Wancer
//
//  Created by Ankit Amonkar on 3/20/24.
//

import SwiftUI
import SwiftData
import ContactsUI
import Foundation
import Contacts

struct Tooltip: View {
    let text: String

    var body: some View {
        Text(text)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .background(Color.black)
            .foregroundColor(Color.white)
            .cornerRadius(8)
            .shadow(radius: 4)
    }
}

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
            Alert(title: Text(String(user.id)),
                  dismissButton: .default(Text("OK")))
        }
    }
}


struct ContactsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User] = []
    @State private var isShowingTooltip = false
    
    var body: some View {
        VStack {
            Button("Fetch Contacts") {
                fetchAllContactsAndInsertIntoDatabase()
                self.isShowingTooltip.toggle()
            }
            .onTapGesture {
                self.isShowingTooltip = false
            }
            .overlay(
                Tooltip(text: "Fetches all contacts on phone")
                    .opacity(isShowingTooltip ? 1.0 : 0.0)
            )
            List(users) { user in
                ContactButton(user: user)
            }
        }
    }

    
    func fetchAllContacts(completion: @escaping ([CNContact]?, Error?) -> Void) {
        let store = CNContactStore()
        
        // Request access to the user's contacts
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                completion(nil, error ?? NSError(domain: "AccessDenied", code: 0, userInfo: nil))
                return
            }
            
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor
            ]
            
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            var contacts = [CNContact]()
            
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    contacts.append(contact)
                }
                completion(contacts, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    func insertContactsIntoDatabase(_ contacts: [CNContact]) {
        // Insert fetched contacts into SQLite database
        for contact in contacts {
            if let firstPhoneNumber = contact.phoneNumbers.first {
                let regex = try! NSRegularExpression(pattern: "[-]", options: .caseInsensitive)
                let fullPhoneNumber = regex.stringByReplacingMatches(in: firstPhoneNumber.value.stringValue, options: [], range: NSRange(location: 0, length: firstPhoneNumber.value.stringValue.count), withTemplate: "")
                 
                // Extract the last 10 digits
                let phoneNumber = String(fullPhoneNumber.suffix(10))
                let newUser = User(id: Int(phoneNumber) ?? 0, firstName: contact.givenName, lastName: contact.familyName, groups: [])
                
                if(newUser.id != 0) {
                    modelContext.insert(newUser)
                }
            }
        }
    }

    func fetchAllContactsAndInsertIntoDatabase() {
        fetchAllContacts { fetchedContacts, error in
            if let fetchedContacts = fetchedContacts {
                print("Obtained contacts")
                // Perform database insertion here
                insertContactsIntoDatabase(fetchedContacts)
            } else if let error = error {
                print("Error fetching contacts: \(error)")
            }
        }
    }
}
