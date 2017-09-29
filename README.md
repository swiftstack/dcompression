# Compression

Compression algorithms

## Package.swift

```swift
.package(url: "https://github.com/tris-foundation/compression.git", from: "0.4.0")
```

## Memo

```swift
struct Inflate {
    static func decode<T: InputStream>(from stream: T) throws -> [UInt8]
}
```
