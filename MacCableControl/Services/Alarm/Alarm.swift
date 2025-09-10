//
//  Alarm.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 08.09.2025.
//

import AppKit

final class Alarm {
    public var isOn: Bool { process != nil }

    public var soundURL: URL? {
        didSet {
            guard let soundURL else { return }
            sound = NSSound(
                contentsOf: soundURL,
                byReference: false
            )
        }
    }

    private var sound: NSSound?
    private var process: Timer?

    public init(soundURL: URL? = nil) {
        self.soundURL = soundURL
    }

    deinit {
        stop()
    }
}

// MARK: - Public
extension Alarm {
    public func signal(_ isOn: Bool) {
        isOn ? start() : stop()
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
}
