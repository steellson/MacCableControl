//
//  AppDelegate.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    @MainActor
    private let trayWindow: NSWindow? = TrayWindow(
        alarm: Alarm(),
        saver: Saver(directory: "MCC-Data"),
        finder: Finder(),
        pusher: Pusher([.badge, .banner]),
        chargeTracker: ChargeTracker()
    )

    func applicationDidFinishLaunching(_ notification: Notification) { }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

