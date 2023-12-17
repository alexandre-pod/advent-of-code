import Foundation

typealias HeatLossMap = [[Int]]

func main() {
    var input: HeatLossMap = []

    while let line = readLine() {
        input.append(line.map { Int(String($0))! })
    }

    print(part1(heatLossMap: input))
    print(part2(heatLossMap: input))
}

// MARK: - Part 1

func part1(heatLossMap: HeatLossMap) -> Int {

    var dijkstraMap: [DijkstraKey: Int] = [:]
    var bestSource: [DijkstraKey: DijkstraKey] = [:]

    let startKey = DijkstraKey(coordinates: Coordinates(x: 0, y: 0), direction: .right, directionLength: 0)
    dijkstraMap[startKey] = 0

    let endCoordinates = Coordinates(x: heatLossMap[0].count - 1, y: heatLossMap.count - 1)

    var remainingKeys = [startKey]

    while !remainingKeys.isEmpty {
        let smallestKey = remainingKeys.removeLast()

        let heatLossValue = dijkstraMap[smallestKey]!

        smallestKey.accessibleKeys(in: heatLossMap).forEach { nextKey in
            let nextValue = heatLossValue + heatLossMap[nextKey.coordinates]
            if nextValue < dijkstraMap[nextKey] ?? .max {
                bestSource[nextKey] = smallestKey
                dijkstraMap[nextKey] = nextValue
                remainingKeys.sortedInsertion(of: nextKey, using: { dijkstraMap[$0]! >= dijkstraMap[$1]! })
            }
        }
    }

    let bestKeyValue = dijkstraMap
        .filter { $0.key.coordinates == endCoordinates }
        .min { $0.value < $1.value }!

    let reversePath = sequence(first: bestKeyValue.key) { key in
        bestSource[key]
    }

    var displayBuffer = DisplayBuffer()

    reversePath.reversed().forEach {
        displayBuffer.pixels[$0.coordinates] = $0.direction.characterSymbol
    }

    displayBuffer.print()

    return bestKeyValue.value
}

struct DijkstraKey: Hashable {
    let coordinates: Coordinates
    let direction: Direction
    let directionLength: Int
}

extension DijkstraKey {
    func accessibleKeys(in map: HeatLossMap) -> [DijkstraKey] {
        return Direction.allCases
            .filter { $0.opposite != direction }
            .map {
                DijkstraKey(
                    coordinates: self.coordinates.apply(direction: $0),
                    direction: $0,
                    directionLength: direction == $0 ? directionLength + 1 : 1
                )
            }
            .filter { $0.directionLength <= 3 }
            .filter { map.isValidCoordinates($0.coordinates) }
    }
}

extension Direction {
    func isStraight(with other: Direction) -> Bool {
        switch (self, other) {
        case (.up, .up), (.up, .down),
            (.left, .left), (.left, .right),
            (.right, .right), (.right, .left),
            (.down, .down), (.down, .up):
            return true
        default:
            return false
        }
    }

    var opposite: Direction {
        return switch self {
        case .up: .down
        case .down: .up
        case .left: .right
        case .right: .left
        }
    }
}

// MARK: - Part 2

func part2(heatLossMap: HeatLossMap) -> Int {

    var dijkstraMap: [DijkstraKey: Int] = [:]
    var bestSource: [DijkstraKey: DijkstraKey] = [:]

    let startKey = DijkstraKey(coordinates: Coordinates(x: 0, y: 0), direction: .right, directionLength: 0)
    dijkstraMap[startKey] = 0
    let startKey2 = DijkstraKey(coordinates: Coordinates(x: 0, y: 0), direction: .down, directionLength: 0)
    dijkstraMap[startKey2] = 0

    let endCoordinates = Coordinates(x: heatLossMap[0].count - 1, y: heatLossMap.count - 1)

    var remainingKeys = [startKey, startKey2]

    while !remainingKeys.isEmpty {
        let smallestKey = remainingKeys.removeLast()

        let heatLossValue = dijkstraMap[smallestKey]!

        smallestKey.accessibleKeysPart2(in: heatLossMap).forEach { nextKey in
            let nextValue = heatLossValue + heatLossMap[nextKey.coordinates]
            if nextValue < dijkstraMap[nextKey] ?? .max {
                bestSource[nextKey] = smallestKey
                dijkstraMap[nextKey] = nextValue
                remainingKeys.sortedInsertion(of: nextKey, using: { dijkstraMap[$0]! >= dijkstraMap[$1]! })
            }
        }
    }

    let bestKeyValue = dijkstraMap
        .filter { $0.key.coordinates == endCoordinates }
        .filter { $0.key.directionLength >= 4 }
        .min { $0.value < $1.value }!

    let reversePath = sequence(first: bestKeyValue.key) { key in
        bestSource[key]
    }

    var displayBuffer = DisplayBuffer()

    reversePath.reversed().forEach {
        displayBuffer.pixels[$0.coordinates] = $0.direction.characterSymbol
    }

    displayBuffer.print()

    return bestKeyValue.value
}

extension DijkstraKey {

    func accessibleKeysPart2(in map: HeatLossMap) -> [DijkstraKey] {
        return Direction.allCases
            .filter { $0.opposite != direction }
            .map {
                DijkstraKey(
                    coordinates: self.coordinates.apply(direction: $0),
                    direction: $0,
                    directionLength: direction == $0 ? directionLength + 1 : 1
                )
            }
            .filter { map.isValidCoordinates($0.coordinates) }
            .filter { $0.directionLength <= 10 }
            .filter { $0.direction == direction || directionLength >= 4 }
    }
}

// MARK: - Visualisation

struct DisplayBuffer {
    var pixels: [Coordinates: Character] = [:]

    func print() {
        let minX = pixels.keys.map(\.x).min()!
        let maxX = pixels.keys.map(\.x).max()!
        let minY = pixels.keys.map(\.y).min()!
        let maxY = pixels.keys.map(\.y).max()!
        for y in minY...maxY {
            let line = (minX...maxX)
                .map { pixels[Coordinates(x: $0, y: y)] ?? "." }
                .map { String($0) }
                .joined()
            Swift.print(line)
        }
    }
}

extension Direction {
    var characterSymbol: Character {
        return switch self {
        case .up: "^"
        case .down: "v"
        case .left: "<"
        case .right: ">"
        }
    }
}

main()

// Sample
// 102 - 94

// input
// 1076 - 1219
