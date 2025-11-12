//
//  BatteryService.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import Foundation
import Combine
import AppKit

class BatteryService: ObservableObject {
    @Published var batteryInfo = BatteryInfo()
    private var timer: Timer?
    private let queue = DispatchQueue(label: "batterymanager.joshattic.us.service", qos: .utility)
    private var isScreenLocked = false
    
    init() {
        fetchBatteryInfo()
        startAutoRefresh()
        setupScreenLockObservers()
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupScreenLockObservers() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenDidLock),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenDidUnlock),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )
    }
    
    @objc private func screenDidLock() {
        isScreenLocked = true
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func screenDidUnlock() {
        isScreenLocked = false
        fetchBatteryInfo()
        startAutoRefresh()
    }
    
    func startAutoRefresh() {
        guard !isScreenLocked else { return }
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.fetchBatteryInfo()
        }
    }
    
    func fetchBatteryInfo() {
        queue.async { [weak self] in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/sbin/ioreg")
            task.arguments = ["-rw0", "-c", "AppleSmartBattery"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            
            do {
                try task.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    self?.parseBatteryOutput(output)
                }
            } catch {
                print("Error fetching battery info: \(error)")
            }
        }
    }
    
    private func parseBatteryOutput(_ output: String) {
        var info = BatteryInfo()
        
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if let range = trimmed.range(of: "\"([^\"]+)\"\\s*=\\s*(.+)", options: .regularExpression) {
                let match = trimmed[range]
                let components = match.components(separatedBy: "\" = ")
                
                guard components.count >= 2 else { continue }
                
                let key = components[0].replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
                var value = components[1].trimmingCharacters(in: .whitespaces)
                
                if let lastChar = value.last, !lastChar.isNumber && !lastChar.isLetter && lastChar != ">" {
                    value = String(value.dropLast())
                }
                
                switch key {
                case "CurrentCapacity":
                    info.currentCapacity = Int(value) ?? 0
                case "MaxCapacity":
                    info.maxCapacity = Int(value) ?? 0
                case "DesignCapacity":
                    info.designCapacity = Int(value) ?? 0
                case "CycleCount":
                    info.cycleCount = Int(value) ?? 0
                case "IsCharging":
                    info.isCharging = value == "Yes"
                case "FullyCharged":
                    info.fullyCharged = value == "Yes"
                case "ExternalConnected":
                    info.externalConnected = value == "Yes"
                case "TimeRemaining":
                    info.timeRemaining = Int(value) ?? 0
                case "Voltage":
                    info.voltage = Int(value) ?? 0
                case "Amperage":
                    info.amperage = Int(value) ?? 0
                case "InstantAmperage":
                    info.instantAmperage = Int(value) ?? 0
                case "Temperature":
                    info.temperature = Double(value) ?? 0.0
                case "VirtualTemperature":
                    info.virtualTemperature = Double(value) ?? 0.0
                case "NominalChargeCapacity":
                    info.nominalChargeCapacity = Int(value) ?? 0
                case "DesignCycleCount9C":
                    info.designCycleCount = Int(value) ?? 0
                case "BatteryInstalled":
                    info.batteryInstalled = value == "Yes"
                case "AtCriticalLevel":
                    info.atCriticalLevel = value == "Yes"
                case "DeviceName":
                    info.deviceName = value.replacingOccurrences(of: "\"", with: "")
                case "Serial":
                    info.serial = value.replacingOccurrences(of: "\"", with: "")
                case "AppleRawCurrentCapacity":
                    info.rawCurrentCapacity = Int(value) ?? 0
                case "AppleRawMaxCapacity":
                    info.rawMaxCapacity = Int(value) ?? 0
                case "ManufactureDate":
                    info.manufactureDate = value.replacingOccurrences(of: "\"", with: "")
                    self.parseManufactureDate(value, into: &info)
                default:
                    break
                }
            }
            
            self.parseLifetimeData(output, into: &info)
        }
        
        DispatchQueue.main.async {
            self.batteryInfo = info
        }
    }
    
    private func parseManufactureDate(_ value: String, into info: inout BatteryInfo) {
    }
    
    private func parseLifetimeData(_ output: String, into info: inout BatteryInfo) {
        if let lifetimeStart = output.range(of: "\"LifetimeData\"\\s*=\\s*\\{", options: .regularExpression) {
            var braceCount = 1
            var lifetimeContent = ""
            let startIndex = lifetimeStart.upperBound
            
            for i in output[startIndex...].indices {
                let char = output[i]
                if char == "{" {
                    braceCount += 1
                } else if char == "}" {
                    braceCount -= 1
                    if braceCount == 0 {
                        break
                    }
                }
                lifetimeContent.append(char)
            }
            
            if let totalOpTime = extractValue(from: lifetimeContent, key: "TotalOperatingTime") {
                info.totalOperatingTime = Int(totalOpTime) ?? 0
            }
            
            if let minTempStr = extractLargeValue(from: lifetimeContent, key: "MinimumTemperature") {
                info.minimumTemperature = Double(minTempStr) ?? 0.0
            }
            
            if let maxTemp = extractValue(from: lifetimeContent, key: "MaximumTemperature") {
                info.maximumTemperature = Double(maxTemp) ?? 0.0
            }
            
            if let avgTemp = extractValue(from: lifetimeContent, key: "AverageTemperature") {
                info.averageTemperature = Double(avgTemp) ?? 0.0
            }
            
            if let maxCharge = extractValue(from: lifetimeContent, key: "MaximumChargeCurrent") {
                info.maximumChargeCurrent = Int(maxCharge) ?? 0
            }
            
            if let maxDischarge = extractLargeValue(from: lifetimeContent, key: "MaximumDischargeCurrent") {
                if let dischargeValue = UInt64(maxDischarge) {
                    let signedValue = Int64(bitPattern: dischargeValue)
                    info.maximumDischargeCurrent = Int(signedValue)
                }
            }
            
            if let minVoltage = extractValue(from: lifetimeContent, key: "MinimumPackVoltage") {
                info.minimumPackVoltage = Int(minVoltage) ?? 0
            }
            
            if let maxVoltage = extractValue(from: lifetimeContent, key: "MaximumPackVoltage") {
                info.maximumPackVoltage = Int(maxVoltage) ?? 0
            }
            
            if let tempSamples = extractValue(from: lifetimeContent, key: "TemperatureSamples") {
                info.temperatureSamples = Int(tempSamples) ?? 0
            }
        }
        
        if let batteryDataRange = output.range(of: "\"BatteryData\"\\s*=\\s*\\{[^}]+\\}", options: .regularExpression) {
            let batteryDataSection = String(output[batteryDataRange])
            
            if let mfgData = extractStringValue(from: batteryDataSection, key: "MfgData") {
                parseManufacturerFromMfgData(mfgData, into: &info)
            }
        }
        
        if let mfgData = extractStringValue(from: output, key: "ManufacturerData") {
            parseManufacturerFromMfgData(mfgData, into: &info)
        }
        
        if let shutdownRange = output.range(of: "\"BatteryShutdownReason\"\\s*=\\s*\\{[^}]+\\}", options: .regularExpression) {
            let shutdownSection = String(output[shutdownRange])
            
            if let errorCode = extractValue(from: shutdownSection, key: "ShutDownDataError") {
                let code = Int(errorCode) ?? 0
                info.shutdownReason = info.shutdownReasonDescription(code)
            }
            if let voltage = extractValue(from: shutdownSection, key: "ShutDownVoltage") {
                info.shutdownVoltage = Int(voltage) ?? 0
            }
            if let temp = extractValue(from: shutdownSection, key: "ShutDownTemperature") {
                let tempValue = Int(temp) ?? 0
                info.shutdownTemperature = (Double(tempValue) - 2731.5) / 10.0
            }
        }
        
        if let powerOutRange = output.range(of: "\"PowerOutDetails\"\\s*=\\s*\\([^)]+\\)", options: .regularExpression) {
            let powerOutSection = String(output[powerOutRange])
            
            if let adapterV = extractValue(from: powerOutSection, key: "AdapterVoltage") {
                info.adapterVoltage = Int(adapterV) ?? 0
            }
            if let pdPower = extractValue(from: powerOutSection, key: "PDPowermW") {
                let powerMw = Int(pdPower) ?? 0
                info.chargingWattage = Double(powerMw) / 1000.0
            }
        }
    }
    
    private func parseManufacturerFromMfgData(_ hexString: String, into info: inout BatteryInfo) {
        let cleaned = hexString.replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: ">", with: "")
        
        if cleaned.contains("41544c") || cleaned.contains("415450") { // "ATL" in hex
            info.manufacturer = "Simplo Technology Inc"
        } else if cleaned.contains("534d50") { // "SMP" in hex
            info.manufacturer = "SMP"
        } else if cleaned.contains("4c47") { // "LG" in hex
            info.manufacturer = "LG Chem"
        } else if cleaned.contains("534e59") { // "SNY" in hex
            info.manufacturer = "Sony"
        } else {
            info.manufacturer = "Unknown"
        }
    }
    
    private func extractValue(from text: String, key: String) -> String? {
        let pattern = "\"\(key)\"\\s*=\\s*(\\d+)"
        if let range = text.range(of: pattern, options: .regularExpression) {
            let match = String(text[range])
            let components = match.components(separatedBy: "=")
            if components.count >= 2 {
                return components[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }
    
    private func extractLargeValue(from text: String, key: String) -> String? {
        let pattern = "\"\(key)\"\\s*=\\s*(\\d+)"
        if let range = text.range(of: pattern, options: .regularExpression) {
            let match = String(text[range])
            let components = match.components(separatedBy: "=")
            if components.count >= 2 {
                return components[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }
    
    private func extractStringValue(from text: String, key: String) -> String? {
        let pattern = "\"\(key)\"\\s*=\\s*<([^>]+)>"
        if let range = text.range(of: pattern, options: .regularExpression) {
            let match = String(text[range])
            if let dataStart = match.range(of: "<"),
               let dataEnd = match.range(of: ">") {
                let startIndex = match.index(after: dataStart.upperBound)
                let endIndex = dataEnd.lowerBound
                return String(match[startIndex..<endIndex])
            }
        }
        return nil
    }
}
