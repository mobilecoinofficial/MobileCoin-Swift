// swift-tools-version:6.1
import Foundation
import PackageDescription

let package = Package(
    name: "MobileCoin",
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
            from: "6.1.0"
        ),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.36.1"
        ),
    ],
    targets: [
        // HTTP only, which is what the pod chain ships and what production runs.
        // The file list mirrors the podspec CoreHTTP subspec. Sources/GRPC is
        // left out rather than guarded: its files import GRPC and NIO
        // unconditionally, and so do the tests excluded below.
        .target(
            name: "MobileCoin",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "LibMobileCoinCoreHTTP", package: "libmobilecoin"),
            ],
            path: "Sources",
            // GRPC is excluded as well as left out of sources, otherwise
            // SwiftPM warns about its 25 files on every graph load.
            exclude: ["GRPC"],
            sources: [
                "Common",
                "HTTPS",
            ]
         ),
        // LibMobileCoinTestVector is its own product from 6.1.0. It used to ride
        // along inside the Core products, so the tests picked it up through
        // MobileCoin without asking.
        .testTarget(
            name: "MobileCoinTests",
            dependencies: [
                "MobileCoin",
                .product(name: "LibMobileCoinTestVectors", package: "libmobilecoin"),
            ],
            path: "Tests",
            exclude: [
                "Common/Secrets/secrets.json.sample",
                "ProtocolSpecific/Grpc",
            ],
            resources: [
                .copy("Common/FixtureData/Transaction"),
                .copy("Common/Secrets/secrets.json"),
                .copy("Common/Secrets/process_info.json"),
            ],
            // The test targets stay in Swift 5 mode. Migrating them means
            // restructuring how every async XCTestCase captures self, which is
            // its own piece of work and changes nothing a consumer compiles.
            swiftSettings: [.swiftLanguageMode(.v5)]

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
            ],
            // The test targets stay in Swift 5 mode. Migrating them means
            // restructuring how every async XCTestCase captures self, which is
            // its own piece of work and changes nothing a consumer compiles.
            swiftSettings: [.swiftLanguageMode(.v5)]

         ),
    ]
)
