//  Created by Andrew Steellson on 18.05.2025.

import UserNotifications

public final class Pusher: NSObject {
    private(set) var isAuthorized: Bool = false

    private let options: UNNotificationPresentationOptions
    private let notifications: UNUserNotificationCenter

    public init(_ options: UNNotificationPresentationOptions? = nil) {
        self.options = options ?? [.banner, .sound, .badge]
        self.notifications = UNUserNotificationCenter.current()
        super.init()

        notifications.delegate = self
    }
}

// MARK: - Types
public extension Pusher {
    enum Errors: Error {
        case isNotAuthorized
    }
}

// MARK: - Delegate
extension Pusher: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler(options)
    }
}

// MARK: - Public
public extension Pusher {
    /// Common request for system permissions
    /// - Returns: Is granged or not
    @discardableResult
    func requestPermissions() async throws -> Bool {
        isAuthorized = try await notifications.requestAuthorization(
            options: [.alert, .badge, .sound]
        )
        return isAuthorized
    }

    /// Send system-like notification
    /// Could be scheduled with interval
    /// - Parameter push: Conformed model
    func send(_ push: Push) throws {
        guard isAuthorized else {
            throw Errors.isNotAuthorized
        }

        let content = UNMutableNotificationContent()
        content.title = push.title

        if let subtitle = push.subtitle {
            content.subtitle =  subtitle
        }

        if options.contains(.sound) {
            content.sound = UNNotificationSound(
                named: UNNotificationSoundName(
                    push.sound ?? "default"
                )
            )
        }

        notifications.add(
            UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(
                    timeInterval: push.after ?? 1,
                    repeats: false
                )
            )
        )
    }
}
