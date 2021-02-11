import Stream
import struct Foundation.Date

public struct GZip {
    struct Header {
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

        public enum CompressionMethod: UInt8 {
            case deflate = 8
        }

        public enum OperatingSystem: UInt8 {
            case fat = 0
            case amiga = 1
            case vms = 2
            case unix = 3
            case vmCMS = 4
            case atari = 5
            case hpfs = 6
            case macintosh = 7
            case zSystem = 8
            case cpM = 9
            case tops20 = 10
            case ntfs = 11
            case qdos = 12
            case acorn = 13
            case unknown = 255
        }

        public let compressionMethod: CompressionMethod
        public let isTextFile: Bool

        public let fileName: String?
        public let comment: String?

        public let modificationTime: Date?
        public let operatingSystem: OperatingSystem

        static func decode<T>(from stream: T) async throws -> Self
            where T: StreamReader
        {
            let crc32Stream = CRC32Stream()

            let magic = try await stream.read(UInt16.self)
            guard magic == 0x1f8b else {
                throw GZip.Error.invalidMagic
            }
            try crc32Stream.write(magic)

            let rawMethod = try await stream.read(UInt8.self)
            guard let method = CompressionMethod(rawValue: rawMethod) else {
                throw GZip.Error.unsupportedCompressionMethod
            }
            try crc32Stream.write(rawMethod)

            let rawFlags = try await stream.read(UInt8.self)
            let flags = Flags(rawValue: rawFlags)
            guard flags.isValid else {
                throw GZip.Error.invalidFlags
            }
            try crc32Stream.write(rawFlags)

            let extraFlags = try await stream.read(UInt8.self)
            try crc32Stream.write(extraFlags)

            let rawOperatingSystem = try await stream.read(UInt8.self)
            guard let operatingSystem =
                OperatingSystem(rawValue: rawOperatingSystem) else {
                    throw GZip.Error.invalidOperatingSystem
            }
            try crc32Stream.write(rawOperatingSystem)

            let time = try await stream.read(UInt32.self)
            try crc32Stream.write(time)

            if flags.contains(.extra) {
                let len = Int(try await stream.read(UInt16.self))
                guard try await stream.cache(count: len) else {
                     throw GZip.Error.invalidExtra
                }
                try await stream.read(count: len) { bytes in
                    try crc32Stream.write(bytes)
                }
            }

            func readZeroTerminatedString() async throws -> String? {
                var bytes = [UInt8]()
                while true {
                    let nextByte = try await stream.read(UInt8.self)
                    try crc32Stream.write(nextByte)
                    guard nextByte > 0 else {
                        break
                    }
                    bytes.append(nextByte)
                }
                return String(bytes: bytes, encoding: .isoLatin1)
            }

            let fileName = flags.contains(.name)
                ? try await readZeroTerminatedString()
                : nil

            let comment = flags.contains(.comment)
                ? try await readZeroTerminatedString()
                : nil

            if flags.contains(.crc) {
                let crc16 = try await stream.read(UInt16.self)
                let crc32 = crc32Stream.value
                guard UInt16(truncatingIfNeeded: crc32) == crc16 else {
                    throw GZip.Error.invalidCRC
                }
            }

            return Header.init(
                compressionMethod: method,
                isTextFile: flags.contains(.text),
                fileName: fileName,
                comment: comment,
                modificationTime: Date(modificationTime: time),
                operatingSystem: operatingSystem)
        }
    }

    public enum Error: Swift.Error {
        case invalidCRC
        case invalidMagic
        case invalidFlags
        case invalidExtra
        case invalidInputSize
        case invalidOperatingSystem
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

extension Date {
    init?(modificationTime: UInt32) {
        guard modificationTime > 0 else {
            return nil
        }
        self = Date(timeIntervalSince1970: Double(modificationTime))
    }
}
