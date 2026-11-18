import XCTest
@testable import FollowspotCore

final class SettingsMigrationTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "FollowspotCoreTests.SettingsMigration.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testCopiesKnownKeys() {
        let legacy: [String: Any] = [
            "accentColor": "teal",
            "haloSize": "large",
            "showsSelectionGuides": false,
            "unrelated": "ignored",
        ]
        let copied = SettingsMigration.migrate(legacy: legacy, into: defaults)
        XCTAssertEqual(Set(copied), ["accentColor", "haloSize", "showsSelectionGuides"])
        XCTAssertEqual(ColorStore(defaults: defaults).load().accent, .teal)
        let appearance = AppearanceStore(defaults: defaults).load()
        XCTAssertEqual(appearance.haloSize, .large)
        XCTAssertFalse(appearance.showsSelectionGuides)
        XCTAssertNil(defaults.object(forKey: "unrelated"))
    }

    func testDoesNotOverwriteExistingValues() {
        defaults.set("green", forKey: "accentColor")
        SettingsMigration.migrate(legacy: ["accentColor": "teal"], into: defaults)
        XCTAssertEqual(defaults.string(forKey: "accentColor"), "green")
    }

    func testRunsOnlyOnce() {
        SettingsMigration.migrate(legacy: [:], into: defaults)
        let copied = SettingsMigration.migrate(legacy: ["accentColor": "teal"], into: defaults)
        XCTAssertTrue(copied.isEmpty)
        XCTAssertNil(defaults.object(forKey: "accentColor"))
    }

    func testMissingLegacyDomain() {
        let copied = SettingsMigration.migrate(legacy: nil, into: defaults)
        XCTAssertTrue(copied.isEmpty)
        XCTAssertTrue(defaults.bool(forKey: SettingsMigration.doneKey))
        XCTAssertEqual(ColorStore(defaults: defaults).load(), MarkingColors(accentID: nil, rightClickID: nil))
    }
}
