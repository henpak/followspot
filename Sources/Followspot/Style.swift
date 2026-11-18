import AppKit
import FollowspotCore

/// Visual constants (add-presenter-overlay design.md, Decision 9). Sizes and durations are
/// fixed; marking colours are derived from the user's palette choice
/// (add-marking-colors design.md, Decision 5).
enum Style {
    // Click rings
    struct RingMetrics: Equatable {
        let startRadius: CGFloat
        let endRadius: CGFloat
        let lineWidth: CGFloat
    }

    /// Ring sizes per level (add-marking-colors design.md, Decision 8; medium = original values).
    static func ring(_ size: MarkingSize) -> RingMetrics {
        switch size {
        case .small: return RingMetrics(startRadius: 12, endRadius: 20, lineWidth: 3)
        case .medium: return RingMetrics(startRadius: 18, endRadius: 30, lineWidth: 4)
        case .large: return RingMetrics(startRadius: 26, endRadius: 44, lineWidth: 5)
        }
    }

    static let ringDuration: CFTimeInterval = 0.4
    static let ringFillAlpha: CGFloat = 0.18
    /// Clicks with further mouse buttons – not user-selectable.
    static let otherClickColor = NSColor(srgbRed: 0.25, green: 0.85, blue: 0.45, alpha: 1)

    // Cursor halo
    static func haloRadius(_ size: MarkingSize) -> CGFloat {
        switch size {
        case .small: return 20
        case .medium: return 28
        case .large: return 40
        }
    }
    static let haloLineWidth: CGFloat = 2
    static func haloFill(_ accent: PaletteColor) -> NSColor { color(accent, alpha: 0.28) }
    static func haloStroke(_ accent: PaletteColor) -> NSColor { color(accent, alpha: 0.75) }

    // Dimming (spotlight + rectangle highlight)
    static func dimColor(_ level: DimLevel) -> NSColor {
        NSColor(white: 0, alpha: CGFloat(level.opacity))
    }

    static func spotlightRadius(_ size: MarkingSize) -> CGFloat {
        switch size {
        case .small: return 80
        case .medium: return 120
        case .large: return 180
        }
    }

    // Rectangle highlight
    static let highlightBorderWidth: CGFloat = 3
    static let highlightCornerRadius: CGFloat = 6
    static func highlightBorder(_ accent: PaletteColor) -> NSColor { color(accent) }

    // Selection mode
    static let crosshairLineWidth: CGFloat = 1
    static let selectionLineWidth: CGFloat = 2
    static func crosshair(_ accent: PaletteColor) -> NSColor { color(accent, alpha: 0.8) }
    static func selectionStroke(_ accent: PaletteColor) -> NSColor { color(accent) }
    static func selectionFill(_ accent: PaletteColor) -> NSColor { color(accent, alpha: 0.08) }

    /// Fully opaque (or given alpha) sRGB colour of a palette entry.
    static func color(_ palette: PaletteColor, alpha: CGFloat = 1) -> NSColor {
        let rgb = palette.rgb
        return NSColor(srgbRed: rgb.red, green: rgb.green, blue: rgb.blue, alpha: alpha)
    }
    /// Practically invisible, but makes sure the overlay receives the mouse everywhere while selecting.
    static let selectionCatcherColor = NSColor(white: 0, alpha: 0.005)
}
