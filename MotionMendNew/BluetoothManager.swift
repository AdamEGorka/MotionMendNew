import CoreBluetooth
import Foundation
import KneeLibrary

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isBluetoothOn = false
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
//    @Published var receivedData: String = "" // Stores received data as a string for simplicity
    @Published var receivedData: [String] = []
    
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    
    // new
    @Published var currentKneeAngle: String = ""
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.isBluetoothOn = central.state == .poweredOn
        }
        
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not available")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            if !self.discoveredPeripherals.contains(peripheral) {
                self.discoveredPeripherals.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectedPeripheral = peripheral
        }
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Check if this is the characteristic you want to read data from
                if characteristic.properties.contains(.notify) {
                    // Enable notifications for this characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    // This method will be called when new data is received
    // old
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let data = characteristic.value {
//            // Convert received data to a string (modify this based on your data format)
//            if let dataString = String(data: data, encoding: .utf8) {
//                DispatchQueue.main.async {
////                    self.receivedData = dataString
//                    self.receivedData.append(dataString)
//                    print("Received data: \(dataString)")
//                }
//            }
//        }
//    }
    // new to work with actual knee angle calculating
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            // Convert received data to a string (modify this based on your data format)
            if let dataString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
//                    self.receivedData = dataString
                    self.receivedData.append(dataString)
                    print("Received data: \(dataString)")
                    
                    let columns = dataString.split(whereSeparator: {$0 == "\t" || $0 == " "}).filter { !$0.isEmpty }
                    
                    if columns.count >= 4,
                       let femurQuaternion = parseQuaternion(from: String(columns[2])),
                       let tibiaQuaternion = parseQuaternion(from: String(columns[3])) {
                        let kneeAngle = calculateKneeAngle(femur: femurQuaternion, tibia: tibiaQuaternion)
                        let kneeAngleDegrees = kneeAngle * 100.0 / .pi
                        self.currentKneeAngle = String(format: "%.2f degrees", kneeAngleDegrees)
                        print("Current knee angle: \(kneeAngle * 100.0 / .pi) degrees")
                    }
                    
                }
            }
        }
    }
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            DispatchQueue.main.async {
                self.connectedPeripheral = nil
            }
        }
    }
    // intended to replicate the process of natural bluetooth updates
    func simulateBluetoothDataFromFile() {
        guard let filepath = Bundle.main.path(forResource: "data", ofType: "sto") else {
            print("failed to find .sto - fuck")
            return
        }
        
        do {
            let fileContent = try String(contentsOfFile: filepath, encoding: .utf8)
            let lines = fileContent.split(separator: "\n")
            
            var index = 1
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                if index >= lines.count {
                    timer.invalidate()
                    return
                }
                let line = lines[index]
                index += 1
                
                let columns = line.split(whereSeparator: { $0 == "\t" || $0 == " "}).filter { !$0.isEmpty }
                
                if columns.count >= 4,
                   let femurQuaternion = parseQuaternion(from: String(columns[2])),
                    let tibiaQuaternion = parseQuaternion(from: String(columns[3])) {
                    
                    let kneeAngle = calculateKneeAngle(femur: femurQuaternion, tibia: tibiaQuaternion)
                    let kneeAngleDegrees = kneeAngle * 190.0 / .pi
                    self.currentKneeAngle = String(format: "%.2f degrees", kneeAngleDegrees)
                    print("simulated current knee angle: \(self.currentKneeAngle)")
                }
            }
        } catch {
            print("fucked up while reading")
        }
    }
}
