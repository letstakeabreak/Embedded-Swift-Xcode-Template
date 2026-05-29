//
//  CompletionView.swift
//  ESPSwiftInstaller
//
//  Created by Gibeom Ko on 5/30/26.
//

import SwiftUI

// Shown when installation completes successfully.
struct CompletionView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 52))
                        .foregroundColor(.green)
                }
                
                Text("Installation Complete!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("You're ready to write ESP32-C6 firmware in Swift.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // ---- Next Steps ----
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Next Steps")
                    .font(.headline)
                
                NextStepRow(
                    number: "1",
                    text: "Open Xcode and create a new project"
                )
                NextStepRow(
                    number: "2",
                    text: "Select the ESP32-C6 template under Other"
                )
                NextStepRow(
                    number: "3",
                    text: "Connect your ESP32-C6 board via USB"
                )
                NextStepRow(
                    number: "4",
                    text: "Press ⌘B to build and flash automatically"
                )
            }
            .padding(.horizontal, 64)
            
            Spacer()
            
            // ---- Actions ----
            
            HStack(spacing: 12) {
                Button("Open Xcode") {
                    NSWorkspace.shared.openApplication(
                        at: URL(fileURLWithPath: "/Applications/Xcode.app"),
                        configuration: NSWorkspace.OpenConfiguration()
                    )
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Close") {
                    NSApplication.shared.terminate(nil)
                }
                .controlSize(.large)
            }
            .padding(.bottom, 28)
        }
        .padding(.horizontal, 40)
    }
}

struct NextStepRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(Color.accentColor)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    CompletionView()
}
