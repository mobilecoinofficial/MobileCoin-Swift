// swift-tools-version:5.7
import Foundation
import PackageDescription

let package = Package(
    name: "MobileCoin",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "MobileCoinCore",
            targets: ["MobileCoin"]),
    ],
    dependencies: [
        // Here we define our package's external dependencies
        // and from where they can be fetched:
        .package(
            url: "https://github.com/mobilecoinofficial/libmobilecoin.git",
            from: "6.0.4"
        ),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.28.2"
        ),
    ],
    targets: [
        // HTTP only, which is what the pod chain ships and what production runs.
        // The file list mirrors the podspec CoreHTTP subspec. Sources/GRPC is
        // left out rather than guarded: its files import GRPC and NIO
        // unconditionally.
        .target(
            name: "MobileCoin",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "LibMobileCoinCoreHTTP", package: "libmobilecoin"),
            ],
            path: ".",
            sources: [
                "Sources/Common",
                "Sources/HTTPS",
                "HTTPOnly/WrappedNIOSSLCertificateValidator.swift",
            ]
         ),
        .testTarget(
            name: "MobileCoinTests",
            dependencies: ["MobileCoin"],
            path: "Tests",
            exclude: [
                "Common/Secrets/secrets.json.sample",
            ],
            resources: [
                .copy("Common/FixtureData/Transaction"),
                .copy("Common/Secrets/secrets.json"),
                .copy("Common/Secrets/process_info.json"),
            ]
        ),
        .target(
            name: "TestSetupClient",
            dependencies: ["MobileCoin"],
            path: "tools/TestSetupClient/TestSetupClient",
            exclude: [
                "Assets.xcassets",
                "Preview Content/Preview Assets.xcassets",
            ],
            swiftSettings: [
                .define("SPM_BUILD"),
            ]
         ),
        .testTarget(
            name: "TestSetupClientTests",
            dependencies: ["TestSetupClient"],
            path: "tools/TestSetupClient/TestSetupClientTests",
            resources: [
                // The committed sample keeps Bundle.module synthesized before the
                // generator writes process_info.json. With every declared resource
                // missing, SwiftPM emits no accessor and the target cannot compile.
                .copy("process_info.json.sample"),
                .copy("process_info.json"),
            ]
         ),
    ]
)
