//
//  InstallStep.swift
//  ESPSwiftInstaller
//
//  Created by Gibeom Ko on 5/29/26.
//

import Foundation

// Represents a single step in the installation process.
// Each step maps to a phase of install.sh output.
struct InstallStep: Identifiable {
    let id = UUID ()
    let title: String
    let marker: String // String in install.sh output that triggers this step
    var state: StepState = .waiting
    
    enum StepState {
        case waiting
        case inProgress
        case completed
        case failed
    }
}

extension InstallStep {
    // The four steps matching install.sh's [1/4] ... [4/4]
    static var allSteps: [InstallStep] = [
        InstallStep(title: "Installing ESP-IDF", marker: "[1/4]"),
        InstallStep(title: "Installing Embedded Swift Toolchain", marker: "[2/4]"),
        InstallStep(title: "Installing Xcode Template", marker: "[3/4]"),
        InstallStep(title: "Installing Helper Scripts", marker: "[4/4]")
    ]
}
