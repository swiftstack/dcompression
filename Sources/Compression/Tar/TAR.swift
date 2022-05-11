import Stream

public struct TAR {
    public enum Compression {
        case none
        case gzip
    }

    public enum Error: Swift.Error {
        case invalidKind(UInt8)
        case invalidSize(String)
    }

    public static func decode<T>(
        from stream: T,
        compression: Compression = .none
    ) async throws -> [Entry] where T: StreamReader {
        let entries: [Entry] = compression == .gzip
            ? try await .init(decoding: GZip.decode(from: stream))
            : try await .init(decoding: stream)

        return entries.removeBlockPadding().mergeLongNames()
    }
}

extension Array where Element == TAR.Entry {
    func removeBlockPadding() -> Self {
        if let index = firstIndex(where: { $0.name.isEmpty && $0.size == 0 }) {
            return .init(self[0..<index])
        }
        return self
    }

    func mergeLongNames() -> Self {
        var result: Self = []
        var longName = ""

        for var entry in self {
            guard entry.typeflag != .longName else {
                longName = .init(decoding: entry.data, as: UTF8.self)
                continue
            }
            if !longName.isEmpty {
                entry.name = longName
                longName = ""
            }
            result.append(entry)
        }

        return result
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
