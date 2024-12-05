import CoreBluetooth
import Foundation
import KneeLibrary
import MySQLKit
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isBluetoothOn = false
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var currentKneeAngle: String = ""
    
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    private var db: DatabaseManager
    
    var avgFemur: [Double] = []
    var avgTibia: [Double] = []
    var counter = 0
    var femur0: Double = 0
    var tibia0: Double = 0
    var angles: [(Double, Double)] = []
    var timestamp0 = Date().timeIntervalSince1970
    let AVG_CALIBRATION = 100
    
    // Global arrays to store roll, pitch, and yaw values for each IMU
    var imu1RollValues: [Double] = []
    var imu1PitchValues: [Double] = []
    var imu1YawValues: [Double] = []
    
    var imu2RollValues: [Double] = []
    var imu2PitchValues: [Double] = []
    var imu2YawValues: [Double] = []
    
    var imu3RollValues: [Double] = []
    var imu3PitchValues: [Double] = []
    var imu3YawValues: [Double] = []
    
    var timestamps: [Double] = []
    var knee_angles_l: [Double] = []
    
    override init() {
        db = DatabaseManager()
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
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            if let dataString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    print(dataString)
                    self.processData(dataString)
                }
            }
        }
    }
    
    func processData(_ dataString: String) {
        let values = dataString.split(separator: ",").compactMap { Double($0) }
        
        guard values.count % 3 == 0 else {
            print("Invalid data format")
            return
        }
        
        var femur: Double = 0
        var tibia: Double = 0
        let currentTimestamp = Date().timeIntervalSince1970
        let uniqueTimestamp = currentTimestamp + Double(counter) * 0.0001
        for i in stride(from: 0, to: values.count, by: 3) {
            let roll = values[i]
            let pitch = values[i + 1]
            let yaw = values[i + 2]
            timestamps.append(uniqueTimestamp)
            switch i {
            case 0:
                imu1RollValues.append(roll)
                imu1PitchValues.append(pitch)
                imu1YawValues.append(yaw)
            case 3:
                imu2RollValues.append(roll)
                imu2PitchValues.append(pitch)
                imu2YawValues.append(yaw)
                femur = pitch
            case 6:
                imu3RollValues.append(roll)
                imu3PitchValues.append(pitch)
                imu3YawValues.append(yaw)
                tibia = pitch
            default:
                break
            }
        }
        
        if counter < AVG_CALIBRATION {
            if counter == 0 {
                print("Calibrating, please stand still")
            }
            avgFemur.append(femur)
            avgTibia.append(tibia)
            counter += 1
        } else if counter == AVG_CALIBRATION {
            tibia0 = avgTibia.reduce(0, +) / Double(avgTibia.count)
            femur0 = avgFemur.reduce(0, +) / Double(avgFemur.count)
            counter += 1
        } else {
            let angle = (femur0 - femur) - (tibia0 - tibia)
            currentKneeAngle = String(format: "%.2f degrees", angle)
            angles.append((Date().timeIntervalSince1970 - timestamp0, angle))
            knee_angles_l.append(angle)
            print("computed angle: \(angle)")
        }
    }
    
    func saveDataToDatabase() {
        guard imu1RollValues.count > 0, imu2RollValues.count > 0, imu3RollValues.count > 0 else {
            print("Not enough data to save to database")
            return
        }
        
        for i in AVG_CALIBRATION..<min(imu1RollValues.count, imu2RollValues.count, imu3RollValues.count, knee_angles_l.count) {
            let queryString = """
            INSERT INTO patient_data (
                patient_id, timestamp, pelvis_roll, pelvis_pitch, pelvis_yaw,
                femur_l_roll, femur_l_pitch, femur_l_yaw,
                femur_r_roll, femur_r_pitch, femur_r_yaw,
                tibia_l_roll, tibia_l_pitch, tibia_l_yaw,
                tibia_r_roll, tibia_r_pitch, tibia_r_yaw, knee_angle_l
            ) VALUES (
                1, FROM_UNIXTIME(\(timestamps[i] + Double((i)))), \(imu1RollValues[i]), \(imu1PitchValues[i]), \(imu1YawValues[i]),
                \(imu2RollValues[i]), \(imu2PitchValues[i]), \(imu2YawValues[i]),
                \(imu3RollValues[i]), \(imu3PitchValues[i]), \(imu3YawValues[i]),
                \(imu3RollValues[i]), \(imu3PitchValues[i]), \(imu3YawValues[i]),
                \(imu2RollValues[i]), \(imu2PitchValues[i]), \(imu2YawValues[i]), \(knee_angles_l[i])
            )
            """
            
            db.executeQuery(queryString).whenComplete { result in
                switch result {
                case .success:
                    print("Data row \(i + 1) saved to database successfully")
                case .failure(let error):
                    print("Failed to save data row \(i + 1) to database: \(error)")
                }
            }
        }
    }
    
    func simulate() {
        guard let filepath = Bundle.main.path(forResource: "data_raw", ofType: "txt") else {
            print("Failed to find data_raw.txt file")
            return
        }
        
        do {
            let fileContent = try String(contentsOfFile: filepath, encoding: .utf8)
            let lines = fileContent.split(separator: "\n")
            var index = 0
            
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                if index >= lines.count {
                    timer.invalidate()
                    return
                }
                let line = lines[index]
                let columns = line.split(separator: "\t").dropFirst() // Ignore the first column (time)
                let dataString = columns.joined(separator: ",")
                DispatchQueue.main.async {
                    self.processData(dataString)
                }
                index += 1
            }
        } catch {
            print("Error reading data_raw.txt file: \(error)")
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
}
class DatabaseManager {
    let configuration: MySQLConfiguration
    let eventLoopGroup: EventLoopGroup
    let pools: EventLoopGroupConnectionPool<MySQLConnectionSource>
    
    init() {
        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        
        configuration = MySQLConfiguration(
            hostname: "senior-design-db.cpkioi4c2tfg.us-east-1.rds.amazonaws.com",
            port: 3306,
            username: "peterismostpro",
            password: "p3tah!theStall1on",
            database: "MOTION_MEND",
            tlsConfiguration: tlsConfig
        )
        eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
                
        pools = EventLoopGroupConnectionPool(
            source: MySQLConnectionSource(configuration: configuration),
            on: eventLoopGroup
        )
    }
    
    func executeQuery(_ queryString: String) -> EventLoopFuture<Void> {
        return pools.withConnection { conn in
            print(conn)
            return conn.query(queryString)
                .map { result in
                    print("Query executed successfully")
                    return ()
                }
                .flatMapError { error in
                    print("Query error: \(error)")
                    return conn.eventLoop.future(error: error)
                }
        }
    }
}





