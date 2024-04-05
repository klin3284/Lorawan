//
//  BleutoothManager.swift
//
//  Created by Kenny Lin 03/16/2024
//

import CoreBluetooth


class BluetoothManager: NSObject, ObservableObject {
    @Published var isBluetoothEnabled = false
    @Published var discoveredPeripherals = [CBPeripheral]()
    @Published var connectedPeripheral: CBPeripheral? = nil
    @Published var characteristics = [CBCharacteristic]()
    @Published var messageQueue = Queue<Signal>()
    
    private var centralManager: CBCentralManager!
    private var packetString : String = ""
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
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
            let splitString = value.splitIntoNCharacterStrings(51)
            for part in splitString {
                if let value = part.data(using: .utf8){
                    self.connectedPeripheral?.writeValue(value, for: characteristic, type: .withoutResponse)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){}
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
    
    func toggleBluetooth() {
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
            centralManager = nil
        } else {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    func handleMessage(_ decodedMessage: String) {
        var signal: Signal? = nil
        
        switch String(decodedMessage.prefix(5)) {
        case Constants.MESSAGE_TYPE:
            print("Message")
            signal = MessageSignal(groupId: decodedMessage[5..<21], messageId: decodedMessage[25..<41], senderNumber: decodedMessage[45..<55], text: decodedMessage[55..<255])
            break
            
        case Constants.INVITATION_TYPE:
            print("Invitation")
            signal = InvitationSignal(groupId: decodedMessage[5..<25], memberNumbers: decodedMessage[25..<125].splitIntoNCharacterStrings(10), senderNumber: decodedMessage[125..<135])
            break
            
        case Constants.ACCEPTATION_TYPE:
            print("Acceptation")
            signal = AcceptationSignal(groupId:decodedMessage[5..<25], senderNumber: decodedMessage[25..<35])
            break
            
        case Constants.DELIVERED_TYPE:
            print("Delivered")
            signal = DeliveredSignal(groupId:decodedMessage[5..<25], messageId: decodedMessage[25..<45], senderNumber: decodedMessage[45..<55])
            break
            
        case Constants.NAVIGATION_TYPE:
            print("Navigation")
            signal = NavigationSignal(groupId:decodedMessage[5..<25], messageId: decodedMessage[25..<45], senderNumber: decodedMessage[45..<55], location: decodedMessage[55..<75])
            break
            
        case Constants.SOS_TYPE:
            print("SOS")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let dateToString = dateFormatter.date(from: decodedMessage[45..<65]) {
                signal = SosSignal(name: decodedMessage[5..<35], senderNumber: decodedMessage[35..<45], createdAt: dateToString, location: decodedMessage[65..<85], text: decodedMessage[85..<255])
            }
            break
            
        default:
            return
        }
        
        if let signalHandled = signal {
            print("enqueue signal")
            messageQueue.enqueue(signalHandled)
            NotificationCenter.default.post(name: NSNotification.MessageReceived, object: nil)
        }
        return
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
        
        if(packetString.count >= 255) {
            self.handleMessage(String(packetString.prefix(255)))
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
