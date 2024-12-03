import SwiftUI
import KneeLibrary

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var repCount: Int = 0
    @State private var hasReachedNinety: Bool = false
    @State private var approachingFullExtension: Bool = false
    @State private var motivationalText: String = "Bend your knee"
    @State private var isSimulationMode: Bool? = nil
//    let palette = (
//        background: CColor(UIColor(hex: "#153243ff") ?? .white),
//        primary: Color(hex: "#2C3E50"),
//        accent: Color(hex: "#3498DB"),
//        secondary: Color(hex: "#2ECC71"),
//        text: Color(hex: "#34495E")
//    )
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
        "Great effort, keep bending!"
    ]
    
    var body: some View {
        NavigationView {
            VStack (spacing: 1) {
                Image("MotionMendLogoCropped")
                    .resizable()
                    .scaledToFit()
//                    .frame(width: 150, height: 150)
                
                if isSimulationMode == nil {
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
                    HStack {
                        Button(action: {
                            isSimulationMode = true
                        }) {
                            Text("Simulation Mode")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                                .padding(.horizontal, 10)
                        }
                        
                        Button(action: {
                            isSimulationMode = false
                        }) {
                            Text("Exercise Mode")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(15)
                                .padding(.horizontal, 10)
                        }
                    }
                    .padding(.top, 20)
                } else {
                    VStack (spacing: 2) {
                        Text("Knee Bends")
                            .font(.title2)
                            .bold()
                            .padding(.top, 15)
    
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Position:")
                                .font(.headline)
                                .bold()
                            Text("Sit with your back straight, thigh resting on a chair, and knee extended")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
    
                            Text("Bend:")
                                .font(.headline)
                                .bold()
                            Text("Slowly bend your knee until discomfort or your foot is flat on the floor")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
    
                            Text("Hold:")
                                .font(.headline)
                                .bold()
                            Text("Pause for a second as you reach bottom of the movement.")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
    
                            Text("Raise:")
                                .font(.headline)
                                .bold()
                            Text("Gently raise your leg back up to the starting position.")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .font(.body)
                        .padding()
                        .background(Color(UIColor(hex: "#153243ff") ?? .white))
                        .foregroundColor(Color.white)
//                        .background(Color(UIColor.systemGray6))
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
                            .rotationEffect(.degrees(-75)) // Initially horizontal (fully extended)
                        
                        Image("foot")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(getKneeAngle() - 90)) // Foot starts horizontal, follows knee angle
                            .animation(.easeInOut(duration: 0.4), value: getKneeAngle())
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Feedback and Progress Section
                    VStack {
                        Text(motivationalText)
                            .font(.title)
                            .bold()
                            .foregroundColor(Color.white)
                            .padding()
                            .background(Color(UIColor(hex: "#153243ff") ?? .white))
//                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(15)
                        ProgressView(value: Double(repCount), total: 5)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color(UIColor(hex: "#153243ff") ?? .white)))
                                .padding()
                        Text("\(repCount) of 5 Reps")
                            .font(.title2)
                            .foregroundColor(Color(UIColor(hex: "#153243ff") ?? .white))
                            .padding(.bottom, 20)
                    }
                    
                    Spacer()
                    
                    // Start Button
                    Button(action: {
                        if isSimulationMode == true {
                            bluetoothManager.simulateBluetoothDataFromFile()
                        } else {
                            
                            // Start exercise logic here
                        }
                    }) {
                        Text(isSimulationMode == true ? "Start Exercise" : "Start Exercise")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
//                            .background(Color.purple)
                            .background(Color(UIColor(hex: "#153243ff") ?? .white))
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color(UIColor(hex: "#f4eddeff") ?? .white))
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
            approachingFullExtension = true
            motivationalText = approachingQuotes.randomElement() ?? "Almost there!"
        } else if kneeAngle >= 90 {
            hasReachedNinety = true
            approachingFullExtension = false
            motivationalText = "Now bend back!"
        } else if kneeAngle < 15 && hasReachedNinety {
            repCount += 1
            hasReachedNinety = false
            motivationalText = motivationalQuotes.randomElement() ?? "Great job!"
        } else if kneeAngle < 85 {
            approachingFullExtension = false
        }
    }
}

#Preview {
    ContentView()
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}













//import SwiftUI
//import KneeLibrary
//
//struct ContentView: View {
//    @StateObject private var bluetoothManager = BluetoothManager()
//    @State private var repCount: Int = 0
//    @State private var hasReachedNinety: Bool = false // Tracks if knee angle has reached 90 degrees
//    @State private var approachingNinety: Bool = false // Tracks if knee angle is approaching 90 degrees
//    @State private var motivationalText: String = "Bend your knee" // Initial instruction text
//    
//    let motivationalQuotes = [
//        "Great job! Keep going!",
//        "You're doing amazing!",
//        "Stay strong! You got this!",
//        "Fantastic effort!",
//        "You're crushing it!"
//    ]
//    
//    let approachingQuotes = [
//        "Almost there, keep pushing!",
//        "You're so close, keep it up!",
//        "Just a little more!",
//        "Great effort, keep extending!"
//    ]
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Title and Instruction Section
//                VStack {
//                    Text("Knee Extensions")
//                        .font(.title2)
//                        .bold()
//                        .padding(.top, 10)
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Start Position:")
//                            .font(.headline)
//                            .bold()
//                        Text("Sit with your back straight, feet flat on the floor, and knees bent at 90 degrees.")
//                            .font(.footnote)
//                            .fixedSize(horizontal: false, vertical: true)
//                        
//                        Text("Lift:")
//                            .font(.headline)
//                            .bold()
//                        Text("Slowly extend your leg out in front of you, straightening the knee until it is nearly parallel to the floor.")
//                            .font(.footnote)
//                            .fixedSize(horizontal: false, vertical: true)
//                        
//                        Text("Hold:")
//                            .font(.headline)
//                            .bold()
//                        Text("Pause for a second at the top of the movement.")
//                            .font(.footnote)
//                            .fixedSize(horizontal: false, vertical: true)
//                        
//                        Text("Lower:")
//                            .font(.headline)
//                            .bold()
//                        Text("Gently lower your leg back down to the starting position.")
//                            .font(.footnote)
//                            .fixedSize(horizontal: false, vertical: true)
//                    }
//                    .font(.body)
//                    .padding()
//                    .background(Color(UIColor.systemGray6))
//                    .cornerRadius(15)
//                    .padding(.horizontal, 20)
//                }
//                
//                Spacer()
//                
//                // Knee and Leg Visualization Section
//                ZStack {
//                    Image("knee")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 150, height: 150)
//                        .offset(x: 0, y: 0)
//                    
//                    Image("foot")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 150, height: 150)
//                        .offset(x: 0, y: 0)
//                        .rotationEffect(.degrees(getKneeAngle()))
//                        .animation(.easeInOut(duration: 0.4), value: getKneeAngle())
//                }
//                .padding()
//                
//                Spacer()
//                
//                // Feedback and Progress Section
//                VStack {
//                    Text(motivationalText)
//                        .font(.title)
//                        .bold()
//                        .foregroundColor(Color.purple)
//                        .padding()
//                        .background(Color(UIColor.systemGray6))
//                        .cornerRadius(15)
//                    
//                    Text("\(repCount) of 5 Reps")
//                        .font(.title2)
//                        .foregroundColor(Color.purple)
//                        .padding(.bottom, 20)
//                }
//                
//                Spacer()
//                
//                // Exercise Progress Button Section
//                Button(action: {
//                    bluetoothManager.simulateBluetoothDataFromFile()
//                }) {
//                    Text("Start Exercise")
//                        .font(.title3)
//                        .bold()
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.purple)
//                        .cornerRadius(15)
//                        .padding(.horizontal, 20)
//                }
//                
//                Spacer()
//            }
//            .padding()
//            .onChange(of: bluetoothManager.currentKneeAngle) { newValue in
//                updateRepCount()
//            }
//        }
//    }
//    
//    private func getKneeAngle() -> Double {
//        guard let kneeAngle = Double(bluetoothManager.currentKneeAngle.replacingOccurrences(of: " degrees", with: "")) else {
//            return 0.0
//        }
//        return kneeAngle
//    }
//    
//    private func updateRepCount() {
//        let kneeAngle = getKneeAngle()
//        
//        if kneeAngle >= 85 && kneeAngle < 90 && !hasReachedNinety {
//            // If knee angle is approaching 90 degrees, provide motivational feedback
//            approachingNinety = true
//            motivationalText = approachingQuotes.randomElement() ?? "Almost there!"
//        } else if kneeAngle >= 90 {
//            // If the knee angle has reached or exceeded 90 degrees
//            hasReachedNinety = true
//            approachingNinety = false
//            motivationalText = "Now bend back!" // Instruction to bend the knee
//        } else if kneeAngle < 15 && hasReachedNinety {
//            // If knee angle goes back down below 10 degrees after reaching 90, count a rep
//            repCount += 1
//            hasReachedNinety = false // Reset for the next rep
//            motivationalText = motivationalQuotes.randomElement() ?? "Great job!" // Random motivational text
//        } else if kneeAngle < 85 {
//            approachingNinety = false
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
//
//
//



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
