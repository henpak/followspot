/// The two user-selectable marking colours (design.md, Decision 2).
///
/// Invariant: `accent != rightClick`, so left and right clicks always stay distinguishable.
public struct MarkingColors: Equatable, Sendable {
    public static let defaultAccent: PaletteColor = .orange
    public static let defaultRightClick: PaletteColor = .blue

    /// Linksklick-Ring, Halo, Highlight-Rahmen, Fadenkreuz, Auswahlrechteck.
    public private(set) var accent: PaletteColor
    /// Rechtsklick-Ring.
    public private(set) var rightClick: PaletteColor

    public init() {
        self.init(accentID: nil, rightClickID: nil)
    }

    /// Builds colours from stored IDs. Unknown or missing IDs fall back to the defaults;
    /// if both end up equal, the accent wins and the right-click colour moves aside.
    public init(accentID: String?, rightClickID: String?) {
        let accent = accentID.flatMap(PaletteColor.init(rawValue:)) ?? Self.defaultAccent
        var rightClick = rightClickID.flatMap(PaletteColor.init(rawValue:)) ?? Self.defaultRightClick
        if rightClick == accent {
            rightClick = Self.alternative(to: accent)
        }
        self.accent = accent
        self.rightClick = rightClick
    }

    /// Whether `color` may be chosen for the given setting (it must not be used by the other one).
    public func isSelectable(_ color: PaletteColor, forAccent: Bool) -> Bool {
        forAccent ? color != rightClick : color != accent
    }

    /// Sets the accent colour. Returns false (and changes nothing) if the right-click colour uses it.
    @discardableResult
    public mutating func setAccent(_ color: PaletteColor) -> Bool {
        guard isSelectable(color, forAccent: true) else { return false }
        accent = color
        return true
    }

    /// Sets the right-click colour. Returns false (and changes nothing) if the accent uses it.
    @discardableResult
    public mutating func setRightClick(_ color: PaletteColor) -> Bool {
        guard isSelectable(color, forAccent: false) else { return false }
        rightClick = color
        return true
    }

    /// Right-click colour to use when it would collide with `accent`:
    /// the default right-click colour, or else the first other palette colour.
    static func alternative(to accent: PaletteColor) -> PaletteColor {
        if accent != defaultRightClick { return defaultRightClick }
        return PaletteColor.allCases.first { $0 != accent }!
    }
}
