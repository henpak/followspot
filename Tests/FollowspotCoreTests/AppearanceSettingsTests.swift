import Foundation
import XCTest
@testable import FollowspotCore

final class MarkingSizeTests: XCTestCase {

    func testThreeLevelsInMenuOrder() {
        XCTAssertEqual(MarkingSize.allCases.map(\.displayName), ["Small", "Medium", "Large"])
    }

    func testIDsAreStable() {
        // Persisted values – must never change.
        XCTAssertEqual(MarkingSize.allCases.map(\.id), ["small", "medium", "large"])
    }
}

final class DimLevelTests: XCTestCase {

    func testThreeLevelsInMenuOrder() {
        XCTAssertEqual(DimLevel.allCases.map(\.displayName), ["Light", "Medium", "Strong"])
        XCTAssertEqual(DimLevel.allCases.map(\.id), ["light", "medium", "strong"])
    }

    func testOpacities() {
        XCTAssertEqual(DimLevel.light.opacity, 0.25)
        XCTAssertEqual(DimLevel.medium.opacity, 0.40, "medium equals the previous fixed 40 %")
        XCTAssertEqual(DimLevel.strong.opacity, 0.60)
    }
}

final class AppearanceSettingsTests: XCTestCase {

    func testDefaults() {
        let s = AppearanceSettings()
        XCTAssertEqual(s.clickRingSize, .medium)
        XCTAssertEqual(s.haloSize, .medium)
        XCTAssertEqual(s.spotlightSize, .medium)
        XCTAssertEqual(s.highlightDimming, .medium)
        XCTAssertEqual(s.spotlightDimming, .medium)
        XCTAssertTrue(s.showsSelectionGuides)
    }

    func testDimmingFromStoredValues() {
        let s = AppearanceSettings(clickRingSizeID: nil, haloSizeID: nil, spotlightSizeID: nil,
                                   highlightDimmingID: "strong", spotlightDimmingID: "nope",
                                   showsSelectionGuides: nil)
        XCTAssertEqual(s.highlightDimming, .strong)
        XCTAssertEqual(s.spotlightDimming, .medium, "unknown value falls back to medium")
    }

    func testDimmingSettingsAreIndependent() {
        var s = AppearanceSettings()
        s.spotlightDimming = .light
        XCTAssertEqual(s.spotlightDimming, .light)
        XCTAssertEqual(s.highlightDimming, .medium)
    }

    func testStoredValues() {
        let s = AppearanceSettings(clickRingSizeID: "small", haloSizeID: "large", spotlightSizeID: "small", showsSelectionGuides: false)
        XCTAssertEqual(s.clickRingSize, .small)
        XCTAssertEqual(s.haloSize, .large)
        XCTAssertEqual(s.spotlightSize, .small)
        XCTAssertFalse(s.showsSelectionGuides)
    }

    func testUnknownOrMissingValuesFallBackToDefaults() {
        let s = AppearanceSettings(clickRingSizeID: "huge", haloSizeID: nil, spotlightSizeID: "", showsSelectionGuides: nil)
        XCTAssertEqual(s, AppearanceSettings())
    }

    func testSizesAreIndependent() {
        var s = AppearanceSettings()
        s.clickRingSize = .small
        s.haloSize = .large
        XCTAssertEqual(s.clickRingSize, .small)
        XCTAssertEqual(s.haloSize, .large)
        XCTAssertEqual(s.spotlightSize, .medium)
    }
}

final class AppearanceStoreTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "FollowspotCoreTests.AppearanceStore.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testMissingKeysGiveDefaults() {
        let s = AppearanceStore(defaults: defaults).load()
        XCTAssertEqual(s, AppearanceSettings())
        XCTAssertTrue(s.showsSelectionGuides, "missing switch means guides on")
    }

    func testRoundTrip() {
        var s = AppearanceSettings()
        s.clickRingSize = .large
        s.haloSize = .small
        s.spotlightSize = .small
        s.highlightDimming = .strong
        s.spotlightDimming = .light
        s.showsSelectionGuides = false
        AppearanceStore(defaults: defaults).save(s)
        XCTAssertEqual(AppearanceStore(defaults: defaults).load(), s)
        XCTAssertEqual(defaults.string(forKey: AppearanceStore.clickRingSizeKey), "large")
        XCTAssertEqual(defaults.string(forKey: AppearanceStore.highlightDimmingKey), "strong")
        XCTAssertEqual(defaults.string(forKey: AppearanceStore.spotlightDimmingKey), "light")
        XCTAssertEqual(defaults.object(forKey: AppearanceStore.showsSelectionGuidesKey) as? Bool, false)
    }

    func testUnknownStoredValueFallsBackToMedium() {
        defaults.set("gigantic", forKey: AppearanceStore.clickRingSizeKey)
        defaults.set("small", forKey: AppearanceStore.haloSizeKey)
        let s = AppearanceStore(defaults: defaults).load()
        XCTAssertEqual(s.clickRingSize, .medium)
        XCTAssertEqual(s.haloSize, .small)
    }
}
