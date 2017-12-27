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

public class CRC32Stream: OutputStream {
    private var c: UInt32 = 0xffffffff

    public var value: UInt32 {
        return c ^ 0xffffffff
    }

    public func write(_ bytes: UnsafeRawPointer, byteCount: Int) throws -> Int {
        for i in 0..<byteCount {
            let byte = bytes.advanced(by: i)
                .assumingMemoryBound(to: UInt8.self)
                .pointee
            c = CRC32.table[Int((c ^ UInt32(byte)) & 0xff)] ^ (c >> 8)
        }
        return byteCount
    }
}
