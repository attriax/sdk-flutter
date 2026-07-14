// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Swift Package Manager manifest for the macOS implementation of the Attriax Flutter
// plugin. As of Flutter stable 3.44 (2026) SwiftPM is the DEFAULT dependency manager;
// Flutter's tool discovers this file at `macos/<plugin_name>/Package.swift` (a directory
// named after the platform package, per
// https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors).
// The CocoaPods podspec (`../attriax_flutter_ios.podspec`) is kept as the fallback for
// Flutter < 3.44, per Flutter's official dual-support recommendation.
//
// This plugin ships SEPARATE ios/ and macos/ native trees (not a shared `darwin/` dir),
// each with its own near-identical Swift file, so there are two Package.swift manifests
// (they differ: UIKit vs Cocoa, `import Flutter` vs `import FlutterMacOS`, and the linked-
// framework set). The Flutter framework module (`import FlutterMacOS`) is INJECTED by
// Flutter's build tooling at build time — plugin manifests declare NO Flutter package
// dependency (verified against the official plugin template and url_launcher_macos, which
// ships `dependencies: []`). Only the vendored KMP core is an explicit dependency here.
//
// Layout (all inputs live UNDER this package directory — relocated out of the old
// CocoaPods `macos/Classes`, `macos/Resources`, `macos/Frameworks` tree; the podspec was
// repointed to the same shared paths):
//
//   macos/attriax_flutter_ios/
//     Package.swift
//     Sources/attriax_flutter_ios/AttriaxIosPlugin.swift
//     Sources/attriax_flutter_ios/PrivacyInfo.xcprivacy
//     Frameworks/AttriaxCore.xcframework            (git-ignored; vendored build artifact)

import PackageDescription

let package = Package(
    name: "attriax_flutter_ios",
    // Podspec floor is `s.platform = :osx, '11.0'` (ATT requires macOS 11+); the manifest
    // matches it.
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(name: "attriax-flutter-ios", targets: ["attriax_flutter_ios"])
    ],
    dependencies: [],
    targets: [
        // The shared KMP core (sdk-kmp macos-arm64_x86_64 slice), vendored as a binary
        // XCFramework — same reproducible artifact as iOS. Copied into
        // `macos/attriax_flutter_ios/Frameworks/` so it sits inside the package root.
        .binaryTarget(
            name: "AttriaxCore",
            path: "Frameworks/AttriaxCore.xcframework"
        ),
        .target(
            name: "attriax_flutter_ios",
            // Only the KMP core — `import FlutterMacOS` is satisfied by the tool-injected
            // FlutterFramework package, not declared here.
            dependencies: ["AttriaxCore"],
            path: "Sources/attriax_flutter_ios",
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            linkerSettings: [
                // The 7 system frameworks the STATIC KMP core references on macOS — kept in
                // sync with `macos/attriax_flutter_ios.podspec`'s `s.frameworks`. AppKit is
                // normally auto-linked but is listed explicitly to match the podspec.
                .linkedFramework("AppTrackingTransparency"),
                .linkedFramework("Network"),
                .linkedFramework("WebKit"),
                .linkedFramework("AppKit"),
                .linkedFramework("Security"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("CoreGraphics")
            ]
        )
    ]
)
