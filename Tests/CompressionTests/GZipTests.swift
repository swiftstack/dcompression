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
import Stream
@testable import Compression

class GZipTests: TestCase {
    func testDecode() {
        let encoded: [UInt8] = [
            0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x13, 0xf3, 0x48, 0xcd, 0xc9, 0xc9, 0xd7,
            0x51, 0x08, 0xcf, 0x2f, 0xca, 0x49, 0x51, 0x04,
            0x00, 0xd0, 0xc3, 0x4a, 0xec, 0x0d, 0x00, 0x00,
            0x00
        ]
        do {
            let decoded = try GZip.decode(from: InputByteStream(encoded))
            let string = String(decoding: decoded, as: UTF8.self)
            assertEqual(string, "Hello, World!")
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testDecode", testDecode),
    ]
}
