import Stream

extension Deflate {
    public enum Error: Swift.Error {
        case insufficientData
        case invalidData
    }

    static var fixedHuffmanCodesLengths: HuffmanBinaryHeap = {
        return HuffmanBinaryHeap(from: [
            (values: 0...143, bitsCount: 8),
            (values: 144...255, bitsCount: 9),
            (values: 256...279, bitsCount: 7),
            (values: 280...287, bitsCount: 8)
        ])
    }()

    static var fixedHuffmanDistances: HuffmanBinaryHeap = {
        return HuffmanBinaryHeap(from: [(values: 0...29, bitsCount: 5)])
    }()

    public static func decode<T>(from stream: T) async throws -> [UInt8]
        where T: StreamReader
    {
        var result = [UInt8]()

        let bitReader = BitInputStream(source: stream)

        var isLastBlock = false

        while !isLastBlock {
            isLastBlock = try await bitReader.read()

            let blockType = try BlockType(try await bitReader.read(2))

            switch blockType {
            case .noCompression:
                bitReader.flush()
                try await copyStored(to: &result, from: stream)

            case .fixedHuffman:
                try await inflateFixed(to: &result, from: bitReader)

            case .dynamicHuffman:
                try await inflateDynamic(to: &result, from: bitReader)
            }
        }
        return result
    }

    static func copyStored<T>(
        to result: inout [UInt8],
        from stream: T
    ) async throws where T: StreamReader {
        let size = try await stream.read(UInt16.self).bigEndian
        let nsize = try await stream.read(UInt16.self).bigEndian
        guard size == ~nsize else {
            throw Error.invalidData
        }
        try await stream.read(count: Int(size)) { block in
            result.append(contentsOf: block)
        }
    }

    static func inflateFixed<T>(
        to result: inout [UInt8],
        from bitReader: T
    ) async throws where T: BitReader {
        try await inflate(
            to: &result,
            from: bitReader,
            codes: fixedHuffmanCodesLengths,
            distances: fixedHuffmanDistances)
    }

    static func inflateDynamic<T>(
        to result: inout [UInt8],
        from bitReader: T
    ) async throws where T: BitReader {
        let valueCodesCount = try await bitReader.read(5) + 257
        let distanceCodesCount = try await bitReader.read(5) + 1
        let lengthsCodesCount = try await bitReader.read(4) + 4

        guard lengthsCodesCount <= LengthBitLengths.order.count else {
            throw Error.invalidData
        }

        var lengthCodes = [Int](repeating: 0, count: 19)
        for i in 0..<lengthsCodesCount {
            lengthCodes[LengthBitLengths.order[i]] = try await bitReader.read(3)
        }
        let lengthsOfLengths = HuffmanBinaryHeap(from: lengthCodes)

        var lengths = [Int]()
        func repeatLength(_ length: Int, count: Int) {
            for _ in 0..<count {
                lengths.append(length)
            }
        }
        while lengths.count < valueCodesCount + distanceCodesCount {
            guard
                let code = try await lengthsOfLengths.read(from: bitReader)
            else {
                throw Error.invalidData
            }

            switch code {
            case 0...15:
                lengths.append(code)
            case 16:
                let repeatCount = try await bitReader.read(2) + 3
                guard let lastLength = lengths.last else {
                    throw Error.invalidData
                }
                repeatLength(lastLength, count: repeatCount)
            case 17:
                let repeatCount = try await bitReader.read(3) + 3
                repeatLength(0, count: repeatCount)
            case 18:
                let repeatCount = try await bitReader.read(7) + 11
                repeatLength(0, count: repeatCount)
            default:
                throw Error.invalidData
            }
        }

        let codesLengths = HuffmanBinaryHeap(from: lengths[..<valueCodesCount])
        let distances = HuffmanBinaryHeap(from: lengths[valueCodesCount...])

        try await inflate(
            to: &result,
            from: bitReader,
            codes: codesLengths,
            distances: distances)
    }

    static func inflate<T>(
        to result: inout [UInt8],
        from bitReader: T,
        codes: HuffmanBinaryHeap,
        distances: HuffmanBinaryHeap
    ) async throws
        where T: BitReader
    {
        while true {
            guard let value = try await codes.read(from: bitReader) else {
                throw Error.invalidData
            }
            switch value {
            case 0..<256:
                result.append(UInt8(value))
            case 256:
                return
            case 257...285:
                var length = LengthCodes.length(for: value)
                let lengthExtraBits = LengthCodes.extraBitsCount(for: value)
                if lengthExtraBits > 0 {
                    length += try await bitReader.read(lengthExtraBits)
                }

                guard
                    let code = try await distances.read(from: bitReader),
                    code >= 0 && code <= 29
                else {
                        throw Error.invalidData
                }
                var distance = DistanceCodes.distance(for: code)
                let distanceExtraBits = DistanceCodes.extraBitsCount(for: code)
                if distanceExtraBits > 0 {
                    distance += try await bitReader.read(distanceExtraBits)
                }

                let startIndex = result.count - distance
                let endIndex = startIndex + length
                guard startIndex >= 0, endIndex > startIndex else {
                    throw Error.invalidData
                }
                for index in startIndex..<endIndex {
                    result.append(result[index])
                }
            default:
                throw Error.invalidData
            }
        }
    }
}

extension Deflate {
    public static func decode(bytes: [UInt8]) async throws -> [UInt8] {
        let stream = InputByteStream(bytes)
        return try await decode(from: stream)
    }
}

@available(*, deprecated, message: "Use Deflate.decode")
public typealias Inflate = Deflate
