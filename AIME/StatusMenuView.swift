//
//  StatusMenuView.swift
//  AIME
//
//  Created by 李旭 on 2024/7/23.
//

import SwiftUI

struct StatusMenuView: View {
    var body: some View {
        VStack {
            SettingsLink {
                Image(systemName: "gearshape")
                Text("Settings")
            }
            Button(action: actionQuit) {
                Image(systemName: "xmark.square")
                Text("Quit")
            }
        }
    }
    
    private func actionQuit() {
       
        
        Task {
            try await Task.sleep(nanoseconds:UInt64(1.0 * 1e9))
            await NSApplication.shared.terminate(self)
        }
    }
}

#Preview {
    StatusMenuView()
}
