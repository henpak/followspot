import Foundation

/// Persists `MarkingColors` as palette IDs in `UserDefaults` (design.md, Decision 3).
public struct ColorStore {
    public static let accentKey = "accentColor"
    public static let rightClickKey = "rightClickColor"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Loads the stored colours; missing or unknown values fall back to the defaults.
    public func load() -> MarkingColors {
        MarkingColors(accentID: defaults.string(forKey: Self.accentKey),
                      rightClickID: defaults.string(forKey: Self.rightClickKey))
    }

    public func save(_ colors: MarkingColors) {
        defaults.set(colors.accent.id, forKey: Self.accentKey)
        defaults.set(colors.rightClick.id, forKey: Self.rightClickKey)
    }
}
