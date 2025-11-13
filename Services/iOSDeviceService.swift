//
//  iOSDeviceService.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import Foundation
import Combine
import AppKit

class iOSDeviceService: ObservableObject {
    
    // Device identifier mapping
    private static let deviceIdentifierMap: [String: String] = [
        // iPhone
        "iPhone1,1": "iPhone",
        "iPhone1,2": "iPhone 3G",
        "iPhone2,1": "iPhone 3GS",
        "iPhone3,1": "iPhone 4",
        "iPhone3,2": "iPhone 4",
        "iPhone3,3": "iPhone 4",
        "iPhone4,1": "iPhone 4s",
        "iPhone5,1": "iPhone 5",
        "iPhone5,2": "iPhone 5",
        "iPhone5,3": "iPhone 5c",
        "iPhone5,4": "iPhone 5c",
        "iPhone6,1": "iPhone 5s",
        "iPhone6,2": "iPhone 5s",
        "iPhone7,1": "iPhone 6 Plus",
        "iPhone7,2": "iPhone 6",
        "iPhone8,1": "iPhone 6s",
        "iPhone8,2": "iPhone 6s Plus",
        "iPhone8,4": "iPhone SE (1st generation)",
        "iPhone9,1": "iPhone 7",
        "iPhone9,2": "iPhone 7 Plus",
        "iPhone9,3": "iPhone 7",
        "iPhone9,4": "iPhone 7 Plus",
        "iPhone10,1": "iPhone 8",
        "iPhone10,2": "iPhone 8 Plus",
        "iPhone10,3": "iPhone X",
        "iPhone10,4": "iPhone 8",
        "iPhone10,5": "iPhone 8 Plus",
        "iPhone10,6": "iPhone X",
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max",
        "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone12,8": "iPhone SE (2nd generation)",
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,6": "iPhone SE (3rd generation)",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,5": "iPhone 16e",
        "iPhone18,1": "iPhone 17 Pro",
        "iPhone18,2": "iPhone 17 Pro Max",
        "iPhone18,3": "iPhone 17",
        "iPhone18,4": "iPhone Air",
        
        // iPad Pro
        "iPad6,3": "iPad Pro (9.7-inch)",
        "iPad6,4": "iPad Pro (9.7-inch)",
        "iPad6,7": "iPad Pro (12.9-inch, 1st generation)",
        "iPad6,8": "iPad Pro (12.9-inch, 1st generation)",
        "iPad7,1": "iPad Pro (12.9-inch, 2nd generation)",
        "iPad7,2": "iPad Pro (12.9-inch, 2nd generation)",
        "iPad7,3": "iPad Pro (10.5-inch)",
        "iPad7,4": "iPad Pro (10.5-inch)",
        "iPad8,1": "iPad Pro (11-inch, 1st generation)",
        "iPad8,2": "iPad Pro (11-inch, 1st generation)",
        "iPad8,3": "iPad Pro (11-inch, 1st generation)",
        "iPad8,4": "iPad Pro (11-inch, 1st generation)",
        "iPad8,5": "iPad Pro (12.9-inch, 3rd generation)",
        "iPad8,6": "iPad Pro (12.9-inch, 3rd generation)",
        "iPad8,7": "iPad Pro (12.9-inch, 3rd generation)",
        "iPad8,8": "iPad Pro (12.9-inch, 3rd generation)",
        "iPad8,9": "iPad Pro (11-inch, 2nd generation)",
        "iPad8,10": "iPad Pro (11-inch, 2nd generation)",
        "iPad8,11": "iPad Pro (12.9-inch, 4th generation)",
        "iPad8,12": "iPad Pro (12.9-inch, 4th generation)",
        "iPad13,4": "iPad Pro (11-inch, 3rd generation)",
        "iPad13,5": "iPad Pro (11-inch, 3rd generation)",
        "iPad13,6": "iPad Pro (11-inch, 3rd generation)",
        "iPad13,7": "iPad Pro (11-inch, 3rd generation)",
        "iPad13,8": "iPad Pro (12.9-inch, 5th generation)",
        "iPad13,9": "iPad Pro (12.9-inch, 5th generation)",
        "iPad13,10": "iPad Pro (12.9-inch, 5th generation)",
        "iPad13,11": "iPad Pro (12.9-inch, 5th generation)",
        "iPad14,3": "iPad Pro (11-inch, 4th generation)",
        "iPad14,4": "iPad Pro (11-inch, 4th generation)",
        "iPad14,5": "iPad Pro (12.9-inch, 6th generation)",
        "iPad14,6": "iPad Pro (12.9-inch, 6th generation)",
        "iPad16,3": "iPad Pro (11-inch, M4)",
        "iPad16,4": "iPad Pro (11-inch, M4)",
        "iPad16,5": "iPad Pro (13-inch, M4)",
        "iPad16,6": "iPad Pro (13-inch, M4)",
        "iPad17,1": "iPad Pro (11-inch, M5)",
        "iPad17,2": "iPad Pro (11-inch, M5)",
        "iPad17,3": "iPad Pro (13-inch, M5)",
        "iPad17,4": "iPad Pro (13-inch, M5)",
        
        // iPad Air
        "iPad4,1": "iPad Air",
        "iPad4,2": "iPad Air",
        "iPad4,3": "iPad Air",
        "iPad5,3": "iPad Air 2",
        "iPad5,4": "iPad Air 2",
        "iPad11,3": "iPad Air (3rd generation)",
        "iPad11,4": "iPad Air (3rd generation)",
        "iPad13,1": "iPad Air (4th generation)",
        "iPad13,2": "iPad Air (4th generation)",
        "iPad13,16": "iPad Air (5th generation)",
        "iPad13,17": "iPad Air (5th generation)",
        "iPad14,8": "iPad Air (11-inch, M2)",
        "iPad14,9": "iPad Air (11-inch, M2)",
        "iPad14,10": "iPad Air (13-inch, M2)",
        "iPad14,11": "iPad Air (13-inch, M2)",
        "iPad15,3": "iPad Air (11-inch, M3)",
        "iPad15,4": "iPad Air (11-inch, M3)",
        "iPad15,5": "iPad Air (13-inch, M3)",
        "iPad15,6": "iPad Air (13-inch, M3)",
        
        // iPad
        "iPad1,1": "iPad",
        "iPad2,1": "iPad 2",
        "iPad2,2": "iPad 2",
        "iPad2,3": "iPad 2",
        "iPad2,4": "iPad 2",
        "iPad3,1": "iPad (3rd generation)",
        "iPad3,2": "iPad (3rd generation)",
        "iPad3,3": "iPad (3rd generation)",
        "iPad3,4": "iPad (4th generation)",
        "iPad3,5": "iPad (4th generation)",
        "iPad3,6": "iPad (4th generation)",
        "iPad6,11": "iPad (5th generation)",
        "iPad6,12": "iPad (5th generation)",
        "iPad7,5": "iPad (6th generation)",
        "iPad7,6": "iPad (6th generation)",
        "iPad7,11": "iPad (7th generation)",
        "iPad7,12": "iPad (7th generation)",
        "iPad11,6": "iPad (8th generation)",
        "iPad11,7": "iPad (8th generation)",
        "iPad12,1": "iPad (9th generation)",
        "iPad12,2": "iPad (9th generation)",
        "iPad13,18": "iPad (10th generation)",
        "iPad13,19": "iPad (10th generation)",
        "iPad15,7": "iPad (A16)",
        "iPad15,8": "iPad (A16)",
        
        // iPad mini
        "iPad2,5": "iPad mini",
        "iPad2,6": "iPad mini",
        "iPad2,7": "iPad mini",
        "iPad4,4": "iPad mini 2",
        "iPad4,5": "iPad mini 2",
        "iPad4,6": "iPad mini 2",
        "iPad4,7": "iPad mini 3",
        "iPad4,8": "iPad mini 3",
        "iPad4,9": "iPad mini 3",
        "iPad5,1": "iPad mini 4",
        "iPad5,2": "iPad mini 4",
        "iPad11,1": "iPad mini (5th generation)",
        "iPad11,2": "iPad mini (5th generation)",
        "iPad14,1": "iPad mini (6th generation)",
        "iPad14,2": "iPad mini (6th generation)",
        "iPad16,1": "iPad mini (A17 Pro)",
        "iPad16,2": "iPad mini (A17 Pro)",
    ]
    @Published var deviceInfo = iOSDeviceInfo()
    @Published var isLibimobiledeviceInstalled = false
    @Published var errorMessage: String?
    
    private var timer: Timer?
    private var consecutiveFailures = 0
    private let maxConsecutiveFailures = 3
    private var isScreenLocked = false
    
    init() {
        checkLibimobiledevice()
        if isLibimobiledeviceInstalled {
            startMonitoring()
        }
        setupScreenLockObservers()
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // Parse device identifier to friendly name
    private func parseDeviceIdentifier(_ identifier: String) -> String {
        // Return the mapped friendly name, or the identifier itself if not found
        return Self.deviceIdentifierMap[identifier] ?? identifier
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
        stopMonitoring()
    }
    
    @objc private func screenDidUnlock() {
        isScreenLocked = false
        if isLibimobiledeviceInstalled {
            startMonitoring()
        }
    }
    
    private func findExecutable(_ name: String) -> String? {
        let possiblePaths = [
            "/opt/homebrew/bin/\(name)",      // Apple Silicon Homebrew
            "/usr/local/bin/\(name)",          // Intel Homebrew
            "/opt/local/bin/\(name)",          // MacPorts
            "/usr/bin/\(name)"                 // System (unlikely but check)
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return nil
    }
    
    private func checkLibimobiledevice() {
        let possiblePaths = [
            "/opt/homebrew/bin/ideviceinfo",      // Apple Silicon Homebrew
            "/usr/local/bin/ideviceinfo",          // Intel Homebrew
            "/opt/local/bin/ideviceinfo"           // MacPorts
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                isLibimobiledeviceInstalled = true
                errorMessage = nil
                return
            }
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["ideviceinfo"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            isLibimobiledeviceInstalled = !output.isEmpty && process.terminationStatus == 0
            
            if !isLibimobiledeviceInstalled {
                errorMessage = "libimobiledevice not found in: \(possiblePaths.joined(separator: ", "))"
            }
        } catch {
            isLibimobiledeviceInstalled = false
            errorMessage = "Failed to check for libimobiledevice: \(error.localizedDescription)"
        }
    }
    
    func startMonitoring() {
        guard !isScreenLocked else { return }
        
        fetchDeviceInfo()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.fetchDeviceInfo()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func refreshDevice() {
        consecutiveFailures = 0
        fetchDeviceInfo()
    }
    
    private func fetchDeviceInfo() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let deviceConnected = self.checkDeviceConnection()
            
            if deviceConnected {
                self.consecutiveFailures = 0
                self.fetchBasicInfo()
                self.fetchBatteryInfo()
            } else {
                self.consecutiveFailures += 1
                DispatchQueue.main.async {
                    var info = iOSDeviceInfo()
                    info.deviceName = "No Device Connected"
                    info.isConnected = false
                    self.deviceInfo = info
                    
                    if self.consecutiveFailures >= self.maxConsecutiveFailures {
                        self.errorMessage = "Unable to detect device. Try reconnecting or restarting usbmuxd."
                    } else {
                        self.errorMessage = nil
                    }
                }
            }
        }
    }
    
    private func checkDeviceConnection() -> Bool {
        guard let ideviceIdPath = findExecutable("idevice_id") else {
            return false
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ideviceIdPath)
        process.arguments = ["-l"]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            
            var data = Data()
            var errorData = Data()
            
            let outputGroup = DispatchGroup()
            
            outputGroup.enter()
            DispatchQueue.global().async {
                data = pipe.fileHandleForReading.readDataToEndOfFile()
                outputGroup.leave()
            }
            
            outputGroup.enter()
            DispatchQueue.global().async {
                errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                outputGroup.leave()
            }
            
            process.waitUntilExit()
            outputGroup.wait()
            
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            if !errorOutput.isEmpty && !errorOutput.contains("Unable to obtain a task name port") {
                print("Device connection check error: \(errorOutput)")
            }
            
            return !output.isEmpty && process.terminationStatus == 0
        } catch {
            print("Device connection check exception: \(error)")
            return false
        }
    }
    
    private func fetchBasicInfo() {
        guard let ideviceinfoPath = findExecutable("ideviceinfo") else {
            DispatchQueue.main.async {
                self.errorMessage = "ideviceinfo not found"
            }
            return
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ideviceinfoPath)
        process.arguments = []
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            
            var data = Data()
            var errorData = Data()
            
            let outputGroup = DispatchGroup()
            
            outputGroup.enter()
            DispatchQueue.global().async {
                data = pipe.fileHandleForReading.readDataToEndOfFile()
                outputGroup.leave()
            }
            
            outputGroup.enter()
            DispatchQueue.global().async {
                errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                outputGroup.leave()
            }
            
            process.waitUntilExit()
            outputGroup.wait()
            
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            if !errorOutput.isEmpty && !errorOutput.contains("Unable to obtain a task name port") {
                print("Device info error: \(errorOutput)")
            }
            
            guard let output = String(data: data, encoding: .utf8), !output.isEmpty else {
                DispatchQueue.main.async {
                    var info = iOSDeviceInfo()
                    info.deviceName = "No Device Connected"
                    info.isConnected = false
                    self.deviceInfo = info
                }
                return
            }
            
            DispatchQueue.main.async {
                self.parseBasicInfo(output)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch device info: \(error.localizedDescription)"
            }
        }
    }
    
    private func parseBasicInfo(_ output: String) {
        let lines = output.components(separatedBy: .newlines)
        var info = deviceInfo
        info.isConnected = true
        
        for line in lines {
            let components = line.components(separatedBy: ": ")
            guard components.count >= 2 else { continue }
            
            let key = components[0].trimmingCharacters(in: .whitespaces)
            let value = components[1].trimmingCharacters(in: .whitespaces)
            
            switch key {
            case "DeviceName":
                info.deviceName = value
            case "ProductType":
                info.deviceModel = value
                info.deviceIdentifier = value
                info.deviceModelName = parseDeviceIdentifier(value)
            case "SerialNumber":
                info.deviceSerial = value
            case "ProductVersion":
                info.osVersion = value
            default:
                break
            }
        }
        
        deviceInfo = info
    }
    
    private func fetchBatteryInfo() {
        guard let ideviceinfoPath = findExecutable("ideviceinfo"),
              let idevicediagnosticsPath = findExecutable("idevicediagnostics") else {
            DispatchQueue.main.async {
                self.errorMessage = "idevice tools not found"
            }
            return
        }
        
        let basicProcess = Process()
        basicProcess.executableURL = URL(fileURLWithPath: ideviceinfoPath)
        basicProcess.arguments = ["-q", "com.apple.mobile.battery"]
        
        let basicPipe = Pipe()
        let basicErrorPipe = Pipe()
        basicProcess.standardOutput = basicPipe
        basicProcess.standardError = basicErrorPipe
        
        let smartBatteryProcess = Process()
        smartBatteryProcess.executableURL = URL(fileURLWithPath: idevicediagnosticsPath)
        smartBatteryProcess.arguments = ["ioregentry", "AppleSmartBattery"]
        
        let smartBatteryPipe = Pipe()
        let smartBatteryErrorPipe = Pipe()
        smartBatteryProcess.standardOutput = smartBatteryPipe
        smartBatteryProcess.standardError = smartBatteryErrorPipe
        
        let pmuChargerProcess = Process()
        pmuChargerProcess.executableURL = URL(fileURLWithPath: idevicediagnosticsPath)
        pmuChargerProcess.arguments = ["ioregentry", "AppleARMPMUCharger"]
        
        let pmuChargerPipe = Pipe()
        let pmuChargerErrorPipe = Pipe()
        pmuChargerProcess.standardOutput = pmuChargerPipe
        pmuChargerProcess.standardError = pmuChargerErrorPipe
        
        do {
            try basicProcess.run()
            try smartBatteryProcess.run()
            try pmuChargerProcess.run()
            
            var basicData = Data()
            var basicErrorData = Data()
            var smartBatteryData = Data()
            var smartBatteryErrorData = Data()
            var pmuChargerData = Data()
            var pmuChargerErrorData = Data()
            
            let basicOutputGroup = DispatchGroup()
            let smartBatteryOutputGroup = DispatchGroup()
            let pmuChargerOutputGroup = DispatchGroup()
            
            basicOutputGroup.enter()
            DispatchQueue.global().async {
                basicData = basicPipe.fileHandleForReading.readDataToEndOfFile()
                basicOutputGroup.leave()
            }
            
            basicOutputGroup.enter()
            DispatchQueue.global().async {
                basicErrorData = basicErrorPipe.fileHandleForReading.readDataToEndOfFile()
                basicOutputGroup.leave()
            }
            
            smartBatteryOutputGroup.enter()
            DispatchQueue.global().async {
                smartBatteryData = smartBatteryPipe.fileHandleForReading.readDataToEndOfFile()
                smartBatteryOutputGroup.leave()
            }
            
            smartBatteryOutputGroup.enter()
            DispatchQueue.global().async {
                smartBatteryErrorData = smartBatteryErrorPipe.fileHandleForReading.readDataToEndOfFile()
                smartBatteryOutputGroup.leave()
            }
            
            pmuChargerOutputGroup.enter()
            DispatchQueue.global().async {
                pmuChargerData = pmuChargerPipe.fileHandleForReading.readDataToEndOfFile()
                pmuChargerOutputGroup.leave()
            }
            
            pmuChargerOutputGroup.enter()
            DispatchQueue.global().async {
                pmuChargerErrorData = pmuChargerErrorPipe.fileHandleForReading.readDataToEndOfFile()
                pmuChargerOutputGroup.leave()
            }
            
            basicProcess.waitUntilExit()
            smartBatteryProcess.waitUntilExit()
            pmuChargerProcess.waitUntilExit()
            
            basicOutputGroup.wait()
            smartBatteryOutputGroup.wait()
            pmuChargerOutputGroup.wait()
            
            let basicErrorOutput = String(data: basicErrorData, encoding: .utf8) ?? ""
            if !basicErrorOutput.isEmpty && !basicErrorOutput.contains("Unable to obtain a task name port") {
                print("Basic battery info error: \(basicErrorOutput)")
            }
            
            let smartBatteryErrorOutput = String(data: smartBatteryErrorData, encoding: .utf8) ?? ""
            if !smartBatteryErrorOutput.isEmpty && !smartBatteryErrorOutput.contains("Unable to obtain a task name port") {
                print("Smart battery info error: \(smartBatteryErrorOutput)")
            }
            
            let pmuChargerErrorOutput = String(data: pmuChargerErrorData, encoding: .utf8) ?? ""
            if !pmuChargerErrorOutput.isEmpty && !pmuChargerErrorOutput.contains("Unable to obtain a task name port") {
                print("PMU charger info error: \(pmuChargerErrorOutput)")
            }
            
            let basicOutput = String(data: basicData, encoding: .utf8) ?? ""
            let smartBatteryOutput = String(data: smartBatteryData, encoding: .utf8) ?? ""
            let pmuChargerOutput = String(data: pmuChargerData, encoding: .utf8) ?? ""
            
            DispatchQueue.main.async {
                self.parseBatteryInfo(basicOutput, smartBatteryInfo: smartBatteryOutput, pmuChargerInfo: pmuChargerOutput)
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch battery info: \(error.localizedDescription)"
            }
        }
    }
    
    private func parseBatteryInfo(_ basicOutput: String, smartBatteryInfo: String, pmuChargerInfo: String) {
        var info = deviceInfo
        
        let lines = basicOutput.components(separatedBy: .newlines)
        
        for line in lines {
            let components = line.components(separatedBy: ": ")
            guard components.count >= 2 else { continue }
            
            let key = components[0].trimmingCharacters(in: .whitespaces)
            let value = components[1].trimmingCharacters(in: .whitespaces)
            
            switch key {
            case "BatteryCurrentCapacity":
                if let percentage = Int(value) {
                    info.currentPercentageValue = percentage
                }
            case "BatteryIsCharging":
                info.isCharging = value.lowercased() == "true"
            case "FullyCharged":
                info.fullyCharged = value.lowercased() == "true"
            default:
                break
            }
        }
        
        var dataSource = ""
        if !smartBatteryInfo.isEmpty, 
           smartBatteryInfo.contains("<?xml") || smartBatteryInfo.contains("IORegistry"),
           let data = smartBatteryInfo.data(using: .utf8) {
            do {
                if let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
                   let ioRegistry = plist["IORegistry"] as? [String: Any] {
                    
                    dataSource = "AppleSmartBattery"
                    
                    if let cycleCount = ioRegistry["CycleCount"] as? Int {
                        info.cycleCount = cycleCount
                    }
                    
                    if let designCapacity = ioRegistry["DesignCapacity"] as? Int {
                        info.designCapacity = designCapacity
                    }
                    
                    if let rawMaxCapacity = ioRegistry["AppleRawMaxCapacity"] as? Int {
                        info.fullChargeCapacity = rawMaxCapacity
                    }
                    
                    if let rawCurrentCapacity = ioRegistry["AppleRawCurrentCapacity"] as? Int {
                        info.currentCapacity = rawCurrentCapacity
                    }
                    
                    if let nominalCapacity = ioRegistry["NominalChargeCapacity"] as? Int {
                        info.nominalChargeCapacity = nominalCapacity
                    }
                    
                    if let voltage = ioRegistry["Voltage"] as? Int {
                        info.voltage = Double(voltage) / 1000.0
                    }
                    
                    if let temperature = ioRegistry["Temperature"] as? Int {
                        info.temperature = Double(temperature)
                    }
                    
                    if let current = ioRegistry["InstantAmperage"] as? Int {
                        info.current = current
                    }
                    
                    if let isCharging = ioRegistry["IsCharging"] as? Bool {
                        info.isCharging = isCharging
                    }
                    
                    if let fullyCharged = ioRegistry["FullyCharged"] as? Bool {
                        info.fullyCharged = fullyCharged
                    }
                }
            } catch {
            }
        }
        
        if dataSource.isEmpty && !pmuChargerInfo.isEmpty,
           pmuChargerInfo.contains("<?xml") || pmuChargerInfo.contains("IORegistry"),
           let data = pmuChargerInfo.data(using: .utf8) {
            do {
                if let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
                   let ioRegistry = plist["IORegistry"] as? [String: Any] {
                    
                    dataSource = "AppleARMPMUCharger"
                    
                    if let cycleCount = ioRegistry["CycleCount"] as? Int {
                        info.cycleCount = cycleCount
                    }
                    
                    if let designCapacity = ioRegistry["DesignCapacity"] as? Int {
                        info.designCapacity = designCapacity
                    }
                    
                    if let rawMaxCapacity = ioRegistry["AppleRawMaxCapacity"] as? Int {
                        info.fullChargeCapacity = rawMaxCapacity
                    }
                    
                    if let rawCurrentCapacity = ioRegistry["AppleRawCurrentCapacity"] as? Int {
                        info.currentCapacity = rawCurrentCapacity
                    }
                    
                    if let nominalCapacity = ioRegistry["NominalChargeCapacity"] as? Int {
                        info.nominalChargeCapacity = nominalCapacity
                    }
                    
                    if let voltage = ioRegistry["Voltage"] as? Int {
                        info.voltage = Double(voltage) / 1000.0
                    }
                    
                    if let temperature = ioRegistry["Temperature"] as? Int {
                        info.temperature = Double(temperature)
                    }
                    
                    if let current = ioRegistry["InstantAmperage"] as? Int {
                        info.current = current
                    }
                    
                    if let isCharging = ioRegistry["IsCharging"] as? Bool {
                        info.isCharging = isCharging
                    }
                    
                    if let fullyCharged = ioRegistry["FullyCharged"] as? Bool {
                        info.fullyCharged = fullyCharged
                    }
                }
            } catch {
            }
        }
        
        if !dataSource.isEmpty {
            print("Battery data retrieved from: \(dataSource)")
        }
        
        deviceInfo = info
        errorMessage = nil
    }
    
    func installLibimobiledevice() {
        if let url = URL(string: "https://libimobiledevice.org/#get-started-macos-homebrew") {
            NSWorkspace.shared.open(url)
        }
    }
}
