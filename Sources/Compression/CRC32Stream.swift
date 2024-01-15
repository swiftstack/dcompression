import Stream

public class CRC32Stream: OutputStream {
    var c: UInt32 = 0xffff_ffff

    public var value: UInt32 {
        return c ^ 0xffff_ffff
    }

    @inline(__always)
    public func write(_ byte: UInt8) throws {
        c = CRC32.table[Int((c ^ UInt32(byte)) & 0xff)] ^ (c >> 8)
    }

    @inline(__always)
    public func write(_ bytes: UnsafeRawBufferPointer) throws {
        try bytes.forEach(write)
    }

    @inlinable
    public func write(
        from pointer: UnsafeRawPointer,
        byteCount count: Int
    ) async throws -> Int {
        try write(.init(start: pointer, count: count))
        return count
    }
}

extension CRC32Stream {
    @inlinable
    public func write<T: BinaryInteger>(_ value: T) throws {
        var value = value
        try withUnsafeBytes(of: &value, write)
    }

    @inlinable
    public func write(_ bytes: [UInt8]) throws {
        try bytes.withUnsafeBytes(write)
    }
}
