//
//  MotionMendApp.swift
//  MotionMend
//
//  Created by agorka on 11/4/24.
//
import CoreBluetooth
import SwiftUI

@main
struct MotionMendNewApp: App {
    @StateObject private var bluetoothManager = BluetoothManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetoothManager)
        }
    }
}
