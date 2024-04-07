//
//  ContactsManager.swift
//  Wancer
//
//  Created by Kenny Lin on 4/6/24.
//

import SwiftUI
import ContactsUI
import Foundation
import Contacts

class ContactsManager: ObservableObject {
    static let shared = ContactsManager()
    private var databaseManager = DatabaseManager.shared
    
    func fetchAllContacts(completion: @escaping ([CNContact]?, Error?) -> Void) {
        let store = CNContactStore()
        
        // Request access to the user's contacts
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    completion(nil, error ?? NSError(domain: "AccessDenied", code: 0, userInfo: nil))
                }
                return
            }
            
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor
            ]
            
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            
            DispatchQueue.global().async {
                var contacts = [CNContact]()
                
                do {
                    try store.enumerateContacts(with: request) { contact, _ in
                        contacts.append(contact)
                    }
                    DispatchQueue.main.async {
                        completion(contacts, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func insertContactsIntoDatabase(_ contacts: [CNContact]) {
        for contact in contacts {
            if let firstPhoneNumber = contact.phoneNumbers.first {
                let regex = try! NSRegularExpression(pattern: "\\D", options: .caseInsensitive)
                let fullPhoneNumber = regex.stringByReplacingMatches(in: firstPhoneNumber.value.stringValue, options: [], range: NSRange(location: 0, length: firstPhoneNumber.value.stringValue.count), withTemplate: "")
                
                let phoneNumber = String(fullPhoneNumber.suffix(10))
                
                databaseManager.insertUser(contact.givenName, contact.familyName, phoneNumber)
            }
        }
    }
    
    func fetchAllContactsAndInsertIntoDatabase(completion: @escaping () -> Void) {
        fetchAllContacts { fetchedContacts, error in
            if let fetchedContacts = fetchedContacts {
                print("Obtained contacts")
                // Perform database insertion here
                self.insertContactsIntoDatabase(fetchedContacts)
            } else if let error = error {
                print("Error fetching contacts: \(error)")
            }
            
            // Call the completion handler
            self.databaseManager.getAllUsers()
            completion()
        }
    }
}

