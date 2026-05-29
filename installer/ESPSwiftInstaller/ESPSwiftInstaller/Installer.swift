//
//  Installer.swift
//  ESPSwiftInstaller
//
//  Created by Gibeom Ko on 5/29/26.
//

import Foundation
import Combine

// Manages the execution of install.sh and publishes progress updates
// Uses Process to run the shell script and reads its stdout line by line
@MainActor
class Installer: ObservableObject {
    
    @Published var steps: [InstallStep] = InstallStep.allSteps
    @Published var log: String = ""
    @Published var isRunning: Bool = false
    @Published var isCompleted: Bool = false
    @Published var isFailed: Bool = false
    
    private var process: Process?
    
    // Path to install.sh, bundled inside the .app
        private var installScriptPath: String {
            Bundle.main.path(forResource: "install", ofType: "sh") ?? ""
        }
        
        // Starts the installation process.
        func startInstallation() {
            isRunning = true
            isCompleted = false
            isFailed = false
            log = ""
            steps = InstallStep.allSteps
            
            Task {
                await runInstallScript()
            }
        }
        
        // Cancels the running installation.
        func cancel() {
            process?.terminate()
            isRunning = false
            isFailed = true
            appendLog("\nInstallation cancelled.\n")
        }
        
        // Runs install.sh as the current user and reads stdout line by line.
        private func runInstallScript() async {
            // Prepare temp directory with all bundled resources.
            guard let tempDir = prepareTempDirectory() else {
                appendLog("Error: Could not prepare installation files.\n")
                isFailed = true
                isRunning = false
                return
            }
            
            let process = Process()
            self.process = process
            
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [tempDir + "/install.sh"]
            
            // Pass current user's environment so $HOME resolves correctly.
            var env = ProcessInfo.processInfo.environment
            env["HOME"] = NSHomeDirectory()
            process.environment = env
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            // Read output line by line as it arrives.
            pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
                let data = handle.availableData
                guard !data.isEmpty,
                      let line = String(data: data, encoding: .utf8) else { return }
                
                Task { @MainActor [weak self] in
                    self?.appendLog(line)
                    self?.updateSteps(for: line)
                }
            }
            
            do {
                try process.run()
                process.waitUntilExit()
                
                pipe.fileHandleForReading.readabilityHandler = nil
                
                if process.terminationStatus == 0 {
                    markAllCompleted()
                    isCompleted = true
                } else {
                    isFailed = true
                }
                isRunning = false
                
            } catch {
                appendLog("Error: \(error.localizedDescription)\n")
                isFailed = true
                isRunning = false
            }
        }

        // Copies bundled resources to a temp directory so install.sh
    // can find scripts/ and Xcode Template/ as siblings.
    private func prepareTempDirectory() -> String? {
        let tempDir = NSTemporaryDirectory() + "espswift-install"
        let fm = FileManager.default
        
        // Clean up any previous installation attempt.
        try? fm.removeItem(atPath: tempDir)
        
        do {
            try fm.createDirectory(atPath: tempDir, withIntermediateDirectories: true)
            
            // Copy install.sh from the app bundle.
            guard let installSrc = Bundle.main.path(forResource: "install", ofType: "sh") else {
                appendLog("Error: install.sh not found in bundle.\n")
                return nil
            }
            try fm.copyItem(atPath: installSrc, toPath: tempDir + "/install.sh")
            try fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: tempDir + "/install.sh")
            
            // Look for scripts/ and Xcode Template/ in the bundle's Resources folder.
            // When running from Xcode during development, fall back to the repo path.
            guard let resourcesPath = Bundle.main.resourcePath else { return nil }
            
            let scriptsSrc = resourcesPath + "/scripts"
            let templateSrc = resourcesPath + "/Xcode Template"
            
            if fm.fileExists(atPath: scriptsSrc) {
                try fm.copyItem(atPath: scriptsSrc, toPath: tempDir + "/scripts")
            } else {
                // Development fallback: read directly from the local repository.
                appendLog("Warning: scripts/ not found in bundle, falling back to repo path.\n")
                let repoScripts = ("~/Developer/Embedded-Swift-Xcode-Template/scripts" as NSString).expandingTildeInPath
                if fm.fileExists(atPath: repoScripts) {
                    try fm.copyItem(atPath: repoScripts, toPath: tempDir + "/scripts")
                }
            }
            
            if fm.fileExists(atPath: templateSrc) {
                try fm.copyItem(atPath: templateSrc, toPath: tempDir + "/Xcode Template")
            } else {
                // Development fallback: read directly from the local repository.
                appendLog("Warning: Xcode Template/ not found in bundle, falling back to repo path.\n")
                let repoTemplate = ("~/Developer/Embedded-Swift-Xcode-Template/Xcode Template" as NSString).expandingTildeInPath
                if fm.fileExists(atPath: repoTemplate) {
                    try fm.copyItem(atPath: repoTemplate, toPath: tempDir + "/Xcode Template")
                }
            }
            
            // Make all scripts executable.
            if let scripts = try? fm.contentsOfDirectory(atPath: tempDir + "/scripts") {
                for script in scripts {
                    let scriptPath = tempDir + "/scripts/" + script
                    try? fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)
                }
            }
            
            return tempDir
            
        } catch {
            appendLog("Error preparing temp directory: \(error.localizedDescription)\n")
            return nil
        }
    }
    
    // Appends a line to the log text.
    private func appendLog(_ text: String) {
        log += text
        // Keep log from growing too large.
        if log.count > 50_000 {
            log = String(log.suffix(40_000))
        }
    }
    
    // Checks if a line of output matches a step marker and updates state.
        private func updateSteps(for line: String) {
            for i in steps.indices {
                if line.contains(steps[i].marker) {
                    // Mark previous steps as completed.
                    for j in 0..<i {
                        if steps[j].state == .inProgress {
                            steps[j].state = .completed
                        }
                    }
                    steps[i].state = .inProgress
                    return
                }
            }
            
            // "Installation complete." marks everything done.
            if line.contains("Installation complete.") {
                markAllCompleted()
            }
        }
        
        private func markAllCompleted() {
            for i in steps.indices {
                steps[i].state = .completed
            }
        }
}

