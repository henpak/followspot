import CoreGraphics

/// Coordinate helpers for working with several screens.
///
/// All "global" values use Cocoa's global screen space: origin at the bottom-left
/// corner of the primary screen, y growing upwards. Other screens can have negative
/// origins (left of / below the primary screen). "Local" values are relative to the
/// bottom-left corner of one screen, which is what an overlay window covering that
/// screen uses.
public enum ScreenGeometry {

    /// Converts a global point into the local space of the screen with `screenFrame`.
    public static func localPoint(_ global: CGPoint, inScreenFrame screenFrame: CGRect) -> CGPoint {
        CGPoint(x: global.x - screenFrame.minX, y: global.y - screenFrame.minY)
    }

    /// Converts a point that is local to the screen with `screenFrame` back to global space.
    public static func globalPoint(_ local: CGPoint, inScreenFrame screenFrame: CGRect) -> CGPoint {
        CGPoint(x: local.x + screenFrame.minX, y: local.y + screenFrame.minY)
    }

    /// Whether `point` lies on the screen with `frame`.
    ///
    /// Mirrors `NSMouseInRect(_:_:false)` for unflipped coordinates: x in [minX, maxX),
    /// y in (minY, maxY]. This matters at the very top edge of a screen, where the mouse
    /// location reports `y == maxY`.
    public static func contains(_ frame: CGRect, _ point: CGPoint) -> Bool {
        point.x >= frame.minX && point.x < frame.maxX && point.y > frame.minY && point.y <= frame.maxY
    }

    /// Index of the screen frame containing `point`; falls back to the nearest screen
    /// when the point lies in a gap between screens. Returns nil only for no screens.
    public static func screenIndex(containing point: CGPoint, frames: [CGRect]) -> Int? {
        if let exact = frames.firstIndex(where: { contains($0, point) }) {
            return exact
        }
        return frames.indices.min { distance(from: point, to: frames[$0]) < distance(from: point, to: frames[$1]) }
    }

    /// Normalised rectangle spanned by two points, clamped to `bounds`.
    /// Returns `.zero` if the rectangle lies completely outside `bounds`.
    public static func rect(from a: CGPoint, to b: CGPoint, clampedTo bounds: CGRect) -> CGRect {
        let raw = CGRect(x: min(a.x, b.x), y: min(a.y, b.y), width: abs(a.x - b.x), height: abs(a.y - b.y))
        let clamped = raw.intersection(bounds)
        return clamped.isNull ? .zero : clamped
    }

    static func distance(from p: CGPoint, to r: CGRect) -> CGFloat {
        let dx = max(r.minX - p.x, 0, p.x - r.maxX)
        let dy = max(r.minY - p.y, 0, p.y - r.maxY)
        return (dx * dx + dy * dy).squareRoot()
    }
}
