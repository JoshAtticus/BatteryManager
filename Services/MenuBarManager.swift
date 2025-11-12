//
//  MenuBarManager.swift
//  BatteryManager
//
//  Created on 11/12/2025.
//

import SwiftUI
import AppKit

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var batteryService: BatteryService
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "menuBarEnabled")
            if isEnabled {
                setupMenuBar()
            } else {
                removeMenuBar()
            }
        }
    }
    
    @Published var displayMode: MenuBarDisplayMode {
        didSet {
            UserDefaults.standard.set(displayMode.rawValue, forKey: "menuBarDisplayMode")
            updateMenuBar()
        }
    }
    
    @Published var customElements: [MenuBarElement] {
        didSet {
            saveCustomElements()
            updateMenuBar()
        }
    }
    
    init(batteryService: BatteryService) {
        self.batteryService = batteryService
        self.isEnabled = UserDefaults.standard.bool(forKey: "menuBarEnabled")
        let savedMode = UserDefaults.standard.string(forKey: "menuBarDisplayMode") ?? MenuBarDisplayMode.percentage.rawValue
        self.displayMode = MenuBarDisplayMode(rawValue: savedMode) ?? .percentage
        self.customElements = Self.loadCustomElements()
        
        if isEnabled {
            setupMenuBar()
        }
    }
    
    private func setupMenuBar() {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        }
        
        if let button = statusItem?.button {
            updateMenuBar()
            button.target = self
            button.action = #selector(togglePopover)
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Show Window", action: #selector(showMainWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Battery Manager", action: #selector(quitApp), keyEquivalent: "q"))
        
        for item in menu.items {
            item.target = self
        }
        
        statusItem?.menu = menu
    }
    
    private func removeMenuBar() {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
    }
    
    func updateMenuBar() {
        guard let button = statusItem?.button else { return }
        
        let batteryInfo = batteryService.batteryInfo
        
        switch displayMode {
        case .percentage:
            button.image = nil
            button.title = "\(batteryInfo.currentCapacity)%"
        case .percentageWithIcon:
            button.image = NSImage(systemSymbolName: batteryIcon(for: batteryInfo), accessibilityDescription: "Battery")
            button.title = " \(batteryInfo.currentCapacity)%"
        case .icon:
            button.image = NSImage(systemSymbolName: batteryIcon(for: batteryInfo), accessibilityDescription: "Battery")
            button.title = ""
        case .health:
            button.image = nil
            button.title = String(format: "%.0f%% Health", batteryInfo.healthPercentage)
        case .detailed:
            button.image = nil
            button.title = "\(batteryInfo.currentCapacity)% • \(batteryInfo.powerWattsFormatted)"
        case .custom:
            let displayText = buildCustomDisplay(batteryInfo: batteryInfo)
            if displayText.hasIcon {
                button.image = NSImage(systemSymbolName: batteryIcon(for: batteryInfo), accessibilityDescription: "Battery")
                button.title = displayText.text.isEmpty ? "" : " \(displayText.text)"
            } else {
                button.image = nil
                button.title = displayText.text
            }
        }
    }
    
    private func buildCustomDisplay(batteryInfo: BatteryInfo) -> (text: String, hasIcon: Bool) {
        var parts: [String] = []
        var hasIcon = false
        
        for element in customElements where element.isEnabled {
            switch element.type {
            case .icon:
                hasIcon = true
            case .percentage:
                parts.append("\(batteryInfo.currentCapacity)%")
            case .health:
                parts.append(String(format: "%.0f%%", batteryInfo.healthPercentage))
            case .power:
                parts.append(batteryInfo.powerWattsFormatted)
            case .temperature:
                parts.append(String(format: "%.0f°C", batteryInfo.temperatureCelsius))
            case .voltage:
                parts.append(String(format: "%.1fV", batteryInfo.voltageDisplay))
            }
        }
        
        return (parts.joined(separator: " • "), hasIcon)
    }
    
    private func saveCustomElements() {
        if let encoded = try? JSONEncoder().encode(customElements) {
            UserDefaults.standard.set(encoded, forKey: "menuBarCustomElements")
        }
    }
    
    private static func loadCustomElements() -> [MenuBarElement] {
        guard let data = UserDefaults.standard.data(forKey: "menuBarCustomElements"),
              let elements = try? JSONDecoder().decode([MenuBarElement].self, from: data) else {
            return MenuBarElement.defaultElements
        }
        return elements
    }
    
    private func batteryIcon(for batteryInfo: BatteryInfo) -> String {
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
    
    @objc private func togglePopover() {
        showMainWindow()
    }
    
    @objc private func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc private func openSettings() {
        NotificationCenter.default.post(name: .openSettings, object: nil)
        showMainWindow()
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

enum MenuBarDisplayMode: String, CaseIterable {
    case percentage = "Percentage"
    case percentageWithIcon = "Percentage with Icon"
    case icon = "Icon Only"
    case health = "Health"
    case detailed = "Detailed"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
}

struct MenuBarElement: Codable, Identifiable, Equatable {
    let id: UUID
    var type: ElementType
    var isEnabled: Bool
    
    enum ElementType: String, Codable, CaseIterable {
        case icon = "Icon"
        case percentage = "Percentage"
        case health = "Health"
        case power = "Power"
        case temperature = "Temperature"
        case voltage = "Voltage"
    }
    
    init(id: UUID = UUID(), type: ElementType, isEnabled: Bool = true) {
        self.id = id
        self.type = type
        self.isEnabled = isEnabled
    }
    
    static let defaultElements: [MenuBarElement] = [
        MenuBarElement(type: .icon, isEnabled: true),
        MenuBarElement(type: .percentage, isEnabled: true),
        MenuBarElement(type: .health, isEnabled: false),
        MenuBarElement(type: .power, isEnabled: false),
        MenuBarElement(type: .temperature, isEnabled: false),
        MenuBarElement(type: .voltage, isEnabled: false)
    ]
}
