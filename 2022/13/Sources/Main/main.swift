import Foundation

struct Packet {
    let content: [PacketContent]
}

enum PacketContent: Equatable {
    case integer(Int)
    indirect case list([PacketContent])
}

typealias PacketPairs = [(Packet, Packet)]

func main() {
    var packetPairs: PacketPairs = []

    var packetPair: [Packet] = []

    while let line = readLine() {
        if line.isEmpty {
            packetPairs.append((packetPair[0], packetPair[1]))
            packetPair = []
        } else {
            packetPair.append(parsePacket(from: line)!)
        }
    }
    packetPairs.append((packetPair[0], packetPair[1]))
    packetPair = []

    print(part1(packetPairs: packetPairs))
    print(part2(packetPairs: packetPairs))
}

// MARK: - Part 1

func part1(packetPairs: PacketPairs) -> Int {
    return packetPairs
        .enumerated()
        .filter { compare($0.element.0, $0.element.1) == .orderedAscending }
        .map { $0.offset + 1 }
        .reduce(0, +)
}

func compare(_ packet1: Packet, _ packet2: Packet) -> ComparisonResult {
    let comparisonResult = compare(packet1.content, packet2.content)
    guard comparisonResult == .orderedSame else { return comparisonResult }
    if packet1.content.count == packet2.content.count {
        fatalError("SAME LENGTH: Unknown comparison result")
    }
    return packet1.content.count <= packet2.content.count ? .orderedAscending : .orderedDescending
}

func compare(_ list1: [PacketContent], _ list2: [PacketContent]) -> ComparisonResult {
    for (content1, content2) in zip(list1, list2) {
        let comparisonResult = compare(content1, content2)
        if comparisonResult != .orderedSame {
            return comparisonResult
        }
    }
    if list1.count == list2.count {
        return .orderedSame
    }
    return list1.count > list2.count ? .orderedDescending : .orderedAscending
}

func compare(_ content1: PacketContent, _ content2: PacketContent) -> ComparisonResult {
    switch (content1, content2) {
    case let (.integer(val1), .integer(val2)):
        if val1 == val2 {
            return .orderedSame
        }
        return val1 < val2 ? .orderedAscending : .orderedDescending
    case let (.list(list1), .list(list2)):
        return compare(list1, list2)
    case let (.list(list1), .integer(val2)):
        return compare(list1, [.integer(val2)])
    case let (.integer(val1), .list(list2)):
        return compare([.integer(val1)], list2)
    }
}

// MARK: - Part 2

func part2(packetPairs: PacketPairs) -> Int {

    let dividerPacket1 = Packet(content: [.list([.integer(2)])])
    let dividerPacket2 = Packet(content: [.list([.integer(6)])])

    let allPackets = packetPairs.flatMap { [$0.0, $0.1] } + [dividerPacket1, dividerPacket2]

    let sortedPackets = allPackets.sorted { compare($0, $1) == .orderedAscending }
    let firstDivider = sortedPackets.firstIndex { $0.content == dividerPacket1.content }! + 1
    let secondDivider = sortedPackets.firstIndex { $0.content == dividerPacket2.content }! + 1

    return firstDivider * secondDivider
}

// MARK: - Debug

extension Packet: CustomStringConvertible {
    var description: String {
        return "[" + content.map(\.description).joined(separator: ",") + "]"
    }
}

extension PacketContent: CustomStringConvertible {
    var description: String {
        switch self {
        case .integer(let int):
            return String(int)
        case .list(let array):
            return "[" + array.map(\.description).joined(separator: ",") + "]"
        }
    }
}

extension ComparisonResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case .orderedAscending:
            return "orderedAscending"
        case .orderedSame:
            return "orderedSame"
        case .orderedDescending:
            return "orderedDescending"
        }
    }
}

main()
