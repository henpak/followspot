import XCTest
@testable import FollowspotCore

final class ClickKindTests: XCTestCase {

    func testPrimaryButtonIsLeftClick() {
        XCTAssertEqual(ClickKind.classify(buttonNumber: 0, controlPressed: false), .left)
    }

    func testCtrlPrimaryButtonIsRightClick() {
        XCTAssertEqual(ClickKind.classify(buttonNumber: 0, controlPressed: true), .right)
    }

    func testSecondaryButtonIsRightClick() {
        XCTAssertEqual(ClickKind.classify(buttonNumber: 1, controlPressed: false), .right)
        XCTAssertEqual(ClickKind.classify(buttonNumber: 1, controlPressed: true), .right)
    }

    func testOtherButtons() {
        XCTAssertEqual(ClickKind.classify(buttonNumber: 2, controlPressed: false), .other)
        XCTAssertEqual(ClickKind.classify(buttonNumber: 4, controlPressed: false), .other)
    }
}
