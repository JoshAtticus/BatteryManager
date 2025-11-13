//
//  iOSDeviceInfo.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import Foundation

struct iOSDeviceInfo {
    var deviceName: String = "No Device Connected"
    var deviceModel: String = ""
    var deviceIdentifier: String = ""  // Raw identifier like "iPhone11,8"
    var deviceModelName: String = ""   // Friendly name like "iPhone XR"
    var deviceSerial: String = ""
    var osVersion: String = ""
    var isConnected: Bool = false
    
    var cycleCount: Int = 0
    var designCapacity: Int = 0
    var fullChargeCapacity: Int = 0
    var nominalChargeCapacity: Int = 0
    var currentCapacity: Int = 0  // in mAh
    var currentPercentageValue: Int = 0  // Raw percentage from device (0-100)
    var voltage: Double = 0.0
    var temperature: Double = 0.0
    var current: Int = 0
    var isCharging: Bool = false
    var fullyCharged: Bool = false
    
    var healthPercentage: Double {
        guard designCapacity > 0, fullChargeCapacity >= 0 else { return 0 }
        let percentage = (Double(fullChargeCapacity) / Double(designCapacity)) * 100.0
        guard percentage.isFinite else { return 0 }
        return min(max(percentage, 0), 100)
    }
    
    var currentPercentage: Int {
        if currentPercentageValue > 0 {
            return min(currentPercentageValue, 100)
        }
        guard fullChargeCapacity > 0, currentCapacity >= 0 else { return 0 }
        let percentage = (Double(currentCapacity) / Double(fullChargeCapacity)) * 100.0
        guard percentage.isFinite else { return 0 }
        return min(max(Int(percentage), 0), 100)
    }
    
    var healthStatus: String {
        let health = healthPercentage
        if health >= 100 {
            return "Brand New"
        }
        switch health {
        case 0..<50:
            return "Very Poor"
        case 50..<70:
            return "Poor"
        case 70..<80:
            return "Fair"
        case 80..<90:
            return "Good"
        default:
            return "Excellent"
        }
    }
    
    var temperatureCelsius: Double {
        let temp = temperature / 100.0
        guard temp.isFinite else { return 0 }
        return temp
    }
    
    var currentAmps: Double {
        let amps = Double(current) / 1000.0
        guard amps.isFinite else { return 0 }
        return amps
    }
    
    var powerWatts: Double {
        let power = voltage * currentAmps
        guard power.isFinite else { return 0 }
        return power
    }
}
