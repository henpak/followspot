import CoreGraphics
import XCTest
@testable import FollowspotCore

final class OverlayStateTests: XCTestCase {

    let rect = CGRect(x: 10, y: 20, width: 300, height: 200)

    func testDefaults() {
        let s = OverlayState()
        XCTAssertTrue(s.clickRingsEnabled, "click rings are on at launch")
        XCTAssertFalse(s.haloEnabled, "halo is off at launch")
        XCTAssertFalse(s.spotlightEnabled)
        XCTAssertEqual(s.mode, .normal)
        XCTAssertNil(s.highlight)
        XCTAssertFalse(s.isHighlightActive)
    }

    func testOneShotSelectionCreatesHighlightAndReturnsToNormal() {
        var s = OverlayState()
        s.beginSelection()
        XCTAssertEqual(s.mode, .selecting)
        XCTAssertTrue(s.isHighlightActive)
        s.finishSelection(rect: rect, displayID: 7)
        XCTAssertEqual(s.mode, .normal)
        XCTAssertEqual(s.highlight, Highlight(rect: rect, displayID: 7))
        XCTAssertTrue(s.isHighlightActive)
    }

    func testClickWithoutDragCreatesNoHighlight() {
        var s = OverlayState()
        s.beginSelection()
        s.finishSelection(rect: CGRect(x: 10, y: 10, width: 1, height: 0), displayID: 1)
        XCTAssertEqual(s.mode, .normal)
        XCTAssertNil(s.highlight)
        XCTAssertFalse(s.isHighlightActive)
    }

    func testThinDragCreatesNoHighlight() {
        var s = OverlayState()
        s.beginSelection()
        s.finishSelection(rect: CGRect(x: 10, y: 10, width: 300, height: 2), displayID: 1)
        XCTAssertNil(s.highlight)
    }

    func testFinishWithoutSelectingIsIgnored() {
        var s = OverlayState()
        s.finishSelection(rect: rect, displayID: 1)
        XCTAssertNil(s.highlight)
    }

    // MARK: Highlight hotkey toggles (replace-escape-with-toggle-hotkeys)

    func testToggleStartsSelectionWhenNothingIsActive() {
        var s = OverlayState()
        s.toggleSelection()
        XCTAssertEqual(s.mode, .selecting)
    }

    func testToggleCancelsRunningSelection() {
        var s = OverlayState()
        s.toggleSelection()
        s.toggleSelection()
        XCTAssertEqual(s.mode, .normal)
        XCTAssertNil(s.highlight)
        XCTAssertFalse(s.isHighlightActive)
    }

    func testToggleRemovesHighlightWithoutStartingNewSelection() {
        var s = OverlayState()
        s.toggleSelection()
        s.finishSelection(rect: rect, displayID: 1)
        s.toggleSelection()
        XCTAssertNil(s.highlight)
        XCTAssertEqual(s.mode, .normal, "removing the highlight must not start a new selection")
        s.toggleSelection()
        XCTAssertEqual(s.mode, .selecting, "pressing again starts a new selection")
    }

    func testToggleHighlightKeepsHaloSpotlightAndClickRings() {
        // Bug report: Esc after a highlight also switched the halo off.
        var s = OverlayState()
        s.toggleHalo()
        s.toggleSpotlight()
        s.toggleSelection()
        s.finishSelection(rect: rect, displayID: 1)
        s.toggleSelection()
        XCTAssertNil(s.highlight)
        XCTAssertTrue(s.haloEnabled)
        XCTAssertTrue(s.spotlightEnabled)
        XCTAssertTrue(s.clickRingsEnabled)
    }

    func testHaloAndSpotlightDoNotActivateHighlight() {
        var s = OverlayState()
        s.toggleHalo()
        s.toggleSpotlight()
        XCTAssertFalse(s.isHighlightActive)
    }

    func testCancelSelection() {
        var s = OverlayState()
        s.beginSelection()
        s.cancelSelection()
        XCTAssertEqual(s.mode, .normal)
        XCTAssertNil(s.highlight)
    }

    func testGlobalClickRemovesHighlight() {
        var s = OverlayState()
        s.beginSelection()
        s.finishSelection(rect: rect, displayID: 1)
        s.registerGlobalClick()
        XCTAssertNil(s.highlight)
        XCTAssertFalse(s.isHighlightActive)
    }

    func testGlobalClickKeepsHalo() {
        var s = OverlayState()
        s.toggleHalo()
        s.beginSelection()
        s.finishSelection(rect: rect, displayID: 1)
        s.registerGlobalClick()
        XCTAssertNil(s.highlight)
        XCTAssertTrue(s.haloEnabled)
    }

    func testGlobalClickDuringSelectionIsIgnored() {
        var s = OverlayState()
        s.beginSelection()
        s.registerGlobalClick()
        XCTAssertEqual(s.mode, .selecting)
    }

    func testNewSelectionReplacesHighlight() {
        var s = OverlayState()
        s.beginSelection()
        s.finishSelection(rect: rect, displayID: 1)
        s.beginSelection()
        XCTAssertNil(s.highlight, "old highlight is removed when a new selection starts")
        XCTAssertEqual(s.mode, .selecting)
        let other = CGRect(x: 500, y: 500, width: 50, height: 50)
        s.finishSelection(rect: other, displayID: 2)
        XCTAssertEqual(s.highlight, Highlight(rect: other, displayID: 2))
    }

    func testClearAllRemovesMarkingsButKeepsClickRings() {
        var s = OverlayState()
        s.toggleSpotlight()
        s.toggleHalo()
        s.beginSelection()
        s.finishSelection(rect: rect, displayID: 1)
        s.clearAll()
        XCTAssertFalse(s.spotlightEnabled)
        XCTAssertFalse(s.haloEnabled)
        XCTAssertNil(s.highlight)
        XCTAssertEqual(s.mode, .normal)
        XCTAssertTrue(s.clickRingsEnabled)
    }

    func testDisplayRemovalDropsHighlight() {
        var s = OverlayState()
        s.beginSelection()
        s.finishSelection(rect: rect, displayID: 2)
        s.displaysChanged(available: [1, 2])
        XCTAssertNotNil(s.highlight)
        s.displaysChanged(available: [1])
        XCTAssertNil(s.highlight)
    }
}
