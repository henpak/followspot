/// Which kind of click a mouse-down represents, for colouring click rings.
public enum ClickKind: Equatable, Sendable {
    case left
    case right
    case other

    /// - Parameters:
    ///   - buttonNumber: `NSEvent.buttonNumber` (0 = primary, 1 = secondary, 2+ = other).
    ///   - controlPressed: whether ctrl was held; ctrl + primary click is a right click on macOS.
    public static func classify(buttonNumber: Int, controlPressed: Bool) -> ClickKind {
        switch buttonNumber {
        case 0: return controlPressed ? .right : .left
        case 1: return .right
        default: return .other
        }
    }
}
