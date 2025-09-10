//
//  TrayWindow.swift
//  Tray
//
//  Created by Andrew Steellson on 06.09.2025.
//

import Combine
import SwiftUI

final class TrayWindow: NSWindow {
    private var image: NSImage? {
        didSet { statusItem.button?.image = image }
    }

    private var cancellables = Set<AnyCancellable>()

    private let customMenu: Menu
    private let menuViewModel: MenuViewModel
    private let statusItem: NSStatusItem

    override var canBecomeKey: Bool { true }

    // MARK: - Initialization
    init() {
        let menuViewModel = MenuViewModel()
        let customMenu = Menu(viewModel: menuViewModel)

        self.customMenu = customMenu
        self.menuViewModel = menuViewModel
        self.statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.resizable],
            backing: .buffered,
            defer: false
        )


        configureBasic()
        configureButton()
        configureSubscription()
    }

    override func resignKey() {
        super.resignKey()
        orderOut(nil)
    }
}

// MARK: - Configuration
private extension TrayWindow {
    func configureBasic() {
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

    func configureSubscription() {
        menuViewModel.$isCharging
            .removeDuplicates()
            .sink { [weak self] isTracking in
                let imageName = isTracking
                ? "bolt.shield.fill"
                : "bolt.shield"

                self?.image = NSImage(
                    systemSymbolName: imageName,
                    accessibilityDescription: "Power Plug"
                )
            }
            .store(in: &cancellables)
    }

    func configureStatusItem() {
        statusItem.menu = customMenu

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
    func toggleWindow() {
        guard let buttonFrame = statusItem.button?.window?.frame else { return }
        configureStatusItem()

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
    func handleClick() {
        toggleWindow()
    }
}
