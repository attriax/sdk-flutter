// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Swift Package Manager manifest for the iOS implementation of the Attriax Flutter
// plugin. As of Flutter stable 3.44 (2026) SwiftPM is the DEFAULT dependency manager;
// Flutter's tool discovers this file at `ios/<plugin_name>/Package.swift` (i.e. a
// directory named after the platform package, per
// https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors).
// The CocoaPods podspec (`../attriax_flutter_ios.podspec`) is kept as the fallback for
// Flutter < 3.44, per Flutter's official dual-support recommendation.
//
// The Flutter framework module (`import Flutter`) is INJECTED by Flutter's build tooling
// at build time — the tool adds the generated `FlutterFramework` package to the app-level
// aggregate and makes `import Flutter` resolvable to every plugin target automatically.
// Plugin manifests therefore declare NO Flutter package dependency (verified against the
// official plugin template and url_launcher_ios/url_launcher_macos, which both ship
// `dependencies: []`). Only the vendored KMP core is an explicit dependency here.
//
// Layout (all inputs live UNDER this package directory — SPM forbids target paths that
// escape the package root, so the sources/resource/xcframework were relocated here out
// of the old CocoaPods `ios/Classes`, `ios/Resources`, `ios/Frameworks` tree; the
// podspec was repointed to the same shared paths so both build systems consume one tree):
//
//   ios/attriax_flutter_ios/
//     Package.swift
//     Sources/attriax_flutter_ios/AttriaxIosPlugin.swift
//     Sources/attriax_flutter_ios/PrivacyInfo.xcprivacy
//     Frameworks/AttriaxCore.xcframework            (git-ignored; vendored build artifact)

import PackageDescription

let package = Package(
    name: "attriax_flutter_ios",
    // Podspec floor is `s.platform = :ios, '14.0'` (ATT / App Attest / AdServices require
    // iOS 14+); the manifest matches it. `.v14` requires tools >= 5.5.
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Per the docs: "If the plugin name contains `_`, the library name must be a
        // `-` separated version of the plugin name." Target name keeps the underscores
        // (it is the Swift module name that hosts `AttriaxIosPlugin`).
        .library(name: "attriax-flutter-ios", targets: ["attriax_flutter_ios"])
    ],
    dependencies: [],
    targets: [
        // The shared KMP core (sdk-kmp), vendored as a binary XCFramework. This mirrors
        // `sdk-ios/Package.swift`, which uses the same `.binaryTarget` over the same
        // reproducible artifact. The xcframework is git-ignored and produced by sdk-kmp
        // (`sdk-ios/scripts/build-xcframework.sh` → `./gradlew
        // :core:assembleAttriaxCoreReleaseXCFramework`); it is copied into
        // `ios/attriax_flutter_ios/Frameworks/` so it sits inside the package root
        // (SPM binary-target paths may not escape the package).
        .binaryTarget(
            name: "AttriaxCore",
            path: "Frameworks/AttriaxCore.xcframework"
        ),
        .target(
            name: "attriax_flutter_ios",
            // Only the KMP core — `import Flutter` is satisfied by the tool-injected
            // FlutterFramework package, not declared here.
            dependencies: ["AttriaxCore"],
            // Default SPM convention would auto-discover Sources/attriax_flutter_ios; set
            // explicitly for clarity.
            path: "Sources/attriax_flutter_ios",
            resources: [
                // Privacy manifest, shipped as a processed resource (matches the podspec's
                // `resource_bundles` privacy bundle). Path is relative to this target's dir.
                .process("PrivacyInfo.xcprivacy")
            ],
            linkerSettings: [
                // The 11 system frameworks the STATIC KMP core references — kept byte-for-byte
                // in sync with `attriax_flutter_ios.podspec`'s `s.frameworks`. All ship with
                // the OS (no third-party dependency). (Note: sdk-ios/Package.swift links 10 —
                // it omits CoreGraphics + SystemConfiguration differs; the podspec is the
                // source of truth for THIS plugin, so all 11 are linked here.)
                .linkedFramework("AdSupport"),
                .linkedFramework("SafariServices"),
                .linkedFramework("AppTrackingTransparency"),
                .linkedFramework("AdServices"),
                .linkedFramework("StoreKit"),
                .linkedFramework("DeviceCheck"),
                .linkedFramework("Network"),
                .linkedFramework("WebKit"),
                .linkedFramework("Security"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("CoreGraphics")
            ]
        )
    ]
)
