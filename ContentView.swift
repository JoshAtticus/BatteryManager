//
//  ContentView.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import SwiftUI

enum Tab {
    case status, health, details, iosDevice, settings
}

struct ContentView: View {
    @StateObject private var batteryService = BatteryService()
    @State private var selectedTab: Tab = .status
    @State private var menuBarManager: MenuBarManager?
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TabButtonWithData(
                        title: "Status",
                        icon: "battery.100",
                        isSelected: selectedTab == .status,
                        liveData: "\(batteryService.batteryInfo.currentCapacity)%"
                    ) {
                        selectedTab = .status
                    }
                    TabButtonWithData(
                        title: "Health",
                        icon: "heart.fill",
                        isSelected: selectedTab == .health,
                        liveData: String(format: "%.0f%%", batteryService.batteryInfo.healthPercentage)
                    ) {
                        selectedTab = .health
                    }
                    TabButton(title: "Details", icon: "list.bullet", isSelected: selectedTab == .details) {
                        selectedTab = .details
                    }
                    TabButton(title: "iOS Device", icon: "iphone", isSelected: selectedTab == .iosDevice) {
                        selectedTab = .iosDevice
                    }
                    TabButton(title: "Settings", icon: "gear", isSelected: selectedTab == .settings) {
                        selectedTab = .settings
                    }
                }
                .padding(8)
                .background(.ultraThinMaterial)
                
                Divider()
                
                Group {
                    switch selectedTab {
                    case .status:
                        StatusView(batteryInfo: batteryService.batteryInfo)
                    case .health:
                        HealthView(batteryInfo: batteryService.batteryInfo)
                    case .details:
                        DetailsView(batteryInfo: batteryService.batteryInfo)
                    case .iosDevice:
                        iOSDeviceView()
                    case .settings:
                        if let menuBarManager = menuBarManager {
                            SettingsView(menuBarManager: menuBarManager)
                        } else {
                            Text("Loading...")
                        }
                    }
                }
            }
        }
        .frame(width: 400, height: 550)
        .onAppear {
            if menuBarManager == nil {
                menuBarManager = MenuBarManager(batteryService: batteryService)
            }
            setupNotificationObservers()
            setupMenuBarUpdates()
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .openSettings,
            object: nil,
            queue: .main
        ) { _ in
            selectedTab = .settings
        }
    }
    
    private func setupMenuBarUpdates() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            menuBarManager?.updateMenuBar()
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .frame(height: 16)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
    }
}

struct TabButtonWithData: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let liveData: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .frame(height: 16)
                Text(isSelected ? title : liveData)
                    .font(.caption)
                    .fontWeight(isSelected ? .regular : .semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

#Preview {
    ContentView()
        .frame(width: 400, height: 550)
}
