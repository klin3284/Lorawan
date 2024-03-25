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
                        checkUser(phoneNumber: phoneNumber)
                        if let phoneNum = getMePhoneNumber() {
                            print(phoneNum)
                        }
                    }
                }
            }
            .navigationBarTitle("Your Contact Info")
        }
    }
    
    func getMePhoneNumber() -> String? {
        return UserDefaults.standard.string(forKey: "mePhoneNumber")
    }
    
//    func fetchUser(withId id: Int) -> User? {
//        // Perform the fetch using a model context - this is a placeholder
//        // You need to replace 'modelContext.fetch()' with the actual method call
//        guard let user = modelContext.fetch(FetchDescriptor<User>(predicate: Predicate<User> { $0.id == id })).first else {
//            print("User not found")
//            return nil
//        }
//        return user
//    }
    
    func checkUser(phoneNumber: String) {
        UserDefaults.standard.set(phoneNumber, forKey: "mePhoneNumber")
        // Convert the phone number string to an integer since your user IDs are integers
//        if let phoneNumberAsInt = Int(phoneNumber) {
//            if let user = fetchUser(withId: Int(phoneNumberAsInt)) {
//                UserDefaults.standard.set(phoneNumber, forKey: "mePhoneNumber")
//                print("User verified and phone number saved as 'me' user.")
//            } else {
//                print("No user found with this phone number.")
//            }
//        }
    }
    
    func saveContact() {
        let newContact = CNMutableContact()
        let phone = CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: phoneNumber))
        newContact.phoneNumbers = [phone]
        // Save the contact
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        do {
            try store.execute(saveRequest)
            print("Contact saved!")
        } catch {
            print("Saving contact failed, error: \(error)")
        }
    }
}
