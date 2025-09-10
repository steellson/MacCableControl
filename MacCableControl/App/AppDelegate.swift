//
//  AppDelegate.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import Cocoa
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {

    @MainActor
    private let trayWindow: NSWindow? = TrayWindow()

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerAutorun()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

// MARK: - Autorun
private extension AppDelegate {
    func registerAutorun() {
        do {
            let appService = SMAppService.mainApp
            try appService.register()

            let status = appService.status
            status == .enabled
            ? Log.success("Autorun enabled")
            : Log.warning("Autorun status is: \(status)")
        } catch {
            Log.critical("Failed to register autorun: \(error)")
        }
    }
}
