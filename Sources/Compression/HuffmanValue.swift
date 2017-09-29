/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

struct HuffmanValue {
    let value: Int
    let bitsCount: Int
}

extension HuffmanValue: Comparable {
    static func <(lhs: HuffmanValue, rhs: HuffmanValue) -> Bool {
        if lhs.bitsCount == rhs.bitsCount {
            return lhs.value < rhs.value
        } else {
            return lhs.bitsCount < rhs.bitsCount
        }
    }

    static func ==(lhs: HuffmanValue, rhs: HuffmanValue) -> Bool {
        return lhs.bitsCount == rhs.bitsCount && lhs.value == rhs.value
    }
}
