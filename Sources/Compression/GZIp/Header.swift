import Stream
import struct Foundation.Date

extension GZip {
    struct Header {
        public let method: Method
        public let isTextFile: Bool

        public let fileName: String?
        public let comment: String?

        public let modified: Date?
        public let system: System

        static func decode<T>(from stream: T) async throws -> Self
            where T: StreamReader
        {
            let crc32Stream = CRC32Stream()

            _ = try await Magic.decode(from: stream, crc32Stream: crc32Stream)

            let method = try await Method.decode(
                from: stream,
                crc32Stream: crc32Stream)

            let flags = try await Flags.decode(
                from: stream,
                crc32Stream: crc32Stream)

            let extraFlags = try await stream.read(UInt8.self)
            try crc32Stream.write(extraFlags)

            let system = try await System.decode(
                from: stream,
                crc32Stream: crc32Stream)

            let timestamp = try await stream.read(UInt32.self)
            try crc32Stream.write(timestamp)

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
                method: method,
                isTextFile: flags.contains(.text),
                fileName: fileName,
                comment: comment,
                modified: Date(timestamp: timestamp),
                system: system)
        }
    }
}

extension Date {
    init?(timestamp: UInt32) {
        guard timestamp > 0 else {
            return nil
        }
        self = Date(timeIntervalSince1970: Double(timestamp))
    }
}
