import Stream

extension TAR.Entry.Kind {
    init<T: StreamReader>(decoding stream: T) async throws {
        let value = try await stream.read(UInt8.self)
        guard let kind = TAR.Entry.Kind(rawValue: value) else {
            throw TAR.Error.invalidKind(value)
        }
        self = kind
    }
}
