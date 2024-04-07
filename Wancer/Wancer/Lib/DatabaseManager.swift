//
//  DatabaseManager.swift
//  Wancer
//
//  Created by Kenny Lin on 4/5/24.
//

import SwiftUI
import SQLite

class DatabaseManager: ObservableObject {
    @Published var users: [User] = []
    @Published var groups: [Group] = []
    @Published var messages: [Message] = []
    
    static let DIR_TASK_DB = "WancerDB"
    static let STORE_NAME = "wancer.sqlite3"
    
    private let usersTable = Table("users")
    private let usersGroupTable = Table("userGroups")
    private let groupsTable = Table("groups")
    private let emergencysTable = Table("emergency")
    private let messagesTable = Table("messages")
    private let id = Expression<Int64>("id")
    private let firstName = Expression<String>("firstName")
    private let lastName = Expression<String>("lastName")
    private let phoneNumber = Expression<String>("phoneNumber")
    private let userId = Expression<Int64>("userId")
    private let groupId = Expression<Int64>("groupId")
    private let name = Expression<String>("name")
    private let text = Expression<String>("text")
    private let secret = Expression<String>("secret")
    private let acceptedAt = Expression<String?>("acceptedAt")
    private let createdAt = Expression<Date>("createdAt")
    
    static let shared = DatabaseManager()
    
    private var database: Connection? = nil
    
    private init() {
        if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dirPath = docDir.appendingPathComponent(Self.DIR_TASK_DB)
            
            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let dbPath = dirPath.appendingPathComponent(Self.STORE_NAME).path
                database = try Connection(dbPath)
                createTables()
                fetchAll()
                print("SQLiteDataStore init successfully at: \(dbPath) ")
            } catch {
                database = nil
                print("SQLiteDataStore init error: \(error)")
            }
        } else {
            database = nil
        }
    }
    
    private func createTables() {
        guard let db = database else { return }
        
        do {
            try db.run(usersTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(firstName)
                table.column(lastName)
                table.column(phoneNumber, unique: true)
            })
            
            try db.run(groupsTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(name)
                table.column(secret, unique: true)
                table.column(acceptedAt, defaultValue: nil)
            })
            
            try db.run(usersGroupTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(userId)
                table.column(groupId)
                table.foreignKey(userId, references: usersTable, id, delete: .setNull)
                table.foreignKey(groupId, references: groupsTable, id, delete: .setNull)
            })
            
            try db.run(messagesTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(groupId)
                table.column(userId)
                table.column(text)
                table.column(createdAt)
                table.column(secret)
                table.foreignKey(groupId, references: groupsTable, id, delete: .setNull)
            })
            
        } catch {
            print(error)
        }
    }
    
    func insertUser(_ firstName: String, _ lastName: String, _ phoneNumber: String) -> Int64? {
        guard let db = database else { return nil }
        
        let insert = usersTable.insert(self.firstName <- firstName,
                                       self.lastName <- lastName,
                                       self.phoneNumber <- phoneNumber)
        
        do {
            let rowID = try db.run(insert)
            return rowID
        } catch {
            print(error)
            return nil
        }
    }
    
    func insertGroup(_ name: String, _ secret: String, _ acceptedAt: Date) -> Int64? {
        guard let db = database else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: acceptedAt)
        
        let insert = groupsTable.insert(self.name <- name,
                                        self.secret <- secret,
                                        self.acceptedAt <- dateString)
        
        do {
            let rowID = try db.run(insert)
            return rowID
        } catch {
            print("Error inserting group: \(error)")
            return nil
        }
    }
    
    func insertGroupNotAccepted(_ secret: String) -> Int64? {
        guard let db = database else { return nil }
        
        let insert = groupsTable.insert(self.name <- "",
                                        self.secret <- secret)
        
        do {
            let rowID = try db.run(insert)
            return rowID
        } catch {
            print("Error inserting group: \(error)")
            return nil
        }
    }
    
    func getMessageCountByUser(_ userId: Int64, _ groupId: Int64) -> Int {
        guard let db = database else { return 0 }
        
        do {
            return try db.scalar(messagesTable.filter(self.groupId == groupId && self.userId == userId).count)
        } catch {
            print("Error finding messages")
            return 0
        }
    }
    
    func insertMessage(_ userId: Int64, _ groupId: Int64, _ text: String, _ createdAt: Date, _ secret: String) -> Int64? {
        guard let db = database else { return nil }
        
        do {
           // let secretRow = String(secret + Int64(try db.scalar(messagesTable.filter(self.groupId == groupId && self.userId == userId).count)))
            let insert = messagesTable.insert(self.userId <- userId,
                                              self.groupId <- groupId,
                                              self.text <- text,
                                              self.createdAt <- createdAt,
                                              self.secret <- secret)
            
            let rowID = try db.run(insert)
            return rowID
        } catch {
            print("Error inserting message: \(error)")
            return nil
        }
    }
    
    func insertUserGroup(_ userId: Int64, _ groupId: Int64) -> Int64? {
        guard let db = database else { return nil }
        
        let insert = usersGroupTable.insert(self.userId <- userId,
                                            self.groupId <- groupId)
        
        do {
            let rowID = try db.run(insert)
            return rowID
        } catch {
            print("Error inserting group: \(error)")
            return nil
        }
    }
    
    func updateGroupAccepted(_ id: Int64, _ acceptedAt: Date) {
        guard let db = database else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: acceptedAt)
        
        do {
            let groupToUpdate = groupsTable.filter(self.id == id)
            try db.run(groupToUpdate.update(self.acceptedAt <- dateString))
        } catch {
            print("Error updating group with id \(groupId): \(error)")
        }
    }
    
    func updateGroupName(_ id: Int64, _ name: String) {
        guard let db = database else { return }
        
        do {
            let groupToUpdate = groupsTable.filter(self.id == id)
            try db.run(groupToUpdate.update(self.name <- name))
        } catch {
            print("Error updating group with id \(groupId): \(error)")
        }
    }
    
    func fetchAll() {
        getAllUsers()
        getAllGroups()
    }
    
    func getAllUsers() {
        guard let db = database else { return }
        
        do {
            var fetchedUsers: [User] = []
            
            for user in try db.prepare(self.usersTable) {
                fetchedUsers.append(User(id: user[id],
                                         firstName: user[firstName],
                                         lastName: user[lastName],
                                         phoneNumber: user[phoneNumber]))
            }
            
            users = fetchedUsers
        } catch {
            print("Error fetching users: \(error)")
        }
    }
    
    func getAllGroups() {
        guard let db = database else { return }
        
        do {
            var fetchedGroups: [Group] = []
            
            for group in try db.prepare(self.groupsTable) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let acceptedAt = group[acceptedAt]
                
                var date: Date? = nil
                if let acceptedAt {
                    date = dateFormatter.date(from: acceptedAt)
                }
                
                let groupId = group[id]
                
                // Fetch messages associated with the current group
                let messagesForGroup = getMessagesByGroudId(groupId)
                
                var newGroup = Group(id: groupId,
                                     name: group[name],
                                     acceptedAt: date,
                                     secret: group[secret],
                                     messages: messagesForGroup) // Assign fetched messages
                
                fetchedGroups.append(newGroup)
            }
            
            groups = fetchedGroups
        } catch {
            print("Error fetching groups: \(error)")
        }
    }
    
    
    func getUsersByGroupId(_ groupId: Int64) -> [User] {
        guard let db = database else { return [] }
        
        var groupUsers: [User] = []
        
        do {
            let query = usersGroupTable
                .join(usersTable, on: usersGroupTable[userId] == usersTable[id])
                .filter(self.groupId == groupId)
            
            for row in try db.prepare(query) {
                let user = User(id: row[usersTable[id]],
                                firstName: row[usersTable[firstName]],
                                lastName: row[usersTable[lastName]],
                                phoneNumber: row[usersTable[phoneNumber]])
                groupUsers.append(user)
            }
        } catch {
            print("Error fetching users from group: \(error)")
        }
        
        return groupUsers
    }
    
    func getUserByPhoneNumber(_ phoneNumber: String) -> User? {
        guard let db = database else { return nil }
        
        var fetchedUser: User? = nil
        do {
            let query = usersTable.filter(self.phoneNumber == phoneNumber)
            for user in try db.prepare(query) {
                let newUser = User(id: user[id],
                                   firstName: user[firstName],
                                   lastName: user[lastName],
                                   phoneNumber: phoneNumber)
                fetchedUser = newUser
                break
            }
            
            return fetchedUser
        } catch {
            print("Error fetching messages for group \(groupId): \(error)")
        }
        return fetchedUser
    }
    
    func getMessagesByGroudId(_ groupId: Int64) -> [Message] {
        guard let db = database else { return [] }
        
        do {
            var fetchedMessages: [Message] = []
            
            let query = messagesTable.filter(self.groupId == groupId)
            for message in try db.prepare(query) {
                let newMessage = Message(id: message[id],
                                         userId: message[userId],
                                         groupId: groupId,
                                         text: message[text],
                                         createdAt: message[createdAt],
                                         secret: message[secret])
                fetchedMessages.append(newMessage)
            }
            
            return fetchedMessages
        } catch {
            print("Error fetching messages for group \(groupId): \(error)")
            return []
        }
    }
    
    func getMessageById(_ messageId: Int64) -> Message? {
        guard let db = database else { return nil }
        
        var fetchedMessage: Message? = nil
        do {
            let query = messagesTable.filter(self.id == messageId)
            for message in try db.prepare(query) {
                let newMessage = Message(id: messageId,
                                         userId: message[userId],
                                         groupId: message[groupId],
                                         text: message[text],
                                         createdAt: message[createdAt],
                                         secret: message[secret])
                fetchedMessage = newMessage
                break
            }
        } catch {
            print(error)
        }
        
        return fetchedMessage
    }
    
    func deleteGroup(_ groupId: Int64) -> Int {
        guard let db = database else { return 0 }
        
        let groupToDelete = groupsTable.filter(self.id == groupId)
        
        do {
            return try db.run(groupToDelete.delete())
        } catch {
            print("delete failed: \(error)")
            return 0
        }
    }
}
