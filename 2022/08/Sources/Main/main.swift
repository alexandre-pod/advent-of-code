import Foundation

func main() {
    var heightGrid: [[Int]] = []

    while let line = readLine() {
        heightGrid.append(line.map { Int(String($0))! })
    }

    let treeMap = Map(heightGrid)

    print(part1(treeMap: treeMap))
    print(part2(treeMap: treeMap))
}

// MARK: - Part 1

func part1(treeMap: Map<Int>) -> Int {
    let visibleTrees = getVisibleTrees(in: treeMap)
    return visibleTrees.count
}

private func getVisibleTrees(in treeMap: Map<Int>) -> Set<MapCoordinate> {
    var visibleTrees: Set<MapCoordinate> = []

    treeMap.leftCoordinates.forEach { startIndex in
        var maxHeight = -1
        for coordinate in treeMap.coordinates(from: startIndex, along: .right) {
            if treeMap[coordinate] > maxHeight {
                visibleTrees.insert(coordinate)
                maxHeight = treeMap[coordinate]
            }
        }
    }

    treeMap.rightCoordinates.forEach { startIndex in
        var maxHeight = -1
        for coordinate in treeMap.coordinates(from: startIndex, along: .left) {
            if treeMap[coordinate] > maxHeight {
                visibleTrees.insert(coordinate)
                maxHeight = treeMap[coordinate]
            }
        }
    }

    treeMap.topCoordinates.forEach { startIndex in
        var maxHeight = -1
        for coordinate in treeMap.coordinates(from: startIndex, along: .bottom) {
            if treeMap[coordinate] > maxHeight {
                visibleTrees.insert(coordinate)
                maxHeight = treeMap[coordinate]
            }
        }
    }

    treeMap.bottomCoordinates.forEach { startIndex in
        var maxHeight = -1
        for coordinate in treeMap.coordinates(from: startIndex, along: .top) {
            if treeMap[coordinate] > maxHeight {
                visibleTrees.insert(coordinate)
                maxHeight = treeMap[coordinate]
            }
        }
    }

    return visibleTrees
}

extension Map {
    var leftCoordinates: [MapCoordinate] {
        (0..<height).map { MapCoordinate(line: $0, column: 0) }
    }

    var rightCoordinates: [MapCoordinate] {
        (0..<height).map { MapCoordinate(line: $0, column: width - 1) }
    }

    var topCoordinates: [MapCoordinate] {
        (0..<width).map { MapCoordinate(line: 0, column: $0) }
    }

    var bottomCoordinates: [MapCoordinate] {
        (0..<width).map { MapCoordinate(line: height - 1, column: $0) }
    }
}

// MARK: - Part 2

func part2(treeMap: Map<Int>) -> Int {
    return treeMap.allCoordinates.map { scenicScore(at: $0, in: treeMap) }.max()!
}

func scenicScore(at coordinate: MapCoordinate, in treeMap: Map<Int>) -> Int {
    return MapDirection.allCases
        .map { visibleTrees(from: coordinate, along: $0, in: treeMap) }
        .reduce(1, *)
}

func visibleTrees(from coordinate: MapCoordinate, along direction: MapDirection, in treeMap: Map<Int>) -> Int {
    let maxHeight = treeMap[coordinate]
    let candidates = treeMap.coordinates(from: coordinate, along: direction).dropFirst()
    return candidates.firstIndex { treeMap[$0] >= maxHeight }.map { $0 } ?? candidates.count
}

main()
