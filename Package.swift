// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Followspot",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "Followspot", targets: ["Followspot"]),
    ],
    targets: [
        // Pure, AppKit-free logic (geometry, state machine) – unit tested.
        .target(name: "FollowspotCore"),
        // The menu bar app itself (AppKit, Core Animation, Carbon hotkeys).
        .executableTarget(name: "Followspot", dependencies: ["FollowspotCore"]),
        .testTarget(name: "FollowspotCoreTests", dependencies: ["FollowspotCore"]),
    ],
    swiftLanguageModes: [.v5]
)
