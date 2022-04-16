import Stream

extension GZip.Header {
    struct Flags: OptionSet {
        var rawValue: UInt8

        static let text = Flags(rawValue: 1 << 0)
        static let crc = Flags(rawValue: 1 << 1)
        static let extra = Flags(rawValue: 1 << 2)
        static let name = Flags(rawValue: 1 << 3)
        static let comment = Flags(rawValue: 1 << 4)
        static let reservered1 = Flags(rawValue: 1 << 5)
        static let reservered2 = Flags(rawValue: 1 << 6)
        static let reservered3 = Flags(rawValue: 1 << 7)

        var isValid: Bool {
            return !contains(.reservered1)
                && !contains(.reservered2)
                && !contains(.reservered3)
        }
    }
}

extension GZip.Header.Flags {
    static func decode<T>(
        from stream: T,
        crc32Stream: CRC32Stream
    ) async throws -> Self
        where T: StreamReader
    {
        let rawFlags = try await stream.read(UInt8.self)
        let flags = Self(rawValue: rawFlags)
        guard flags.isValid else {
            throw GZip.Error.invalidFlags
        }
        try crc32Stream.write(rawFlags)
        return .init(rawValue: rawFlags)
    }
}
