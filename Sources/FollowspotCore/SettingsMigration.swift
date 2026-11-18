import Foundation

/// One-time takeover of settings from the app's former name "Presenter"
/// (publish-followspot design.md, Decision 4).
public enum SettingsMigration {
    /// UserDefaults domain used before the app was renamed to Followspot.
    public static let legacyDomain = "local.presenter.app"

    /// Set once the migration has run, so it never runs again.
    public static let doneKey = "migratedFromLegacyDomain"

    /// All persisted settings keys.
    public static let keys: [String] = [
        ColorStore.accentKey,
        ColorStore.rightClickKey,
        AppearanceStore.clickRingSizeKey,
        AppearanceStore.haloSizeKey,
        AppearanceStore.spotlightSizeKey,
        AppearanceStore.highlightDimmingKey,
        AppearanceStore.spotlightDimmingKey,
        AppearanceStore.showsSelectionGuidesKey,
        "debugLogging",
    ]

    /// Copies known keys from `legacy` that `defaults` does not have yet. Runs at most once;
    /// the legacy domain itself is left untouched.
    /// - Returns: the keys that were copied.
    @discardableResult
    public static func migrate(legacy: [String: Any]?, into defaults: UserDefaults) -> [String] {
        guard !defaults.bool(forKey: doneKey) else { return [] }
        var copied: [String] = []
        for key in keys {
            guard let value = legacy?[key], defaults.object(forKey: key) == nil else { continue }
            defaults.set(value, forKey: key)
            copied.append(key)
        }
        defaults.set(true, forKey: doneKey)
        return copied
    }
}
