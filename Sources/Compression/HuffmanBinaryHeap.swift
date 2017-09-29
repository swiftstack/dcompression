/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

struct HuffmanBinaryHeap {
    let tree: [Int?]

    init(from values: [HuffmanValue]) {
        guard values.count > 0 else {
            self.tree = []
            return
        }

        let values = values.sorted()

        let maxBits = values.last!.bitsCount
        let nodesCount = 1 << (maxBits + 1)
        var tree = [Int?](repeating: nil, count: nodesCount)

        var code: UInt16 = 0
        var currentBitsCount = 0
        for value in values {
            if value.bitsCount != currentBitsCount {
                code <<= (value.bitsCount - currentBitsCount)
                currentBitsCount = value.bitsCount
            }

            var index = 0
            var mask = UInt16(1 << (currentBitsCount - 1))
            for _ in 0..<currentBitsCount {
                switch code & mask == 0 {
                case true: index = index * 2 + 1
                case false: index = index * 2 + 2
                }
                mask >>= 1
            }
            tree[index] = value.value

            code += 1
        }

        self.tree = tree
    }
}

extension HuffmanBinaryHeap {
    init(from ranges: [(values: CountableClosedRange<Int>, bitsCount: Int)]) {
        var huffmanValues = [HuffmanValue]()
        for range in ranges {
            guard range.bitsCount > 0 else {
                continue
            }
            for value in range.values {
                let huffmanValue = HuffmanValue(
                    value: value, bitsCount: range.bitsCount)
                huffmanValues.append(huffmanValue)
            }
        }
        self.init(from: huffmanValues)
    }
}

extension HuffmanBinaryHeap {
    init<T: Collection>(from array: T)
        where T.Element == Int, T.Index == Int, T.IndexDistance == Int
    {
        var huffmanValues = [HuffmanValue]()
        for i in 0..<array.count {
            let bitsCount = array[array.startIndex + i]
            guard bitsCount > 0 else {
                continue
            }
            let value = HuffmanValue(value: i, bitsCount: bitsCount)
            huffmanValues.append(value)
        }
        self.init(from: huffmanValues)
    }
}

extension HuffmanBinaryHeap {
    func read<T: BitReader>(from bitReader: T) throws -> Int? {
        var index = 0
        while true {
            let nextBit = try bitReader.read()
            switch nextBit {
            case false: index = index * 2 + 1
            case true: index = index * 2 + 2
            }
            guard index < tree.count else {
                return nil
            }
            if let value = tree[index] {
                return value
            }
        }
    }
}

extension HuffmanBinaryHeap: Equatable {
    static func ==(lhs: HuffmanBinaryHeap, rhs: HuffmanBinaryHeap) -> Bool {
        return lhs.tree.elementsEqual(rhs.tree, by: { $0 == $1 })
    }
}
