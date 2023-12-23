//
//  part1.swift
//  
//
//  Created by Alexandre Podlewski on 23/12/2023.
//

import Foundation

func part1(hikingMap: HikingMap) -> Int {
    let graph = HikingPathGraph.createFrom(hikingMap)

    let possiblePaths = findPaths(
        from: hikingMap.startCoordinates,
        to: hikingMap.endCoordinates,
        in: graph
    )
    return possiblePaths
        .map { $0.map { graph.distance[$0]! }.reduce(0, +) }
        .max()!
}

func findPaths(from start: Coordinates, to end: Coordinates, in graph: HikingPathGraph) -> [[HikingPathGraph.Arc]] {

    var possibleArcPath = graph.distance.keys.filter { $0.end == end }

    guard !possibleArcPath.isEmpty else { return [] }

    if possibleArcPath.count == 1,
       possibleArcPath.first == HikingPathGraph.Arc(start: start, end: end) {
        let uniquePath = [HikingPathGraph.Arc(start: start, end: end)]
        return [uniquePath]
    }

    return possibleArcPath
        .flatMap { findPaths(from: start, to: $0.start, in: graph) }
        .filter { !$0.isEmpty }
        .map {
            let lastArcPath = $0.last!
            let endArc = HikingPathGraph.Arc(start: lastArcPath.end, end: end)
            return $0 + [endArc]
        }
}

struct HikingPathGraph {
    let edges: [Coordinates: Set<Coordinates>]
    let distance: [Arc: Int]

    struct Arc: Hashable {
        let start: Coordinates
        let end: Coordinates
    }
}

extension HikingPathGraph {
    static func createFrom(_ hikingMap: HikingMap) -> HikingPathGraph {
        var edges: [Coordinates: Set<Coordinates>] = [:]
        var distanceOf: [Arc: Int] = [:]

        var toProcessStartPoints: Set<Coordinates> = [hikingMap.startCoordinates]

        while !toProcessStartPoints.isEmpty {
            let startPoint = toProcessStartPoints.removeFirst()

            hikingMap.accessibleCoordinates(from: startPoint).forEach { tuple in
                let destination = tuple.coordinates
                let distance = tuple.distance

                edges[startPoint, default: []].insert(destination)
                assert(distanceOf[Arc(start: startPoint, end: destination)] == nil)
                distanceOf[Arc(start: startPoint, end: destination)] = distance

                if !edges.keys.contains(destination) {
                    toProcessStartPoints.insert(destination)
                }
            }
        }


        return HikingPathGraph(
            edges: edges,
            distance: distanceOf
        )
    }
}

extension HikingMap {
    func accessibleCoordinates(from start: Coordinates, startDistance: Int = 0) -> [(coordinates: Coordinates, distance: Int)] {
        var result: [(coordinates: Coordinates, distance: Int)] = []

        var doneCoordinates: Set<Coordinates> = []
        var toProcessCoordinates: Set<Coordinates> = [start]
        var distanceOf: [Coordinates: Int] = [start: startDistance]

        while !toProcessCoordinates.isEmpty {
            let coordinates = toProcessCoordinates.removeFirst()
            doneCoordinates.insert(coordinates)
            let distance = distanceOf[coordinates]!

            accessibleNeighbors(from: coordinates)
                .filter { !doneCoordinates.contains($0) }
                .forEach {
                    let nextDistance = distance + 1
                    doneCoordinates.insert($0)
                    switch self[$0] {
                    case .wall:
                        break
                    case .path:
                        //                        print("Path at \($0)")
                        toProcessCoordinates.insert($0)
                        distanceOf[$0] = nextDistance
                        if $0 == endCoordinates {
                            result.append((coordinates: $0, distance: nextDistance))
                        }
                    case .left:
                        //                        print("left at \($0)")
                        if coordinates.x - 1 == $0.x && coordinates.y == $0.y {
                            result.append((coordinates: $0, distance: nextDistance))
                        }
                    case .top:
                        //                        print("top at \($0)")
                        if coordinates.x == $0.x && coordinates.y - 1 == $0.y {
                            result.append((coordinates: $0, distance: nextDistance))
                        }
                    case .right:
                        //                        print("right at \($0)")
                        if coordinates.x + 1 == $0.x && coordinates.y == $0.y {
                            result.append((coordinates: $0, distance: nextDistance))
                        }
                    case .bottom:
                        //                        print("bottom at \($0)")
                        if coordinates.x == $0.x && coordinates.y + 1 == $0.y {
                            result.append((coordinates: $0, distance: nextDistance))
                        }
                    }
                }
        }


        return result
    }

    func accessibleNeighbors(from coordinates: Coordinates) -> [Coordinates] {
        var nonWallNeighbours = coordinates.neighbours
            .filter { isValidCoordinates($0) }
            .filter { self[$0] != .wall }
        switch self[coordinates] {
        case .wall:
            return []
        case .path:
            return nonWallNeighbours
        case .left:
            return nonWallNeighbours.filter { $0.y == coordinates.y && $0.x == coordinates.x - 1 }
        case .top:
            return nonWallNeighbours.filter { $0.y == coordinates.y - 1 && $0.x == coordinates.x }
        case .right:
            return nonWallNeighbours.filter { $0.y == coordinates.y && $0.x == coordinates.x + 1 }
        case .bottom:
            return nonWallNeighbours.filter { $0.y == coordinates.y + 1  && $0.x == coordinates.x }
        }
    }
}

// MARK: - Visualisation

extension HikingPathGraph: CustomStringConvertible {
    var description: String {
        return self.distance
            .sorted { $0.key.start.x + $0.key.start.y < $1.key.start.x + $1.key.start.y }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
}

extension HikingPathGraph.Arc: CustomStringConvertible {
    var description: String {
        "\(start) -> \(end)"
    }
}
