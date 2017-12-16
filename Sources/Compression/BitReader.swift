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

protocol BitReader {
    func read() throws -> Bool
    func read(_ count: Int) throws -> Int
    func flush()
}

enum BitStreamError: Error {
    case insufficientData
}

let bitMasks: [UInt16] = [
    0b0000_0000_0000_0000,
    0b0000_0000_0000_0001, 0b0000_0000_0000_0011,
    0b0000_0000_0000_0111, 0b0000_0000_0000_1111,
    0b0000_0000_0001_1111, 0b0000_0000_0011_1111,
    0b0000_0000_0111_1111, 0b0000_0000_1111_1111,
    0b0000_0001_1111_1111, 0b0000_0011_1111_1111,
    0b0000_0111_1111_1111, 0b0000_1111_1111_1111,
    0b0001_1111_1111_1111, 0b0011_1111_1111_1111,
    0b0111_1111_1111_1111, 0b1111_1111_1111_1111,
]

class BitInputStream<T: InputStream>: BitReader {
    let source: T
    var buffer: UInt16 = 0
    var stored = 0

    init(source: T) {
        self.source = source
    }

    func flush() {
        buffer = 0
        stored = 0
    }

    func read() throws -> Bool {
        if stored == 0 {
            guard try source.read(to: &buffer, byteCount: 1) == 1 else {
                throw BitStreamError.insufficientData
            }
            stored = 8
        }
        let bit = buffer & bitMasks[1]
        buffer &>>= 1
        stored -= 1
        return bit != 0
    }

    func read(_ count: Int) throws -> Int {
        assert(count > 0 && count <= 16)

        if count <= stored {
            let result = buffer & bitMasks[count]
            stored -= count
            buffer &>>= count
            return Int(result)
        }

        var result = (buffer & bitMasks[stored])
        let written = stored
        let remain = count - stored

        let bytes = ((remain - 1) >> 3) + 1
        guard try source.read(to: &buffer, byteCount: bytes) == bytes else {
            throw BitStreamError.insufficientData
        }
        stored = bytes << 3

        result |= (buffer & bitMasks[remain]) << written
        buffer &>>= remain
        stored -= remain

        return Int(result)
    }
}
