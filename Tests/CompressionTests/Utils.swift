import Stream

class TestInputStream: InputStream {
    enum Error: Swift.Error {
        case insufficientData
    }

    let bytes: [UInt8]
    var index = 0

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    func read(to buffer: UnsafeMutableRawBufferPointer) throws -> Int {
        guard bytes.count - index >= buffer.count else {
            throw Error.insufficientData
        }
        buffer.copyBytes(from: bytes[index..<index+buffer.count])
        index += buffer.count
        return buffer.count
    }
}
