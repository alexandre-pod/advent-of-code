import Foundation

typealias PuzzleMap = Grid2D<Int>

func main() {
    var numbers: [[Int]] = []

    while let line = readLine() {
        numbers.append(line.map { Int(String($0))! })
    }

    let input = PuzzleMap(cells: numbers)

    print(part1(puzzleMap: input))
    print(part2(puzzleMap: input))
}

// MARK: - Part 1

func part1(puzzleMap: PuzzleMap) -> Int {

//    var edges: Set<Edge<Coordinate2D>> = []
    var edges: [Coordinate2D: [Coordinate2D]] = [:]
    var zeroPositions: Set<Coordinate2D> = []

    for coordinate in puzzleMap.allCoordinates {
        if puzzleMap[coordinate] == 0 {
            zeroPositions.insert(coordinate)
        }
        for neighbour in puzzleMap.neighbours(to: coordinate) {
            if puzzleMap[neighbour] - puzzleMap[coordinate] == 1 {
                edges[coordinate, default: []].append(neighbour)
//                edges.insert(Edge(from: coordinate, to: neighbour))
            }
        }
    }
    return zeroPositions
        .map { puzzleMap.nineReached(from: $0, edges: edges).count }
        .reduce(0, +)
}

extension Grid2D<Int> {
    func nineReached(from start: Coordinate2D, edges: [Coordinate2D: [Coordinate2D]]) -> Set<Coordinate2D> {

        if self[start] == 9 {
            return [start]
        }

        return edges[start, default: []]
            .map { nineReached(from: $0, edges: edges) }
            .reduce(into: Set<Coordinate2D>()) { partialResult, set in
                partialResult.formUnion(set)
            }
    }
}

extension Grid2D {
    func neighbours(to position: Coordinate2D) -> [Coordinate2D] {
        guard contains(position) else { return [] }

        return [(-1, 0), (1, 0), (0, -1), (0, 1)]
            .map { Direction(deltaX: $0.0, deltaY: $0.1) }
            .map { position.moved(by: $0) }
            .filter { self.contains($0) }
    }
}

//struct Edge<T: Hashable>: Hashable {
//    let from: T
//    let to: T
//}

// MARK: - Part 2

func part2(puzzleMap: PuzzleMap) -> Int {
    var edges: [Coordinate2D: [Coordinate2D]] = [:]
    var zeroPositions: Set<Coordinate2D> = []

    for coordinate in puzzleMap.allCoordinates {
        if puzzleMap[coordinate] == 0 {
            zeroPositions.insert(coordinate)
        }
        for neighbour in puzzleMap.neighbours(to: coordinate) {
            if puzzleMap[neighbour] - puzzleMap[coordinate] == 1 {
                edges[coordinate, default: []].append(neighbour)
            }
        }
    }
    return zeroPositions
        .map { puzzleMap.countNineReached(from: $0, edges: edges) }
        .reduce(0, +)
}

extension Grid2D<Int> {
    func countNineReached(from start: Coordinate2D, edges: [Coordinate2D: [Coordinate2D]]) -> Int {
        if self[start] == 9 {
            return 1
        }
        return edges[start, default: []]
            .map { countNineReached(from: $0, edges: edges) }
            .reduce(0, +)
    }
}

main()
