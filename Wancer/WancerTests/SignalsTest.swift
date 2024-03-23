//
//  SignalFactory.swift
//  Wancer
//
//  Created by Kenny Lin on 3/23/24.
//

import XCTest

class SignalsTest: XCTestCase {

    func randomDigitsString(ofLength length: Int) -> String {
        var result = ""
        for _ in 0..<length {
            let digit = arc4random_uniform(10) // Generate a random digit (0-9)
            result += "\(digit)" // Append the digit to the result string
        }
        return result
    }
    
    func testGenericSignal() {
        let sut = Signal()

        let actual = sut.buildString()
        let expected = ""
        
        XCTAssertEqual(actual, expected)
    }
    
    func testInvitationSignal() {
        let groupId = randomDigitsString(ofLength: 20)
        let senderId = randomDigitsString(ofLength: 10)
        let memberCount = Int.random(in: 1..<10)
        var memberNumbers: [String] = []
        for _ in 0..<memberCount { memberNumbers.append(randomDigitsString(ofLength: 10))}
        let sut = InvitationSignal(groupId: groupId, memberNumbers: memberNumbers, senderNumber: senderId)
        
        let actual = sut.buildString()
        let expected = Constants.INVITATION_TYPE + groupId + memberNumbers.joined(separator: "") + String(repeating: " ", count: (10 - memberCount) * 10) + senderId + String(repeating: " ", count: 120)

        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.count, 255)
    }
    
    func testAcceptationSignal() {
        let groupId = randomDigitsString(ofLength: 20)
        let senderId = randomDigitsString(ofLength: 10)
        
        let sut = AcceptationSignal(groupId: groupId, senderNumber: senderId)
        
        let actual = sut.buildString()
        let expected = Constants.ACCEPTATION_TYPE + groupId + senderId + String(repeating: " ", count: 220)
        
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.count, 255)
    }
    
    func testMessageSignal() {
        let groupId = randomDigitsString(ofLength: 20)
        let messageId = randomDigitsString(ofLength: 20)
        let senderId = randomDigitsString(ofLength: 10)
        let messageCount = Int.random(in: 1..<200)
        let text = randomDigitsString(ofLength: messageCount)
        
        let sut = MessageSignal(groupId: groupId, messageId: messageId, senderNumber: senderId, text: text)
        
        let actual = sut.buildString()
        let expected = Constants.MESSAGE_TYPE + groupId + messageId + senderId + text + String(repeating: " ", count: 200 - messageCount)
        
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.count, 255)
    }
    
    func testNavigationSignal() {
        let groupId = randomDigitsString(ofLength: 20)
        let messageId = randomDigitsString(ofLength: 20)
        let senderId = randomDigitsString(ofLength: 10)
        let location = randomDigitsString(ofLength: 20)
        
        let sut = NavigationSignal(groupId: groupId, messageId: messageId, senderNumber: senderId, location: location)
        
        let actual = sut.buildString()
        let expected = Constants.NAVIGATION_TYPE + groupId + messageId + senderId + location + String(repeating: " ", count: 180)
        
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.count, 255)
    }
    
    func testDeliveredSignal() {
        let groupId = randomDigitsString(ofLength: 20)
        let messageId = randomDigitsString(ofLength: 20)
        let senderId = randomDigitsString(ofLength: 10)

        let sut = DeliveredSignal(groupId: groupId, messageId: messageId, senderNumber: senderId)
        
        let actual = sut.buildString()
        let expected = Constants.DELIVERED_TYPE + groupId + messageId + senderId + String(repeating: " ", count: 200)
        
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.count, 255)
    }
    
    func testSosSignal() {
        let nameCount = Int.random(in: 1..<30)
        let name = randomDigitsString(ofLength: nameCount)
        let senderId = randomDigitsString(ofLength: 10)
        let time = Date()
        let location = randomDigitsString(ofLength: 20)
        let messageCount = Int.random(in: 1..<170)
        let text = randomDigitsString(ofLength: messageCount)
        
        let sut = SosSignal(name: name, senderNumber: senderId, createdAt: time, location: location, text: text)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateToString = dateFormatter.string(from: time)
        XCTAssertEqual(dateToString.count, 19)
        
        let actual = sut.buildString()
        let expected = Constants.SOS_TYPE + name + String(repeating: " ", count: 30 - nameCount) + senderId + dateToString + " " + location + text + String(repeating: " ", count: 170 - messageCount)
        
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(actual.count, 255)
    }
    
}
