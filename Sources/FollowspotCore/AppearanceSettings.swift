import Foundation

/// Size levels for click ring, halo and spotlight (spec marking-appearance: Größenstufen).
/// The raw value is the persisted ID; concrete point sizes live in the app's `Style`.
public enum MarkingSize: String, CaseIterable, Sendable {
    case small
    case medium
    case large

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
}

/// How strongly the area outside a highlight / spotlight is darkened
/// (spec marking-appearance: Abdunklungsstärke).
public enum DimLevel: String, CaseIterable, Sendable {
    case light
    case medium
    case strong

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }

    /// Opacity of the black dimming layer.
    public var opacity: Double {
        switch self {
        case .light: return 0.25
        case .medium: return 0.40
        case .strong: return 0.60
        }
    }
}

/// User-adjustable sizes, dimming levels and the selection-guides switch (design.md, Decisions 7 and 8a).
public struct AppearanceSettings: Equatable, Sendable {
    public static let defaultSize: MarkingSize = .medium
    public static let defaultDimming: DimLevel = .medium
    public static let defaultShowsSelectionGuides = true

    public var clickRingSize: MarkingSize
    public var haloSize: MarkingSize
    public var spotlightSize: MarkingSize
    public var highlightDimming: DimLevel
    public var spotlightDimming: DimLevel
    /// Crosshair lines across the screen while drawing a rectangle.
    public var showsSelectionGuides: Bool

    public init() {
        self.init(clickRingSizeID: nil, haloSizeID: nil, spotlightSizeID: nil,
                  highlightDimmingID: nil, spotlightDimmingID: nil, showsSelectionGuides: nil)
    }

    /// Builds settings from stored values; missing or unknown values fall back to the defaults.
    public init(clickRingSizeID: String?, haloSizeID: String?, spotlightSizeID: String?,
                highlightDimmingID: String? = nil, spotlightDimmingID: String? = nil,
                showsSelectionGuides: Bool?) {
        self.clickRingSize = Self.size(clickRingSizeID)
        self.haloSize = Self.size(haloSizeID)
        self.spotlightSize = Self.size(spotlightSizeID)
        self.highlightDimming = Self.dimming(highlightDimmingID)
        self.spotlightDimming = Self.dimming(spotlightDimmingID)
        self.showsSelectionGuides = showsSelectionGuides ?? Self.defaultShowsSelectionGuides
    }

    private static func size(_ id: String?) -> MarkingSize {
        id.flatMap(MarkingSize.init(rawValue:)) ?? defaultSize
    }

    private static func dimming(_ id: String?) -> DimLevel {
        id.flatMap(DimLevel.init(rawValue:)) ?? defaultDimming
    }
}

/// Persists `AppearanceSettings` in `UserDefaults` (design.md, Decision 7).
public struct AppearanceStore {
    public static let clickRingSizeKey = "clickRingSize"
    public static let haloSizeKey = "haloSize"
    public static let spotlightSizeKey = "spotlightSize"
    public static let highlightDimmingKey = "highlightDimming"
    public static let spotlightDimmingKey = "spotlightDimming"
    public static let showsSelectionGuidesKey = "showsSelectionGuides"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> AppearanceSettings {
        // `bool(forKey:)` returns false for a missing key, so check for presence explicitly.
        let guides = defaults.object(forKey: Self.showsSelectionGuidesKey) as? Bool
        return AppearanceSettings(clickRingSizeID: defaults.string(forKey: Self.clickRingSizeKey),
                                  haloSizeID: defaults.string(forKey: Self.haloSizeKey),
                                  spotlightSizeID: defaults.string(forKey: Self.spotlightSizeKey),
                                  highlightDimmingID: defaults.string(forKey: Self.highlightDimmingKey),
                                  spotlightDimmingID: defaults.string(forKey: Self.spotlightDimmingKey),
                                  showsSelectionGuides: guides)
    }

    public func save(_ settings: AppearanceSettings) {
        defaults.set(settings.clickRingSize.id, forKey: Self.clickRingSizeKey)
        defaults.set(settings.haloSize.id, forKey: Self.haloSizeKey)
        defaults.set(settings.spotlightSize.id, forKey: Self.spotlightSizeKey)
        defaults.set(settings.highlightDimming.id, forKey: Self.highlightDimmingKey)
        defaults.set(settings.spotlightDimming.id, forKey: Self.spotlightDimmingKey)
        defaults.set(settings.showsSelectionGuides, forKey: Self.showsSelectionGuidesKey)
    }
}
