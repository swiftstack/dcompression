# Compression

Compression algorithms

## Package.swift

```swift
.package(url: "https://github.com/swiftstack/dcompression.git", .branch("fiber"))
```

## Memo

```swift
struct Inflate {
    static func decode<T: InputStream>(from stream: T) throws -> [UInt8]
}

struct GZip {
    static func decode<T: InputStream>(from stream: T) throws -> [UInt8]
}
```
