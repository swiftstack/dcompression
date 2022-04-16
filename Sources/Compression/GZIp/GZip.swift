import Stream
import struct Foundation.Date

public struct GZip {
    public enum Error: Swift.Error {
        case invalidCRC
        case invalidMagic
        case invalidFlags
        case invalidExtra
        case invalidInputSize
        case unsupportedCompressionMethod
    }

    public static func decode<T>(from stream: T) async throws -> [UInt8]
        where T: StreamReader
    {
        _ = try await Header.decode(from: stream)
        let bytes = try await Deflate.decode(from: stream)

        let crc32 = try await stream.read(UInt32.self).bigEndian
        guard CRC32.calculate(bytes: bytes) == crc32 else {
            throw Error.invalidCRC
        }

        let inputSize = Int(try await stream.read(UInt32.self).bigEndian)
        guard bytes.count % (1 << 32) == inputSize else {
            throw Error.invalidInputSize
        }

        return bytes
    }
}

extension GZip {
    public static func decode(bytes: [UInt8]) async throws -> [UInt8] {
        let stream = InputByteStream(bytes)
        return try await decode(from: stream)
    }
}
