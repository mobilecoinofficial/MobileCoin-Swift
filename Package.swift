// swift-tools-version:5.7
import PackageDescription
import Foundation

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
            path: "Vendor/libmobilecoin"
        ),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.0"
        ),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.5.0"
        ),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.15.0")
    ],
    targets: [
        .target(
            name: "MobileCoin",
            dependencies: [.product(name: "SwiftProtobuf", package: "swift-protobuf"), .product(name: "LibMobileCoinCore", package: "libmobilecoin")],
            path: "Sources"
         ),
        .testTarget(
            name: "MobileCoinTests",
            dependencies: ["MobileCoin"], 
            path: "Tests",
            resources: [
                .copy("Common/FixtureData/Transaction")
            ]
        )
    ]
)
