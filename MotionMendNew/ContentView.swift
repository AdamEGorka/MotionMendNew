import SwiftUI
import KneeLibrary
struct ContentView: View {
    
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var autoScrollEnabled = true
        @State private var userIsInteracting = false
    
    var body: some View {
        NavigationView {
            VStack {
                // commenting out for testing
//                if bluetoothManager.isBluetoothOn {
                if true {
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
                    if !bluetoothManager.currentKneeAngle.isEmpty {
                        Text("Current knee angle: \(bluetoothManager.currentKneeAngle)")
                            .font(.headline)
                            .padding()
                    }
                    // button to start sim
                    Button(action: {
                        bluetoothManager.simulateBluetoothDataFromFile()
                    }) {
                        Text("Simulate Bluetooth Data")
                            .padding()
                            .background(Color.blue)
                    }
                    // Display received data
//                    if !bluetoothManager.receivedData.isEmpty {
//                        ScrollViewReader { scrollViewProxy in
//                            List(bluetoothManager.receivedData.indices, id: \.self) { index in
//                                Text(bluetoothManager.receivedData[index])
//                                    .foregroundColor(.pink)
//                                    .lineLimit(1)
//                                    .truncationMode(.tail)
//                                    .font(.caption)
//                                    .frame(maxWidth: .infinity, alignment: .center) // Center align text
//                                    .id(index) // Set unique ID for each item
//                            }
//                            .onChange(of: bluetoothManager.receivedData.count) {
//                                withAnimation {
//                                    scrollViewProxy.scrollTo(bluetoothManager.receivedData.count - 1)
//                                }
//                            }
//                        }
////                        List(bluetoothManager.receivedData, id: \.self) {
////                            data in
////                            Text(data)
////                                .foregroundColor(.pink)
////                                .lineLimit(1)
////                                .font(.caption)        // Smaller font for fitting more text
////                                .contextMenu {          // Allow copy or full view on long press
////                                    Text(data)
////                                        .font(.body)
////                                }
////                                .frame(maxWidth: .infinity, alignment: .center) // Center align text
////                        }
////                        Text("Received Data: \(bluetoothManager.receivedData)")
////                            .padding()
////                            .foregroundColor(.blue)
//                    }
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
