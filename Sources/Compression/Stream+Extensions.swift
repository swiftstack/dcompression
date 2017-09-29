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

extension InputStream {
    func read(_ type: UInt16.Type) throws -> UInt16 {
        var result: UInt16 = 0
        try withUnsafeMutableBytes(of: &result) { buffer in
            guard try read(to: buffer) == 2 else {
                throw Inflate.Error.insufficientData
            }
        }
        return result
    }
}
