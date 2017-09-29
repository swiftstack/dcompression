// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Compression",
    products: [
        .library(
            name: "Compression",
            targets: ["Compression"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-stack/stream.git",
            from: "0.4.0"),
        .package(
            url: "https://github.com/swift-stack/test.git",
            from: "0.4.0")
    ],
    targets: [
        .target(
            name: "Compression",
            dependencies: ["Stream"]),
        .testTarget(
            name: "CompressionTests",
            dependencies: ["Compression", "Test"]),
    ]
)
