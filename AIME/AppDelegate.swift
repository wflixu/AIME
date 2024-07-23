//
//  AppDelegate.swift
//  AIME
//
//  Created by lixu on 2024/7/16.
//

import Cocoa
import Foundation
import Carbon


class AppDelegate: NSObject, NSApplicationDelegate {
    
    @AppLog()
    private var logger
    
    var records: [String: String]  = [:];
    
    var currentAppBundleIdentifier: String?
    
    var settingApp: String = "";
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.info(" app did finish ")
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidActivate), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        
        DistributedNotificationCenter.default().addObserver(
                forName: NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String),
                object: nil,
                queue: nil
            ) { notification in
                self.logger.info("notification: \(notification)")
                self.logInputSourceChange()
            }
        
    }
    
    @objc func appDidActivate(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let app = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           let bundleIdentifier = app.bundleIdentifier {
            
            if bundleIdentifier != currentAppBundleIdentifier {
                currentAppBundleIdentifier = bundleIdentifier
                settingApp = bundleIdentifier
                self.switchInputMethod(for: bundleIdentifier)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.settingApp = ""
                }
                
            }
        }
    }
    
    @objc func getCurrentInputSourceId() -> String? {
        if let currentKeyboard = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() {
            // 获取输入源的本地化名字
            if let soureIDPointer = TISGetInputSourceProperty(currentKeyboard, kTISPropertyInputSourceID) {
                let souceID =   Unmanaged<CFString>.fromOpaque(soureIDPointer).takeUnretainedValue() as String
                return souceID
                
            } else {
                
                return nil
            }
        }
        else {
            return nil
        }
        
    }
    
    func getCurrentAppBundleID() -> String? {
        return NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }
    
    @objc func logInputSourceChange() {
        
        if let bundleID = getCurrentAppBundleID(), let sourceID = getCurrentInputSourceId() ,let curddd = self.currentAppBundleIdentifier {
            
            
            if settingApp  == bundleID {
                logger.info("changed log ###: \(bundleID) -- \(sourceID)--\(curddd)")
                 
            } else {
                logger.info("changed log: \(bundleID) -- \(sourceID)--\(curddd)")
                records[bundleID] = sourceID
            }
            
        }
    }
    
   
    
    func switchInputMethod(for bundleIdentifier: String) {
        if let lastSourceID = records[bundleIdentifier] {
            setLastInputMethod( lastSourceID)
        } else {
            record(bundleIdentifier)
        }
    }
    func setLastInputMethod(_ sourceID:String) {
        guard let sourceList = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource],let bundleID = getCurrentAppBundleID() else {
            return
        }
        
        for source in sourceList {
            if let sourceIDPointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) {
                
                let sourceIDString = Unmanaged<CFString>.fromOpaque(sourceIDPointer).takeUnretainedValue() as String
                
                
                if sourceIDString == sourceID {
                    logger.info("setInput: \(bundleID) -- \(sourceID)")
                    settingApp  = bundleID;
                    TISSelectInputSource(source)
                    break
                }
            }
            
        }
    }
        
    func record(_ bundle: String) {
        if let souceID = getCurrentInputSourceId(){
            logger.info("record: \(bundle) -- \(souceID)")
            records[bundle] = souceID;
        }
    }
        
    
}
