import Foundation

typealias HikingMap = [[Tile]]

enum Tile: Character {
    case wall = "#"
    case path = "."
    case left = "<"
    case top = "^"
    case right = ">"
    case bottom = "v"
}

extension HikingMap {
    var startCoordinates: Coordinates {
        Coordinates(
            x: self[0].firstIndex(of: .path)!,
            y: 0
        )
    }

    var endCoordinates: Coordinates {
        Coordinates(
            x: self[count - 1].firstIndex(of: .path)!,
            y: count - 1
        )
    }
}

func main() {
    var input: HikingMap = []

    while let line = readLine() {
        input.append(line.map { Tile(rawValue: $0)! })
    }

    print(part1(hikingMap: input))
    print(part2(hikingMap: input))
}

// MARK: - Part 1

// look at part1.swift

extension Coordinates {
    var neighbours: [Coordinates] {
        return (-1...1).flatMap { dy in
            (-1...1)
                .filter { dx in abs(dx) + abs(dy) == 1 }
                .map { dx in Coordinates(x: x + dx, y: y + dy) }
        }
    }
}

// MARK: - Part 2

func part2(hikingMap: HikingMap) -> Int {
    let edgesGraph = hikingMap.edgesGraph()
//    edgesGraph.debugDisplay()

    let allPaths = edgesGraph.allPaths(from: hikingMap.startCoordinates, to: hikingMap.endCoordinates)

    return allPaths
        .map { edgesGraph.weight(ofPath: $0) }
        .max()!
}

typealias EdgeGraph = [Coordinates: [Coordinates: Int]]

extension EdgeGraph {

    func weight(ofPath path: [Coordinates]) -> Int {
        let weights = zip(path, path.dropFirst())
            .map { self[$0.0]![$0.1]! }
        return weights.reduce(0, +)
    }

    func allPaths(from start: Coordinates, to end: Coordinates, without excludedCoordinates: Set<Coordinates> = []) -> [[Coordinates]] {
        if start == end {
            return [[end]]
        }
        return self[start, default: [:]].keys
            .filter { !excludedCoordinates.contains($0) }
            .flatMap { allPaths(from: $0, to: end, without: excludedCoordinates.union([start])) }
            .map { [start] + $0 }
    }
}

extension EdgeGraph {
    func debugDisplay() {
        self
            .sorted { $0.key < $1.key }
            .forEach {
                print("\($0.key): \($0.value.sorted { $0.key < $1.key })")
            }
    }
}

extension Coordinates: Comparable {
    static func < (lhs: Coordinates, rhs: Coordinates) -> Bool {
        lhs.x + lhs.y < rhs.x + rhs.y
    }
}

struct Edge: Hashable {
    let point1: Coordinates
    let point2: Coordinates
}

extension HikingMap {
    func edgesGraph() -> [Coordinates: [Coordinates: Int]] {

        var edges: [Coordinates: [Coordinates: Int]] = [:]

        var processed: Set<Coordinates> = []
        var toProcess: Set<Coordinates> = [startCoordinates]

        while !toProcess.isEmpty {
            let point = toProcess.removeFirst()
            processed.insert(point)

            accessibleIntersectionsOrEndInternal(from: point).forEach { (end, distance) in
                edges[point, default: [:]][end] = distance
                if !processed.contains(end) {
                    toProcess.insert(end)
                }
            }
        }


        return edges
    }

    func isIntersectionOrEnd(_ coordinates: Coordinates) -> Bool {
        let neighbours = nonWallNeighbors(of: coordinates)
        return neighbours.count != 2
    }

    func nonWallNeighbors(of coordinates: Coordinates) -> [Coordinates] {
        return coordinates
            .neighbours
            .filter { self.isValidCoordinates($0) }
            .filter { self[$0] != .wall }
    }

    func accessibleIntersectionsOrEndInternal(from start: Coordinates) -> [(coordinates: Coordinates, distance: Int)] {
        var result: [(coordinates: Coordinates, distance: Int)] = []

        var doneCoordinates: Set<Coordinates> = [start]
        var toProcessCoordinates: Set<Coordinates> = Set(nonWallNeighbors(of: start))
        var distanceToStart: [Coordinates: Int] = [start: 0]
        nonWallNeighbors(of: start).forEach { distanceToStart[$0] = 1 }

        while !toProcessCoordinates.isEmpty {
            let coordinates = toProcessCoordinates.removeFirst()
            doneCoordinates.insert(coordinates)
            let distance = distanceToStart[coordinates]!
            if isIntersectionOrEnd(coordinates) {
                result.append((coordinates: coordinates, distance: distance))
            } else {
                nonWallNeighbors(of: coordinates)
                    .filter { !doneCoordinates.contains($0) }
                    .forEach {
                        distanceToStart[$0] = distance + 1
                        toProcessCoordinates.insert($0)
                    }
            }
        }

        return result
    }
}


// MARK: - Visualisation

extension Coordinates: CustomStringConvertible {
    var description: String {
        "(y: \(y), x: \(x))"
    }
}

main()
