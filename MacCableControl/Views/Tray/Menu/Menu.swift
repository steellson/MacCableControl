//
//  Menu.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 09.09.2025.
//

import AppKit
import Combine

final class Menu: NSMenu {
    enum MenuItem {
        case trackingHeader
        case tracking
        case soundHeader
        case select
        case reset
        case quit
    }

    private lazy var menuItems: [NSMenuItem] = [
        build(menuItem: .trackingHeader),
        build(menuItem: .tracking),
        .separator(),
        build(menuItem: .soundHeader),
        build(menuItem: .reset),
        build(menuItem: .select),
        .separator(),
        build(menuItem: .quit)
    ]

    private var cancellables: Set<AnyCancellable> = []

    private var viewModel: MenuViewModel?

    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        super.init(title: "")

        subscribe()
        menuItems.forEach(addItem)
    }

    @available(*, unavailable, message: "use init(viewModel:)")
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subscription
private extension Menu {
    func subscribe() {
        guard let viewModel else { return }

        viewModel.$hasCustomSound
            .removeDuplicates()
            .sink { [weak self] hasCustomSound in
                let resetItem = self?.menuItems.first(where: { $0.title == "Reset" })
                resetItem?.isEnabled = hasCustomSound
                resetItem?.target = hasCustomSound ? self : nil
            }
            .store(in: &cancellables)
    }
}

// MARK: - Building
private extension Menu {
    func build(menuItem: MenuItem) -> NSMenuItem {
        switch menuItem {
        case .trackingHeader:
            let trackingHeader = NSMenuItem(
                title: "",
                action: nil,
                keyEquivalent: ""
            )
            let attributedTitle = NSAttributedString(
                string: "TRACKING 🔌",
                attributes: [
                    .font: NSFont.systemFont(ofSize: 12, weight: .bold),
                    .foregroundColor: NSColor.white,
                ]
            )
            trackingHeader.isEnabled = false
            trackingHeader.attributedTitle = attributedTitle
            return trackingHeader

        case .tracking:
            let item = NSMenuItem(
                title: "",
                action: nil,
                keyEquivalent: ""
            )
            let container = NSView(frame: NSRect(
                x: 0,
                y: 0,
                width: 40,
                height: 32
            ))
            let toggle = NSSwitch()
            toggle.frame = NSRect(
                x: 14,
                y: 5,
                width: toggle.intrinsicContentSize.width,
                height: toggle.intrinsicContentSize.height
            )

            toggle.target = self
            toggle.action = #selector(toggleTracking)
            toggle.state = viewModel?.isCharging == true ? .on : .off

            container.addSubview(toggle)
            item.view = container
            return item

        case .soundHeader:
            let header = NSMenuItem(
                title: "",
                action: nil,
                keyEquivalent: ""
            )
            let attributedTitle = NSAttributedString(
                string: "SOUND  📣",
                attributes: [
                    .font: NSFont.systemFont(ofSize: 12, weight: .bold),
                    .foregroundColor: NSColor.white,
                ]
            )
            header.attributedTitle = attributedTitle
            return header

        case .select:
            let sound = NSMenuItem(
                title: "Select",
                action: #selector(selectSound),
                keyEquivalent: "s"
            )
            sound.target = self
            return sound

        case .reset:
            let reset = NSMenuItem(
                title: "Reset",
                action: #selector(resetSound),
                keyEquivalent: "r"
            )
            return reset

        case .quit:
            let quit = NSMenuItem(
                title: "Quit",
                action: #selector(killApp),
                keyEquivalent: "q"
            )
            quit.target = self
            return quit
        }
    }
}

// MARK: - Actions
@objc private extension Menu {
    func toggleTracking(_ sender: Any?) {
        guard let toggle = sender as? NSSwitch else { return }

        viewModel?.isCharging = toggle.state == .on ? true : false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            toggle.enclosingMenuItem?.menu?.cancelTracking()
        }
    }

    func selectSound() {
        Task { [weak self] in
            await self?.viewModel?.selectSound()
        }
    }

    func resetSound() {
        viewModel?.resetSound()
    }

    func killApp() {
        NSApp.terminate(nil)
    }
}
