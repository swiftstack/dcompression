import Test
@testable import DCompression

class BlockTypeTests: TestCase {
    func testBlockType() {
        expect(try BlockType(0) == .noCompression)
        expect(try BlockType(1) == .fixedHuffman)
        expect(try BlockType(2) == .dynamicHuffman)
        expect(throws: BlockType.Error.invalidType) {
            try BlockType(3)
        }
    }
}
