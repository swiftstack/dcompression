// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "DCompression",
    products: [
        .library(
            name: "DCompression",
            targets: ["DCompression"]),
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
            name: "DCompression",
            dependencies: ["Stream"],
            path: "./Sources/Compression"),
        .testTarget(
            name: "CompressionTests",
            dependencies: ["DCompression", "Test"]),
    ]
)
