//
//  TrayViewModel.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import SwiftUI

final class TrayViewModel: ObservableObject {
    @Published var isCharging: Bool = false

    private let chargeTracker = ChargeTracker()
    private var beepProcess: Timer?
}

// MARK: - Public
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
        }
    }

    func onChange(_ state: BatteryState) {
        let isntCharging = state.status == .notCharging
        let isntPluggedIn = !chargeTracker.isPowerAdapterPluggedIn()
        let shouldBeep = isntCharging && isntPluggedIn

        beep(shouldBeep)
    }

    func beep(_ isOn: Bool) {
        guard isOn else {
            beepProcess?.invalidate()
            beepProcess = nil
            return
        }

        beepProcess = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) {  _ in
            NSSound.beep()
        }
        beepProcess?.fire()
    }
}
