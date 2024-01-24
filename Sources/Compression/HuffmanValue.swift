struct HuffmanValue: Equatable {
    let value: Int
    let bitsCount: Int
}

extension HuffmanValue: Comparable {
    static func < (lhs: HuffmanValue, rhs: HuffmanValue) -> Bool {
        if lhs.bitsCount == rhs.bitsCount {
            return lhs.value < rhs.value
        } else {
            return lhs.bitsCount < rhs.bitsCount
        }
    }
}
