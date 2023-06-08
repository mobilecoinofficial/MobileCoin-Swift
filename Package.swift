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
            targets: ["MobileCoinHTTPS", "MobileCoinGRPC", "MobileCoinCommon"]),
        .library(
            name: "MobileCoinGRPC",
            targets: ["MobileCoinGRPC", "MobileCoinCommon"]),
        .library(
            name: "MobileCoinHTTP",
            targets: ["MobileCoinHTTPS", "MobileCoinCommon"]),
    ],
    dependencies: [
        // Here we define our package's external dependencies
        // and from where they can be fetched:
        .package(
            path: "Vendor/libmobilecoin"
        ),
        .package(
            url: "https://github.com/apple/swift-log",
            from: "1.4.0"
        ),
        .package(
            url: "https://github.com/apple/swift-protobuf",
            from: "1.5.0"
        ),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MobileCoinCommon",
            dependencies: [.product(name: "SwiftProtobuf", package: "swift-protobuf"), .product(name: "LibMobileCoinCore", package: "libmobilecoin")],
            path: "Sources/Common"
         ),
        .target(
            name: "MobileCoinHTTPS",
            dependencies: [.target(name: "MobileCoinCommon"),.product(name: "LibMobileCoinCoreHTTP", package: "libmobilecoin")],
            path: "Sources/HTTPS"
        ),
        .target(
            name: "MobileCoinGRPC",
            dependencies: [.target(name: "MobileCoinCommon"),.product(name: "LibMobileCoinCoreGRPC", package: "libmobilecoin"), .product(name: "GRPC", package: "grpc-swift")],
            path: "Sources/GRPC"
        )
    ]
)


