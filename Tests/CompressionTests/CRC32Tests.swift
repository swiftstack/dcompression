/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Test
@testable import Compression

class CRC32Tests: TestCase {
    func testCRC32() {
        let bytes = [UInt8]("123456789".utf8)
        let crc = CRC32.calculate(bytes: bytes)
        assertEqual(crc, 0xcbf43926)
    }

    func testCRC32Fox() {
        let bytes = [UInt8]("The quick brown fox jumps over the lazy dog".utf8)
        let crc = CRC32.calculate(bytes: bytes)
        assertEqual(crc, 0x414fa339)
    }

    func testCRC32Zero() {
        let bytes = [UInt8]("".utf8)
        let crc = CRC32.calculate(bytes: bytes)
        assertEqual(crc, 0x0)
    }

    static var allTests = [
        ("testCRC32", testCRC32),
        ("testCRC32Fox", testCRC32Fox),
        ("testCRC32Zero", testCRC32Zero),
    ]
}
