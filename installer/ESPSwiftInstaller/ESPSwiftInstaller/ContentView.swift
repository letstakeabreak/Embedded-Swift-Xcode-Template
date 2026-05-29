//
//  ContentView.swift
//  ESPSwiftInstaller
//
//  Created by Gibeom Ko on 5/29/26.
//

import SwiftUI

// Root view that switches between Welcome, Progress, and Completion screens.
struct ContentView: View {
    
    @StateObject private var installer = Installer()
    
    var body: some View {
        Group {
            if installer.isCompleted {
                CompletionView()
            } else if installer.isRunning || installer.isFailed {
                InstallProgressView(installer: installer)
            } else {
                WelcomeView(installer: installer)
            }
        }
        .frame(width: 560, height: 420)
    }
}

#Preview {
    ContentView()
}
