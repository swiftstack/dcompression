import Stream

extension GZip.Header {
    public enum Method: UInt8 {
        case deflate = 8
    }
}

extension GZip.Header.Method {
    static func decode<T>(
        from stream: T,
        crc32Stream: CRC32Stream
    ) async throws -> Self
        where T: StreamReader
    {
        let rawMethod = try await stream.read(UInt8.self)
        guard let method = Self(rawValue: rawMethod) else {
            throw GZip.Error.unsupportedCompressionMethod
        }
        try crc32Stream.write(rawMethod)
        return method
    }
}
