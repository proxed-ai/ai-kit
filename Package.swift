// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-ai-kit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
    ],
    products: [
        .library(name: "AIKit", targets: ["AIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/loopwork-ai/JSONSchema", from: "1.0.0"),
    ],
    targets: [
        .target(name: "AIKit", dependencies: [
            .product(name: "JSONSchema", package: "JSONSchema"),
        ]),
        .testTarget(name: "AIKitTests", dependencies: ["AIKit"]),
    ]
)
