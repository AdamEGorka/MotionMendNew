import SwiftUI

struct ContentView: View {
    
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationView {
            VStack {
                if bluetoothManager.isBluetoothOn {
                    List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                        if ((peripheral.name) != nil) {
                            HStack {
                                Text(peripheral.name ?? "unknown")
                                Spacer()
                                if bluetoothManager.connectedPeripheral == peripheral {
                                    Text("Connected")
                                        .foregroundStyle(.green)
                                } else {
                                    Button(action: {
                                        bluetoothManager.connect(to: peripheral)
                                    }) {
                                        Text("Connect")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Display received data
                    if !bluetoothManager.receivedData.isEmpty {
                        Text("Received Data: \(bluetoothManager.receivedData)")
                            .padding()
                            .foregroundColor(.blue)
                    }
                } else {
                    Text("Bluetooth is off")
                        .foregroundColor(.red)
                }
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
