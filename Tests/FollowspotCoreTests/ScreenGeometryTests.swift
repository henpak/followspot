import CoreGraphics
import XCTest
@testable import FollowspotCore

final class ScreenGeometryTests: XCTestCase {

    // Built-in Retina display (1512x982 pt) as primary screen.
    let builtIn = CGRect(x: 0, y: 0, width: 1512, height: 982)
    // External QHD monitor to the right, slightly lower.
    let externalRight = CGRect(x: 1512, y: -200, width: 2560, height: 1440)
    // External QHD monitor to the left (negative origin).
    let externalLeft = CGRect(x: -2560, y: 0, width: 2560, height: 1440)

    func testLocalPointOnPrimaryScreenIsUnchanged() {
        let p = CGPoint(x: 100, y: 200)
        XCTAssertEqual(ScreenGeometry.localPoint(p, inScreenFrame: builtIn), p)
    }

    func testLocalPointOnScreenToTheRightWithNegativeY() {
        let global = CGPoint(x: 1600, y: -150)
        XCTAssertEqual(ScreenGeometry.localPoint(global, inScreenFrame: externalRight), CGPoint(x: 88, y: 50))
    }

    func testLocalPointOnScreenWithNegativeX() {
        let global = CGPoint(x: -2500, y: 1000)
        XCTAssertEqual(ScreenGeometry.localPoint(global, inScreenFrame: externalLeft), CGPoint(x: 60, y: 1000))
    }

    func testLocalAndGlobalRoundTrip() {
        let global = CGPoint(x: 3000, y: 1100)
        let local = ScreenGeometry.localPoint(global, inScreenFrame: externalRight)
        XCTAssertEqual(ScreenGeometry.globalPoint(local, inScreenFrame: externalRight), global)
    }

    func testScreenIndexFindsCorrectScreen() {
        let frames = [builtIn, externalRight]
        XCTAssertEqual(ScreenGeometry.screenIndex(containing: CGPoint(x: 700, y: 500), frames: frames), 0)
        XCTAssertEqual(ScreenGeometry.screenIndex(containing: CGPoint(x: 2000, y: -100), frames: frames), 1)
    }

    func testScreenIndexWithNegativeOrigin() {
        let frames = [builtIn, externalLeft]
        XCTAssertEqual(ScreenGeometry.screenIndex(containing: CGPoint(x: -1, y: 500), frames: frames), 1)
        XCTAssertEqual(ScreenGeometry.screenIndex(containing: CGPoint(x: 0, y: 500), frames: frames), 0)
    }

    func testTopEdgeBelongsToScreen() {
        // The mouse at the very top of a screen reports y == maxY.
        XCTAssertTrue(ScreenGeometry.contains(builtIn, CGPoint(x: 10, y: 982)))
        XCTAssertFalse(ScreenGeometry.contains(builtIn, CGPoint(x: 10, y: 0)))
        XCTAssertFalse(ScreenGeometry.contains(builtIn, CGPoint(x: 1512, y: 10)))
    }

    func testPointInGapFallsBackToNearestScreen() {
        // Above the built-in display, but the external one reaches higher: gap at x=100, y=1200.
        let frames = [builtIn, externalRight]
        XCTAssertEqual(ScreenGeometry.screenIndex(containing: CGPoint(x: 100, y: 1200), frames: frames), 0)
        XCTAssertEqual(ScreenGeometry.screenIndex(containing: CGPoint(x: 1500, y: 1200), frames: frames), 1)
    }

    func testScreenIndexWithoutScreens() {
        XCTAssertNil(ScreenGeometry.screenIndex(containing: .zero, frames: []))
    }

    func testRectIsNormalisedForAnyDragDirection() {
        let bounds = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let expected = CGRect(x: 100, y: 100, width: 200, height: 300)
        XCTAssertEqual(ScreenGeometry.rect(from: CGPoint(x: 100, y: 100), to: CGPoint(x: 300, y: 400), clampedTo: bounds), expected)
        XCTAssertEqual(ScreenGeometry.rect(from: CGPoint(x: 300, y: 400), to: CGPoint(x: 100, y: 100), clampedTo: bounds), expected)
        XCTAssertEqual(ScreenGeometry.rect(from: CGPoint(x: 300, y: 100), to: CGPoint(x: 100, y: 400), clampedTo: bounds), expected)
    }

    func testRectIsClampedToStartScreen() {
        // Dragging past the right edge onto another screen stays on the start screen.
        let bounds = CGRect(x: 0, y: 0, width: 1512, height: 982)
        let r = ScreenGeometry.rect(from: CGPoint(x: 1400, y: 500), to: CGPoint(x: 1800, y: 1100), clampedTo: bounds)
        XCTAssertEqual(r, CGRect(x: 1400, y: 500, width: 112, height: 482))
    }

    func testRectCompletelyOutsideIsZero() {
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        XCTAssertEqual(ScreenGeometry.rect(from: CGPoint(x: 200, y: 200), to: CGPoint(x: 300, y: 300), clampedTo: bounds), .zero)
    }
}
