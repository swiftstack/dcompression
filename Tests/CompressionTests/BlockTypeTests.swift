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
