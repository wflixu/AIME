//
//  AppDelegate.swift
//  AIME
//
//  Created by lixu on 2024/7/16.
//

import Carbon
import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    @AppLog()
    private var logger
    
    var records: [String: String] = [:]
    
    var currentAppBundleIdentifier: String?
    
    var settingApp: String = ""
    
    let debouncer = Debouncer(delay: 1)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.info(" app did finish ")
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidActivate), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(recordInputSourceChange),
            name: NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String),
            object: nil
        )
    }
    func applicationWillTerminate(_ notification: Notification) {
        DistributedNotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    deinit {
        DistributedNotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    @objc func appDidActivate(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let app = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           let bundleIdentifier = app.bundleIdentifier
        {
            if bundleIdentifier != currentAppBundleIdentifier {
                currentAppBundleIdentifier = bundleIdentifier
                settingApp = bundleIdentifier
                switchInputMethod(for: bundleIdentifier)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.settingApp = ""
                }
            }
        }
    }
    
    func switchInputMethod(for bundleIdentifier: String) {
        if let lastSourceID = records[bundleIdentifier], let currentInputSourceId = getCurrentAppBundleID() {
            if lastSourceID != currentInputSourceId {
                setLastInputMethod(lastSourceID)
            }
        } else {
            record(bundleIdentifier)
        }
    }
    
    func setLastInputMethod(_ sourceID: String) {
        guard let sourceList = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource], let bundleID = getCurrentAppBundleID() else {
            return
        }
        
        for source in sourceList {
            if let sourceIDPointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) {
                let sourceIDString = Unmanaged<CFString>.fromOpaque(sourceIDPointer).takeUnretainedValue() as String
                
                if sourceIDString == sourceID {
                    logger.info("setInput: \(bundleID) -- \(sourceID)")
                    settingApp = bundleID
                    TISSelectInputSource(source)
                    break
                }
            }
        }
    }
        
    func record(_ bundle: String) {
        if let sourceID = getCurrentInputSourceId() {
            logger.info("record: \(bundle) -- \(sourceID)")
            records[bundle] = sourceID
        }
    }
    
    @objc func getCurrentInputSourceId() -> String? {
        if let currentKeyboard = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() {
            // 获取输入源的本地化名字
            if let soureIDPointer = TISGetInputSourceProperty(currentKeyboard, kTISPropertyInputSourceID) {
                let sourceID = Unmanaged<CFString>.fromOpaque(soureIDPointer).takeUnretainedValue() as String
                return sourceID
                
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getCurrentAppBundleID() -> String? {
        return NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }
    
    @objc func recordInputSourceChange() {
        logger.info("event change handle")
        if let bundleID = getCurrentAppBundleID(), let sourceID = getCurrentInputSourceId(), let curddd = currentAppBundleIdentifier {
            if settingApp == bundleID {
                logger.info("changed log ###: \(bundleID) -- \(sourceID)--\(curddd)")
                 
            } else {
                logger.info("changed log: \(bundleID) -- \(sourceID)--\(curddd)")
                records[bundleID] = sourceID
            }
        }
    }
}
