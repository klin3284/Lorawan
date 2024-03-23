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

struct ContactRow: View {
    let contact: CNContact
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Text("\(contact.givenName) \(contact.familyName)")
                .padding()
                .background(isHovered ? Color.gray : Color.clear)
                .onHover { hovering in
                    self.isHovered = hovering
                }
            // Additional information about the contact can be displayed here
            if isHovered {
                VStack(alignment: .leading) {
                    Text("Phone: \(contact.phoneNumbers.first?.value.stringValue ?? "")")
                    // Add more details as needed
                }
                .padding()
                .background(Color.white)
                .foregroundColor(Color.black)
                .cornerRadius(8)
                .shadow(radius: 4)
                .offset(y: -30) // Adjust tooltip position as needed
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

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
                self.isShowingTooltip.toggle() // Toggle tooltip visibility
            }) {
                Text("\(user.firstName) \(user.lastName)")
            }
            .onTapGesture {
                self.isShowingTooltip = false // Hide tooltip on tap
            }
            .overlay(
                Tooltip(text: "Phone: \(user.id)")
                    .opacity(isShowingTooltip ? 1.0 : 0.0)
            )
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
            //         ZStack {
            //             Button("add contacts") {
            //                 ForEach(fetchAllContactsAndInsertIntoDatabase(), id: \.self) { contact in
            //                     Text(contact.firstName + contact.lastName) {
            //    //             if let meContact = fetchMeContact() {
            //    //                 meContact.givenName
            //    //             }
            //             }
            //             .buttonStyle(DefaultButtonStyle())
            //             .onHover { hovering in
            //                 self.isHovering = hovering
            //             }
            //
            //             if isHovering {
            //                 Tooltip(text: user.firstName + user.lastName + String(user.id))
            //                     .frame(width: 120, height: 40)
            //                     .background(Color.black)
            //                     .foregroundColor(Color.white)
            //                     .cornerRadius(8)
            //                     .offset(x: 0, y: -50) // Adjust tooltip position as needed
            //             }
            //         }
            //         .padding()
//            
//            List {
//                ForEach (users) {user in
//                    Text(user.firstName + user.lastName + String(user.id))
//                }
//            }
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
        var meContact: CNContact?
        // Insert fetched contacts into SQLite database
        for contact in contacts {
            if contact.isKeyAvailable(CNContactPhoneNumbersKey), contact.phoneNumbers.contains(where: { $0.label == CNLabelPhoneNumberiPhone }) {
                meContact = contact
            }
            if let firstPhoneNumber = contact.phoneNumbers.first {
                let regex = try! NSRegularExpression(pattern: "[-]", options: .caseInsensitive)
                let phoneNumber = regex.stringByReplacingMatches(in: firstPhoneNumber.value.stringValue, options: [], range: NSRange(location: 0, length: firstPhoneNumber.value.stringValue.count), withTemplate: "")
                let newUser = User(id: Int(phoneNumber) ?? 0, firstName: contact.givenName, lastName: contact.familyName, groups: [])
                
                if(newUser.id != 0) {
                    modelContext.insert(newUser)
                }
//                if(newUser.id == Int((meContact?.phoneNumbers.first!.value.stringValue)!)) {
//                    newUser.firstName = "ME"
//                    modelContext.insert(newUser)
//                }
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
    
//    func fetchMeContact() -> CNContact? {
//        let store = CNContactStore()
//        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
//        
//        do {
//            // Fetch the "ME" contact
//            let meContact = try store.unifiedMeContactWithKeys(toFetch: keysToFetch)
//            return meContact
//        } catch {
//            print("Error fetching 'Me' contact: \(error)")
//            return nil
//        }
//    }
    
    func fetchMeContact() -> CNContact? {
        let store = CNContactStore()
        
        // Fetch all contacts
        let keysToFetch = [CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        var meContact: CNContact?
        do {
            try store.enumerateContacts(with: fetchRequest) { contact, stop in
                if contact.isKeyAvailable(CNContactPhoneNumbersKey), contact.phoneNumbers.contains(where: { $0.label == CNLabelPhoneNumberiPhone }) {
                    meContact = contact
                    stop.pointee = true
                }
            }
        } catch {
            print("Error fetching contacts: \(error)")
        }
        
        if let firstPhoneNumber = meContact?.phoneNumbers.first {
            let regex = try! NSRegularExpression(pattern: "[-]", options: .caseInsensitive)
            let phoneNumber = regex.stringByReplacingMatches(in: firstPhoneNumber.value.stringValue, options: [], range: NSRange(location: 0, length: firstPhoneNumber.value.stringValue.count), withTemplate: "")
            let newUser = User(id: Int(phoneNumber) ?? 0, firstName: meContact!.givenName, lastName: meContact!.familyName, groups: [])
            
            if(newUser.id != 0) {
                modelContext.insert(newUser)
            }
        }
       
        return meContact
    }
}
