import CoreGraphics

/// The area that stays bright inside a dimmed screen.
public enum Cutout: Equatable, Sendable {
    case rect(CGRect, cornerRadius: CGFloat)
    case circle(center: CGPoint, radius: CGFloat)
}

/// Builds the path for a dimming layer: the full screen minus an optional cutout.
/// The path is meant to be filled with the even-odd rule.
public enum DimmingPath {

    public static func make(bounds: CGRect, cutout: Cutout?) -> CGPath {
        let path = CGMutablePath()
        path.addRect(bounds)

        switch cutout {
        case let .rect(rect, cornerRadius)?:
            let r = rect.standardized
            guard r.width > 0, r.height > 0 else { break }
            let radius = max(0, min(cornerRadius, r.width / 2, r.height / 2))
            if radius > 0 {
                path.addRoundedRect(in: r, cornerWidth: radius, cornerHeight: radius)
            } else {
                path.addRect(r)
            }
        case let .circle(center, radius)?:
            guard radius > 0 else { break }
            path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                       width: radius * 2, height: radius * 2))
        case nil:
            break
        }
        return path
    }
}
