import XCTest

extension BitReaderTests {
    static let __allTests = [
        ("testBitReader", testBitReader),
        ("testBitReaderCount", testBitReaderCount),
    ]
}

extension BlockTypeTests {
    static let __allTests = [
        ("testBlockType", testBlockType),
    ]
}

extension CRC32Tests {
    static let __allTests = [
        ("testCRC32", testCRC32),
        ("testCRC32Fox", testCRC32Fox),
        ("testCRC32Stream", testCRC32Stream),
        ("testCRC32Zero", testCRC32Zero),
    ]
}

extension GZipTests {
    static let __allTests = [
        ("testDecode", testDecode),
    ]
}

extension HuffmanBinaryHeapTests {
    static let __allTests = [
        ("testHeapFromRange", testHeapFromRange),
        ("testHeapFromValues", testHeapFromValues),
        ("testRead", testRead),
    ]
}

extension InflateTests {
    static let __allTests = [
        ("testInflateDynamicHuffman", testInflateDynamicHuffman),
        ("testInflateFixedHuffman", testInflateFixedHuffman),
        ("testInflateNoCompression", testInflateNoCompression),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BitReaderTests.__allTests),
        testCase(BlockTypeTests.__allTests),
        testCase(CRC32Tests.__allTests),
        testCase(GZipTests.__allTests),
        testCase(HuffmanBinaryHeapTests.__allTests),
        testCase(InflateTests.__allTests),
    ]
}
#endif
