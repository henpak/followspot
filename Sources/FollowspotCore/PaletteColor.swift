/// An sRGB colour value (components 0...1), independent of AppKit.
public struct RGB: Equatable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double

    public init(_ red: Double, _ green: Double, _ blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

/// The fixed palette of marking colours (spec marking-colors: Farbpalette).
///
/// The raw value is the stable ID that is persisted – names and tones may be
/// adjusted later without invalidating stored settings (design.md, Decision 1).
public enum PaletteColor: String, CaseIterable, Sendable {
    case orange
    case yellow
    case red
    case pink
    case purple
    case blue
    case teal
    case green

    public var id: String { rawValue }

    /// Display name for the menu.
    public var displayName: String {
        switch self {
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .red: return "Red"
        case .pink: return "Pink"
        case .purple: return "Purple"
        case .blue: return "Blue"
        case .teal: return "Teal"
        case .green: return "Green"
        }
    }

    public var rgb: RGB {
        switch self {
        case .orange: return RGB(1.00, 0.60, 0.00)
        case .yellow: return RGB(1.00, 0.80, 0.00)
        case .red: return RGB(1.00, 0.23, 0.19)
        case .pink: return RGB(1.00, 0.18, 0.57)
        case .purple: return RGB(0.69, 0.32, 0.87)
        case .blue: return RGB(0.18, 0.55, 1.00)
        case .teal: return RGB(0.00, 0.78, 0.80)
        case .green: return RGB(0.20, 0.80, 0.35)
        }
    }
}
