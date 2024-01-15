import Test

@testable import DCompression

test("CRC32") {
    let bytes = [UInt8]("123456789".utf8)
    let crc = CRC32.calculate(bytes: bytes)
    expect(crc == 0xcbf43926)
}

test("CRC32Fox") {
    let bytes = [UInt8]("The quick brown fox jumps over the lazy dog".utf8)
    let crc = CRC32.calculate(bytes: bytes)
    expect(crc == 0x414fa339)
}

test("CRC32Zero") {
    let bytes = [UInt8]("".utf8)
    let crc = CRC32.calculate(bytes: bytes)
    expect(crc == 0x0)
}

test("CRC32Stream") {
    let bytes = [UInt8]("The quick brown fox jumps over the lazy dog".utf8)
    let crc32Stream = CRC32Stream()
    _ = try? crc32Stream.write(bytes)
    expect(crc32Stream.value == 0x414fa339)
}

await run()
