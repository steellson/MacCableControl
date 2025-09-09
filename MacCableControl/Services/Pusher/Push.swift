//
//  Push.swift
//  MacCableControl
//
//  Created by Andrew Steellson on 09.09.2025.
//

import Foundation

public struct Push {
    public let title: String
    public let sound: String?
    public let subtitle: String?
    public let after: TimeInterval?

    public init (
        title: String,
        sound: String? = nil,
        subtitle: String? = nil,
        after: TimeInterval? = nil
    ) {
        self.title = title
        self.sound = sound
        self.subtitle = subtitle
        self.after = after
    }
}
