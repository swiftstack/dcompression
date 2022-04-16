import Stream

extension GZip.Header {
    public struct Magic {
        let value: UInt16
    }
}

extension GZip.Header.Magic {
    static func decode<T>(
        from stream: T,
        crc32Stream: CRC32Stream
    ) async throws -> Self
        where T: StreamReader
    {
        let magic = try await stream.read(UInt16.self)
        guard magic == 0x1f8b else {
            throw GZip.Error.invalidMagic
        }
        try crc32Stream.write(magic)
        return .init(value: magic)
    }
}
