/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************
 *  This file contains code that has not yet been described                   *
 ******************************************************************************/

import Test
import Stream
@testable import Compression

class BitReaderTests: TestCase {
    func testBitReader() {
        let stream = InputByteStream([
            0b0011_1100,
            0b0101_1010,
        ])
        let bitReader = BitInputStream(source: stream)

        assertEqual(try bitReader.read(), false)
        assertEqual(try bitReader.read(), false)
        assertEqual(try bitReader.read(), true)
        assertEqual(try bitReader.read(), true)

        assertEqual(try bitReader.read(), true)
        assertEqual(try bitReader.read(), true)
        assertEqual(try bitReader.read(), false)
        assertEqual(try bitReader.read(), false)

        assertEqual(try bitReader.read(), false)
        assertEqual(try bitReader.read(), true)
        assertEqual(try bitReader.read(), false)
        assertEqual(try bitReader.read(), true)

        assertEqual(try bitReader.read(), true)
        assertEqual(try bitReader.read(), false)
        assertEqual(try bitReader.read(), true)
        assertEqual(try bitReader.read(), false)
    }

    func testBitReaderCount() {
        let stream = InputByteStream([
            0b0111_0011, 0b0100_1001, 0b0100_1101, 0b1100_1011,
            0b0100_1001, 0b0010_1100, 0b0100_1001, 0b0101_0101,
            0b0000_0000, 0b0001_0001, 0b0000_0000
        ])
        let bitReader = BitInputStream(source: stream)

        assertEqual(try bitReader.read(1), 0b1)
        assertEqual(try bitReader.read(2), 0b01)
        assertEqual(try bitReader.read(8), 0b001_01110)
        assertEqual(try bitReader.read(8), 0b101_01001)
        assertEqual(try bitReader.read(8), 0b011_01001)
        assertEqual(try bitReader.read(8), 0b001_11001)
        assertEqual(try bitReader.read(8), 0b100_01001)
        assertEqual(try bitReader.read(8), 0b001_00101)
        assertEqual(try bitReader.read(8), 0b101_01001)
        assertEqual(try bitReader.read(8), 0b000_01010)
        assertEqual(try bitReader.read(7), 0b01_00000)
        assertEqual(try bitReader.read(5), 0b00100)
        assertEqual(try bitReader.read(1), 0b0)
        assertEqual(try bitReader.read(7), 0b0000000)

        assertEqual(bitReader.stored, 1)
    }
}
