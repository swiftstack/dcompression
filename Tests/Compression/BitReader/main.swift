import Test
import Stream

@testable import DCompression

test("BitReader") {
    let stream = InputByteStream([
        0b0011_1100,
        0b0101_1010,
    ])
    let bitReader = BitInputStream(source: stream)

    expect(try await bitReader.read() == false)
    expect(try await bitReader.read() == false)
    expect(try await bitReader.read() == true)
    expect(try await bitReader.read() == true)

    expect(try await bitReader.read() == true)
    expect(try await bitReader.read() == true)
    expect(try await bitReader.read() == false)
    expect(try await bitReader.read() == false)

    expect(try await bitReader.read() == false)
    expect(try await bitReader.read() == true)
    expect(try await bitReader.read() == false)
    expect(try await bitReader.read() == true)

    expect(try await bitReader.read() == true)
    expect(try await bitReader.read() == false)
    expect(try await bitReader.read() == true)
    expect(try await bitReader.read() == false)
}

test("BitReaderCount") {
    let stream = InputByteStream([
        0b0111_0011, 0b0100_1001, 0b0100_1101, 0b1100_1011,
        0b0100_1001, 0b0010_1100, 0b0100_1001, 0b0101_0101,
        0b0000_0000, 0b0001_0001, 0b0000_0000
    ])
    let bitReader = BitInputStream(source: stream)

    expect(try await bitReader.read(1) == 0b1)
    expect(try await bitReader.read(2) == 0b01)
    expect(try await bitReader.read(8) == 0b001_01110)
    expect(try await bitReader.read(8) == 0b101_01001)
    expect(try await bitReader.read(8) == 0b011_01001)
    expect(try await bitReader.read(8) == 0b001_11001)
    expect(try await bitReader.read(8) == 0b100_01001)
    expect(try await bitReader.read(8) == 0b001_00101)
    expect(try await bitReader.read(8) == 0b101_01001)
    expect(try await bitReader.read(8) == 0b000_01010)
    expect(try await bitReader.read(7) == 0b01_00000)
    expect(try await bitReader.read(5) == 0b00100)
    expect(try await bitReader.read(1) == 0b0)
    expect(try await bitReader.read(7) == 0b0000000)

    expect(bitReader.stored == 1)
}

await run()
