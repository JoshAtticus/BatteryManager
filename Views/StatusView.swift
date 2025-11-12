//
//  StatusView.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import SwiftUI

struct StatusView: View {
    let batteryInfo: BatteryInfo
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: batteryIcon)
                    .font(.system(size: 64))
                    .foregroundColor(statusColor)
                
                Text(batteryInfo.chargingStatus)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("\(batteryInfo.currentCapacity)%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(statusColor)
            }
            .padding(.top, 20)
            
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [statusColor, statusColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(batteryInfo.currentCapacity) / 100, height: 20)
                    }
                }
                .frame(height: 20)
                
                Text("\(batteryInfo.rawCurrentCapacity) mAh")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                StatusRow(
                    icon: "bolt.fill",
                    label: "Voltage",
                    value: String(format: "%.2f V", batteryInfo.voltageDisplay)
                )
                
                StatusRow(
                    icon: "waveform.path.ecg",
                    label: "Current",
                    value: String(format: "%.2f A", batteryInfo.currentAmpsDisplay)
                )
                
                StatusRow(
                    icon: "bolt.circle.fill",
                    label: batteryInfo.isCharging ? "Charging Rate" : "Discharging Rate",
                    value: batteryInfo.powerWattsFormatted
                )
                
                StatusRow(
                    icon: "thermometer",
                    label: "Temperature",
                    value: String(format: "%.1f°C", batteryInfo.temperatureCelsius)
                )
                
                if batteryInfo.timeRemaining != 65535 {
                    StatusRow(
                        icon: batteryInfo.isCharging ? "clock.arrow.circlepath" : "clock",
                        label: batteryInfo.isCharging ? "Time to Full" : "Time Remaining",
                        value: batteryInfo.timeRemainingFormatted
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var batteryIcon: String {
        if batteryInfo.isCharging {
            return "battery.100.bolt"
        } else if batteryInfo.fullyCharged {
            return "battery.100"
        } else {
            switch batteryInfo.currentCapacity {
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
        if batteryInfo.isCharging {
            return .green
        } else if batteryInfo.currentCapacity < 20 {
            return .red
        } else if batteryInfo.currentCapacity < 50 {
            return .orange
        } else {
            return .green
        }
    }
}

struct StatusRow: View {
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
