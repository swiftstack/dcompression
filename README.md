# Compression

Compression algorithms

## Package.swift

```swift
.package(url: "https://github.com/tris-foundation/compression.git", .branch("master"))
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
