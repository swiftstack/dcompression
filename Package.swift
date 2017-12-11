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
            .branch("master")),
        .package(
            url: "https://github.com/swift-stack/test.git",
            .branch("master"))
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
