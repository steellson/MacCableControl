//
//  MenuViewModel.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 09.09.2025.
//

import Foundation

final class MenuViewModel: ObservableObject {
    @Published var hasCustomSound: Bool = false

    private let alarm: Alarm
    private let saver: Saver
    private let pusher: Pusher
    private let finder: Finder

    init(
        alarm: Alarm,
        saver: Saver,
        pusher: Pusher,
        finder: Finder
    ) {
        self.alarm = alarm
        self.saver = saver
        self.pusher = pusher
        self.finder = finder

        checkSound()
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

// MARK: - Private
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
