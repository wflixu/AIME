//
//  AIMEApp.swift
//  AIME
//
//  Created by lixu on 2024/7/16.
//


import SwiftUI

@main
struct AIMEApp: App {
    
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
        MenuBarExtra("AIME", systemImage: "keyboard") {
            StatusMenuView()
        }
    }
}



