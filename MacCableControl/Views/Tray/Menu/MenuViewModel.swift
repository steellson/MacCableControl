//
//  MenuViewModel.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 09.09.2025.
//

import Combine
import Foundation

final class MenuViewModel: ObservableObject {
    @Published var isCharging: Bool = false
    @Published var hasCustomSound: Bool = false

    @MainActor
    private let finder = Finder()
    private let alarm = Alarm()
    private let saver = Saver(directory: "MCC-Data")
    private let pusher = Pusher([.badge, .banner])
    private let chargeTracker = ChargeTracker(sendRepeats: true)

    private var cancellables: Set<AnyCancellable> = []

    init() {
        subscribe()
        checkSound()

        Task { try? await pusher.requestPermissions() }
    }
}

// MARK: - View output
extension MenuViewModel {
    func selectSound() async {
        do {
            let url = try await finder.selectFile()
            alarm.soundURL = url
            storeSound(url)
        } catch {
            guard let error = error as? Finder.Errors,
                  error != .selectionCancelled else {
                return
            }

            if alarm.soundURL == nil {
                hasCustomSound = false
            }

            try? pusher.send(
                Push(
                    title: "Selection failed!",
                    subtitle: "File may be corrupted or not accessible."
                )
            )
        }
    }

    func resetSound() {
        saver.resetStore()
        alarm.soundURL = nil
        hasCustomSound = false
    }
}

// MARK: - Tracking
private extension MenuViewModel {
    func subscribe() {
        /// Signal from UI `ON/OFF`
        $isCharging
            .dropFirst()
            .sink { [weak self] in
                self?.process($0)
            }
            .store(in: &cancellables)

        /// State received from tracker
        chargeTracker.state
            .dropFirst()
            .sink { [weak self] in
                self?.onChange($0)
            }
            .store(in: &cancellables)
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


// MARK: - Sound
private extension MenuViewModel {
    func checkSound() {
        guard let url = saver.storedURL() else { return }

        alarm.soundURL = url
        hasCustomSound = true
    }

    func storeSound(_ url: URL) {
        do {
            try saver.save(url: url)
            hasCustomSound = true

            try? pusher.send(
                Push(
                    title: "Successfully selected!",
                    after: 1.5
                )
            )
        } catch {
            if alarm.soundURL == nil {
                hasCustomSound = false
            }

            try? pusher.send(
                Push(
                    title: "Cant save selected sound!",
                    after: 2.0
                )
            )
        }
    }
}
