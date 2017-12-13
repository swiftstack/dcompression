/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

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

        init<T: InputStream>(from stream: T) throws {
            let crcStream = OutputByteStream()

            let magic = try stream.read(UInt16.self)
            guard magic == 0x8b1f else {
                throw GZip.Error.invalidMagic
            }
            try crcStream.write(magic)

            let rawMethod = try stream.read(UInt8.self)
            guard let method = CompressionMethod(rawValue: rawMethod) else {
                throw GZip.Error.unsupportedCompressionMethod
            }
            try crcStream.write(rawMethod)

            let rawFlags = try stream.read(UInt8.self)
            let flags = Flags(rawValue: rawFlags)
            guard flags.isValid else {
                throw GZip.Error.invalidFlags
            }
            try crcStream.write(rawFlags)

            let extraFlags = try stream.read(UInt8.self)
            try crcStream.write(extraFlags)

            let rawOperatingSystem = try stream.read(UInt8.self)
            guard let operatingSystem = OperatingSystem(rawValue: rawOperatingSystem) else {
                throw GZip.Error.invalidOperatingSystem
            }
            try crcStream.write(rawOperatingSystem)

            let time = try stream.read(UInt32.self)
            try crcStream.write(time)


            if flags.contains(.extra) {
                let len = Int(try stream.read(UInt16.self))
                var data = [UInt8](repeating: 0, count: len)
                guard try stream.read(to: &data) == len else {
                    throw GZip.Error.invalidExtra
                }
                _ = try crcStream.write(data)
            }

            func readZeroTerminatedString() throws -> String? {
                var bytes = [UInt8]()
                while true {
                    let nextByte = try stream.read(UInt8.self)
                    try crcStream.write(nextByte)
                    guard nextByte > 0 else {
                        break
                    }
                    bytes.append(nextByte)
                }
                return String(bytes: bytes, encoding: .isoLatin1)
            }

            let fileName = flags.contains(.name)
                ? try readZeroTerminatedString()
                : nil

            let comment = flags.contains(.comment)
                ? try readZeroTerminatedString()
                : nil

            if flags.contains(.crc) {
                let crc16 = try stream.read(UInt16.self)
                let hash = CRC32.calculate(bytes: crcStream.bytes)
                guard UInt16(truncatingIfNeeded: hash) == crc16 else {
                    throw GZip.Error.invalidCRC
                }
            }

            self.compressionMethod = method
            self.isTextFile = flags.contains(.text)
            self.fileName = fileName
            self.comment = comment
            self.modificationTime = Date(modificationTime: time)
            self.operatingSystem = operatingSystem
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

    public static func decode<T: InputStream>(
        from stream: T
    ) throws -> [UInt8] {
        _ = try Header(from: stream)
        let bytes = try Inflate.decode(from: stream)

        let crc32 = try stream.read(UInt32.self)
        guard CRC32.calculate(bytes: bytes) == crc32 else {
            throw Error.invalidCRC
        }

        let inputSize = Int(try stream.read(UInt32.self))
        guard bytes.count % (1 << 32) == inputSize else {
            throw Error.invalidInputSize
        }

        return bytes
    }
}

extension GZip {
    public static func decode(bytes: [UInt8]) throws -> [UInt8] {
        let stream = InputByteStream(bytes)
        return try decode(from: stream)
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
