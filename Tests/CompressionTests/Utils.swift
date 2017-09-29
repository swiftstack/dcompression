/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

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
