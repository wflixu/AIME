//
//  AppDelegate.swift
//  AIME
//
//  Created by lixu on 2024/7/16.
//

import Cocoa


class AppDelegate: NSObject, NSApplicationDelegate {
    
    var currentAppBundleIdentifier: String?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidActivate), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    @objc func appDidActivate(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let app = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           let bundleIdentifier = app.bundleIdentifier {
            
            if bundleIdentifier != currentAppBundleIdentifier {
                currentAppBundleIdentifier = bundleIdentifier
                switchInputMethod(for: bundleIdentifier)
            }
        }
    }

    func switchInputMethod(for bundleIdentifier: String) {
        // 根据不同应用的 bundleIdentifier 切换输入法
        // 你可以使用 AppleScript 或 shell 命令来切换输入法
    }
}

