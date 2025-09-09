//
//  TrayViewModel.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import SwiftUI

final class TrayViewModel: ObservableObject {
    @Published var isCharging: Bool = false

    private let alarm: Alarm
    private let pusher: Pusher
    private let chargeTracker: ChargeTracker

    init(
        alarm: Alarm,
        pusher: Pusher,
        chargeTracker: ChargeTracker
    ) {
        self.alarm = alarm
        self.pusher = pusher
        self.chargeTracker = chargeTracker
    }
}

// MARK: - View output
extension TrayViewModel {
    func toggle(state: Bool) {
        isCharging = state
        process()

        NSHapticFeedbackManager.defaultPerformer.perform(
            .levelChange,
            performanceTime: .default
        )
    }
}

// MARK: - Tracking
private extension TrayViewModel {
    func process() {
        guard isCharging else {
            try? chargeTracker.stopTracking()
            return
        }

        do {
            try chargeTracker.startTracking()
            chargeTracker.onStatusChange = { [weak self] in
                self?.onChange($0)
            }
        } catch {
            isCharging = false

            try? pusher.send(
                Push(
                    title: "Tracking failed!",
                    subtitle: "Something went wrong"
                )
            )
        }
    }

    func onChange(_ state: BatteryState) {
        let isntCharging = state.status == .notCharging
        let isntPluggedIn = !chargeTracker.isPowerAdapterPluggedIn()
        let shouldBeep = isntCharging && isntPluggedIn

        alarm.signal(shouldBeep)
    }
}
