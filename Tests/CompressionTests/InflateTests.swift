import Test
@testable import Compression

class InflateTests: TestCase {
    func testInflateNoCompression() {
        let stream = TestInputStream(bytes: [
            0b0000_0001, // Last block, no compression
            0b0000_1001, 0b0000_0000, // Len - 9, LSB
            0b1111_0110, 0b1111_1111, // nLen
            1, 2, 3, 4, 5, 6, 7, 8, 9 // Data
        ])
        do {
            let bytes = try Inflate.decode(from: stream)
            assertEqual(bytes, [1, 2, 3, 4, 5, 6, 7, 8, 9])
        } catch {
            fail(String(describing: error))
        }

        assertThrowsError(try Inflate.decode(from: stream))
    }

    func testInflateFixedHuffman() {
        let stream = TestInputStream(bytes: [
            0b0111_0011, 0b0100_1001, 0b0100_1101, 0b1100_1011,
            0b0100_1001, 0b0010_1100, 0b0100_1001, 0b0101_0101,
            0b0000_0000, 0b0001_0001, 0b0000_0000
        ])
        do {
            let bytes = try Inflate.decode(from: stream)
            assertEqual(bytes, [UInt8]("Deflate late".utf8))
        } catch {
            fail(String(describing: error))
        }

        assertThrowsError(try Inflate.decode(from: stream))
    }

    func testInflateDynamicHuffman() {
        let stream = TestInputStream(bytes: [
            0b00001100, 0b11001000, 0b01000001, 0b00001010,
            0b10000000, 0b00100000, 0b00010000, 0b00000101,
            0b11010000, 0b01111101, 0b11010000, 0b00011101,
            0b11111110, 0b00001001, 0b10111010, 0b10000100,
            0b11101011, 0b10100000, 0b00101011, 0b01001100,
            0b11111010, 0b10110101, 0b00000001, 0b00011101,
            0b00100001, 0b00100111, 0b10100001, 0b11011011,
            0b11010111, 0b01011011, 0b10111110, 0b11010000,
            0b10101101, 0b11011100, 0b11100010, 0b01001111,
            0b00010101, 0b11010111, 0b01101110, 0b00000011,
            0b11011101, 0b01110000, 0b00110010, 0b11110110,
            0b10100110, 0b01010110, 0b00100000, 0b10000110,
            0b00111101, 0b00011100, 0b00011011, 0b10001110,
            0b01001010, 0b00011001, 0b11111100, 0b00011111,
            0b10010010, 0b10100110, 0b00001110, 0b00100110,
            0b11111000, 0b00100101, 0b00001110, 0b11100110,
            0b11001100, 0b11101000, 0b00111010, 0b00001001,
            0b01101101, 0b10001101, 0b01001001, 0b11000101,
            0b01011001, 0b11011111, 0b01110101, 0b11111001,
            0b00000110, 0b00000000

        ])
        do {
            let bytes = try Inflate.decode(from: stream)
            let expected = [UInt8](
                ("Congratulations on becoming an MCP. " +
                "Please be advised that effective immediately\r\n").utf8)
            assertEqual(bytes, expected)
        } catch {
            fail(String(describing: error))
        }
        // the stream should be empty
        assertThrowsError(try Inflate.decode(from: stream))
        // convenience api
        assertNoThrow(try Inflate.decode(bytes: stream.bytes))
    }
}
