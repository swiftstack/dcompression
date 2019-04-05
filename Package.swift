// swift-tools-version:5.0
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
            url: "https://github.com/tris-foundation/stream.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/test.git",
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
