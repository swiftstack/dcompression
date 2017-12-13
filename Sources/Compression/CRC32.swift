/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

public struct CRC32 {
    static let table: [UInt32] = {
        var table = [UInt32](repeating: 0, count: 256)

        var c: UInt32 = 0
        for n in 0..<256 {
            c = UInt32(n)
            for _ in 0..<8 {
                if c & 1 != 0 {
                    c = 0xedb88320 ^ (c >> 1)
                } else {
                    c = c >> 1
                }
            }
            table[n] = c
        }

        return table
    }()

    public private(set) var value: UInt32 = 0

    public mutating func update(buffer: UnsafeBufferPointer<UInt8>) {
        var c: UInt32  = value ^ 0xffffffff
        for n in 0..<buffer.count {
            c = CRC32.table[Int((c ^ UInt32(buffer[n])) & 0xff)] ^ (c >> 8)
        }
        value = c ^ 0xffffffff
    }

    public static func calculate(buffer: UnsafeBufferPointer<UInt8>) -> UInt32 {
        var crc = CRC32()
        crc.update(buffer: buffer)
        return crc.value
    }
}

extension CRC32 {
    public mutating func update(bytes: [UInt8]) {
        update(buffer: UnsafeBufferPointer(start: bytes, count: bytes.count))
    }

    public static func calculate(bytes: [UInt8]) -> UInt32 {
        return calculate(buffer:
            UnsafeBufferPointer(start: bytes, count: bytes.count))
    }
}
