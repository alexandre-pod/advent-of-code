import Foundation

struct Position: Hashable {
    let x: Int
    let y: Int
}

struct Amphipods: Hashable {
    let category: Category
    let position: Position

    enum Category: String {
        case amber = "A"
        case bronze = "B"
        case copper = "C"
        case desert = "D"
    }
}

extension Amphipods {
    var moveCost: Int {
        switch category {
        case .amber:
            return 1
        case .bronze:
            return 10
        case .copper:
            return 100
        case .desert:
            return 1000
        }
    }
}

extension Array where Element == [Character] {
    subscript(_ position: Position) -> Character {
        self[position.y][position.x]
    }
}

struct Map: Hashable {
    let edges: [Position: [Position]]
    var amphipods: [Amphipods]
    var energySpent = 0
}

// MARK: - Main

func main() {

    var grid: [[Character]] = []

    while let line = readLine() {
        grid.append(line.map { $0 })
    }

    print(part1(grid: grid))
    print(part2(grid: grid))
}

// MARK: - Part 1

func part1(grid: [[Character]]) -> Int {
    let map = createMap(from: grid)

    return findEfficientMovesToComplete(map)?.energySpent ?? -1
}

// MARK: - Part 2

func part2(grid: [[Character]]) -> Int {
    var updatedGrid = grid
    updatedGrid.insert("  #D#C#B#A#".map { $0 }, at: 3)
    updatedGrid.insert("  #D#B#A#C#".map { $0 }, at: 4)

    let map = createMap(from: updatedGrid)

    return findEfficientMovesToComplete(map)?.energySpent ?? -1
}

// MARK: - Parsing

func createMap(from grid: [[Character]]) -> Map {
    var edges: [Position: [Position]] = [:]
    var amphipods: [Amphipods] = []

    for y in grid.indices {
        for x in grid[y].indices {
            let position = Position(x: x, y: y)
            guard grid[position].isSpaceOrAmphipod else { continue }

            edges[position] = adjacentPositions(fromPosition: position, grid: grid)
                .filter { grid[$0].isSpaceOrAmphipod }

            if let amphipodCategory = Amphipods.Category(rawValue: String(grid[position])) {
                amphipods.append(Amphipods(category: amphipodCategory, position: position))
            }
        }
    }

    return Map(edges: edges, amphipods: amphipods)
}

func adjacentPositions<T>(fromPosition position: Position, grid: [[T]]) -> [Position] {
    return (-1...1)
        .map { position.x + $0 }
        .flatMap { _x in
            (-1...1)
                .map { position.y + $0 }
                .map { _y in
                    return Position(x: _x, y: _y)
                }
        }
        .filter { $0.x == position.x || $0.y == position.y }
        .filter {
            $0.x >= 0
            && $0.x < grid[0].count
            && $0.y >= 0
            && $0.y < grid.count
            && ($0.x != position.x || $0.y != position.y)
        }
}

extension Character {
    var isSpaceOrAmphipod: Bool {
        switch self {
        case ".", "A", "B", "C", "D":
            return true
        default:
            return false
        }
    }
}

// MARK: - Common

func findEfficientMovesToComplete(_ map: Map) -> Map? {
    var maps = Heap(array: [map], sort: { $0.energySpent > $1.energySpent })
    var seenConfigurations: [Set<Amphipods>: Int] = [:]
    seenConfigurations[Set(map.amphipods)] = 0

    var count = 0

    var bestScore = Int.max
    var bestMap: Map?

    while let map = maps.remove() {

//        if count % 10000 == 0 {
//            print("gen:", count, ", size:", maps.count, ", best score:", bestScore)
//            map.printMap()
//        }

        if map.isCompleted {
            if bestScore > map.energySpent {
                bestScore = map.energySpent
                bestMap = map
                maps = Heap(array: maps.nodes.filter { $0.energySpent < bestScore }, sort: { $0.energySpent > $1.energySpent })
            }
        }
        let nextMaps = availableMoves(for: map).filter { $0.energySpent < bestScore }

        for nextMap in nextMaps {
            if let seenConfigurationScore = seenConfigurations[Set(nextMap.amphipods)] {
                if seenConfigurationScore > nextMap.energySpent {
                    seenConfigurations[Set(nextMap.amphipods)] = nextMap.energySpent
                    maps.insert(nextMap)
                }
            } else {
                seenConfigurations[Set(nextMap.amphipods)] = nextMap.energySpent
                maps.insert(nextMap)
            }
        }

        count += 1
    }

    return bestMap
}

func availableMoves(for map: Map) -> [Map] {
    guard !map.isCompleted else { return [map] }

    return map.amphipods.flatMap { amphipod -> [Map] in
        return map.availableMoves(for: amphipod).map { newPosition, distance in
            var newMap = map
            newMap.amphipods.removeAll { $0 == amphipod }
            newMap.amphipods.append(Amphipods(category: amphipod.category, position: newPosition))
            newMap.energySpent += distance * amphipod.moveCost
            return newMap
        }
    }
}

extension Amphipods {
    var chamberPosition: Int {
        switch category {
        case .amber:
            return 3
        case .bronze:
            return 5
        case .copper:
            return 7
        case .desert:
            return 9
        }
    }
}

extension Map {

    var isCompleted: Bool {
        amphipods.allSatisfy { isValidFinalDestination($0.position, for: $0) }
    }

    func isValidFinalDestination(_ position: Position, for amphipod: Amphipods) -> Bool {
        guard isChamberPositions(position) else { return false }
        return position.x == amphipod.chamberPosition
    }

    func isChamberPositions(_ position: Position) -> Bool {
        return position.y >= 2
    }

    func isInFrontOfRoom(_ position: Position) -> Bool {
        return !isChamberPositions(position)
            && (position.x == 3 || position.x == 5 || position.x == 7 || position.x == 9)
    }

    func areAllAmphipodsPlaced(of category: Amphipods.Category) -> Bool {
        amphipods.filter { $0.category == category }.allSatisfy { isValidFinalDestination($0.position, for: $0) }
    }

    func availableMoves(for amphipod: Amphipods) -> [(Position, Int)] {

        guard !areAllAmphipodsPlaced(of: amphipod.category) else { return [] }
        if isValidFinalDestination(amphipod.position, for: amphipod), amphipod.position.y == 3 { return [] }

        let isInHallway = !isChamberPositions(amphipod.position)

        let isFinalChamberAccessible = amphipods
            .filter { $0.position.x == amphipod.chamberPosition }
            .allSatisfy { $0.category == amphipod.category }

        if isInHallway {

            guard isFinalChamberAccessible else { return [] }

            let deepestReachablePosition = reachablePositions(from: amphipod.position)
                .filter { $0.0.x == amphipod.chamberPosition }
                .sorted { $0.0.y < $1.0.y }.last

            return [deepestReachablePosition].compactMap { $0 }
        } else {
            return reachablePositions(from: amphipod.position)
                .filter { !isInFrontOfRoom($0.0) }
                .filter { !isChamberPositions($0.0) }
        }
    }

    func reachablePositions(from position: Position, ignoring: Set<Position> = []) -> [(Position, Int)] {
        var ignoring = ignoring.union([position])
        return (edges[position] ?? [])
            .filter { !ignoring.contains($0) }
            .flatMap { adjacentPosition -> [(Position, Int)] in
                ignoring.insert(adjacentPosition)
                if isOccupied(adjacentPosition) { return [] }
                return [(adjacentPosition, 1)]
                    + reachablePositions(from: adjacentPosition, ignoring: ignoring)
                    .filter { !amphipods.map(\.position).contains($0.0) }
                    .map { ($0.0, $0.1 + 1) }
            }
    }

    func isOccupied(_ position: Position) -> Bool {
        return amphipods.map(\.position).contains(position)
    }
}

// MARK: - Start

main()

// MARK: - Debug

extension Map {

    func printMap() {
        let minX = edges.keys.map(\.x).min()!
        let maxX = edges.keys.map(\.x).max()!
        let minY = edges.keys.map(\.y).min()!
        let maxY = edges.keys.map(\.y).max()!

        for y in minY...maxY {
            for x in minX...maxX {
                let position = Position(x: x, y: y)
                if edges[position] == nil {
                    print(" ", terminator: "")
                } else {
                    if let amphipod = amphipods.first(where: { $0.position == position }) {
                        print(amphipod.category.rawValue, terminator: "")
                    } else {
                        print(".", terminator: "")
                    }
                }
            }
            print()
        }
    }

    func debugPrint() {
        print("edges")
        edges.forEach {
            print("\($0) -> \($1)")
        }

        print()

        print("amphipods:")
        amphipods.forEach { print($0) }
    }
}
