//
//  BatteryManagerApp.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import SwiftUI

extension Notification.Name {
    static let openSettings = Notification.Name("openSettings")
}

@main
struct BatteryManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        let windowGroup = WindowGroup {
            ContentView()
                .frame(width: 400, height: 550)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    NotificationCenter.default.post(name: .openSettings, object: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            CommandGroup(replacing: .newItem) {
                EmptyView()
            }
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))
        
        if #available(macOS 13.0, *) {
            return windowGroup.windowResizability(.contentSize)
        } else {
            return windowGroup
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        ensureSingleWindow()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            ensureSingleWindow()
        }
        return true
    }
    
    private func ensureSingleWindow() {
        let windows = NSApp.windows.filter { $0.isVisible && $0.className.contains("NSWindow") }
        
        if windows.count > 1 {
            for window in windows.dropFirst() {
                window.close()
            }
        }
        
        if let window = windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
