/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

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
