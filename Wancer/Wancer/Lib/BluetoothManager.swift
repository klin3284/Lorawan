//
//  BleutoothManager.swift
//
//  Created by Kenny Lin 03/16/2024
//

import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject {
    @Published var isBluetoothEnabled = false
    @Published var discoveredPeripherals = [CBPeripheral]()
    @Published var connectedPeripheral: CBPeripheral? = nil
    @Published var characteristics = [CBCharacteristic]()
    
    private var databaseManager = DatabaseManager.shared
    private var centralManager: CBCentralManager!
    private var packetString : String = ""
    
    static let shared = BluetoothManager()
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func connect(peripheral: CBPeripheral, completion: @escaping (Bool) -> Void) {
        if let name = peripheral.name, name.lowercased().contains("dsd tech") || name.lowercased().contains("wancer") {
            centralManager.connect(peripheral, options: nil)
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func write(value: String, characteristic: CBCharacteristic) {
        if ((connectedPeripheral?.canSendWriteWithoutResponse) != nil) {
            var checkedValue: String = ""
            if value.count < 255 {
                checkedValue = String(calculateChecksum(value)) + value
            }
            let splitString = checkedValue.splitIntoNCharacterStrings(51)
            for part in splitString {
                if let value = part.data(using: .utf8){
                    self.connectedPeripheral?.writeValue(value, for: characteristic, type: .withoutResponse)
                }
            }
            
        }
    }
    
    func subscribeToNotifications(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    func readValue(characteristic: CBCharacteristic) {
        self.connectedPeripheral?.readValue(for: characteristic)
    }
    
    func discoverServices(peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func calculateChecksum(_ input: String) -> Character {
        var checksum: UInt8 = 0
        for byte in input.utf8 {
            checksum = checksum &+ byte
        }
        let asciiValue = UInt8(checksum) % 128
        return Character(UnicodeScalar(asciiValue))
    }
    
    
    func toggleBluetooth() {
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
            centralManager = nil
        } else {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    func handleMessage(_ decodedMessage: String) {
        let messageChecksum = calculateChecksum(decodedMessage[1..<255])
        let messageFirstChar = decodedMessage.first ?? " "
        
        if messageFirstChar == messageChecksum {
            print("Checksum passed")
            switch(decodedMessage[1..<5]) {
            case SignalType.MESSAGE_TYPE:
                print("Message")
                let groupSecret = decodedMessage[5..<25]
                    .trimmingCharacters(in: .whitespaces)
                let messageSecret = decodedMessage[25..<45]
                    .trimmingCharacters(in: .whitespaces)
                let senderPhoneNumber = decodedMessage[45..<55]
                let text = decodedMessage[55..<255]
                    .trimmingCharacters(in: .whitespaces)
                let signalStrength = decodedMessage[255..<259]
                    .trimmingCharacters(in: .whitespaces)
                
                print(signalStrength)
                
                if let group = databaseManager.groups.first(where: {$0.secret == groupSecret}),
                   let senderUser = databaseManager.getUserByPhoneNumber(senderPhoneNumber) {
                    if (group.messages.first(where: { $0.secret == messageSecret }) != nil) {
                        print("message already exist")
                    } else {
                        databaseManager.insertMessage(senderUser.id, group.id, text, Date(), messageSecret, signalStrength)
                        databaseManager.getAllGroups()
                    }
                }
                else {
                    print("cant find group or sender")
                }
                break
                
            case SignalType.INVITATION_TYPE:
                print("Invitation")
                let groupSecret = decodedMessage[5..<25]
                    .trimmingCharacters(in: .whitespaces)
                let groupMembersPhoneNumbers = decodedMessage[25..<125]
                    .trimmingCharacters(in: .whitespaces)
                    .splitIntoNCharacterStrings(10)
                let senderPhoneNumber = decodedMessage[125..<135]
                
                if let groupId = databaseManager.insertGroupNotAccepted(groupSecret),
                   let senderUser = databaseManager.getUserByPhoneNumber(senderPhoneNumber),
                   let currentUser = UserManager.shared.retrieveUser() {
                    if groupMembersPhoneNumbers.contains(currentUser.phoneNumber) {
                        for phoneNumber in groupMembersPhoneNumbers {
                            if let member = databaseManager.getUserByPhoneNumber(phoneNumber) {
                                databaseManager.insertUserGroup(member.id, groupId)
                            } else {
                                if let newUserId = databaseManager.insertUser("Unknown", "Contact", phoneNumber) {
                                    databaseManager.insertUserGroup(newUserId, groupId)
                                }
                            }
                        }
                    }
                    databaseManager.fetchAll()
                }
                break
                
            case SignalType.SOS_TYPE:
                print("SOS")
                
                let type = decodedMessage[5..<10]
                let name = decodedMessage[10..<40]
                    .trimmingCharacters(in: .whitespaces)
                let senderNumber = decodedMessage[40..<50]
                let createdAt = decodedMessage[50..<70]
                let latitudeString = decodedMessage[70..<78]
                let longitudeString = decodedMessage[78..<86]
                let text = decodedMessage[90..<255]
                    .trimmingCharacters(in: .whitespaces)
                
                if let latitude = Double(latitudeString),
                   let longitude = Double(longitudeString),
                   let emergencyType = EmergencyType.init(rawValue: type) {
                    if !databaseManager.emergencies.contains(where: { emergency in
                        return emergency.name == name &&
                        emergency.senderNumber == senderNumber &&
                        emergency.createdAt == DateFormatter.standard.date(from: createdAt) &&
                        emergency.latitude == latitude &&
                        emergency.longitude == longitude &&
                        emergency.text == text}) {
                        
                        databaseManager.insertEmergency(type: emergencyType, name: name, phoneNumber: senderNumber, latitude: latitude, longitude: longitude, text: text)
                        
                        databaseManager.getAllEmergencies()
                    }
                }
                break
                
            default:
                print("Signal is not supported")
                return
            }
        } else {
            print("Checksum break")
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isBluetoothEnabled = true
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            isBluetoothEnabled = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        
        if let index = self.discoveredPeripherals.firstIndex(of: peripheral) {
            self.discoveredPeripherals.remove(at: index)
        }
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if connectedPeripheral == peripheral {
            connectedPeripheral?.delegate = nil
            connectedPeripheral = nil
            characteristics.removeAll()
            self.centralManager.stopScan()
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            NotificationCenter.default.post(name: NSNotification.LostBleConnection, object: nil)
        }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Failed to discover services: \(error.localizedDescription)")
            return
        }
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        self.characteristics.append(contentsOf: characteristics)
        self.subscribeToNotifications(peripheral: peripheral, characteristic: self.characteristics[0])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to update value: \(error.localizedDescription)")
            return
        }
        guard let value = characteristic.value else {
            return
        }
        
        let decodedMessage = String(decoding: value, as: UTF8.self)
        packetString += decodedMessage
        
        if(packetString.count >= 259) {
            self.handleMessage(String(packetString.prefix(259)))
            packetString = ""
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to update notification state: \(error.localizedDescription)")
            return
        }
    }
}
