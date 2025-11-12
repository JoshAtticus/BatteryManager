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
