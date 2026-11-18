import Foundation
import os

/// Optional event log for diagnosing event delivery (clicks, hotkeys, screens).
///
/// Off by default. Enable with:
///   defaults write io.github.henpak.followspot debugLogging -bool true
/// Read with:
///   log show --last 10m --predicate 'subsystem == "io.github.henpak.followspot"'
enum Log {
    static let subsystem = Bundle.main.bundleIdentifier ?? "io.github.henpak.followspot"
    private static let logger = Logger(subsystem: subsystem, category: "events")
    private static let enabled = UserDefaults.standard.bool(forKey: "debugLogging")

    static func event(_ message: @autoclosure () -> String) {
        guard enabled else { return }
        let text = message()
        logger.notice("\(text, privacy: .public)")
    }
}
