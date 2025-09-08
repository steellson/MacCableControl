//
//  AppDelegate.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    private let trayWindow: NSWindow? = TrayWindow(
        TrayView(viewModel: TrayViewModel())
    )

    func applicationDidFinishLaunching(_ notification: Notification) { }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

