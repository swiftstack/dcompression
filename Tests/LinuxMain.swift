import XCTest
@testable import CompressionTests

XCTMain([
    testCase(BitReaderTests.allTests),
    testCase(BlockTypeTests.allTests),
    testCase(CRC32Tests.allTests),
    testCase(InflateTests.allTests),
    testCase(HuffmanBinaryHeapTests.allTests),
])
