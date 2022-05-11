import Stream

extension TAR.Entry {
    init<T: StreamReader>(decoding stream: T) async throws {
        self.name = try await stream.readFixedWidthString(count: 100)
        self.mode = try await Int(stream.read(UInt64.self))
        self.uid = try await Int(stream.read(UInt64.self))
        self.gid = try await Int(stream.read(UInt64.self))
        self.size = try await stream.readFixedWidthOctal(count: 12)
        self.mtime = try await stream.read(count: 12, as: String.self)
        self.chksum = try await stream.read(count: 8, as: String.self)
        self.typeflag = try await .init(decoding: stream)
        self.linkname = try await stream.read(count: 100, as: String.self)
        self.magic = try await stream.read(count: 6)
        self.version = try await stream.read(count: 2)
        self.uname = try await stream.read(count: 32)
        self.gname = try await stream.read(count: 32)
        self.devmajor = try await stream.read(count: 8)
        self.devminor = try await stream.read(count: 8)
        self.prefix = try await stream.read(count: 155)
        self.descriptor = try await stream.read(count: 12)
        self.data = try await stream.read(count: size)
        if size % 512 > 0 {
            try await stream.consume(count: 512 - size % 512)
        }
    }
}

// MARK: Array extension

extension Array where Element == TAR.Entry {
    init<T: StreamReader>(decoding stream: T) async throws {
        var result = [Element]()

        while try await stream.cache(count: 1) {
            try await result.append(.init(decoding: stream))
        }

        self = result
    }

    init(decoding bytes: [UInt8]) async throws {
        try await self.init(decoding: InputByteStream(bytes))
    }
}

// MARK: Stream utils

extension StreamReader {
    func readFixedWidthString(count: Int) async throws -> String {
        try await read(count: count, as: String.self)
            .trimmingCharacters(in: ["\0", " "])
    }

    func readFixedWidthOctal(count: Int) async throws -> Int {
        let string = try await readFixedWidthString(count: count)
        guard !string.isEmpty else { return 0 }
        guard let value = Int(string, radix: 0o10) else {
            throw TAR.Error.invalidSize(string)
        }
        return value
    }
}
