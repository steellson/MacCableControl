//
//  TrayViewModel.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import Combine

final class TrayViewModel: ObservableObject {
    @Published var isCharging: Bool = false

    private let alarm: Alarm
    private let pusher: Pusher
    private let chargeTracker: ChargeTracker

    private var cancelables: Set<AnyCancellable> = []

    init(
        alarm: Alarm,
        pusher: Pusher,
        chargeTracker: ChargeTracker
    ) {
        self.alarm = alarm
        self.pusher = pusher
        self.chargeTracker = chargeTracker

        subscribe()
    }
}

// MARK: - Tracking
private extension TrayViewModel {
    func subscribe() {
        /// Signal from UI `ON/OFF`
        $isCharging
            .dropFirst()
            .sink { [weak self] in
                self?.process($0)
            }
            .store(in: &cancelables)

        /// State received from tracker
        chargeTracker.state
            .dropFirst()
            .sink { [weak self] in
                self?.onChange($0)
            }
            .store(in: &cancelables)
    }

    func process(_ isCharging: Bool) {
        guard isCharging else {
            try? chargeTracker.stopTracking()
            alarm.signal(false)
            return
        }

        do {
            try chargeTracker.startTracking()
        } catch {
            try? pusher.send(
                Push(
                    title: "Tracking failed!",
                    subtitle: "Something went wrong"
                )
            )
        }
    }

    func onChange(_ state: BatteryState) {
        let isPluggedIn = chargeTracker.isPowerAdapterPluggedIn()
        let isPowerOFF = state.status == .notCharging
        let isSignalEnabled = alarm.isPlaying

        if isPluggedIn && isSignalEnabled  { alarm.signal(false) }
        if !isPluggedIn && isPowerOFF { alarm.signal(true)  }
    }
}
