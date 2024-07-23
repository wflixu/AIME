//
//  DemoView.swift
//  AIME
//
//  Created by lixu on 2024/7/16.
//

import SwiftUI

import Foundation
import Carbon



struct DemoView: View {
    @AppLog()
    private var logger
    
    
    var body: some View {
        Button (action: getInputMedth) {
           Text("获取输入法")
        }

    }
    
    func getInputMedth() {
        // 获取当前键盘输入源
        if let currentKeyboard = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() {
            // 获取输入源的本地化名字
            if let name = TISGetInputSourceProperty(currentKeyboard, kTISPropertyLocalizedName) {
              let nameString =   Unmanaged<CFString>.fromOpaque(name).takeUnretainedValue() as String
                print("当前输入源: \(nameString)")
            }
        }
        
        guard let sourceList = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource] else {
            return
        }
        
        for source in sourceList {
            if let sourceIDPointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) {
                
                let sourceIDString = Unmanaged<CFString>.fromOpaque(sourceIDPointer).takeUnretainedValue() as String
                
                logger.info("soucrceid: \(sourceIDString)")
            }
            if let sourceNamePointer = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) {
                
                let sourceNameStr = Unmanaged<CFString>.fromOpaque(sourceNamePointer).takeUnretainedValue() as String
                
                logger.info("sourceName: \(sourceNameStr)")
            }
        }
    }
}

#Preview {
    DemoView()
}
