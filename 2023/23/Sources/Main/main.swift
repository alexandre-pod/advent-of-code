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

    let graph = HikingPathGraph.createIgnoringSlopesFrom(hikingMap)
//    graph.edges.keys.sorted { $0.y + $0.x < $1.y + $1.x }.forEach {
//        print("\($0): ", graph.edges[$0]!.map { $0.description }.joined(separator: ", "))
//    }

//    return longestPathBruteForce(from: hikingMap.startCoordinates, to: hikingMap.endCoordinates, in: graph)!

//    var set: Set<Coordinates> = []
//    return longestPathBruteforceOptimized(from: hikingMap.startCoordinates, to: hikingMap.endCoordinates, in: graph, ignoring: &set)!

//    return longestPath(from: hikingMap.startCoordinates, to: hikingMap.endCoordinates, in: graph)!
    
//    print(graph.canAccess(hikingMap.endCoordinates, from: hikingMap.startCoordinates, without: [Coordinates(x: 1, y: 1)]))

//    return longestPath2(from: hikingMap.startCoordinates, to: hikingMap.endCoordinates, in: graph, map: hikingMap)!
//    return longestPath2(from: hikingMap.endCoordinates, to: hikingMap.startCoordinates, in: graph, map: hikingMap)!


//    print(hikingMap.accessibleIntersectionsOrEndInternal(from: Coordinates(x: 1, y: 0)))
    let edgesGraph = hikingMap.edgesGraph()
//    print()
    edgesGraph.debugDisplay()

//    return edgesGraph.longestPathWeight(from: hikingMap.startCoordinates, to: hikingMap.endCoordinates)!

    let allPaths = edgesGraph.allPaths(from: hikingMap.startCoordinates, to: hikingMap.endCoordinates)

    print("allPaths.count", allPaths.count)

    let lengths = allPaths
        .map {
            edgesGraph.weight(ofPath: $0)
        }

//    lengths.forEach {
//        print($0)
//    }

    return lengths.max()!



//    allPaths.forEach {
//        print($0)
//    }

    // 3574 - too low
    // 4430 - too low
    // 5250
    // 6802

    fatalError()
}

typealias EdgeGraph = [Coordinates: [Coordinates: Int]]

extension EdgeGraph {

    func weight(ofPath path: [Coordinates]) -> Int {
        let weights = zip(path, path.dropFirst())
            .map { self[$0.0]![$0.1]! }
        return weights.reduce(0, +)
    }

//    func longestPathWeight(from start: Coordinates, to end: Coordinates) -> Int? {
//        var longestWeight: [Coordinates: Int] = [start: 0]
//        var longestWeightFrom: [Coordinates: Coordinates] = [:]
//
//        var toProcess: Set<Coordinates> = [start]
//        
//        while !toProcess.isEmpty {
////            let point = toProcess.removeFirst()
//            let point = toProcess.max { longestWeight[$0]! < longestWeight[$1]! }!
//            toProcess.remove(point)
//            let currentWeight = longestWeight[point]!
//
//            print("Processing \(point)")
//
//            let currentPath = Set(sequence(first: point) { longestWeightFrom[$0] })
//
//            let neighborsCandidates = self[point, default: [:]].keys
//                .filter { !currentPath.contains($0) }
//                .filter { canJoin($0, to: end, without: currentPath) }
//
//            for neighbour in neighborsCandidates {
//                let neighbourWeight = longestWeight[neighbour, default: .min]
//                let distance = self[point]![neighbour]!
//                if neighbourWeight < currentWeight {
//                    longestWeight[neighbour] = currentWeight + distance
//                    longestWeightFrom[neighbour] = point
//                    toProcess.insert(neighbour)
//                } else if neighbourWeight > currentWeight + distance {
//                    toProcess.insert(neighbour)
//                }
//            }
//        }
//
//        print("longestWeight")
//        longestWeight
//            .sorted { $0.key < $1.key }
//            .forEach {
//                print($0.key, $0.value)
//            }
//
//        return longestWeight[end]!
//
//        fatalError()
//    }

    func longestPathWeight(from start: Coordinates, to end: Coordinates) -> Int? {
        var longestWeight: [Coordinates: Int] = [start: 0]
        var longestWeightFrom: [Coordinates: Coordinates] = [:]

//        var toProcess: Set<Coordinates> = [start]
        var toProcess: [Coordinates] = [start]

        var loopCount = 0
        var snapshot: [Coordinates: Int] = [:]

        while !toProcess.isEmpty {
            let point = toProcess.removeFirst()
//            let point = toProcess.max { longestWeight[$0]! < longestWeight[$1]! }!
//            toProcess.remove(point)
            let currentWeight = longestWeight[point]!

//            print("Processing \(point)")

            let currentPath = Set(sequence(first: point) { longestWeightFrom[$0] })

            let neighborsCandidates = self[point, default: [:]].keys
                .filter { !currentPath.contains($0) }
                .filter { canJoin($0, to: end, without: currentPath) }

            for neighbour in neighborsCandidates {
                let neighbourWeight = longestWeight[neighbour, default: .min]
                let distance = self[point]![neighbour]!

                if neighbourWeight < currentWeight + distance {
                    longestWeight[neighbour] = currentWeight + distance
                    longestWeightFrom[neighbour] = point
//                    toProcess.insert(neighbour)
                    toProcess.append(neighbour)
                } else if neighbourWeight > currentWeight + distance {
//                    toProcess.insert(neighbour)
                    toProcess.append(neighbour)
                }
            }

            if toProcess.isEmpty {
                loopCount += 1
                print("Checking snapshot")
                print("Current max: \(longestWeight[end]!)")
                if loopCount < 20 || longestWeight != snapshot {
                    snapshot = longestWeight
//                    longestWeight.keys.forEach {
//                        toProcess.insert($0)
//                    }
                    toProcess = Array(longestWeight.keys).shuffled()
                }
            }
        }

        print("longestWeight")
        longestWeight
            .sorted { $0.key < $1.key }
            .forEach {
                print($0.key, $0.value)
            }

        return longestWeight[end]!

        fatalError()
    }

    func allPaths(from start: Coordinates, to end: Coordinates, without excludedCoordinates: Set<Coordinates> = []) -> [[Coordinates]] {
        if start == end {
            return [[end]]
        }
        return self[start, default: [:]].keys
            .filter { !excludedCoordinates.contains($0) }
            .flatMap {
                allPaths(from: $0, to: end, without: excludedCoordinates.union([start]))
            }
            .map {
                [start] + $0
            }
    }

    func canJoin(_ start: Coordinates, to end: Coordinates, without excludedCoordinates: Set<Coordinates>) -> Bool {
        if excludedCoordinates.contains(end) { return false }
        if start == end { return true }

        let neighbours = self[start, default: [:]].keys.filter { !excludedCoordinates.contains($0) }

        return neighbours.contains {
            canJoin($0, to: end, without: excludedCoordinates.union([start]))
        }
    }


//    func longestPathRecursiveMemoized(start: Coordinates, end: Coordinates, )
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
//    func accessibleIntersectionsOrEnd(from start: Coordinates) -> [Edge: Int] {
//
//        start.neighbours
//            .filter { self.isValidCoordinates($0) }
//            .filter { self[$0] != .wall }
//            .flatMap {
//                accessibleIntersectionsOrEndInternal(from: $0, ignoring: start)
//            }
//
//        fatalError()
//    }

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

//        func accessibleIntersectionsOrEndInternal(from start: Coordinates, ignoring: Coordinates) -> [(coordinates: Coordinates, distance: Int)] {
//            var result: [(coordinates: Coordinates, distance: Int)] = []
//
//            var doneCoordinates: Set<Coordinates> = []
//            var toProcessCoordinates: Set<Coordinates> = [start]
//            var distanceOf: [Coordinates: Int] = [start: 0]
//
//            while !toProcessCoordinates.isEmpty {
//                let coordinates = toProcessCoordinates.removeFirst()
//                doneCoordinates.insert(coordinates)
//                let distance = distanceOf[coordinates]!
//
//                let neighbours = accessibleNeighbors(from: coordinates)
//                    .filter { !doneCoordinates.contains($0) }
//                    .filter { !ignoring.contains($0) }
//
//    //            neighbours.forEach {
//    //                doneCoordinates.insert($0)
//    //            }
//                let nextDistance = distance + 1
//                if neighbours.count == 1 {
//                    let neighbour = neighbours[0]
//                    toProcessCoordinates.insert(neighbour)
//                    distanceOf[neighbour] = nextDistance
//                    if neighbour == endCoordinates {
//                        result.append((coordinates: neighbour, distance: nextDistance))
//                    }
//                } else {
//                    neighbours.forEach {
//                        distanceOf[$0] = nextDistance
//                        result.append((coordinates: $0, distance: nextDistance))
//                    }
//                }
//            }
//
//
//            return result
//        }
}


// MARK: - Visualisation

extension Coordinates: CustomStringConvertible {
    var description: String {
        "(y: \(y), x: \(x))"
    }
}

main()
