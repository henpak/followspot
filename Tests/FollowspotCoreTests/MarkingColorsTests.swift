import Foundation
import XCTest
@testable import FollowspotCore

final class PaletteColorTests: XCTestCase {

    func testPaletteHasEightColoursInMenuOrder() {
        XCTAssertEqual(PaletteColor.allCases.map(\.displayName),
                       ["Orange", "Yellow", "Red", "Pink", "Purple", "Blue", "Teal", "Green"])
    }

    func testIDsAndNamesAreUnique() {
        let ids = PaletteColor.allCases.map(\.id)
        let names = PaletteColor.allCases.map(\.displayName)
        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertEqual(Set(names).count, names.count)
    }

    func testIDsAreStable() {
        // Persisted values – must never change.
        XCTAssertEqual(PaletteColor.allCases.map(\.id),
                       ["orange", "yellow", "red", "pink", "purple", "blue", "teal", "green"])
    }

    func testColoursAreValidAndDistinct() {
        let values = PaletteColor.allCases.map(\.rgb)
        for v in values {
            for c in [v.red, v.green, v.blue] { XCTAssertTrue((0...1).contains(c)) }
        }
        XCTAssertEqual(Set(values.map { "\($0.red)-\($0.green)-\($0.blue)" }).count, values.count)
    }
}

final class MarkingColorsTests: XCTestCase {

    func testDefaults() {
        let c = MarkingColors()
        XCTAssertEqual(c.accent, .orange)
        XCTAssertEqual(c.rightClick, .blue)
    }

    func testValidStoredValues() {
        let c = MarkingColors(accentID: "teal", rightClickID: "pink")
        XCTAssertEqual(c.accent, .teal)
        XCTAssertEqual(c.rightClick, .pink)
    }

    func testUnknownOrMissingValuesFallBackToDefaults() {
        XCTAssertEqual(MarkingColors(accentID: "magenta", rightClickID: nil), MarkingColors())
        let c = MarkingColors(accentID: nil, rightClickID: "green")
        XCTAssertEqual(c.accent, .orange)
        XCTAssertEqual(c.rightClick, .green)
    }

    func testEqualStoredColoursKeepAccent() {
        let c = MarkingColors(accentID: "green", rightClickID: "green")
        XCTAssertEqual(c.accent, .green)
        XCTAssertEqual(c.rightClick, .blue)
    }

    func testEqualStoredBlueKeepsAccentAndMovesRightClick() {
        let c = MarkingColors(accentID: "blue", rightClickID: "blue")
        XCTAssertEqual(c.accent, .blue)
        XCTAssertNotEqual(c.rightClick, .blue)
        XCTAssertEqual(c.rightClick, .orange)
    }

    func testAccentBlueWithMissingRightClickAvoidsCollision() {
        let c = MarkingColors(accentID: "blue", rightClickID: nil)
        XCTAssertEqual(c.accent, .blue)
        XCTAssertNotEqual(c.rightClick, .blue)
    }

    func testSetAccent() {
        var c = MarkingColors()
        XCTAssertTrue(c.setAccent(.green))
        XCTAssertEqual(c.accent, .green)
    }

    func testCannotSetAccentToRightClickColour() {
        var c = MarkingColors()
        XCTAssertFalse(c.setAccent(.blue))
        XCTAssertEqual(c.accent, .orange)
    }

    func testCannotSetRightClickToAccentColour() {
        var c = MarkingColors()
        XCTAssertFalse(c.setRightClick(.orange))
        XCTAssertEqual(c.rightClick, .blue)
        XCTAssertTrue(c.setRightClick(.pink))
        XCTAssertEqual(c.rightClick, .pink)
    }

    func testIsSelectable() {
        let c = MarkingColors() // orange / blue
        XCTAssertFalse(c.isSelectable(.orange, forAccent: false), "accent colour is locked in the right-click menu")
        XCTAssertFalse(c.isSelectable(.blue, forAccent: true), "right-click colour is locked in the accent menu")
        XCTAssertTrue(c.isSelectable(.orange, forAccent: true), "current choice stays selectable")
        XCTAssertTrue(c.isSelectable(.green, forAccent: true))
        XCTAssertTrue(c.isSelectable(.green, forAccent: false))
    }

    func testInvariantHoldsForAllStoredCombinations() {
        let ids: [String?] = PaletteColor.allCases.map(\.id) + [nil, "unknown"]
        for a in ids {
            for r in ids {
                let c = MarkingColors(accentID: a, rightClickID: r)
                XCTAssertNotEqual(c.accent, c.rightClick, "accent=\(a ?? "nil") right=\(r ?? "nil")")
            }
        }
    }
}

final class ColorStoreTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "FollowspotCoreTests.ColorStore.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testMissingKeysGiveDefaults() {
        XCTAssertEqual(ColorStore(defaults: defaults).load(), MarkingColors())
    }

    func testRoundTrip() {
        let store = ColorStore(defaults: defaults)
        var colors = MarkingColors()
        colors.setAccent(.teal)
        colors.setRightClick(.pink)
        store.save(colors)
        XCTAssertEqual(ColorStore(defaults: defaults).load(), colors)
        XCTAssertEqual(defaults.string(forKey: ColorStore.accentKey), "teal")
        XCTAssertEqual(defaults.string(forKey: ColorStore.rightClickKey), "pink")
    }

    func testUnknownStoredValueFallsBackToDefault() {
        defaults.set("chartreuse", forKey: ColorStore.accentKey)
        defaults.set("green", forKey: ColorStore.rightClickKey)
        let colors = ColorStore(defaults: defaults).load()
        XCTAssertEqual(colors.accent, .orange)
        XCTAssertEqual(colors.rightClick, .green)
    }
}
