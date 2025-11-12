//
//  SettingsView.swift
//  BatteryManager
//
//  Created on 11/11/2025.
//

import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var menuBarManager: MenuBarManager
    @StateObject private var loginItemManager = LoginItemManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "battery.100.bolt")
                        .font(.system(size: 64))
                        .foregroundColor(.green)
                    
                    Text("Battery Manager")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Monitor your Mac's battery health")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "power")
                            .foregroundColor(.green)
                        Text("General")
                            .font(.headline)
                    }
                    
                    Toggle("Open at Login", isOn: $loginItemManager.isEnabled)
                        .toggleStyle(.switch)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "menubar.rectangle")
                            .foregroundColor(.blue)
                        Text("Menu Bar")
                            .font(.headline)
                    }
                    
                    Toggle("Show in Menu Bar", isOn: $menuBarManager.isEnabled)
                        .toggleStyle(.switch)
                    
                    if menuBarManager.isEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Style")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Picker("", selection: $menuBarManager.displayMode) {
                                ForEach(MenuBarDisplayMode.allCases, id: \.self) { mode in
                                    Text(mode.description).tag(mode)
                                }
                            }
                            .pickerStyle(.radioGroup)
                            
                            if menuBarManager.displayMode == .custom {
                                Divider()
                                    .padding(.vertical, 4)
                                
                                Text("Customize Elements")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                                
                                VStack(spacing: 8) {
                                    ForEach($menuBarManager.customElements) { $element in
                                        HStack {
                                            Image(systemName: "line.3.horizontal")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                            
                                            Toggle(element.type.rawValue, isOn: $element.isEnabled)
                                                .toggleStyle(.checkbox)
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 2)
                                    }
                                    .onMove { from, to in
                                        menuBarManager.customElements.move(fromOffsets: from, toOffset: to)
                                    }
                                }
                                .padding(.leading, 8)
                                
                                Text("Drag to reorder • Check to show")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.leading)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Credits")
                            .font(.headline)
                    }
                    
                    Text("© 2025 JoshAtticus")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
}
