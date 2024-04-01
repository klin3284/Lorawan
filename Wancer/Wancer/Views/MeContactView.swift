//
//  MeContactView.swift
//  Wancer
//
//  Created by Ankit Amonkar on 3/25/24.
//
 
import SwiftUI
import SwiftData
import ContactsUI
import Foundation
import Contacts
 
struct MeContactView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var phoneNumber: String = ""
    @Query private var users: [User] = []
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Phone Number", text: Binding<String>(
                        get: { self.phoneNumber },
                        set: { newValue in  self.phoneNumber = newValue.filter {"0123456789".contains($0) }
                        }
                    ))
                    .keyboardType(.numberPad)
                }
                Section {
                    Button("Save") {
                        checkUser(phoneNumber: phoneNumber, users: users)
                    }
                }
            }
            .navigationBarTitle("Your Contact Info")
        }
        .onAppear(perform: { fetchAllContactsAndInsertIntoDatabase() })
    }
    
    func checkUser(phoneNumber: String, users: [User]) {
        // UserDefaults.standard.set(phoneNumber, forKey: "mePhoneNumber")
        // Convert the phone number string to an integer since your user IDs are integers
        if let phoneNumberAsInt = Int(phoneNumber) {
            if  users.contains(where: { $0.id == phoneNumberAsInt }) {
                UserDefaults.standard.set(phoneNumber, forKey: "mePhoneNumber")
                print("User verified and phone number saved as 'me' user.")
            } else {
                print("No user found with this phone number.")
            }
        }
    }
    
    private func fetchAllContacts(completion: @escaping ([CNContact]?, Error?) -> Void) {
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
 
    private func insertContactsIntoDatabase(_ contacts: [CNContact]) {
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
 
    private func fetchAllContactsAndInsertIntoDatabase() {
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
