import Stream

extension GZip.Header {
    public enum System: RawRepresentable {
        case fat
        case amiga
        case vms
        case unix
        case vmCMS
        case atari
        case hpfs
        case macintosh
        case zSystem
        case cpM
        case tops20
        case ntfs
        case qdos
        case acorn
        case unknown(UInt8)

        public var rawValue: UInt8 {
            switch self {
            case .fat: return 0
            case .amiga: return 1
            case .vms: return 2
            case .unix: return 3
            case .vmCMS: return 4
            case .atari: return 5
            case .hpfs: return 6
            case .macintosh: return 7
            case .zSystem: return 8
            case .cpM: return 9
            case .tops20: return 10
            case .ntfs: return 11
            case .qdos: return 12
            case .acorn: return 13
            case .unknown(let int): return int
            }
        }

        init(rawValue: UInt8) {
            switch rawValue {
            case 0: self = .fat
            case 1: self = .amiga
            case 2: self = .vms
            case 3: self = .unix
            case 4: self = .vmCMS
            case 5: self = .atari
            case 6: self = .hpfs
            case 7: self = .macintosh
            case 8: self = .zSystem
            case 9: self = .cpM
            case 10: self = .tops20
            case 11: self = .hpfs
            case 12: self = .qdos
            case 13: self = .acorn
            default: self = .unknown(rawValue)
            }
        }
    }
}

extension GZip.Header.System {
    static func decode<T>(
        from stream: T,
        crc32Stream: CRC32Stream
    ) async throws -> Self
        where T: StreamReader
    {
        let rawOperatingSystem = try await stream.read(UInt8.self)
        let operatingSystem = Self(rawValue: rawOperatingSystem)
        try crc32Stream.write(rawOperatingSystem)
        return operatingSystem
    }
}
