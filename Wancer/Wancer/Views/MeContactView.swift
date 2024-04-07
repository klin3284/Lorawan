//
//  MeContactView.swift
//  Wancer
//
//  Created by Ankit Amonkar on 3/25/24.
//

import SwiftUI

struct MeContactView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var contactsManager = ContactsManager.shared
    @State private var isShowingMainView = false
    @State private var phoneNumber: String = ""
    @State private var isLoading = true
    @State private var showingFoundAlert = false
    @State private var showingAddContactAlert = false
    @State private var userManager = UserManager.shared
    @State private var firstName = ""
    @State private var lastName = ""
    
    var body: some View {
        NavigationStack{
            if isLoading {
                loadingView
            } else {
                contentView
            }
        }
        .onAppear {
            if userManager.retrieveUser() != nil {
                isShowingMainView = true
            } else {
                contactsManager.fetchAllContactsAndInsertIntoDatabase {
                    isLoading = false
                }
            }
        }
        .alert(isPresented: $showingFoundAlert) {
            if let firstName = userManager.retrieveUser()?.firstName,
               let lastName = userManager.retrieveUser()?.lastName,
               let phoneNumber = userManager.retrieveUser()?.phoneNumber {
                return Alert(title: Text("Is this you?"),
                             message: Text("\(phoneNumber)\n\(firstName) \(lastName)").bold(),
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
                if let userId = databaseManager.insertUser(firstName, lastName, phoneNumber) {
                    userManager.storeUser(User(id: userId, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber))
                    isShowingMainView.toggle()
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
        databaseManager.getAllUsers()
        if let userWithPhoneNumber = databaseManager.users.first(where: { $0.phoneNumber == phoneNumber }) {
            userManager.storeUser(userWithPhoneNumber)
            showingFoundAlert.toggle()
        } else {
            showingAddContactAlert.toggle()
            print("No user found with this phone number.")
        }
    }
}
