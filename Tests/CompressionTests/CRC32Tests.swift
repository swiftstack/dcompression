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

import Test
@testable import Compression

class CRC32Tests: TestCase {
    func testCRC32() {
        let bytes = [UInt8]("123456789".utf8)
        let crc = CRC32.calculate(bytes: bytes)
        assertEqual(crc, 0xcbf43926)
    }

    func testCRC32Fox() {
        let bytes = [UInt8]("The quick brown fox jumps over the lazy dog".utf8)
        let crc = CRC32.calculate(bytes: bytes)
        assertEqual(crc, 0x414fa339)
    }

    func testCRC32Zero() {
        let bytes = [UInt8]("".utf8)
        let crc = CRC32.calculate(bytes: bytes)
        assertEqual(crc, 0x0)
    }

    func testCRC32Stream() {
        let bytes = [UInt8]("The quick brown fox jumps over the lazy dog".utf8)
        let crc32Stream = CRC32Stream()
        _ = try? crc32Stream.write(bytes)
        assertEqual(crc32Stream.value, 0x414fa339)
    }
}
