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
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func write(value: Data, characteristic: CBCharacteristic) {
        if ((connectedPeripheral?.canSendWriteWithoutResponse) != nil) {
            self.connectedPeripheral?.writeValue(value, for: characteristic, type: .withoutResponse)
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
        if let name = peripheral.name, name.lowercased().contains("dsd tech") || name.lowercased().contains("wancer") {
            connectedPeripheral = peripheral
            connectedPeripheral?.delegate = self
        }
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
        print (self.characteristics)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to update value: \(error.localizedDescription)")
            return
        }
        guard characteristic.value != nil else {
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to update notification state: \(error.localizedDescription)")
            return
        }
    }
}
