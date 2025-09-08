//  Created by Andrew Steellson on 08.09.2025.
//

import Foundation

public struct BatteryState {
    public let status: ChargeTracker.Status
    public let description: String

    public init(status: ChargeTracker.Status) {
        self.status = status
        self.description = switch status {
        case .unknown: "Unknown status"
        case .charging: "Charging"
        case .notCharging: "Not charging"
        }
    }
}
