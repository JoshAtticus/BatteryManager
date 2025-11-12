//
//  SharedBatteryData.swift
//  BatteryManager
//
//  Created on 11/12/2025.
//

import Foundation

struct SharedBatteryData: Codable {
    var macCurrentCapacity: Int = 0
    var macIsCharging: Bool = false
    var macFullyCharged: Bool = false
    var macHealthPercentage: Double = 0
    var macCycleCount: Int = 0
    var macDesignCycleCount: Int = 0
    var macMaxCapacity: Int = 0
    var macDesignCapacity: Int = 0
    var macTimeRemaining: Int = 0
    var macVoltage: Double = 0
    var macCurrentAmps: Double = 0
    
    var iOSConnected: Bool = false
    var iOSDeviceName: String = "No Device"
    var iOSCurrentPercentage: Int = 0
    var iOSIsCharging: Bool = false
    var iOSFullyCharged: Bool = false
    var iOSHealthPercentage: Double = 0
    var iOSCycleCount: Int = 0
    var iOSFullChargeCapacity: Int = 0
    var iOSDesignCapacity: Int = 0
    var iOSVoltage: Double = 0
    var iOSCurrentAmps: Double = 0
    
    var lastUpdated: Date = Date()
}

class SharedBatteryDataManager {
    static let shared = SharedBatteryDataManager()
    
    private let userDefaults = UserDefaults(suiteName: "group.batterymanager.joshattic.us")
    private let dataKey = "sharedBatteryData"
    
    func saveBatteryData(mac: BatteryInfo, iOS: iOSDeviceInfo) {
        let data = SharedBatteryData(
            macCurrentCapacity: mac.currentCapacity,
            macIsCharging: mac.isCharging,
            macFullyCharged: mac.fullyCharged,
            macHealthPercentage: mac.healthPercentage,
            macCycleCount: mac.cycleCount,
            macDesignCycleCount: mac.designCycleCount,
            macMaxCapacity: mac.rawMaxCapacity,
            macDesignCapacity: mac.designCapacity,
            macTimeRemaining: mac.timeRemaining,
            macVoltage: mac.voltageDisplay,
            macCurrentAmps: mac.currentAmpsDisplay,
            iOSConnected: iOS.isConnected,
            iOSDeviceName: iOS.deviceName,
            iOSCurrentPercentage: iOS.currentPercentage,
            iOSIsCharging: iOS.isCharging,
            iOSFullyCharged: iOS.fullyCharged,
            iOSHealthPercentage: iOS.healthPercentage,
            iOSCycleCount: iOS.cycleCount,
            iOSFullChargeCapacity: iOS.fullChargeCapacity,
            iOSDesignCapacity: iOS.designCapacity,
            iOSVoltage: iOS.voltage,
            iOSCurrentAmps: iOS.currentAmps,
            lastUpdated: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults?.set(encoded, forKey: dataKey)
        }
    }
    
    func loadBatteryData() -> SharedBatteryData? {
        guard let data = userDefaults?.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(SharedBatteryData.self, from: data) else {
            return nil
        }
        return decoded
    }
}
