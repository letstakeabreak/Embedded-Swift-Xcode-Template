//
//  InstallProgressView.swift
//  ESPSwiftInstaller
//
//  Created by Gibeom Ko on 5/29/26.
//

import SwiftUI

// Shown while installation is running.
// Displays step-by-step progress and live log output.
struct InstallProgressView: View {
    
    @ObservedObject var installer: Installer
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ───────────────────────────────────────────
            VStack(spacing: 6) {
                Text(installer.isFailed ? "Installation Failed" : "Installing...")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(installer.isFailed
                     ? "An error occurred. Check the log below."
                     : "This will take 5–10 minutes. Please keep your Mac awake.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 28)
            .padding(.bottom, 20)
            .padding(.horizontal, 40)
            
            // ── Steps ─────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 8) {
                ForEach(installer.steps) { step in
                    StepRow(step: step)
                }
            }
            .padding(.horizontal, 48)
            
            // ── Log ───────────────────────────────────────────────
            ScrollViewReader { proxy in
                ScrollView {
                    Text(installer.log)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .id("logBottom")
                }
                .background(Color(NSColor.textBackgroundColor).opacity(0.5))
                .cornerRadius(6)
                .frame(height: 120)
                .padding(.horizontal, 48)
                .padding(.top, 12)
                .onChange(of: installer.log) { _ in
                    withAnimation {
                        proxy.scrollTo("logBottom", anchor: .bottom)
                    }
                }
            }
            
            Spacer()
            
            // ── Action ────────────────────────────────────────────
            HStack {
                if installer.isFailed {
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .controlSize(.large)
                } else {
                    Button("Cancel") {
                        installer.cancel()
                    }
                    .controlSize(.large)
                }
            }
            .padding(.bottom, 28)
        }
    }
}

// ── Subview ───────────────────────────────────────────────────────

struct StepRow: View {
    let step: InstallStep
    
    var body: some View {
        HStack(spacing: 10) {
            // State icon
            Group {
                switch step.state {
                case .waiting:
                    Image(systemName: "circle")
                        .foregroundColor(.secondary)
                case .inProgress:
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 16, height: 16)
                case .completed:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                case .failed:
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .frame(width: 18)
            
            Text(step.title)
                .foregroundColor(step.state == .waiting ? .secondary : .primary)
                .fontWeight(step.state == .inProgress ? .medium : .regular)
            
            Spacer()
        }
    }
}
