//
//  CurrentUser.swift
//  Wancer
//
//  Created by Kenny Lin on 4/1/24.
//

import SwiftUI

class UserManager {
    static let shared = UserManager()
    private init() {}

    private var user: User?

    func storeUser(_ user: User) {
        self.user = user
        if let encodedUser = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: "storedUser")
        }
    }

    func retrieveUser() -> User? {
        if let user = self.user {
            return user
        } else if let userData = UserDefaults.standard.data(forKey: "storedUser") {
            do {
                let decodedUser = try JSONDecoder().decode(User.self, from: userData)
                self.user = decodedUser
                return decodedUser
            } catch {
                print("Failed to decode user data: \(error)")
            }
        }
        return nil
    }
}
