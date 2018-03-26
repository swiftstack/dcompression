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

public class CRC32Stream {
    private var c: UInt32 = 0xffffffff

    public var value: UInt32 {
        return c ^ 0xffffffff
    }

    public func write(_ byte: UInt8) throws {
        c = CRC32.table[Int((c ^ UInt32(byte)) & 0xff)] ^ (c >> 8)
    }

    public func write<T: BinaryInteger>(_ value: T) throws {
        var value = value
        try withUnsafeBytes(of: &value, write)
    }

    func write(_ bytes: [UInt8]) throws {
        try bytes.withUnsafeBytes(write)
    }

    func write(_ bytes: UnsafeRawBufferPointer) throws {
        for byte in bytes {
            c = CRC32.table[Int((c ^ UInt32(byte)) & 0xff)] ^ (c >> 8)
        }
    }
}

extension CRC32Stream: OutputStream {
    public func write(
        from buffer: UnsafeRawPointer,
        byteCount: Int) throws -> Int
    {
        try write(UnsafeRawBufferPointer(start: buffer, count: byteCount))
        return byteCount
    }
}
