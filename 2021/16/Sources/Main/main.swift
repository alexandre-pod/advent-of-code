import Foundation

struct Packet {
    let version: Int
    let type: PacketType

    enum PacketType {
        case literal(value: Int)
        case `operator`(
            type: Int,
            lengthType: LengthType,
            subPackets: [Packet]
        )
    }

    enum LengthType {
        case subPacketLength(length: Int)
        case subPacketCount(count: Int)
    }
}

struct TokenFeed {

    private let bits: [Int]
    private(set) var currentIndex = 0
    private(set) var endOfFeed = false

    enum Error: Swift.Error {
        case endOfFeed
        case unexpectedEndOfFeed
    }

    init(bits: [Int]) {
        self.bits = bits
    }

    var currentToken: Int? {
        guard !endOfFeed else { return nil }
        return bits[currentIndex]
    }

    var nextToken: Int? {
        guard !endOfFeed else { return nil }
        return bits[currentIndex + 1]
    }

    mutating func consumeCurrentToken() -> Int? {
        guard !endOfFeed else { return nil }
        defer {
            if bits.indices.last == currentIndex {
                endOfFeed = true
            } else {
                currentIndex += 1
            }
        }
        return bits[currentIndex]
    }
}

extension TokenFeed {
    mutating func consumeTokens(_ n: Int) throws -> [Int] {
        let tokens = (0..<n).map { _ in self.consumeCurrentToken() }

        guard tokens.allSatisfy({ $0 != nil }) else {
            throw Error.unexpectedEndOfFeed
        }

        return tokens.compactMap { $0 }
    }
}

// MARK: - Main

func main() {

    let bits: [Int] = readLine()!.flatMap { $0.hexToBin }

    print(part1(bits: bits))
    print(part2(bits: bits))
}

// MARK: - Part 1

func part1(bits: [Int]) -> Int {

    var tokenFeed = TokenFeed(bits: bits)
    let packet = try! parsePacket(&tokenFeed)
    return getVersions(from: packet).reduce(0, +)
}

func getVersions(from packet: Packet) -> [Int] {
    switch packet.type {
    case .literal:
        return [packet.version]
    case .operator(_, _, let subPackets):
        return [packet.version] + subPackets.flatMap { getVersions(from: $0) }
    }
}

// MARK: - Part 2

func part2(bits: [Int]) -> Int {

    var tokenFeed = TokenFeed(bits: bits)
    let packet = try! parsePacket(&tokenFeed)
    return compute(packet: packet)
}

func compute(packet: Packet) -> Int {
    switch packet.type {
    case .literal(let value):
        return value
    case .operator(let type, _, let subPackets):
        switch type {
        case 0:
            return subPackets.map { compute(packet: $0) }.reduce(0, +)
        case 1:
            return subPackets.map { compute(packet: $0) }.reduce(1, *)
        case 2:
            return subPackets.map { compute(packet: $0) }.min()!
        case 3:
            return subPackets.map { compute(packet: $0) }.max()!
        case 5:
            let first = compute(packet: subPackets[0])
            let second = compute(packet: subPackets[1])
            return first > second ? 1 : 0
        case 6:
            let first = compute(packet: subPackets[0])
            let second = compute(packet: subPackets[1])
            return first < second ? 1 : 0
        case 7:
            let first = compute(packet: subPackets[0])
            let second = compute(packet: subPackets[1])
            return first == second ? 1 : 0
        default: fatalError()
        }
    }
}

// MARK: - Common

func parsePacket(_ tokenFeed: inout TokenFeed) throws -> Packet {
    guard tokenFeed.currentToken != nil else { fatalError("Unexpected end of token") }
    let version = try tokenFeed.consumeTokens(3).binToInt!
    let type = try tokenFeed.consumeTokens(3).binToInt!

    let bitsType: Packet.PacketType
    switch type {
    case 4:
        try bitsType = .literal(value: parseLiteralValue(&tokenFeed))
    default:
        let lengthType = try parseLengthType(&tokenFeed)
        bitsType = .operator(
            type: type,
            lengthType: lengthType,
            subPackets: try parseSubPackets(for: lengthType, &tokenFeed)
        )

    }
    return Packet(version: version, type: bitsType)
}

func parseLiteralValue(_ tokenFeed: inout TokenFeed) throws -> Int {
    var bits: [Int] = []
    while tokenFeed.consumeCurrentToken() == 1 {
        try bits.append(contentsOf: tokenFeed.consumeTokens(4))
    }
    try bits.append(contentsOf: tokenFeed.consumeTokens(4))
    return bits.binToInt!
}

func parseLengthType(_ tokenFeed: inout TokenFeed) throws -> Packet.LengthType {

    let lengthType = tokenFeed.consumeCurrentToken()!
    switch lengthType {
    case 0:
        return try .subPacketLength(length: tokenFeed.consumeTokens(15).binToInt!)
    case 1:
        return try .subPacketCount(count: tokenFeed.consumeTokens(11).binToInt!)
    default:
        fatalError()
    }
}

func parseSubPackets(for lengthType: Packet.LengthType, _ tokenFeed: inout TokenFeed) throws -> [Packet] {

    switch lengthType {
    case .subPacketCount(let count):
        return try (0..<count).map { _ in try parsePacket(&tokenFeed) }
    case .subPacketLength(let length):
        let initialIndex = tokenFeed.currentIndex
        let endIndex = initialIndex + length
        var packets: [Packet] = []
        while tokenFeed.currentIndex < endIndex && !tokenFeed.endOfFeed {
            try packets.append(parsePacket(&tokenFeed))
        }
        return packets
    }

}

extension String {
    var binToInt: Int? {
        return Int(self, radix: 2)
    }

    func leftPad(size: Int, character: Character) -> String {
        var result = self
        while result.count < 4 {
            result = String(character) + result
        }
        return result
    }
}

extension Character {
    var hexToBin: [Int] {
        String(Int(String(self), radix: 16)!, radix: 2)
            .leftPad(size: 4, character: "0")
            .map { Int(String($0))! }
    }
}

extension Array where Element == Int {
    var binToInt: Int? {
        assert(allSatisfy { $0 == 0 || $0 == 1 })
        return self.map { String($0) }.joined().binToInt
    }
}

main()
