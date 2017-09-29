/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

struct LengthBitLengths {
    static let order = [ // Order of the bit length code lengths
        16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
    ]
}

struct LengthCodes {
    static let extraBits = [ // extra bits for codes 257-285
        0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
        3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0
    ]

    static let values = [ // lengths for codes 257-285
        3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
        35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258
    ]

    static func extraBitsCount(for code: Int) -> Int {
        assert(code >= 257 && code <= 285)
        return extraBits[code - 257]
    }

    static func length(for code: Int) -> Int {
        assert(code >= 257 && code <= 285)
        return values[code - 257]
    }
}

struct DistanceCodes {
    static let extraBits = [ // extra bits for codes 0-29
        0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6,
        7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13
    ]

    static let values = [ // distances for codes 0-29
        1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193,
        257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145,
        8193, 12289, 16385, 24577
    ]

    static func extraBitsCount(for code: Int) -> Int {
        assert(code >= 0 && code <= 29)
        return extraBits[code]
    }

    static func distance(for code: Int) -> Int {
        assert(code >= 0 && code <= 29)
        return values[code]
    }
}
