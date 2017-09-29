enum BlockType {
    case noCompression
    case fixedHuffman
    case dynamicHuffman
}

extension BlockType {
    enum Error: Swift.Error {
        case invalidType
    }

    init(_ value: Int) throws {
        switch value {
        case 0: self = .noCompression
        case 1: self = .fixedHuffman
        case 2: self = .dynamicHuffman
        default: throw Error.invalidType
        }
    }
}
