//
//  part2.swift
//  
//
//  Created by Alexandre Podlewski on 23/12/2023.
//

import Foundation

func longestPathBruteForce(from start: Coordinates, to end: Coordinates, in graph: HikingPathGraph, ignoring: Set<Coordinates> = []) -> Int? {
    //    print("\(start) -> \(end) max length ?")
    //    print("graph.edges[end]", graph.edges[end])
    if start == end { return 0 }
    if graph.edges[end] == [start] { return 1 }

    return graph.edges[end, default: []]
        .filter { !ignoring.contains($0) }
        .compactMap { longestPathBruteForce(from: start, to: $0, in: graph, ignoring: ignoring.union([end])) }
        .map { 1 + $0 }
        .max()

    //        var longestPathToEnd: [Coordinates: Int] = [end: 0]
    //
    //    //    var processed: Set<Coordinates>
    //        var toProcess: [Coordinates] = [end]
    //        while !toProcess.isEmpty {
    //            let point = toProcess.removeFirst()
    //            let nextDistance = longestPathToEnd[point]! + 1
    //            graph.edges[point, default: []].forEach { nextPoint in
    //                let nextPointDistance = longestPathToEnd[nextPoint, default: .min]
    //                _ = $0
    //            }
    //        }
    //
    //
    //        return longestPathToEnd[start]
    //    longestPathToEnd.max { $0.value < $1.value }
}

func longestPathBruteforceOptimized(from start: Coordinates, to end: Coordinates, in graph: HikingPathGraph, ignoring: inout Set<Coordinates>) -> Int? {
    //    print("\(start) -> \(end) max length ?")
    //    print("graph.edges[end]", graph.edges[end])
    //    print(ignoring.count)
    if start == end { return 0 }
    if graph.edges[end] == [start] { return 1 }

    ignoring.insert(end)
    defer { ignoring.remove(end) }

    return graph.edges[end, default: []]
        .filter { !ignoring.contains($0) }
        .compactMap { longestPathBruteforceOptimized(from: start, to: $0, in: graph, ignoring: &ignoring) }
        .map { 1 + $0 }
        .max()
}

func longestPath(from start: Coordinates, to end: Coordinates, in graph: HikingPathGraph) -> Int? {
    print("\(start) -> \(end) max length ?")

    var longestPathToEnd: [Coordinates: Int] = [end: 0]
    var longestPathGoingThrough: [Coordinates: Coordinates] = [:]

    //    var donePoints: Set<Coordinates> = []

    //    var processed: Set<Coordinates> = [end]
    var toProcess: Set<Coordinates> = [end] // Set(graph.edges[end] ?? [])

    while !toProcess.isEmpty {
        let point = toProcess.removeFirst()
        let pointDistance = longestPathToEnd[point]!
        let nextDistance = pointDistance + 1

        let pointPath = Set(sequence(first: point) { longestPathGoingThrough[$0] })

        print("Processing \(point) [distance: \(pointDistance)]")
        graph.edges[point, default: []]
        //            .filter { $0 != longestPathGoingThrough[point] }
            .filter { !pointPath.contains($0) }
            .forEach { nextPoint in
                let nextPointPreviousDistance = longestPathToEnd[nextPoint, default: .min]
                if nextPointPreviousDistance < nextDistance {
                    longestPathToEnd[nextPoint] = nextDistance
                    longestPathGoingThrough[nextPoint] = point
                    toProcess.insert(nextPoint)
                } else if nextPointPreviousDistance + 1 > pointDistance {
                    longestPathToEnd[point] = nextPointPreviousDistance + 1
                    longestPathGoingThrough[point] = nextPoint
                    toProcess.insert(point)
                }
            }

        //        Thread.sleep(forTimeInterval: 0.1)

        //        print("final result ?", longestPathToEnd[start])
        //        print("issue if more than 0", longestPathToEnd[end])
    }

    return longestPathToEnd[start]
}

func longestPath2(
    from start: Coordinates,
    to end: Coordinates,
    in graph: HikingPathGraph,
    map: HikingMap
) -> Int? {
    print("\(start) -> \(end) max length ?")

    var distance: [Coordinates: Int] = [start: 0]
    var pathGoingFrom: [Coordinates: Coordinates] = [:]


    var toProcess: Set<Coordinates> = [start]

    while !toProcess.isEmpty {
        print("toProcess: ", toProcess.count)
        let point = toProcess.min { distance[$0]! < distance[$1]! }!
        toProcess.remove(point)
        //        let point = toProcess.removeFirst()
        let pointDistance = distance[point]!

        let pointPath = Set(sequence(first: point) { pathGoingFrom[$0] })

        let nextPointCandidates = graph.edges[point, default: []]
            .filter { !pointPath.contains($0) }
            .filter { graph.canAccess(end, from: $0, without: pointPath) }

        for nextPoint in nextPointCandidates {
            let nextPointDistance = distance[nextPoint] ?? .min
            if nextPointDistance < pointDistance + 1 {
                distance[nextPoint] = pointDistance + 1
                pathGoingFrom[nextPoint] = point
                toProcess.insert(nextPoint)
            } else if nextPointDistance > pointDistance {
                toProcess.insert(nextPoint)
            }
        }

        if (1...100).randomElement() == 5 {
            display(distance: distance, in: map)
        }
        //        display(distance: distance, in: map)
    }

    display(distance: distance, in: map)

    //    let longestPath = Set(sequence(first: end) { pathGoingFrom[$0] })
    //    var buffer = DisplayBuffer()
    //    map.allCoordinates().forEach {
    //        buffer.pixels[$0] = map[$0] == .wall ? "█" : " "
    //    }
    //
    //    longestPath.forEach {
    //        buffer.pixels[$0] = "."
    //    }
    //    buffer.print()

    return distance[end]
}

func display(distance: [Coordinates: Int], in map: HikingMap, widthScale: Int = 4) {

    let threeDigitFormatter = NumberFormatter()
    threeDigitFormatter.minimumIntegerDigits = 3
    threeDigitFormatter.maximumIntegerDigits = 3

    //    let longestPath = Set(sequence(first: end) { pathGoingFrom[$0] })

    var buffer = DisplayBuffer()

    //    map.allCoordinates().forEach {
    //        buffer.pixels[$0] = map[$0] == .wall ? "█" : " "
    //    }
    //
    //    longestPath.forEach {
    //        buffer.pixels[$0] = "."
    //    }

    map.allCoordinates().forEach { coordinates in
        let element: Character = map[coordinates] == .wall ? "█" : " "
        (0..<widthScale).forEach { dx in
            buffer.pixels[Coordinates(x: coordinates.x * widthScale + dx, y: coordinates.y)] = element
        }
    }


    distance.forEach { (point, distance) in
        let string = [" "] + (threeDigitFormatter.string(from: distance as NSNumber) ?? "---").map { $0 }
        (0..<widthScale).forEach { dx in
            buffer.pixels[Coordinates(x: point.x * widthScale + dx, y: point.y)] = string[dx]
        }
    }

    buffer.print()
}

extension HikingPathGraph {
    func canAccess(_ end: Coordinates, from start: Coordinates, without: Set<Coordinates>) -> Bool {
        if without.contains(end) { return false }
        if start == end { return true }
        var pointSet: Set<Coordinates> = without
        return canAccessInternal(end, from: start, without: &pointSet)
    }

    private func canAccessInternal(_ end: Coordinates, from start: Coordinates, without: inout Set<Coordinates>) -> Bool {
        //        print("canAccess \(start) -> \(end)")
        //        print(without)
        //        defer {
        //            print("canAccess \(start) -> \(end) ended")
        //        }
        let nextPoints = self.edges[start, default: []].filter { !without.contains($0) }
        guard !nextPoints.isEmpty else { return false }
        if nextPoints == [end] { return true }

        without.insert(start)
        defer {
            without.remove(start)
        }

        return nextPoints.contains { nextPoint in
            //            print("trying with \(nextPoint)")
            return canAccessInternal(end, from: nextPoint, without: &without)
        }
    }
}

extension HikingPathGraph {
    static func createIgnoringSlopesFrom(_ hikingMap: HikingMap) -> HikingPathGraph {
        var edges: [Coordinates: Set<Coordinates>] = [:]
        //        var distanceOf: [Arc: Int] = [:]

        var processed: Set<Coordinates> = []
        var toProcessStartPoints: Set<Coordinates> = [hikingMap.startCoordinates]

        while !toProcessStartPoints.isEmpty {
            let startPoint = toProcessStartPoints.removeFirst()
            processed.insert(startPoint)

            startPoint.neighbours
                .filter { !processed.contains($0) }
                .filter { hikingMap.isValidCoordinates($0) }
                .filter { hikingMap[$0] != .wall }
                .forEach {
                    edges[startPoint, default: []].insert($0)
                    edges[$0, default: []].insert(startPoint)
                    toProcessStartPoints.insert($0)
                    //                    distanceOf[Arc(start: startPoint, end: $0)] = 1
                }
        }

        return HikingPathGraph(
            edges: edges,
            distance: [:]
        )
    }
}

//extension HikingMap {
//    func accessibleIntersectionsOrEnd(from start: Coordinates, ignoring: Set<Coordinates> = []) -> [(coordinates: Coordinates, distance: Int)] {
//        var result: [(coordinates: Coordinates, distance: Int)] = []
//
//        var doneCoordinates: Set<Coordinates> = []
//        var toProcessCoordinates: Set<Coordinates> = [start]
//        var distanceOf: [Coordinates: Int] = [start: 0]
//
//        while !toProcessCoordinates.isEmpty {
//            let coordinates = toProcessCoordinates.removeFirst()
//            doneCoordinates.insert(coordinates)
//            let distance = distanceOf[coordinates]!
//
//            let neighbours = accessibleNeighbors(from: coordinates)
//                .filter { !doneCoordinates.contains($0) }
//                .filter { !ignoring.contains($0) }
//
//            neighbours.forEach {
//                doneCoordinates.insert($0)
//            }
//            let nextDistance = distance + 1
//            if neighbours.count == 1 {
//                let neighbour = neighbours[0]
//                toProcessCoordinates.insert(neighbour)
//                distanceOf[neighbour] = nextDistance
//                if neighbour == endCoordinates {
//                    result.append((coordinates: neighbour, distance: nextDistance))
//                }
//            } else {
//                neighbours.forEach {
//                    distanceOf[$0] = nextDistance
//                    result.append((coordinates: $0, distance: nextDistance))
//                }
//            }
//        }
//
//
//        return result
//    }
//}
