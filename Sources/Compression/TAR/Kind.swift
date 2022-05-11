import Stream

extension TAR.Entry {
    public enum Kind {
        case file
        case link
        case reserved2
        case character
        case block
        case directory
        case fifo
        case reserved7
        case fileHeader
        case globalHeader
        case longName
        case longLink
    }
}

extension TAR.Entry.Kind: RawRepresentable {
    public var rawValue: UInt8 {
        switch self {
        case .file: return .init(ascii: "0")
        case .link: return .init(ascii: "1")
        case .reserved2: return .init(ascii: "2")
        case .character: return .init(ascii: "3")
        case .block: return .init(ascii: "4")
        case .directory: return .init(ascii: "5")
        case .fifo: return .init(ascii: "6")
        case .reserved7: return .init(ascii: "7")
        case .fileHeader: return .init(ascii: "x")
        case .globalHeader: return .init(ascii: "g")
        case .longName: return .init(ascii: "L")
        case .longLink: return .init(ascii: "K")
        }
    }

    public init?(rawValue: UInt8) {
        switch rawValue {
        case 0, .init(ascii: "0"): self = .file
        case .init(ascii: "1"): self = .link
        case .init(ascii: "2"): self = .reserved2
        case .init(ascii: "3"): self = .character
        case .init(ascii: "4"): self = .block
        case .init(ascii: "5"): self = .directory
        case .init(ascii: "6"): self = .fifo
        case .init(ascii: "7"): self = .reserved7
        case .init(ascii: "x"): self = .fileHeader
        case .init(ascii: "g"): self = .globalHeader
        case .init(ascii: "L"): self = .longName
        case .init(ascii: "K"): self = .longLink
        default: return nil
        }
    }
}

extension TAR.Entry.Kind {
    init<T: StreamReader>(decoding stream: T) async throws {
        let value = try await stream.read(UInt8.self)
        guard let kind = TAR.Entry.Kind(rawValue: value) else {
            throw TAR.Error.invalidKind(value)
        }
        self = kind
    }
}
