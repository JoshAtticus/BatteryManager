//
//  LoginItemManager.swift
//  BatteryManager
//
//  Created on 11/12/2025.
//

import Foundation
import AppKit

class LoginItemManager: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "loginItemEnabled")
            setLoginItem(enabled: isEnabled)
        }
    }
    
    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "loginItemEnabled")
    }
    
    private func setLoginItem(enabled: Bool) {
        if #available(macOS 13.0, *) {
            setLoginItemModern(enabled: enabled)
        } else {
            setLoginItemLegacy(enabled: enabled)
        }
    }
    
    @available(macOS 13.0, *)
    private func setLoginItemModern(enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status == .enabled {
                    try? SMAppService.mainApp.unregister()
                }
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") login item: \(error)")
        }
    }
    
    private func setLoginItemLegacy(enabled: Bool) {
        let bundleURL = Bundle.main.bundleURL
        guard let loginItems = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil)?.takeRetainedValue() else {
            return
        }
        
        if enabled {
            if !isLoginItemEnabled() {
                LSSharedFileListInsertItemURL(
                    loginItems,
                    kLSSharedFileListItemBeforeFirst.takeRetainedValue(),
                    nil,
                    nil,
                    bundleURL as CFURL,
                    nil,
                    nil
                )
            }
        } else {
            guard let loginItemsArray = LSSharedFileListCopySnapshot(loginItems, nil)?.takeRetainedValue() as? [LSSharedFileListItem] else {
                return
            }
            
            for item in loginItemsArray {
                guard let itemURL = LSSharedFileListItemCopyResolvedURL(item, 0, nil)?.takeRetainedValue() as URL? else {
                    continue
                }
                if itemURL == bundleURL {
                    LSSharedFileListItemRemove(loginItems, item)
                }
            }
        }
    }
    
    private func isLoginItemEnabled() -> Bool {
        let bundleURL = Bundle.main.bundleURL
        guard let loginItems = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil)?.takeRetainedValue() else {
            return false
        }
        
        guard let loginItemsArray = LSSharedFileListCopySnapshot(loginItems, nil)?.takeRetainedValue() as? [LSSharedFileListItem] else {
            return false
        }
        
        for item in loginItemsArray {
            guard let itemURL = LSSharedFileListItemCopyResolvedURL(item, 0, nil)?.takeRetainedValue() as URL? else {
                continue
            }
            if itemURL == bundleURL {
                return true
            }
        }
        
        return false
    }
}

import ServiceManagement
