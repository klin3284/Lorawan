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
    
    @State private var isShowingMainView = false
    @State private var phoneNumber: String = ""
    @State private var isLoading = true
    @State private var showingFoundAlert = false
    @State private var showingAddContactAlert = false
    @State private var userManager = UserManager.shared
    @State private var firstName = ""
    @State private var lastName = ""
    
    @Query private var users: [User] = []
    
    var body: some View {
        NavigationStack{
            if isLoading {
                loadingView
            } else {
                contentView
            }
        }
        .onAppear {
            fetchAllContactsAndInsertIntoDatabase {
                isLoading = false
            }
        }
        .alert(isPresented: $showingFoundAlert) {
            if let firstName = userManager.retrieveUser()?.firstName,
               let lastName = userManager.retrieveUser()?.lastName,
               let phoneNumber = userManager.retrieveUser()?.id {
                let formattedPhoneNumber = String(phoneNumber)
                return Alert(title: Text("Is this you?"),
                             message: Text("\(formattedPhoneNumber)\n\(firstName) \(lastName)").bold(),
                             primaryButton: .cancel(Text("No")),
                             secondaryButton: .default(Text("Yes"), action: {
                    isShowingMainView.toggle()
                }))
            } else {
                return Alert(title: Text("User Not Found"),
                             message: Text("Unable to retrieve user information."),
                             dismissButton: .default(Text("OK")))
            }
        }
        .alert("Cannot find you in Contacts.", isPresented: $showingAddContactAlert) {
            Text(String(phoneNumber))
                .bold()
            TextField("First Name", text: $firstName)
            TextField("Last Name", text: $lastName)
            Button("Cancel") {
                showingAddContactAlert.toggle()
            }
            Button("OK") {
                if let validPhoneNumber = Int(phoneNumber) {
                    let newUser = User(id: validPhoneNumber, firstName: firstName, lastName: lastName, groups: [])
                    modelContext.insert(newUser)
                    userManager.storeUser(newUser)
                }
            }
        } message: {
            Text("Lets add in your information!\nWARNING: Make sure Phone Number is Correct!")
        }
        .navigationBarTitle("Your Contact Info")
        .navigationDestination(isPresented: $isShowingMainView) {
            MainView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 25) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2.0)
            Text("Loading contacts...")
        }
    }
    
    
    @ViewBuilder
    private var contentView: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.numberPad)
                Text("This number will be used for other users to receive messages from you.")
                    .font(.caption2)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.leading)
            }
            Section {
                Button("Save") {
                    checkUser(phoneNumber: phoneNumber)
                }
            }
        }
        .navigationBarTitle("Your Contact Info")
    }
    
    func checkUser(phoneNumber: String) {
        if let phoneNumberAsInt = Int(phoneNumber) {
            if let userWithPhoneNumber = users.first(where: { $0.id == phoneNumberAsInt }) {
                userManager.storeUser(userWithPhoneNumber)
                showingFoundAlert.toggle()
            } else {
                showingAddContactAlert.toggle()
                print("No user found with this phone number.")
            }
        }
    }
    
    private func fetchAllContacts(completion: @escaping ([CNContact]?, Error?) -> Void) {
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
    
    private func fetchAllContactsAndInsertIntoDatabase(completion: @escaping () -> Void) {
        fetchAllContacts { fetchedContacts, error in
            if let fetchedContacts = fetchedContacts {
                print("Obtained contacts")
                // Perform database insertion here
                insertContactsIntoDatabase(fetchedContacts)
            } else if let error = error {
                print("Error fetching contacts: \(error)")
            }
            
            // Call the completion handler
            completion()
        }
    }
}
