import AppKit
import FollowspotCore

@main
enum FollowspotApp {
    @MainActor
    static func main() {
        // Take over settings from the former "Presenter" app before any store loads them.
        let legacy = UserDefaults.standard.persistentDomain(forName: SettingsMigration.legacyDomain)
        let copied = SettingsMigration.migrate(legacy: legacy, into: .standard)
        if !copied.isEmpty {
            Log.event("migrated settings from \(SettingsMigration.legacyDomain): \(copied)")
        }

        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        // Menu bar only: no Dock icon, no main window (also set via LSUIElement in Info.plist,
        // this line makes `swift run` behave the same).
        app.setActivationPolicy(.accessory)
        withExtendedLifetime(delegate) {
            app.run()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let controller = OverlayController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        controller.stop()
    }
}
