/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************
 *  This file contains code that has not yet been described                   *
 ******************************************************************************/

import Stream

protocol BitReader {
    func read() throws -> Bool
    func read(_ count: Int) throws -> Int
    func flush()
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

class BitInputStream<T: StreamReader>: BitReader {
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

    @inline(__always)
    private func feed(_ type: UInt8.Type) throws {
        buffer = UInt16(try source.read(UInt8.self))
    }

    @inline(__always)
    private func feed(_ type: UInt16.Type) throws {
        buffer = try source.read(UInt16.self).bigEndian
    }

    func read() throws -> Bool {
        if stored == 0 {
            try feed(UInt8.self)
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

        switch bytes {
        case 1: try feed(UInt8.self)
        case 2: try feed(UInt16.self)
        default: fatalError("unreachable")
        }
        stored = bytes << 3

        result |= (buffer & bitMasks[remain]) << written
        buffer &>>= remain
        stored -= remain

        return Int(result)
    }
}
