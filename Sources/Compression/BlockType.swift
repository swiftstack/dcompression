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
