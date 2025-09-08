//  Created by Andrew Steellson on 29.03.2025.

import OSLog

/// `` ☩ ☩ ☩ ☩ ☩ ☩ ☩ ☩ ``
/// `` ☩   Logger    ☩ ``
/// `` ☩ ☩ ☩ ☩ ☩ ☩ ☩ ☩ ``

public enum Log {
    public static var log:      (String) -> Void {{ Log.send($0) }}
    public static var info:     (String) -> Void {{ Log.send($0, type: .info) }}
    public static var success:  (String) -> Void {{ Log.send($0, type: .success) }}
    public static var debug:    (String) -> Void {{ Log.send($0, type: .debug) }}
    public static var warning:  (String) -> Void {{ Log.send($0, type: .warning) }}
    public static var error:    (String) -> Void {{ Log.send($0, type: .error) }}
    public static var critical: (String) -> Void {{ Log.send($0, type: .critical) }}

    private static let logger     = Logger()
    private static let formatter  = DateFormatter()
    private static let timeFormat = "HH:mm:ss"
}

// MARK: - Pretty
public extension Log {
    enum UseCase: String {
        case none
        case info     = "💎"
        case success  = "✅"
        case debug    = "🛠️"
        case warning  = "⚠️"
        case error    = "❗️"
        case critical = "🤬"
    }
}

// MARK: - Action
private extension Log {
    /// Send logs into console
    /// - Parameters:
    ///   - message: Text info for logging
    ///   - type: Use for setting log level
    static func send(
        _ message: String,
        type: UseCase = .none
    ) {
        formatter.dateFormat = timeFormat

        let prefix = type == .none ? "" : "\(type.rawValue) "
        let log = prefix + message

        let time = formatter.string(from: .now)
        let msg = "[\(time)] \(log)"

        switch type {
        case .none:     logger.log("\(msg)")
        case .info:     logger.info("\(msg)")
        case .debug:    logger.debug("\(msg)")
        case .success:  logger.info("\(msg)")
        case .warning:  logger.warning("\(msg)")
        case .error:    logger.fault("\(msg)")
        case .critical: logger.critical("\(msg)")
        }
    }
}
