//
//  HealthView.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import SwiftUI

struct HealthView: View {
    let batteryInfo: BatteryInfo
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 48))
                        .foregroundColor(healthColor)
                    
                    Text(String(format: "%.1f%%", batteryInfo.healthPercentage))
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(healthColor)
                    
                    Text(batteryInfo.healthStatus)
                        .font(.headline)
                        .foregroundColor(healthColor)
                        .multilineTextAlignment(.center)
                    
                    Text("\(batteryInfo.rawMaxCapacity) / \(batteryInfo.designCapacity) mAh")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.blue)
                        Text("Cycle Count")
                            .font(.headline)
                    }
                    
                    HStack {
                        Text("Current")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(batteryInfo.cycleCount)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Design Maximum")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(batteryInfo.designCycleCount)")
                            .fontWeight(.semibold)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(cycleColor)
                                .frame(
                                    width: geometry.size.width * min(CGFloat(batteryInfo.cycleCount) / CGFloat(batteryInfo.designCycleCount), 1.0),
                                    height: 12
                                )
                        }
                    }
                    .frame(height: 12)
                    
                    Text("\(Int((Double(batteryInfo.cycleCount) / Double(batteryInfo.designCycleCount)) * 100))% of design cycles used")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.purple)
                        Text("Capacity Details")
                            .font(.headline)
                    }
                    
                    VStack(spacing: 12) {
                        CapacityRow(label: "Design Capacity", value: "\(batteryInfo.designCapacity) mAh")
                        CapacityRow(label: "Current Max Capacity", value: "\(batteryInfo.rawMaxCapacity) mAh")
                        CapacityRow(label: "Nominal Capacity", value: "\(batteryInfo.nominalChargeCapacity) mAh")
                        CapacityRow(label: "Current Capacity", value: "\(batteryInfo.rawCurrentCapacity) mAh")
                        CapacityRow(label: "Capacity Lost", value: "\(batteryInfo.designCapacity - batteryInfo.rawMaxCapacity) mAh")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
    }
    
    private var healthColor: Color {
        let health = batteryInfo.healthPercentage
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
    
    private var cycleColor: Color {
        let percentage = Double(batteryInfo.cycleCount) / Double(batteryInfo.designCycleCount)
        switch percentage {
        case 0..<0.5:
            return .green
        case 0.5..<0.8:
            return .yellow
        case 0.8..<1.0:
            return .orange
        default:
            return .red
        }
    }
}

struct CapacityRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
