//
//  iOSDeviceView.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import SwiftUI

struct iOSDeviceView: View {
    @StateObject private var deviceService = iOSDeviceService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !deviceService.isLibimobiledeviceInstalled {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("libimobiledevice Required")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("To read battery information from connected iOS devices, you need to install libimobiledevice.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Install via Homebrew:")
                                .font(.headline)
                            
                            HStack {
                                Text("brew install libimobiledevice")
                                    .font(.system(.body, design: .monospaced))
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(6)
                                
                                Button(action: {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString("brew install libimobiledevice", forType: .string)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        
                        Button("Open Installation Guide") {
                            deviceService.installLibimobiledevice()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if !deviceService.deviceInfo.isConnected {
                    VStack(spacing: 16) {
                        Image(systemName: "iphone.slash")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        
                        Text("No Device Connected")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Connect your iPhone or iPad via USB and trust this computer.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InstructionRow(number: 1, text: "Connect your iOS device via USB cable")
                            InstructionRow(number: 2, text: "Unlock your device")
                            InstructionRow(number: 3, text: "Tap 'Trust' when prompted on your device")
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Troubleshooting:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Try unplugging and reconnecting the device")
                                Text("• Restart the usbmuxd service: sudo launchctl stop com.apple.usbmuxd")
                                Text("• Check that you've trusted this computer on your device")
                                Text("• Make sure the USB cable supports data transfer")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        
                        Button(action: {
                            deviceService.refreshDevice()
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                                .frame(minWidth: 120)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                        
                        if let error = deviceService.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(systemName: deviceIcon)
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text(deviceService.deviceInfo.deviceName)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if !deviceService.deviceInfo.deviceModel.isEmpty {
                                Text(deviceService.deviceInfo.deviceModel)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top)
                        
                        VStack(spacing: 12) {
                            Image(systemName: batteryIcon)
                                .font(.system(size: 48))
                                .foregroundColor(statusColor)
                            
                            Text("\(deviceService.deviceInfo.currentPercentage)%")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(statusColor)
                            
                            Text(deviceService.deviceInfo.isCharging ? "Charging" : "Discharging")
                                .font(.headline)
                                .foregroundColor(statusColor)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        if deviceService.deviceInfo.deviceModel.lowercased().contains("ipod") {
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("iPod Touch Limitation")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    Spacer()
                                }
                                
                                Text("iPod touch devices do not include battery gas gauges. Battery health, capacity, cycle count, and other detailed battery metrics cannot be determined.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        if !deviceService.deviceInfo.deviceModel.lowercased().contains("ipod") &&
                           deviceService.deviceInfo.designCapacity == 0 &&
                           deviceService.deviceInfo.fullChargeCapacity == 0 &&
                           deviceService.deviceInfo.cycleCount == 0 {
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text("Battery Data Unavailable")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                
                                Text("This device is not reporting proper battery gas gauge values. This may indicate:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• Device needs to be unlocked and trusted")
                                    Text("• A faulty battery management system")
                                    Text("• A poor quality aftermarket battery")
                                    Text("• Battery hardware failure")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Original Apple batteries and quality replacements should report detailed metrics.")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                    .multilineTextAlignment(.leading)
                                    .padding(.top, 4)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(healthColor)
                                Text("Battery Health")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(format: "%.1f%%", deviceService.deviceInfo.healthPercentage))
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(healthColor)
                                    Text(deviceService.deviceInfo.healthStatus)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(deviceService.deviceInfo.fullChargeCapacity) mAh")
                                        .font(.headline)
                                    Text("of \(deviceService.deviceInfo.designCapacity) mAh")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.blue)
                                Text("Cycle Count")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(deviceService.deviceInfo.cycleCount)")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.purple)
                                Text("Technical Details")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                iOSDetailRow(
                                    icon: "bolt.fill",
                                    label: "Voltage",
                                    value: String(format: "%.2f V", deviceService.deviceInfo.voltage)
                                )
                                
                                iOSDetailRow(
                                    icon: "waveform.path.ecg",
                                    label: "Current",
                                    value: String(format: "%.2f A", deviceService.deviceInfo.currentAmps)
                                )
                                
                                if deviceService.deviceInfo.powerWatts > 0.1 {
                                    iOSDetailRow(
                                        icon: "bolt.circle.fill",
                                        label: "Power",
                                        value: String(format: "%.1f W", abs(deviceService.deviceInfo.powerWatts))
                                    )
                                }
                                
                                if deviceService.deviceInfo.temperature > 0 {
                                    iOSDetailRow(
                                        icon: "thermometer",
                                        label: "Temperature",
                                        value: String(format: "%.1f°C", deviceService.deviceInfo.temperatureCelsius)
                                    )
                                }
                                
                                iOSDetailRow(
                                    icon: "battery.100",
                                    label: "Current Capacity",
                                    value: "\(deviceService.deviceInfo.currentCapacity) mAh"
                                )
                                
                                if deviceService.deviceInfo.nominalChargeCapacity > 0 {
                                    iOSDetailRow(
                                        icon: "gauge",
                                        label: "Nominal Capacity",
                                        value: "\(deviceService.deviceInfo.nominalChargeCapacity) mAh"
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        if !deviceService.deviceInfo.deviceSerial.isEmpty || !deviceService.deviceInfo.osVersion.isEmpty {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Device Information")
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                VStack(spacing: 8) {
                                    if !deviceService.deviceInfo.osVersion.isEmpty {
                                        iOSDetailRow(
                                            icon: "apps.iphone",
                                            label: "iOS Version",
                                            value: deviceService.deviceInfo.osVersion
                                        )
                                    }
                                    
                                    if !deviceService.deviceInfo.deviceSerial.isEmpty {
                                        iOSDetailRow(
                                            icon: "number",
                                            label: "Serial Number",
                                            value: deviceService.deviceInfo.deviceSerial
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                
                if let error = deviceService.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
    }
    
    private var deviceIcon: String {
        let model = deviceService.deviceInfo.deviceModel.lowercased()
        if model.contains("ipad") {
            return "ipad"
        } else if model.contains("ipod") {
            return "ipodtouch"
        } else {
            return "iphone"
        }
    }
    
    private var batteryIcon: String {
        let percentage = deviceService.deviceInfo.currentPercentage
        if deviceService.deviceInfo.isCharging {
            return "battery.100.bolt"
        } else if deviceService.deviceInfo.fullyCharged {
            return "battery.100"
        } else {
            switch percentage {
            case 0..<25:
                return "battery.25"
            case 25..<50:
                return "battery.50"
            case 50..<75:
                return "battery.75"
            default:
                return "battery.100"
            }
        }
    }
    
    private var statusColor: Color {
        if deviceService.deviceInfo.isCharging {
            return .green
        } else if deviceService.deviceInfo.currentPercentage < 20 {
            return .red
        } else if deviceService.deviceInfo.currentPercentage < 50 {
            return .orange
        } else {
            return .green
        }
    }
    
    private var healthColor: Color {
        let health = deviceService.deviceInfo.healthPercentage
        switch health {
        case 0..<50:
            return .red
        case 50..<70:
            return .orange
        case 70..<80:
            return .yellow
        case 80..<90:
            return .green
        default:
            return .green
        }
    }
}

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.accentColor))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct iOSDetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    iOSDeviceView()
        .frame(width: 400, height: 550)
}
