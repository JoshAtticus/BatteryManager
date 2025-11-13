//
//  DetailsView.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import SwiftUI

struct DetailsView: View {
    let batteryInfo: BatteryInfo
    @StateObject private var macInfoService = MacInfoService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                DetailSection(title: "Mac Information", icon: "desktopcomputer", color: .blue) {
                    DetailRow(label: "Name", value: macInfoService.macInfo.name)
                    DetailRow(label: "Device Identifier", value: macInfoService.macInfo.identifier)
                    if !macInfoService.macInfo.model.isEmpty {
                        DetailRow(label: "Model", value: macInfoService.macInfo.model)
                    }
                    if !macInfoService.macInfo.modelDescription.isEmpty {
                        DetailRow(label: "Model Number", value: macInfoService.macInfo.modelDescription)
                    }
                    DetailRow(label: "Serial", value: macInfoService.macInfo.serial)
                    
                    if !macInfoService.macInfo.chipDescription.isEmpty {
                        DetailRow(label: "Chip", value: macInfoService.macInfo.chipDescription)
                    }
                    if !macInfoService.macInfo.chipPlatform.isEmpty {
                        DetailRow(label: "Chip Platform", value: macInfoService.macInfo.chipPlatform)
                    }
                    DetailRow(label: "OS Version", value: macInfoService.macInfo.osVersion)
                    DetailRow(label: "Thermal State", value: macInfoService.macInfo.thermalState)
                    if !macInfoService.macInfo.logicBoardSerial.isEmpty {
                        DetailRow(label: "Logic Board Serial", value: macInfoService.macInfo.logicBoardSerial)
                    }
                    DetailRow(label: "Time Since Last Reboot", value: macInfoService.macInfo.timeSinceLastReboot)
                }
                
                DetailSection(title: "Battery Information", icon: "info.circle.fill", color: .blue) {
                    DetailRow(label: "Device Name", value: batteryInfo.deviceName)
                    DetailRow(label: "Serial Number", value: batteryInfo.serial)
                    if !batteryInfo.manufacturer.isEmpty {
                        DetailRow(label: "Manufacturer", value: batteryInfo.manufacturer)
                    }
                    if !batteryInfo.manufactureDate.isEmpty {
                        DetailRow(label: "Manufacture Date", value: batteryInfo.manufactureDate)
                    }
                    DetailRow(label: "Battery Installed", value: batteryInfo.batteryInstalled ? "Yes" : "No")
                }
                
                DetailSection(title: "Power Information", icon: "bolt.circle.fill", color: .yellow) {
                    DetailRow(label: "External Connected", value: batteryInfo.externalConnected ? "Yes" : "No")
                    DetailRow(label: "Is Charging", value: batteryInfo.isCharging ? "Yes" : "No")
                    DetailRow(label: "Fully Charged", value: batteryInfo.fullyCharged ? "Yes" : "No")
                    if batteryInfo.chargingWattage > 0 {
                        DetailRow(label: "Negotiated Power", value: String(format: "%.1f W", batteryInfo.chargingWattage))
                    }
                    if batteryInfo.adapterVoltage > 0 {
                        DetailRow(label: "Adapter Voltage", value: String(format: "%.2f V", Double(batteryInfo.adapterVoltage) / 1000.0))
                    }
                    DetailRow(label: "Charging Voltage", value: "\(batteryInfo.chargingVoltage) mV")
                    DetailRow(label: "Charging Current", value: "\(batteryInfo.chargingCurrent) mA")
                }
                
                DetailSection(title: "Voltage & Current", icon: "waveform.circle.fill", color: .purple) {
                    DetailRow(label: "Voltage", value: String(format: "%.2f V (%d mV)", batteryInfo.voltageDisplay, batteryInfo.voltage))
                    DetailRow(label: "Amperage", value: String(format: "%.2f A", batteryInfo.currentAmpsDisplay))
                    DetailRow(label: "Instant Amperage", value: String(format: "%.2f A", Double(batteryInfo.instantAmperage > 32767 ? batteryInfo.instantAmperage - 65536 : batteryInfo.instantAmperage) / 1000.0))
                }
                
                DetailSection(title: "Temperature", icon: "thermometer", color: .orange) {
                    DetailRow(label: "Battery Temperature", value: String(format: "%.1f°C (%d raw)", batteryInfo.temperatureCelsius, Int(batteryInfo.temperature)))
                    DetailRow(label: "Virtual Temperature", value: String(format: "%.1f°C (%d raw)", batteryInfo.virtualTemperatureCelsius, Int(batteryInfo.virtualTemperature)))
                }
                
                DetailSection(title: "Capacity Details", icon: "chart.bar.fill", color: .green) {
                    DetailRow(label: "Current Capacity", value: "\(batteryInfo.currentCapacity)%")
                    DetailRow(label: "Max Capacity", value: "\(batteryInfo.maxCapacity)%")
                    DetailRow(label: "Design Capacity", value: "\(batteryInfo.designCapacity) mAh")
                    DetailRow(label: "Nominal Capacity", value: "\(batteryInfo.nominalChargeCapacity) mAh")
                    DetailRow(label: "Raw Current", value: "\(batteryInfo.rawCurrentCapacity) mAh")
                    DetailRow(label: "Raw Maximum", value: "\(batteryInfo.rawMaxCapacity) mAh")
                }
                
                DetailSection(title: "Status", icon: "exclamationmark.circle.fill", color: .red) {
                    DetailRow(label: "Critical Level", value: batteryInfo.atCriticalLevel ? "Yes" : "No")
                    DetailRow(label: "Time Remaining", value: batteryInfo.timeRemainingFormatted)
                }
                
                DetailSection(title: "Lifetime Data", icon: "clock.badge.checkmark.fill", color: .cyan) {
                    if batteryInfo.totalOperatingTime > 0 {
                        DetailRow(label: "Total Operating Time", value: String(format: "%d hours (%d days)", batteryInfo.totalOperatingTime, batteryInfo.totalOperatingTime / 24))
                    }
                    if batteryInfo.temperatureSamples > 0 && batteryInfo.totalOperatingTime > 0 {
                        let totalMinutes = batteryInfo.totalOperatingTime * 60
                        let intervalMinutes = Double(totalMinutes) / Double(batteryInfo.temperatureSamples)
                        let recordingDays = batteryInfo.totalOperatingTime / 24
                        DetailRow(label: "Temperature Recording Period", value: String(format: "%d days", recordingDays, intervalMinutes))
                    }
                    if batteryInfo.minimumTemperature != 0 {
                        DetailRow(label: "Minimum Temperature", value: String(format: "%.1f°C", batteryInfo.minimumTemperature / 10.0))
                    }
                    if batteryInfo.maximumTemperature > 0 {
                        DetailRow(label: "Maximum Temperature", value: String(format: "%.1f°C", batteryInfo.maximumTemperature / 10.0))
                    }
                    if batteryInfo.averageTemperature > 0 {
                        DetailRow(label: "Average Temperature", value: String(format: "%.1f°C", batteryInfo.averageTemperature / 10.0))
                    }
                    if batteryInfo.maximumChargeCurrent > 0 {
                        DetailRow(label: "Maximum Charge Rate", value: "\(batteryInfo.maximumChargeCurrent) mA")
                    }
                    if batteryInfo.maximumDischargeCurrent != 0 {
                        DetailRow(label: "Maximum Discharge Rate", value: String(format: "%d mA", abs(batteryInfo.maximumDischargeCurrent)))
                    }
                    if batteryInfo.minimumPackVoltage > 0 {
                        DetailRow(label: "Minimum Voltage", value: String(format: "%.3f V (%d mV)", Double(batteryInfo.minimumPackVoltage) / 1000.0, batteryInfo.minimumPackVoltage))
                    }
                    if batteryInfo.maximumPackVoltage > 0 {
                        DetailRow(label: "Maximum Voltage", value: String(format: "%.3f V (%d mV)", Double(batteryInfo.maximumPackVoltage) / 1000.0, batteryInfo.maximumPackVoltage))
                    }
                }
                
                if !batteryInfo.shutdownReason.isEmpty {
                    DetailSection(title: "Last Shutdown", icon: "power.circle.fill", color: .pink) {
                        DetailRow(label: "Shutdown Reason", value: batteryInfo.shutdownReason)
                        if batteryInfo.shutdownVoltage > 0 {
                            DetailRow(label: "Voltage at Shutdown", value: String(format: "%.2f V", Double(batteryInfo.shutdownVoltage) / 1000.0))
                        }
                        if batteryInfo.shutdownTemperature != 0 {
                            DetailRow(label: "Temperature at Shutdown", value: String(format: "%.1f°C", batteryInfo.shutdownTemperature))
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            
            VStack(spacing: 8) {
                content
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
