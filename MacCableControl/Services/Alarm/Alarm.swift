//
//  Alarm.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import AppKit

final class Alarm {
    public var isPlaying: Bool { process != nil }
    public var soundURL: URL? {
        didSet { onAddURL() }
    }

    private var sound: NSSound?
    private var process: Timer?

    public init(soundURL: URL? = nil) {
        self.soundURL = soundURL
    }

    deinit { stop() }
}

// MARK: - Public
extension Alarm {
    public func signal(_ isOn: Bool) {
        guard isOn else {
            stop()
            return
        }
        if isPlaying { stop() }
        start()
    }
}

// MARK: - Private
private extension Alarm {
    func start() {
        let interval = sound?.duration ?? 1.0
        process = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self]  _ in
            self?.beep()
        }
        process?.fire()
    }

    func stop() {
        sound?.stop()
        process?.invalidate()
        process = nil
    }

    func beep() {
        guard let sound else {
            NSSound.beep()
            return
        }
        sound.play()
    }

    func onAddURL() {
        let isOn = isPlaying
        if isOn { stop() }

        sound = if let soundURL {
            NSSound(
                contentsOf: soundURL,
                byReference: false
            )
        } else {
            nil
        }

        if isOn { start() }
    }
}
