// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DCompression",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "DCompression",
            targets: ["DCompression"]),
    ],
    dependencies: [
        .package(name: "Stream"),
        .package(name: "FileSystem"),
        .package(name: "Test"),
    ],
    targets: [
        .target(
            name: "DCompression",
            dependencies: [
                .product(name: "Stream", package: "stream"),
            ],
            path: "./Sources/Compression",
            swiftSettings: swift6),
    ]
)

let swift6: [SwiftSetting] = [
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("StrictConcurrency"),
    .enableUpcomingFeature("ImplicitOpenExistentials"),
    .enableUpcomingFeature("BareSlashRegexLiterals"),
]

// MARK: - tests

testTarget("Compression") { test in
    test("BitReader")
    test("BlockType")
    test("CRC32")
    test("GZip")
    test("HuffmanBinaryHeap")
    test("Inflate")
    test("TAR")
}

func testTarget(_ target: String, task: ((String) -> Void) -> Void) {
    task { test in addTest(target: target, name: test) }
}

func addTest(target: String, name: String) {
    package.targets.append(
        .executableTarget(
            name: "Tests/\(target)/\(name)",
            dependencies: [
                .target(name: "DCompression"),
                .product(name: "FileSystem", package: "filesystem"),
                .product(name: "Test", package: "test"),
            ],
            path: "Tests/\(target)/\(name)",
            swiftSettings: swift6))
}

// MARK: - custom package source

#if canImport(ObjectiveC)
import Darwin.C
#else
import Glibc
#endif

extension Package.Dependency {
    enum Source: String {
        case local, remote, github

        static var `default`: Self { .github }

        var baseUrl: String {
            switch self {
            case .local: return "../"
            case .remote: return "https://swiftstack.io/"
            case .github: return "https://github.com/swiftstack/"
            }
        }

        func url(for name: String) -> String {
            return self == .local
                ? baseUrl + name.lowercased()
                : baseUrl + name.lowercased() + ".git"
        }
    }

    static func package(name: String) -> Package.Dependency {
        guard let pointer = getenv("SWIFTSTACK") else {
            return .package(name: name, source: .default)
        }
        guard let source = Source(rawValue: String(cString: pointer)) else {
            fatalError("Invalid source. Use local, remote or github")
        }
        return .package(name: name, source: source)
    }

    static func package(name: String, source: Source) -> Package.Dependency {
        return source == .local
            ? .package(name: name, path: source.url(for: name))
            : .package(url: source.url(for: name), branch: "dev")
    }
}
