import SwiftUI
import KneeLibrary

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var repCount: Int = 0
    @State private var hasReachedNinety: Bool = false // Tracks if knee angle has reached 90 degrees
    @State private var approachingNinety: Bool = false // Tracks if knee angle is approaching 90 degrees
    @State private var motivationalText: String = "Bend your knee" // Initial instruction text
    
    let motivationalQuotes = [
        "Great job! Keep going!",
        "You're doing amazing!",
        "Stay strong! You got this!",
        "Fantastic effort!",
        "You're crushing it!"
    ]
    
    let approachingQuotes = [
        "Almost there, keep pushing!",
        "You're so close, keep it up!",
        "Just a little more!",
        "Great effort, keep extending!"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Title and Instruction Section
                VStack {
                    Text("Knee Extensions")
                        .font(.title2)
                        .bold()
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Position:")
                            .font(.headline)
                            .bold()
                        Text("Sit with your back straight, feet flat on the floor, and knees bent at 90 degrees.")
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Lift:")
                            .font(.headline)
                            .bold()
                        Text("Slowly extend your leg out in front of you, straightening the knee until it is nearly parallel to the floor.")
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Hold:")
                            .font(.headline)
                            .bold()
                        Text("Pause for a second at the top of the movement.")
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Lower:")
                            .font(.headline)
                            .bold()
                        Text("Gently lower your leg back down to the starting position.")
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(.body)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Knee and Leg Visualization Section
                ZStack {
                    Image("knee")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .offset(x: 0, y: 0)
                    
                    Image("foot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .offset(x: 0, y: 0)
                        .rotationEffect(.degrees(getKneeAngle()))
                        .animation(.easeInOut(duration: 0.4), value: getKneeAngle())
                }
                .padding()
                
                Spacer()
                
                // Feedback and Progress Section
                VStack {
                    Text(motivationalText)
                        .font(.title)
                        .bold()
                        .foregroundColor(Color.purple)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                    
                    Text("\(repCount) of 5 Reps")
                        .font(.title2)
                        .foregroundColor(Color.purple)
                        .padding(.bottom, 20)
                }
                
                Spacer()
                
                // Exercise Progress Button Section
                Button(action: {
                    bluetoothManager.simulateBluetoothDataFromFile()
                }) {
                    Text("Start Exercise")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding()
            .onChange(of: bluetoothManager.currentKneeAngle) { newValue in
                updateRepCount()
            }
        }
    }
    
    private func getKneeAngle() -> Double {
        guard let kneeAngle = Double(bluetoothManager.currentKneeAngle.replacingOccurrences(of: " degrees", with: "")) else {
            return 0.0
        }
        return kneeAngle
    }
    
    private func updateRepCount() {
        let kneeAngle = getKneeAngle()
        
        if kneeAngle >= 85 && kneeAngle < 90 && !hasReachedNinety {
            // If knee angle is approaching 90 degrees, provide motivational feedback
            approachingNinety = true
            motivationalText = approachingQuotes.randomElement() ?? "Almost there!"
        } else if kneeAngle >= 90 {
            // If the knee angle has reached or exceeded 90 degrees
            hasReachedNinety = true
            approachingNinety = false
            motivationalText = "Now bend back!" // Instruction to bend the knee
        } else if kneeAngle < 15 && hasReachedNinety {
            // If knee angle goes back down below 10 degrees after reaching 90, count a rep
            repCount += 1
            hasReachedNinety = false // Reset for the next rep
            motivationalText = motivationalQuotes.randomElement() ?? "Great job!" // Random motivational text
        } else if kneeAngle < 85 {
            approachingNinety = false
        }
    }
}

#Preview {
    ContentView()
}






//
//
//import SwiftUI
//import KneeLibrary
//struct ContentView: View {
//    
//    @StateObject private var bluetoothManager = BluetoothManager()
//    @State private var autoScrollEnabled = true
//        @State private var userIsInteracting = false
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                // commenting out for testing
////                if bluetoothManager.isBluetoothOn {
//                if true {
//                    Spacer()
//                    
//                    ZStack {
//                        Image("knee")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 150, height: 150)
//                            .offset(x: 0, y: 0)
//                        Image("foot")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 150, height: 150)
//                            .offset(x: 0, y: 0)
//                            .rotationEffect(.degrees(getKneeAngle()))
//                            .animation(.easeInOut(duration: 0.4), value: getKneeAngle())
//                    }
//                    .padding()
////                    List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
////                        if ((peripheral.name) != nil) {
////                            HStack {
////                                Text(peripheral.name ?? "unknown")
////                                Spacer()
////                                if bluetoothManager.connectedPeripheral == peripheral {
////                                    Text("Connected")
////                                        .foregroundStyle(.green)
////                                } else {
////                                    Button(action: {
////                                        bluetoothManager.connect(to: peripheral)
////                                    }) {
////                                        Text("Connect")
////                                    }
////                                }
////                            }
////                        }
////                    }
//                    if !bluetoothManager.currentKneeAngle.isEmpty {
//                        Text("Current knee angle: \(bluetoothManager.currentKneeAngle)")
//                            .font(.headline)
//                            .padding()
//                    }
//                    // button to start sim
//                    Button(action: {
//                        bluetoothManager.simulateBluetoothDataFromFile()
//                    }) {
//                        Text("Simulate Bluetooth Data")
//                            .padding()
//                            .background(Color.blue)
//                    }
//                    // Display received data
////                    if !bluetoothManager.receivedData.isEmpty {
////                        ScrollViewReader { scrollViewProxy in
////                            List(bluetoothManager.receivedData.indices, id: \.self) { index in
////                                Text(bluetoothManager.receivedData[index])
////                                    .foregroundColor(.pink)
////                                    .lineLimit(1)
////                                    .truncationMode(.tail)
////                                    .font(.caption)
////                                    .frame(maxWidth: .infinity, alignment: .center) // Center align text
////                                    .id(index) // Set unique ID for each item
////                            }
////                            .onChange(of: bluetoothManager.receivedData.count) {
////                                withAnimation {
////                                    scrollViewProxy.scrollTo(bluetoothManager.receivedData.count - 1)
////                                }
////                            }
////                        }
//////                        List(bluetoothManager.receivedData, id: \.self) {
//////                            data in
//////                            Text(data)
//////                                .foregroundColor(.pink)
//////                                .lineLimit(1)
//////                                .font(.caption)        // Smaller font for fitting more text
//////                                .contextMenu {          // Allow copy or full view on long press
//////                                    Text(data)
//////                                        .font(.body)
//////                                }
//////                                .frame(maxWidth: .infinity, alignment: .center) // Center align text
//////                        }
//////                        Text("Received Data: \(bluetoothManager.receivedData)")
//////                            .padding()
//////                            .foregroundColor(.blue)
////                    }
//                } else {
//                    Text("Bluetooth is off")
//                        .foregroundColor(.red)
//                }
//            }
//            .padding()
//        }
//    }
//    private func getKneeAngle() -> Double {
//        guard let kneeAngle = Double(bluetoothManager.currentKneeAngle.replacingOccurrences(of: " degrees", with: "")) else {
//            return 0.0
//        }
//        return kneeAngle
//    }
//}
//
//#Preview {
//    ContentView()
//}
//
//
//
