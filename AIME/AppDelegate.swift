//
//  AppDelegate.swift
//  AIME
//
//  Created by lixu on 2024/7/16.
//

import Carbon
import Cocoa
import Foundation

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    @AppLog()
    private var logger
    
    var records: [String: TISInputSource] = [:]
    
    var inputSourceChangeInProgress = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.info(" app did finish ")
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidActivate), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(inputSourceChanged),
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

    @objc func inputSourceChanged() {
        logger.info("event change handle")
        if inputSourceChangeInProgress {
            return
        }
        
        inputSourceChangeInProgress = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.inputSourceChangeInProgress = false
        }
        guard
            let bundleIdentifier = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        else {
            return
        }
        
        let currentInputSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        logger.info("changed log: \(bundleIdentifier) -- ")
        records[bundleIdentifier] = currentInputSource
    }
    
    @objc func appDidActivate(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let app = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           let bundleIdentifier = app.bundleIdentifier
        {
            guard let currentInputSourceId = getCurrentInputSourceId() else {
                return
            }
            
            logger.info("appDidActivate：\(bundleIdentifier)")
            
            if let lastSource = records[bundleIdentifier], let lastSourceID = getInputSouceId(inputSource: lastSource) {
                if lastSourceID != currentInputSourceId {
                    logger.info("start set input .....：\(bundleIdentifier)")
                    inputSourceChangeInProgress = true
                    TISSelectInputSource(lastSource)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.inputSourceChangeInProgress = true
                    }
                }
            } else {
                let currentInputSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
                logger.info("changed log at app launched: \(bundleIdentifier) -- ")
                records[bundleIdentifier] = currentInputSource
            }
        }
    }

    func getInputSouceId(inputSource: TISInputSource) -> String? {
        var id: String? = nil
        if
            let inputSourceID = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID)
        {
            id = Unmanaged<CFString>.fromOpaque(inputSourceID).takeUnretainedValue() as String
        }

        return id
    }
    
    func getCurrentInputSourceId() -> String? {
        let currentInputSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        return getInputSouceId(inputSource: currentInputSource)
    }

    func getCurrentAppBundleID() -> String? {
        return NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }
}
