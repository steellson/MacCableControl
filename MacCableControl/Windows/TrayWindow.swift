//
//  TrayWindow.swift
//  Tray
//
//  Created by Andrew Steellson on 06.09.2025.
//

import SwiftUI

final class TrayWindow: NSWindow {

    private let statusItem: NSStatusItem
    private var image: NSImage? = NSImage(
        systemSymbolName: "bolt.shield",
        accessibilityDescription: "Power Plug"
    )

    override var canBecomeKey: Bool { true }

    override func resignKey() {
        super.resignKey()
        orderOut(nil)
    }

    init(_ contentView: TrayView) {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.resizable],
            backing: .buffered,
            defer: false
        )

        configureBasic(with: contentView)
        configureButton()
    }
}

// MARK: - Configuration
private extension TrayWindow {

    func configureBasic(with trayView: TrayView) {
        contentView = NSHostingView(rootView: trayView)
        contentView?.layer?.backgroundColor = .clear
        contentView?.clipsToBounds = true

        level = .floating
        isReleasedWhenClosed = false
        standardWindowButton(.zoomButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
    }

    func configureButton() {
        guard let statusButton = statusItem.button else { return }

        statusButton.image = image
        statusButton.target = self
        statusButton.action = #selector(handleClick)
        statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    func configureMenu() {
        let menu = NSMenu()
        let quit = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        )

        quit.target = self
        menu.addItem(quit)
        statusItem.menu = menu

        if let button = statusItem.button {
            button.performClick(nil)
        }

        DispatchQueue.main.async {
            self.statusItem.menu = nil
        }
    }
}

// MARK: - Calculations
private extension TrayWindow {

    func calculatePosition(for rect: CGRect) -> (x: CGFloat, y: CGFloat) {
        let origin = rect.origin
        let frameWidth = frame.size.width
        let buttonWidth = rect.size.width

        let divideBy: CGFloat = 2.0
        let xPos = origin.x + buttonWidth / divideBy - frameWidth / divideBy
        let yPos = origin.y - frame.size.height

        return (x: xPos, y: yPos)
    }
}

// MARK: - Actions
private extension TrayWindow {

    @objc
    func handleClick() {
        guard NSApp.currentEvent?.type == .rightMouseUp else {
            toggleWindow()
            return
        }

        if isVisible { toggleWindow() }
        configureMenu()
    }

    func toggleWindow() {
        guard let buttonFrame = statusItem.button?.window?.frame else { return }

        if isVisible {
            orderOut(nil)
        } else {
            let position = calculatePosition(for: buttonFrame)
            setFrameOrigin(NSPoint(x: position.x, y: position.y))

            orderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc
    func quit() {
        NSApp.terminate(nil)
    }
}
