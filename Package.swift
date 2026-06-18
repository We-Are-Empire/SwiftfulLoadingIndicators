// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftfulLoadingIndicators",
    platforms: [
        // The attached `skipstone` plugin product requires iOS 16+; match the canonical
        // consumers (RideUIShared = iOS 17 / watchOS 10 / macOS 14) exactly. These are
        // well above the `.task { Task.sleep ... }` structured-concurrency floor the
        // Combine-strip needs (Skip-Fuse Android has no Combine Timer.publish). tvOS is
        // dropped — no consumer targets it and skipstone's tvOS floor is unspecified.
        .iOS(.v17), .watchOS(.v10), .macOS(.v14),
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
                // Unconditional (NOT Android-gated): for a URL/revision dependency, skipstone's
                // host-side gradle generation only treats the package as a full Skip-Fuse module
                // when the SkipFuse edge is visible at host manifest-eval time. An Android-only
                // condition hides it on the host → skipstone emits a stub gradle module
                // (`android {}` with no android-library plugin → "Unresolved reference 'android'").
                // Matches the sibling URL-dep forks SwiftUIToast / SwiftySensors. SkipFuse/UI no-op
                // on Apple platforms, so this is inert for the iOS/macOS builds.
                .product(name: "SkipFuse", package: "skip-fuse"),
                .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
            ],
            plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(
            name: "SwiftfulLoadingIndicatorsTests",
            dependencies: ["SwiftfulLoadingIndicators"]),
    ]
)
