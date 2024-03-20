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

struct ContactsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    var body: some View {
     VStack {
         Button("add contacts") {
             fetchAllContactsAndInsertIntoDatabase()
         }
         List {
             ForEach (users) {user in
                 Text(user.firstName)
             }
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
                let phoneNumber = regex.stringByReplacingMatches(in: firstPhoneNumber.value.stringValue, options: [], range: NSRange(location: 0, length: firstPhoneNumber.value.stringValue.count), withTemplate: "")
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
