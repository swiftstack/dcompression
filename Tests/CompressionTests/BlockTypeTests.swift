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

class BlockTypeTests: TestCase {
    func testBlockType() {
        assertEqual(try BlockType(0), .noCompression)
        assertEqual(try BlockType(1), .fixedHuffman)
        assertEqual(try BlockType(2), .dynamicHuffman)
        assertThrowsError(try BlockType(3))
    }
}
