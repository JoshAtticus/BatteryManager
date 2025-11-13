//
//  MacInfoService.swift
//  BatteryManager
//
//  Created on 11/13/2025.
//

import Foundation
import IOKit
import Combine

class MacInfoService: ObservableObject {
    @Published var macInfo = MacInfo()
    
    init() {
        fetchMacInfo()
    }
    
    func fetchMacInfo() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            var info = MacInfo()
            
            // Fetch computer name
            info.name = Host.current().localizedName ?? "Unknown"
            
            // Fetch model identifier
            info.identifier = self?.getSystemProfilerValue(dataType: "SPHardwareDataType", key: "machine_model") ?? ""
            
            // Fetch model number
            info.model = self?.getSystemProfilerValue(dataType: "SPHardwareDataType", key: "machine_name") ?? ""
            
            // Fetch model description
            info.modelDescription = self?.getModelDescription() ?? ""
            
            // Fetch serial number
            info.serial = self?.getIORegistryValue(service: "IOPlatformExpertDevice", key: "IOPlatformSerialNumber") ?? ""
            
            // Fetch logic board serial
            info.logicBoardSerial = self?.getIORegistryValue(service: "IOPlatformExpertDevice", key: "board-id") ?? ""
            
            // Fetch chip information
            self?.fetchChipInfo(into: &info)
            
            // Fetch thermal state
            info.thermalState = self?.getThermalState() ?? "Normal"
            
            // Fetch OS version
            info.osVersion = self?.getOSVersion() ?? ""
            
            // Fetch time since last reboot
            info.timeSinceLastReboot = self?.getTimeSinceReboot() ?? ""
            
            DispatchQueue.main.async {
                self?.macInfo = info
            }
        }
    }
    
    private func getSystemProfilerValue(dataType: String, key: String) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
        task.arguments = [dataType, "-json"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let hardwareData = json[dataType] as? [[String: Any]],
               let firstItem = hardwareData.first,
               let value = firstItem[key] as? String {
                return value
            }
        } catch {
            print("Error fetching system profiler data: \(error)")
        }
        return nil
    }
    
    private func getModelDescription() -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/sysctl")
        task.arguments = ["-n", "hw.model"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            if let output = String(data: data, encoding: .utf8) {
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Error fetching model description: \(error)")
        }
        return nil
    }
    
    private func getIORegistryValue(service: String, key: String) -> String? {
        let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(service))
        defer { IOObjectRelease(platformExpert) }
        
        guard platformExpert != 0 else { return nil }
        
        if let property = IORegistryEntryCreateCFProperty(platformExpert, key as CFString, kCFAllocatorDefault, 0) {
            let value = property.takeRetainedValue()
            if let stringValue = value as? String {
                return stringValue
            } else if let data = value as? Data {
                return String(data: data, encoding: .utf8)?.trimmingCharacters(in: CharacterSet(["\0"]))
            }
        }
        return nil
    }
    
    private func fetchChipInfo(into info: inout MacInfo) {
        // Get chip brand (Apple Silicon vs Intel)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/sysctl")
        task.arguments = ["-n", "machdep.cpu.brand_string"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            if let output = String(data: data, encoding: .utf8) {
                info.chipDescription = output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Error fetching chip info: \(error)")
        }
        
        // Get platform
        if let platform = getIORegistryValue(service: "IOPlatformExpertDevice", key: "platform-name") {
            info.chipPlatform = platform
        }
    }
    
    private func getThermalState() -> String {
        // Try to get thermal pressure level
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        task.arguments = ["-g", "therm"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            if let output = String(data: data, encoding: .utf8) {
                if output.contains("CPU_Speed_Limit") {
                    // Parse the thermal state from output
                    let lines = output.components(separatedBy: .newlines)
                    for line in lines {
                        if line.contains("CPU_Speed_Limit") {
                            let components = line.components(separatedBy: "=")
                            if components.count >= 2 {
                                let value = components[1].trimmingCharacters(in: .whitespaces)
                                if let speedLimit = Int(value), speedLimit < 100 {
                                    return "Throttled (\(speedLimit)%)"
                                }
                            }
                        }
                    }
                }
                return "Normal"
            }
        } catch {
            print("Error fetching thermal state: \(error)")
        }
        return "Normal"
    }
    
    private func getOSVersion() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        
        // Get marketing name
        if let marketingName = getOSMarketingName(version: version.majorVersion) {
            return "\(marketingName) (\(versionString))"
        }
        
        return "macOS \(versionString)"
    }
    
    private func getOSMarketingName(version: Int) -> String? {
        let names: [Int: String] = [
            26: "macOS Tahoe",
            15: "macOS Sequoia",
            14: "macOS Sonoma",
            13: "macOS Ventura",
            12: "macOS Monterey",
        ]
        return names[version]
    }
    
    private func getTimeSinceReboot() -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/sysctl")
        task.arguments = ["-n", "kern.boottime"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            if let output = String(data: data, encoding: .utf8) {
                // Parse boot time: { sec = 1234567890, usec = 0 }
                if let secRange = output.range(of: "sec = (\\d+)", options: .regularExpression) {
                    let secString = output[secRange].replacingOccurrences(of: "sec = ", with: "")
                    if let bootTime = TimeInterval(secString) {
                        let bootDate = Date(timeIntervalSince1970: bootTime)
                        let now = Date()
                        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: bootDate, to: now)
                        
                        if let days = components.day, let hours = components.hour, let minutes = components.minute {
                            if days > 0 {
                                return "\(days) days and \(hours) hours"
                            } else if hours > 0 {
                                return "\(hours) hours and \(minutes) minutes"
                            } else {
                                return "\(minutes) minutes"
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error fetching reboot time: \(error)")
        }
        return "Unknown"
    }
}
