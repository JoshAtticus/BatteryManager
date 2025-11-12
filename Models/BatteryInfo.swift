//
//  BatteryInfo.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import Foundation

struct BatteryInfo {
    var currentCapacity: Int = 0
    var maxCapacity: Int = 0
    var designCapacity: Int = 0
    var cycleCount: Int = 0
    var isCharging: Bool = false
    var fullyCharged: Bool = false
    var externalConnected: Bool = false
    var timeRemaining: Int = 0

    var voltage: Int = 0
    var amperage: Int = 0
    var instantAmperage: Int = 0
    
    var temperature: Double = 0.0
    var virtualTemperature: Double = 0.0
    
    var nominalChargeCapacity: Int = 0
    var designCycleCount: Int = 0
    var batteryInstalled: Bool = false
    var atCriticalLevel: Bool = false

    var deviceName: String = ""
    var serial: String = ""
    var manufacturerData: String = ""
    
    var chargingVoltage: Int = 0
    var chargingCurrent: Int = 0
    var adapterConnected: Bool = false
    
    var rawCurrentCapacity: Int = 0
    var rawMaxCapacity: Int = 0
    
    var manufactureDate: String = ""
    var manufacturer: String = ""
    var batteryAge: Int = 0  // in days
    var totalOperatingTime: Int = 0  // in hours
    var temperatureSamples: Int = 0  // count of temperature readings
    var minimumTemperature: Double = 0.0  // in tenths of °C
    var maximumTemperature: Double = 0.0  // in tenths of °C
    var averageTemperature: Double = 0.0
    var maximumChargeCurrent: Int = 0  // in mA
    var maximumDischargeCurrent: Int = 0  // in mA
    var minimumPackVoltage: Int = 0  // in mV
    var maximumPackVoltage: Int = 0  // in mV
    
    var shutdownReason: String = ""
    var shutdownVoltage: Int = 0
    var shutdownTemperature: Double = 0.0
    var shutdownTimestamp: String = ""
    
    var adapterVoltage: Int = 0  // in mV
    var adapterPower: Int = 0  // in mW
    var chargingWattage: Double = 0.0  // Negotiated power in watts
    
    var chargePercentage: Double {
        guard maxCapacity > 0 else { return 0 }
        let percentage = Double(currentCapacity) / Double(maxCapacity) * 100
        guard percentage.isFinite else { return 0 }
        return min(max(percentage, 0), 100)
    }
    
    var healthPercentage: Double {
        guard designCapacity > 0 else { return 0 }
        let percentage = Double(rawMaxCapacity) / Double(designCapacity) * 100
        guard percentage.isFinite else { return 0 }
        return min(max(percentage, 0), 100)
    }
    
    var healthStatus: String {
        let health = healthPercentage
        if health >= 100 {
            return "Brand New"
        }
        switch health {
        case 0..<50:
            return "Very Poor · Service Recommended"
        case 50..<70:
            return "Poor · Service Recommended"
        case 70..<80:
            return "Fair"
        case 80..<90:
            return "Good"
        default:
            return "Excellent"
        }
    }
    
    var temperatureCelsius: Double {
        let temp = (temperature - 2731.5) / 10.0
        guard temp.isFinite else { return 0 }
        return temp
    }
    
    var virtualTemperatureCelsius: Double {
        let temp = (virtualTemperature - 2731.5) / 10.0
        guard temp.isFinite else { return 0 }
        return temp
    }
    
    var voltageDisplay: Double {
        let v = Double(voltage) / 1000.0
        guard v.isFinite else { return 0 }
        return v
    }
    
    var currentAmpsDisplay: Double {
        let signed = amperage > 32767 ? amperage - 65536 : amperage
        let amps = Double(signed) / 1000.0
        guard amps.isFinite else { return 0 }
        return amps
    }
    
    var powerWatts: Double {
        let power = voltageDisplay * abs(currentAmpsDisplay)
        guard power.isFinite else { return 0 }
        return power
    }
    
    var powerWattsFormatted: String {
        return String(format: "%.2f W", powerWatts)
    }
    
    var timeRemainingFormatted: String {
        if isCharging {
            return timeRemaining == 65535 ? "Calculating..." : formatTime(timeRemaining)
        } else {
            return timeRemaining == 65535 ? "Calculating..." : formatTime(timeRemaining)
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return String(format: "%d:%02d", hours, mins)
    }
    
    var chargingStatus: String {
        if fullyCharged {
            return "Fully Charged"
        } else if isCharging {
            return "Charging"
        } else if externalConnected {
            return "Not Charging"
        } else {
            return "On Battery"
        }
    }
    
    func shutdownReasonDescription(_ code: Int) -> String {
        switch code {
        case 0:
            return "Power Disconnected"
        case 3:
            return "Hard/Dirty Shutdown"
        case 5:
            return "Clean Shutdown"
        case -3:
            return "Overheating (Multiple Sensors)"
        case -60:
            return "Bad Master Directory Block"
        case -61, -62:
            return "Unresponsive Application"
        case -74:
            return "Battery Temperature Exceeds Limit"
        case -79:
            return "Incorrect Current from Battery"
        case -103:
            return "Battery Cell Under Voltage"
        case -104:
            return "Unknown Battery Fault"
        case -128:
            return "Unknown/Memory Related"
        default:
            return "Unknown (\(code))"
        }
    }
}
