import Stream

public struct TAR {
    public enum Compression {
        case none
        case gzip
    }

    public enum Error: Swift.Error {
        case invalidField
    }

    public static func decode<T>(
        from stream: T,
        compression: Compression = .none
    ) async throws -> [Entry] where T: StreamReader {
        switch compression {
        case .none: return try await .init(decoding: stream)
        case .gzip: return try await .init(decoding: GZip.decode(from: stream))
        }
    }
}

extension TAR {
    public static func decode(
        from bytes: [UInt8],
        compression: Compression = .none
    ) async throws -> [Entry] {
        try await decode(
            from: InputByteStream(bytes),
            compression: compression)
    }
}
