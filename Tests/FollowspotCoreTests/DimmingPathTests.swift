import CoreGraphics
import XCTest
@testable import FollowspotCore

final class DimmingPathTests: XCTestCase {

    let bounds = CGRect(x: 0, y: 0, width: 1000, height: 800)

    private func isDimmed(_ path: CGPath, _ point: CGPoint) -> Bool {
        path.contains(point, using: .evenOdd)
    }

    func testWithoutCutoutEverythingIsDimmed() {
        let path = DimmingPath.make(bounds: bounds, cutout: nil)
        XCTAssertTrue(isDimmed(path, CGPoint(x: 10, y: 10)))
        XCTAssertTrue(isDimmed(path, CGPoint(x: 500, y: 400)))
    }

    func testRectCutoutStaysBright() {
        let path = DimmingPath.make(bounds: bounds, cutout: .rect(CGRect(x: 100, y: 100, width: 300, height: 200), cornerRadius: 6))
        XCTAssertFalse(isDimmed(path, CGPoint(x: 250, y: 200)), "inside the highlight must stay bright")
        XCTAssertTrue(isDimmed(path, CGPoint(x: 50, y: 50)), "outside the highlight is dimmed")
        XCTAssertTrue(isDimmed(path, CGPoint(x: 600, y: 600)))
    }

    func testCircleCutoutStaysBright() {
        let path = DimmingPath.make(bounds: bounds, cutout: .circle(center: CGPoint(x: 500, y: 400), radius: 120))
        XCTAssertFalse(isDimmed(path, CGPoint(x: 500, y: 400)))
        XCTAssertFalse(isDimmed(path, CGPoint(x: 600, y: 400)))
        XCTAssertTrue(isDimmed(path, CGPoint(x: 630, y: 400)), "just outside the radius")
        XCTAssertTrue(isDimmed(path, CGPoint(x: 10, y: 10)))
    }

    func testEmptyRectCutoutIsIgnored() {
        let path = DimmingPath.make(bounds: bounds, cutout: .rect(.zero, cornerRadius: 6))
        XCTAssertTrue(isDimmed(path, CGPoint(x: 1, y: 1)))
    }

    func testOversizedCornerRadiusDoesNotCrash() {
        let path = DimmingPath.make(bounds: bounds, cutout: .rect(CGRect(x: 100, y: 100, width: 10, height: 10), cornerRadius: 50))
        XCTAssertFalse(isDimmed(path, CGPoint(x: 105, y: 105)))
    }
}
