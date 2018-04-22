/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

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
