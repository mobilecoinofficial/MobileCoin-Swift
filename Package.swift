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
            targets: ["MobileCoinHTTP", "MobileCoinGRPC", "MobileCoinCommon"]),
        .library(
            name: "MobileCoinGRPC",
            targets: ["MobileCoinGRPC", "MobileCoinCommon"]),
        .library(
            name: "MobileCoinHTTP",
            targets: ["MobileCoinHTTP", "MobileCoinCommon"]),
    ],
    dependencies: [
        // Here we define our package's external dependencies
        // and from where they can be fetched:
        .package(
            url: "https://github.com/mobilecoinofficial/libmobilecoin",
            from: "1.4.0"
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
            dependencies: [.product(name: "SwiftProtobuf", package: "swift-protobuf")],
            path: "Sources/Common"
         ),
        .target(
            name: "MobileCoinHTTP",
            dependencies: [.target(name: "LibMobileCoinCommon")],
            path: "Sources/HTTP"
        ),
        .target(
            name: "MobileCoinGRPC",
            dependencies: [.target(name: "LibMobileCoinCommon"), .product(name: "GRPC", package: "grpc-swift")],
            path: "Sources/GRPC"
        ),
        .binaryTarget(
            name: "LibMobileCoinLibrary",
            url: "https://yus.s3.us-east-1.amazonaws.com/bundle.zip",
            // url: "https://github.com/mobilecoinofficial/libmobilecoin/blob/adam/%23184377543-3/Artifacts/bundle.zip",
            checksum: "051c9615e85c7bf092f8bf3121eccd55c3f297240209b10d25a312835bc7a2ec")
    ]
)


