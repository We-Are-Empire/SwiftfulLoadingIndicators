// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftfulLoadingIndicators",
    platforms: [
        // Bumped to the structured-concurrency floor: the indicator views drive their
        // phase counters with a `.task { Task.sleep ... }` loop (Skip-Fuse Android has
        // no Combine Timer.publish), which requires iOS 15 / macOS 12 / watchOS 8 / tvOS 15.
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftfulLoadingIndicators",
            targets: ["SwiftfulLoadingIndicators"]),
    ],
    dependencies: [
        // SkipFuse + SkipFuseUI bring SwiftUI on Android: the `import SwiftUI` in these
        // views resolves to SkipFuseUI there, which needs the `CJNI` module SkipFuse
        // supplies. Android-only on the target below (no effect on Apple builds).
        .package(url: "https://source.skip.tools/skip-fuse.git", from: "1.0.0"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0"),
        // `skip` package — attaches the `skipstone` build-tool plugin so SkipFuseUI can
        // generate the per-View JNI bridge stubs its Android render pipeline needs to
        // invoke `body` on these SwiftUI views. Pinned to the SAME patched revision the
        // rest of the Ride graph uses (must match exactly, or SwiftPM cannot resolve two
        // revisions of one package). The plugin no-ops on Apple platforms.
        .package(url: "https://source.skip.tools/skip.git", revision: "8254f29dba1b95af020f016b4387e8ffc92c4340"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftfulLoadingIndicators",
            dependencies: [
                .product(name: "SkipFuse", package: "skip-fuse", condition: .when(platforms: [.android])),
                .product(name: "SkipFuseUI", package: "skip-fuse-ui", condition: .when(platforms: [.android])),
            ],
            plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(
            name: "SwiftfulLoadingIndicatorsTests",
            dependencies: ["SwiftfulLoadingIndicators"]),
    ]
)
