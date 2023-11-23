//
//  SecurityManager.swift
//  Expenso
//
//  Created by Eugene Ned on 23.11.2023.
//

import Foundation

final class SecurityManager {

    static let shared = SecurityManager()

    private init() {}

    func performSecurityChecks() {
        jailbreakDetection()
        debuggingDetection()
        fridaDetection()
        emulatorDetection()
        setupDeviceBinding()
    }

    // MARK: - Step 1: Jailbreak detection
    private func jailbreakDetection() {
        do {
            let pathToFileInRestrictedDirectory = "/private/jailbreak.txt"
            try "This is a test.".write(toFile: pathToFileInRestrictedDirectory, atomically: true, encoding: String.Encoding.utf8)
            try FileManager.default.removeItem(atPath: pathToFileInRestrictedDirectory)
            logger(message: "Device is jailbroken!", level: .error, passedCheck: false)
        } catch {
            logger(message: "Device is NOT jailbroken", level: .info, passedCheck: true)
        }
    }
    
    // MARK: - Step 2: Debugging detection
    private func debuggingDetection() {
        var kinfo = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let sysctlResult = sysctl(&mib, u_int(mib.count), &kinfo, &size, nil, 0)
        if sysctlResult != 0 {
            perror("sysctl")
            return
        }
        if (kinfo.kp_proc.p_flag & P_TRACED) != 0 {
            logger(message: "App is being debugged!", level: .error, passedCheck: false)
        } else {
            logger(message: "App is NOT being debugged", level: .info, passedCheck: true)
        }
    }
    
    // MARK: - Step 3: Frida detection
    /// Looking not specificaly for Frida but for the whole bunch of apps that are using similar strategy
    private func fridaDetection() {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let sysctlResult = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        if sysctlResult == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
            logger(message: "Frida is being attached! But might be a false alarm..", level: .error, passedCheck: false)
        } else {
            logger(message: "Frida is NOT being attached", level: .info, passedCheck: true)
        }
    }
    
    // MARK: - Step 4: Emulator detection
    private func emulatorDetection() {
        #if targetEnvironment(simulator)
            logger(message: "App is running in an emulated environment!", level: .error, passedCheck: false)
        #else
            logger(message: "App is NOT running in an emulated environment", level: .info, passedCheck: true)
        #endif
    }
    
    // MARK: - Step 5: Device binding
    private func setupDeviceBinding() {
        if KeychainManager.shared.getDeviceIdentifier() == nil {
            let newIdentifier = UUID().uuidString
            KeychainManager.shared.saveDeviceIdentifier(newIdentifier)
            logger(message: "Device is being binded", level: .info, passedCheck: true)
        }
    }
}
