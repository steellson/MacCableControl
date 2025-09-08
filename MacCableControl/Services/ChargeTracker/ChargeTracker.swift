//  Created by Andrew Steellson on 08.09.2025.
//

import IOKit.ps
import Foundation

/// ⚡️Tool for tracking battarey charging status changes⚡️
public final class ChargeTracker {
    public var onStatusChange: ((BatteryState) -> Void)?

    private var status: Status = .unknown
    private var runLoopSource: CFRunLoopSource?

    private let sendRepeats: Bool

    public init(sendRepeats: Bool = true) {
        self.sendRepeats = sendRepeats
    }

    deinit {
        try? stopTracking()
    }
}

// MARK: - Types
public extension ChargeTracker {
    enum Status {
        case unknown
        case charging
        case notCharging
    }

    enum Errors: Error {
        case cantStart
        case cantStop
        case cantHandleChanges
    }
}

// MARK: - Public
public extension ChargeTracker {
    func startTracking() throws {
        runLoopSource = buildRunloopSource()
        guard let runLoopSource else {
            Log.error("Cant start charge tracking! Runloop source isn't created")
            throw Errors.cantStart
        }

        CFRunLoopAddSource(
            CFRunLoopGetMain(),
            runLoopSource,
            .defaultMode
        )

        Log.success("Charge tracker started!")
        try handlePowerSourceChange()
    }

    func stopTracking() throws {
        guard let runLoopSource else {
            Log.error("Cant stop charge tracking! Cant find runloop source")
            throw Errors.cantStop
        }

        CFRunLoopRemoveSource(
            CFRunLoopGetMain(),
            runLoopSource,
            .defaultMode
        )

        self.runLoopSource = nil
        Log.success("Charge tracker stopped!")
    }

    func isPowerAdapterPluggedIn() -> Bool {
        let adapterDetails = IOPSCopyExternalPowerAdapterDetails()?
            .takeRetainedValue() as? [String: Any]

        guard let adapterDetails, !adapterDetails.isEmpty else {
            Log.warning("Power adapter isn't connected 🔌")
            return false
        }

        Log.warning("Power adapter connected ⚡️")
        return true
    }
}

// MARK: - Handling
private extension ChargeTracker {
    /// Observing status changes
    func handlePowerSourceChange() throws {
        let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue()

        guard let info, let sources = sources as? [CFTypeRef] else {
            updateStatus(.unknown)
            Log.warning("Cant handle power changes! Somethins went wrong")
            throw Errors.cantHandleChanges
        }

        trackNewStatus(with: info, sources: sources)
    }

    /// Get power ststus for key from info dictionary
    /// - Parameters:
    ///   - info: Returned by IOPSCopyPowerSourcesInfo()
    ///   - sources: One of the references in the array returned by IOPSCopyPowerSourcesList()
    func trackNewStatus(with info: CFTypeRef?, sources: [CFTypeRef]) {
        for process in sources {
            let description = IOPSGetPowerSourceDescription(info, process)?.takeUnretainedValue()
            guard let description = description as? [String: Any] else { continue }

            if let isCharging = description[kIOPSIsChargingKey as String] as? Bool {
                updateStatus(isCharging ? .charging : .notCharging)
                return
            }
        }
        updateStatus(.unknown)
    }

    /// Send exclusive events without duplicates
    /// - Parameter newStatus: Current received status `ON/OFF`
    func updateStatus(_ newStatus: Status) {
        guard newStatus != status else {
            if sendRepeats { onStatusChange?(BatteryState(status: newStatus)) }
            Log.debug("Charging status didnt change: \(newStatus)")
            return
        }

        status = newStatus
        onStatusChange?(BatteryState(status: newStatus))
        Log.debug("Charging status updated: \(newStatus)")
    }
}

// MARK: - Building
private extension ChargeTracker {
    /// C-based callback with tracking process ⚠️
    func buildPowerSourceCallback() -> IOPowerSourceCallbackType {
        return { context in
            guard let context else {
                Log.warning("Cant create IOPowerSourceCallback without context")
                return
            }

            let unretainedSelf = Unmanaged<ChargeTracker>
                .fromOpaque(context)
                .takeUnretainedValue()

            try? unretainedSelf.handlePowerSourceChange()
        }
    }

    func buildRunloopSource() -> CFRunLoopSource? {
        let callback = buildPowerSourceCallback()
        let context = Unmanaged.passUnretained(self).toOpaque()
        let source = IOPSNotificationCreateRunLoopSource(callback, context)

        return source?.takeRetainedValue()
    }
}
